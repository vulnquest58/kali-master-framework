#!/usr/bin/env bash
# modules/03_python_venv.sh

do_python_venv() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 3/${STEP_TOTAL} — PYTHON VIRTUAL ENVIRONMENTS${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Detect Python version dynamically
    # ========================================================
    local python_version
    python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
    local python_short_version
    python_short_version=$(echo "$python_version" | tr -d '.')
    
    info "Detected Python version: ${BOLD}$python_version${RESET}"
    echo ""
    
    # ========================================================
    # Phase 1: Create Main Virtual Environment
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/7] CREATING MAIN VIRTUAL ENVIRONMENT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "$VENV_DIR" ]]; then
        info "Creating venv at: $VENV_DIR"
        if python3 -m venv "$VENV_DIR" >> "$LOG_FILE" 2>&1; then
            ok "Main venv created successfully"
        else
            fail "Failed to create main venv"
            return 1
        fi
    else
        ok "Main venv already exists: $VENV_DIR"
    fi
    
    # Upgrade pip, wheel, setuptools
    info "Upgrading pip, wheel, setuptools..."
    if "${VENV_DIR}/bin/pip" install --upgrade pip wheel setuptools --quiet >> "$LOG_FILE" 2>&1; then
        local pip_version
        pip_version=$("${VENV_DIR}/bin/pip" --version 2>&1 | awk '{print $2}')
        ok "pip upgraded to version $pip_version"
    else
        warn "pip upgrade failed — continuing with existing version"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Install Main Venv Packages (Categorized)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/7] INSTALLING MAIN VENV PACKAGES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Define packages by category
    declare -A PY_CATEGORIES
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Mode: ${YELLOW}MINIMAL${RESET} — Core packages only"
        
        PY_CATEGORIES=(
            ["HTTP Clients"]="requests httpx aiohttp"
            ["Exploitation"]="pwntools impacket"
            ["Crypto"]="cryptography pycryptodome"
            ["Parsing"]="beautifulsoup4 lxml"
            ["UI/UX"]="tqdm colorama tabulate"
        )
    else
        info "Mode: ${GREEN}FULL${RESET} — Complete installation"
        
        # Web & HTTP
        PY_CATEGORIES=(
            ["HTTP Clients"]="requests httpx aiohttp urllib3"
            ["Web Frameworks"]="flask fastapi uvicorn starlette"
            ["CLI Frameworks"]="rich click typer prompt-toolkit"
            ["Exploitation"]="pwntools impacket scapy"
            ["Crypto"]="cryptography pyOpenSSL pycryptodome paramiko"
            ["Database"]="pymongo redis sqlalchemy neo4j dnspython"
            ["Parsing"]="beautifulsoup4 lxml Pillow pdfminer.six"
            ["RE Tools"]="ropgadget r2pipe capstone keystone-engine unicorn"
            ["Proxy/MITM"]="mitmproxy"
            ["OSINT"]="shodan censys"
            ["Bug Bounty"]="arjun waymore dnsgen"
            ["AD Tools"]="ldap3 bloodhound ldapdomaindump"
            ["Network"]="jwt netexec pysmb"
            ["UI/UX"]="tqdm colorama tabulate xlsxwriter jinja2"
            ["Config"]="pyyaml toml parameterized python-dotenv"
            ["Utilities"]="factordb-pycli ciphey python-magic"
            ["Evasion"]="pefile pefile2"
        )
    fi
    
    local total_categories=${#PY_CATEGORIES[@]}
    local current_category=0
    
    # Sort categories
    IFS=$'\n' sorted_categories=($(sort <<<"${!PY_CATEGORIES[*]}")); unset IFS
    
    for category in "${sorted_categories[@]}"; do
        ((current_category++))
        local packages="${PY_CATEGORIES[$category]}"
        local pkg_array=($packages)
        local pkg_count=${#pkg_array[@]}
        
        echo ""
        echo -e "  ${BOLD}[${current_category}/${total_categories}]${RESET} ${CYAN}$category${RESET} ${DIM}($pkg_count packages)${RESET}"
        
        for pkg in "${pkg_array[@]}"; do
            # Check if already installed
            if "${VENV_DIR}/bin/pip" show "$pkg" &>/dev/null; then
                local installed_version
                installed_version=$("${VENV_DIR}/bin/pip" show "$pkg" 2>/dev/null | grep "^Version:" | awk '{print $2}')
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}($installed_version) [already installed]${RESET}"
                ((total_skipped++))
                continue
            fi
            
            # Install package
            if "${VENV_DIR}/bin/pip" install "$pkg" --quiet >> "$LOG_FILE" 2>&1; then
                local installed_version
                installed_version=$("${VENV_DIR}/bin/pip" show "$pkg" 2>/dev/null | grep "^Version:" | awk '{print $2}')
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}($installed_version)${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} $pkg ${DIM}[FAILED]${RESET}"
                ((total_failed++))
                
                # Retry with verbose for critical packages
                if [[ "$pkg" =~ ^(pwntools|impacket|cryptography|requests)$ ]]; then
                    warn "Retrying $pkg with verbose output..."
                    "${VENV_DIR}/bin/pip" install "$pkg" >> "$LOG_FILE" 2>&1 || true
                fi
            fi
        done
    done
    
    echo ""
    
    # ========================================================
    # Phase 3: Special Package Configurations
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/7] SPECIAL CONFIGURATIONS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Keystone library setup for SGN
    info "Configuring keystone library for SGN..."
    local keystone_lib_path
    keystone_lib_path=$(find "${VENV_DIR}/lib" -name "libkeystone.so" 2>/dev/null | head -1)
    
    if [[ -n "$keystone_lib_path" ]]; then
        cp "$keystone_lib_path" /usr/local/lib/libkeystone.so 2>/dev/null || true
        ln -sf /usr/local/lib/libkeystone.so /usr/local/lib/libkeystone.so.0 2>/dev/null || true
        ldconfig 2>/dev/null || true
        ok "Keystone library configured for SGN"
    else
        warn "Keystone library not found — SGN may not work"
    fi
    
    # wfuzz with pycurl/openssl fix
    info "Installing wfuzz (with pycurl/openssl fix)..."
    apt-get install -y -qq libcurl4-openssl-dev >> "$LOG_FILE" 2>&1 || true
    
    if PYCURL_SSL_LIBRARY=openssl "${VENV_DIR}/bin/pip" install pycurl --quiet --force-reinstall >> "$LOG_FILE" 2>&1; then
        if "${VENV_DIR}/bin/pip" install wfuzz --quiet >> "$LOG_FILE" 2>&1; then
            ok "wfuzz installed successfully"
            ((total_installed++))
        else
            warn "wfuzz pip failed — trying apt..."
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq wfuzz >> "$LOG_FILE" 2>&1; then
                ok "wfuzz installed via apt"
            else
                fail "wfuzz installation failed"
                ((total_failed++))
            fi
        fi
    else
        fail "pycurl installation failed"
    fi
    
    # frida-tools
    info "Installing frida-tools..."
    if "${VENV_DIR}/bin/pip" install "frida-tools" --quiet >> "$LOG_FILE" 2>&1; then
        local frida_version
        frida_version=$("${VENV_DIR}/bin/pip" show frida-tools 2>/dev/null | grep "^Version:" | awk '{print $2}')
        ok "frida-tools installed (version $frida_version)"
        ((total_installed++))
    else
        warn "frida-tools failed — kernel version mismatch possible"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Create Isolated Angr Venv
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/7] CREATING ANGR VENV (ISOLATED)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "$ANGR_VENV" ]]; then
        info "Creating angr venv at: $ANGR_VENV"
        if python3 -m venv "$ANGR_VENV" >> "$LOG_FILE" 2>&1; then
            ok "Angr venv created"
        else
            fail "Failed to create angr venv"
        fi
    else
        ok "Angr venv already exists"
    fi
    
    info "Upgrading pip in angr venv..."
    "${ANGR_VENV}/bin/pip" install --upgrade pip wheel --quiet >> "$LOG_FILE" 2>&1 || true
    
    # Install angr with protobuf<4 to avoid conflicts
    info "Installing angr (with protobuf<4 fix)..."
    if "${ANGR_VENV}/bin/pip" install "protobuf<4" --quiet >> "$LOG_FILE" 2>&1; then
        if "${ANGR_VENV}/bin/pip" install angr --quiet >> "$LOG_FILE" 2>&1; then
            local angr_version
            angr_version=$("${ANGR_VENV}/bin/pip" show angr 2>/dev/null | grep "^Version:" | awk '{print $2}')
            ok "angr installed (version $angr_version)"
            ((total_installed++))
        else
            fail "angr installation failed"
            ((total_failed++))
        fi
    else
        fail "protobuf installation failed — angr may not work"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Create Isolated FLARE Venv
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/7] CREATING FLARE VENV (ISOLATED)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "$FLARE_VENV" ]]; then
        info "Creating FLARE venv at: $FLARE_VENV"
        if python3 -m venv "$FLARE_VENV" >> "$LOG_FILE" 2>&1; then
            ok "FLARE venv created"
        else
            fail "Failed to create FLARE venv"
        fi
    else
        ok "FLARE venv already exists"
    fi
    
    info "Upgrading pip in FLARE venv..."
    "${FLARE_VENV}/bin/pip" install --upgrade pip wheel --quiet >> "$LOG_FILE" 2>&1 || true
    
    # Install FLARE tools
    local flare_tools=("flare-capa:capa" "flare-floss:floss")
    
    for tool_info in "${flare_tools[@]}"; do
        IFS=':' read -r pkg binary <<< "$tool_info"
        
        info "Installing $pkg..."
        if "${FLARE_VENV}/bin/pip" install "$pkg" --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${FLARE_VENV}/bin/${binary}" ]]; then
                make_wrapper "$binary" "${FLARE_VENV}/bin/${binary}"
                local version
                version=$("${FLARE_VENV}/bin/pip" show "$pkg" 2>/dev/null | grep "^Version:" | awk '{print $2}')
                ok "$binary installed (version $version)"
                ((total_installed++))
            else
                warn "$pkg installed but binary not found"
                ((total_failed++))
            fi
        else
            fail "$pkg installation failed"
            ((total_failed++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 6: Volatility3 & Wrappers
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/7] VOLATILITY3 & WRAPPERS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Volatility3
    if ! smart_find_tool "vol" &>/dev/null && ! smart_find_tool "vol3" &>/dev/null; then
        info "Installing volatility3..."
        if "${VENV_DIR}/bin/pip" install volatility3 --quiet >> "$LOG_FILE" 2>&1; then
            ok "volatility3 installed"
            ((total_installed++))
        else
            warn "volatility3 installation failed"
            ((total_failed++))
        fi
    else
        ok "volatility3 already installed"
        ((total_skipped++))
    fi
    
    # Create volatility wrappers
    local vol_wrapper_created=0
    for volbin in vol3 vol; do
        if [[ -x "${VENV_DIR}/bin/${volbin}" ]] && [[ $vol_wrapper_created -eq 0 ]]; then
            make_wrapper "vol" "${VENV_DIR}/bin/${volbin}"
            make_wrapper "vol3" "${VENV_DIR}/bin/${volbin}"
            ok "vol/vol3 wrappers created → ${volbin}"
            vol_wrapper_created=1
        fi
    done
    
    # Create wrappers for other tools
    info "Creating additional wrappers..."
    local tools_to_wrap=("pwntools:pwn" "impacket:psexec.py" "mitmproxy:mitmproxy")
    
    for tool_info in "${tools_to_wrap[@]}"; do
        IFS=':' read -r pkg binary <<< "$tool_info"
        if [[ -x "${VENV_DIR}/bin/${binary}" ]]; then
            make_wrapper "$binary" "${VENV_DIR}/bin/${binary}" 2>/dev/null || true
        fi
    done
    
    ok "Wrappers created"
    echo ""
    
    # ========================================================
    # Phase 7: Auto-activation Setup
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/7] AUTO-ACTIVATION SETUP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # System-wide activation
    cat > /etc/profile.d/kali-venv.sh << VENV_PROFILE
