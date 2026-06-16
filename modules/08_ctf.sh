#!/usr/bin/env bash
# modules/08_ctf.sh

do_ctf() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 8/${STEP_TOTAL} — CTF TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "CTF tools — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Core CTF Tools (APT) - Categorized
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/8] CORE CTF TOOLS (APT)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local apt_categories=(
        "Password Cracking|john hashcat medusa"
        "Network Auth|hydra"
        "Steganography|steghide stegseek zsteg outguess"
        "Image Analysis|exiftool libimage-exiftool-perl exiv2"
        "Binary Analysis|binwalk foremost"
        "Data Recovery|testdisk photorec"
        "Networking|netcat-openbsd socat"
    )
    
    local apt_total=0
    local apt_installed=0
    local apt_failed=0
    
    for category_info in "${apt_categories[@]}"; do
        IFS='|' read -r category packages <<< "$category_info"
        local pkg_array=($packages)
        local pkg_count=${#pkg_array[@]}
        apt_total=$((apt_total + pkg_count))
        
        echo ""
        echo -e "  ${BOLD}${category}${RESET} ${DIM}($pkg_count packages)${RESET}"
        
        for pkg in "${pkg_array[@]}"; do
            if smart_find_tool "$pkg" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
                ((total_skipped++))
                ((apt_installed++))
                continue
            fi
            
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$pkg" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
                ((total_installed++))
                ((apt_installed++))
            else
                echo -e "    ${RED}✗${RESET} $pkg ${DIM}[failed]${RESET}"
                ((total_failed++))
                ((apt_failed++))
            fi
        done
    done
    
    echo ""
    if [[ $apt_failed -eq 0 ]]; then
        ok "Core CTF tools: ${apt_installed}/${apt_total} packages ready"
    else
        warn "Core CTF tools: ${apt_installed}/${apt_total} installed, ${apt_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Cryptography Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/8] CRYPTOGRAPHY TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # RsaCtfTool
    if [[ -d "${TOOLS_DIR}/RsaCtfTool" ]]; then
        echo -e "    ${GREEN}✔${RESET} RsaCtfTool ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing RsaCtfTool..."
        if git clone -q https://github.com/RsaCtfTool/RsaCtfTool "${TOOLS_DIR}/RsaCtfTool" >> "$LOG_FILE" 2>&1; then
            if "${VENV_DIR}/bin/pip" install -r "${TOOLS_DIR}/RsaCtfTool/requirements.txt" --quiet >> "$LOG_FILE" 2>&1; then
                make_venv_wrapper "rsactftool" "$VENV_DIR" "${TOOLS_DIR}/RsaCtfTool/RsaCtfTool.py"
                echo -e "    ${GREEN}✔${RESET} RsaCtfTool ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "RsaCtfTool installed"
            else
                echo -e "    ${RED}✗${RESET} RsaCtfTool ${DIM}[deps failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} RsaCtfTool ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # factordb-cli
    if smart_find_tool "factordb" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} factordb-cli ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing factordb-cli..."
        if install_venv_tool "factordb-cli" "factordb-pycli" "factordb" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} factordb-cli ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} factordb-cli ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # xortool (XOR analysis)
    if smart_find_tool "xortool" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} xortool ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing xortool..."
        if install_venv_tool "xortool" "xortool" "xortool" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} xortool ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} xortool ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # hash_extender (Hash length extension attacks)
    if [[ -d "${TOOLS_DIR}/hash_extender" ]]; then
        echo -e "    ${GREEN}✔${RESET} hash_extender ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing hash_extender..."
        if git clone -q https://github.com/iagox86/hash_extender "${TOOLS_DIR}/hash_extender" >> "$LOG_FILE" 2>&1; then
            if (cd "${TOOLS_DIR}/hash_extender" && make >> "$LOG_FILE" 2>&1); then
                ln -sf "${TOOLS_DIR}/hash_extender/hash_extender" "${LOCAL_BIN}/hash_extender" 2>/dev/null
                echo -e "    ${GREEN}✔${RESET} hash_extender ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "hash_extender installed"
            else
                echo -e "    ${RED}✗${RESET} hash_extender ${DIM}[build failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} hash_extender ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # basecrack (Base encoding detector)
    if smart_find_tool "basecrack" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} basecrack ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing basecrack..."
        if install_py_github_tool "basecrack" "" "https://github.com/AngelKitty/basecrack.git" "basecrack.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} basecrack ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} basecrack ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Steganography Tools (Advanced)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/8] ADVANCED STEGANOGRAPHY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # StegVeritas
    if smart_find_tool "stegoveritas" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} stegoveritas ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing stegoveritas..."
        if "${VENV_DIR}/bin/pip" install stegoveritas --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/stegoveritas" ]]; then
                make_wrapper "stegoveritas" "${VENV_DIR}/bin/stegoveritas"
                echo -e "    ${GREEN}✔${RESET} stegoveritas ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "stegoveritas installed"
            else
                echo -e "    ${RED}✗${RESET} stegoveritas ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} stegoveritas ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Stegsolve (Java-based)
    if [[ -f "${TOOLS_DIR}/stegsolve.jar" ]]; then
        echo -e "    ${GREEN}✔${RESET} Stegsolve ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Stegsolve..."
        if safe_curl "https://github.com/zardus/ctf-tools/raw/master/stegsolve/install/Stegsolve.jar" "${TOOLS_DIR}/stegsolve.jar"; then
            cat > "${LOCAL_BIN}/stegsolve" << 'STEGSOLVE'