# Kali Master v6.7.0 — Auto-activate Python venv
if [[ -f "${VENV_DIR}/bin/activate" ]]; then
    source "${VENV_DIR}/bin/activate"
fi
VENV_PROFILE
    chmod +x /etc/profile.d/kali-venv.sh
    ok "System-wide activation configured (/etc/profile.d/kali-venv.sh)"
    
    # Shell-specific activation
    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "kali-venv" "$rc" 2>/dev/null; then
                cat >> "$rc" << RCEOF

# Kali Master v6.7.0 — Auto-activate Python venv
if [[ -f "${VENV_DIR}/bin/activate" ]]; then
    source "${VENV_DIR}/bin/activate"
fi
RCEOF
                ok "Activation added to $(basename $rc)"
            else
                skip "Activation already in $(basename $rc)"
            fi
        fi
    done
    
    echo ""
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    local step_minutes=$((step_duration / 60))
    local step_seconds=$((step_duration % 60))
    
    # Count packages in each venv
    local main_pkg_count
    main_pkg_count=$("${VENV_DIR}/bin/pip" list 2>/dev/null | wc -l)
    main_pkg_count=$((main_pkg_count - 2))  # Subtract header lines
    
    local angr_pkg_count=0
    if [[ -d "$ANGR_VENV" ]]; then
        angr_pkg_count=$("${ANGR_VENV}/bin/pip" list 2>/dev/null | wc -l)
        angr_pkg_count=$((angr_pkg_count - 2))
    fi
    
    local flare_pkg_count=0
    if [[ -d "$FLARE_VENV" ]]; then
        flare_pkg_count=$("${FLARE_VENV}/bin/pip" list 2>/dev/null | wc -l)
        flare_pkg_count=$((flare_pkg_count - 2))
    fi
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  PYTHON VENV SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} packages"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} packages (already installed)"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} packages"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 packages"
    fi
    
    echo ""
    echo -e "  ${BOLD}Virtual Environments:${RESET}"
    echo -e "    ${GREEN}●${RESET} Main:    ${DIM}${VENV_DIR}${RESET} ${DIM}(${main_pkg_count} packages)${RESET}"
    echo -e "    ${GREEN}●${RESET} Angr:    ${DIM}${ANGR_VENV}${RESET} ${DIM}(${angr_pkg_count} packages)${RESET}"
    echo -e "    ${GREEN}●${RESET} FLARE:   ${DIM}${FLARE_VENV}${RESET} ${DIM}(${flare_pkg_count} packages)${RESET}"
    echo ""
    echo -e "  ${BOLD}Python Version:${RESET}  ${python_version}"
    echo -e "  ${BOLD}pip Version:${RESET}     ${pip_version:-unknown}"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some packages failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All Python packages installed successfully"
    fi
    
    echo ""
}

# ============================================================
# STEP 4 — Go Language Installation (Professional Edition)
# ============================================================