#!/usr/bin/env bash
java -jar /opt/tools/stegsolve.jar "$@"
STEGSOLVE
            chmod +x "${LOCAL_BIN}/stegsolve"
            echo -e "    ${GREEN}✔${RESET} Stegsolve ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "Stegsolve installed"
        else
            echo -e "    ${RED}✗${RESET} Stegsolve ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # StegExtract
    if smart_find_tool "stegextract" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} stegextract ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing stegextract..."
        if install_py_github_tool "stegextract" "" "https://github.com/evyatarmeged/stegextract.git" "stegextract.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} stegextract ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} stegextract ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Forensics Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/8] FORENSICS TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Volatility 2 (Legacy)
    if [[ -d "${TOOLS_DIR}/volatility" ]]; then
        echo -e "    ${GREEN}✔${RESET} Volatility 2 ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Volatility 2..."
        if install_py_github_tool "volatility2" "" "https://github.com/volatilityfoundation/volatility.git" "vol.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} Volatility 2 ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Volatility 2 ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Volatility 3 (Modern) - Already in Python venv step
    if smart_find_tool "vol" &>/dev/null || smart_find_tool "vol3" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} Volatility 3 ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} Volatility 3 ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # binwalk (already installed in RE step)
    if smart_find_tool "binwalk" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} binwalk ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} binwalk ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # foremost (already installed)
    if smart_find_tool "foremost" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} foremost ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} foremost ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # bulk_extractor
    if smart_find_tool "bulk_extractor" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} bulk_extractor ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing bulk_extractor..."
        if install_apt_tool "bulk_extractor" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} bulk_extractor ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} bulk_extractor ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # autopsy (Digital forensics GUI)
    if smart_find_tool "autopsy" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} autopsy ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing autopsy..."
        if install_apt_tool "autopsy" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} autopsy ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} autopsy ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Web Exploitation (CTF-specific)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/8] WEB EXPLOITATION (CTF)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # commix (already installed in bug bounty)
    if smart_find_tool "commix" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} commix ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} commix ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # sqlmap (already installed)
    if smart_find_tool "sqlmap" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} sqlmap ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} sqlmap ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # XSStrike (already installed)
    if smart_find_tool "xsstrike" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} XSStrike ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} XSStrike ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # tplmap (Server-Side Template Injection)
    if smart_find_tool "tplmap" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} tplmap ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing tplmap..."
        if install_py_github_tool "tplmap" "" "https://github.com/epinna/tplmap.git" "tplmap.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} tplmap ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} tplmap ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # dotdotpwn (Directory traversal)
    if smart_find_tool "dotdotpwn" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} dotdotpwn ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing dotdotpwn..."
        if install_apt_tool "dotdotpwn" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} dotdotpwn ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} dotdotpwn ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: Binary Exploitation (CTF-specific)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/8] BINARY EXPLOITATION (CTF)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # heapinspect
    if [[ -d "${TOOLS_DIR}/heapinspect" ]]; then
        echo -e "    ${GREEN}✔${RESET} heapinspect ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing heapinspect..."
        if install_py_github_tool "heapinspect" "" "https://github.com/matrix1001/heapinspect.git" "heapinspect.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} heapinspect ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} heapinspect ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # ROPgadget (already installed in RE step)
    if smart_find_tool "ROPgadget" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ROPgadget ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} ROPgadget ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # ropper (already installed)
    if smart_find_tool "ropper" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ropper ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} ropper ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # pwntools (already installed)
    if smart_find_tool "pwn" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} pwntools ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} pwntools ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # one_gadget (Ruby - already installed in RE step)
    if smart_find_tool "one_gadget" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} one_gadget ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        echo -e "    ${RED}✗${RESET} one_gadget ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Miscellaneous CTF Utilities
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/8] MISCELLANEOUS CTF UTILITIES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Ciphey (Auto-decoder)
    if smart_find_tool "ciphey" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ciphey ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing ciphey..."
        if install_venv_tool "ciphey" "ciphey" "ciphey" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} ciphey ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} ciphey ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # CyberChef Server (Local instance)
    if [[ -d "${TOOLS_DIR}/CyberChef" ]]; then
        echo -e "    ${GREEN}✔${RESET} CyberChef ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing CyberChef..."
        if git clone -q --depth 1 https://github.com/gchq/CyberChef "${TOOLS_DIR}/CyberChef" >> "$LOG_FILE" 2>&1; then
            if (cd "${TOOLS_DIR}/CyberChef" && npm install >> "$LOG_FILE" 2>&1 && npm run build >> "$LOG_FILE" 2>&1); then
                cat > "${LOCAL_BIN}/cyberchef" << 'CYBERCHEF'
#!/usr/bin/env bash
cd /opt/tools/CyberChef
npm run start
CYBERCHEF
                chmod +x "${LOCAL_BIN}/cyberchef"
                echo -e "    ${GREEN}✔${RESET} CyberChef ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "CyberChef installed (run: cyberchef)"
            else
                echo -e "    ${RED}✗${RESET} CyberChef ${DIM}[build failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} CyberChef ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # qr-tools (QR code analysis)
    if smart_find_tool "qrtools" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} qrtools ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing qrtools..."
        if install_apt_tool "qrtools" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} qrtools ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            # Try alternative: python3-qrtools or zbar
            if install_apt_tool "zbar-tools" 2>&1 | grep -q "installed"; then
                echo -e "    ${GREEN}✔${RESET} zbar-tools ${DIM}[installed as alternative]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} qrtools ${DIM}[failed]${RESET}"
                ((total_failed++))
            fi
        fi
    fi
    
    # aircrack-ng (Wireless CTF challenges)
    if smart_find_tool "aircrack-ng" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} aircrack-ng ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing aircrack-ng..."
        if install_apt_tool "aircrack-ng" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} aircrack-ng ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} aircrack-ng ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/8] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical CTF tools
    local critical_tools=("john" "hashcat" "hydra" "steghide" "binwalk" "vol" "gdb")
    local verified=0
    local missing_critical=()
    
    for tool in "${critical_tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            ((verified++))
        else
            missing_critical+=("$tool")
        fi
    done
    
    if [[ ${#missing_critical[@]} -eq 0 ]]; then
        ok "Critical CTF tools verified (${verified}/${#critical_tools[@]})"
    else
        warn "Missing critical tools: ${missing_critical[*]}"
    fi
    
    # Get version info for key tools
    info "Tool versions:"
    for tool in john hashcat hydra; do
        if smart_find_tool "$tool" &>/dev/null; then
            local version
            case "$tool" in
                john)
                    version=$(john --version 2>&1 | head -1 | grep -oP '[\d.]+' | head -1 || echo "unknown")
                    ;;
                hashcat)
                    version=$(hashcat --version 2>&1 | head -1 || echo "unknown")
                    ;;
                hydra)
                    version=$(hydra -h 2>&1 | head -1 | grep -oP 'v[\d.]+' || echo "unknown")
                    ;;
            esac
            echo -e "    ${DIM}• $tool: $version${RESET}"
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
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  CTF TOOLKIT SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} tools"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} tools (already installed)"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} tools"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 tools"
    fi
    
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Core CTF Tools (APT): ${apt_installed} packages"
    echo -e "    ${GREEN}●${RESET} Cryptography: RsaCtfTool, factordb, xortool, hash_extender, basecrack"
    echo -e "    ${GREEN}●${RESET} Steganography: steghide, stegseek, zsteg, stegoveritas, Stegsolve"
    echo -e "    ${GREEN}●${RESET} Forensics: Volatility 2/3, binwalk, foremost, bulk_extractor"
    echo -e "    ${GREEN}●${RESET} Web Exploitation: commix, sqlmap, XSStrike, tplmap, dotdotpwn"
    echo -e "    ${GREEN}●${RESET} Binary Exploitation: heapinspect, ROPgadget, ropper, pwntools"
    echo -e "    ${GREEN}●${RESET} Utilities: ciphey, CyberChef, qrtools, aircrack-ng"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All CTF tools installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}john --wordlist=rockyou.txt hash.txt${RESET}    ${DIM}→ Password cracking${RESET}"
    echo -e "    ${CYAN}hashcat -m 0 hash.txt rockyou.txt${RESET}       ${DIM}→ GPU password cracking${RESET}"
    echo -e "    ${CYAN}hydra -l user -P pass.txt ssh://target${RESET}  ${DIM}→ Network auth brute${RESET}"
    echo -e "    ${CYAN}steghide extract -sf image.jpg${RESET}          ${DIM}→ Extract hidden data${RESET}"
    echo -e "    ${CYAN}binwalk -e firmware.bin${RESET}                 ${DIM}→ Firmware analysis${RESET}"
    echo -e "    ${CYAN}vol -f memdump.mem windows.pslist${RESET}       ${DIM}→ Memory forensics${RESET}"
    echo -e "    ${CYAN}rsactftool --publickey key.pem --private${RESET} ${DIM}→ RSA attacks${RESET}"
    echo -e "    ${CYAN}ciphey -f encrypted.txt${RESET}                 ${DIM}→ Auto-decode${RESET}"
    echo -e "    ${CYAN}cyberchef${RESET}                               ${DIM}→ Launch CyberChef${RESET}"
    echo -e "    ${CYAN}newctf challenge_name htb${RESET}               ${DIM}→ Create CTF workspace${RESET}"
    echo ""
}

# ============================================================
# STEP 9 — Active Directory & Network Toolkit (Professional)
# ============================================================
