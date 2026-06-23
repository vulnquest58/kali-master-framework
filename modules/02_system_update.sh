#!/usr/bin/env bash
# modules/02_system_update.sh — Kali Master Framework v7.0.0

do_system_update() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 2/${STEP_TOTAL} — SYSTEM UPDATE & DEPENDENCIES${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    export DEBIAN_FRONTEND=noninteractive
    local step_start_time
    step_start_time=$(date +%s)
    
    # ========================================================
    # Phase 1: Update Package Lists
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/5] UPDATING PACKAGE LISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Running apt-get update..."
    if apt-get update -qq >> "$LOG_FILE" 2>&1; then
        ok "Package lists updated"
    else
        fail "apt-get update failed — retrying with verbose output"
        apt-get update >> "$LOG_FILE" 2>&1 || {
            fail "apt-get update failed completely"
            warn "Continuing with existing package lists"
        }
    fi
    
    # ========================================================
    # Phase 2: Upgrade Existing Packages
    # ========================================================
    echo ""
    echo -e "${BOLD}${CYAN}[PHASE 2/5] UPGRADING EXISTING PACKAGES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Count upgradable packages
    local upgradable_count
    upgradable_count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
    
    if [[ "$upgradable_count" -gt 0 ]]; then
        info "Found $upgradable_count packages to upgrade"
        info "Running apt-get upgrade..."
        
        if apt-get upgrade -y -qq \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1; then
            ok "Packages upgraded successfully"
        else
            warn "Some packages failed to upgrade — continuing"
        fi
    else
        ok "All packages are up-to-date"
    fi
    
    # ========================================================
    # Phase 3: Install Packages by Category
    # ========================================================
    echo ""
    echo -e "${BOLD}${CYAN}[PHASE 3/5] INSTALLING PACKAGES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Define packages by category
    declare -A PKG_CATEGORIES
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Mode: ${YELLOW}MINIMAL${RESET} — Core packages only"
        
        PKG_CATEGORIES=(
            ["Build Essentials"]="build-essential pkg-config git curl wget"
            ["Python"]="python3 python3-pip python3-venv python3-dev"
            ["Libraries"]="libcurl4-openssl-dev libssl-dev libffi-dev libpcap-dev libxml2-dev libxslt1-dev zlib1g-dev"
            ["Runtimes"]="default-jdk ruby-full golang-go"
            ["Tools"]="vim tmux zsh fzf jq tree htop net-tools dnsutils whois nmap sublist3r"
        )
    else
        info "Mode: ${GREEN}FULL${RESET} — Complete installation"
        
        # Build & Compilation
        PKG_CATEGORIES=(
            ["Build Essentials"]="build-essential pkg-config cmake ninja-build meson autoconf automake libtool gcc g++ gcc-multilib g++-multilib nasm yasm"
            ["Core Tools"]="git curl wget unzip p7zip-full tar gzip bzip2 patchelf file"
            ["Python"]="python3 python3-pip python3-venv python3-dev python3-setuptools python3-wheel pipx libpython3-dev"
            ["Libraries - Core"]="libcurl4-openssl-dev libcurl4 libssl-dev libffi-dev libgmp-dev libmpfr-dev libmpc-dev"
            ["Libraries - Network"]="libpcap-dev libpcap0.8 libnetfilter-queue-dev libnfnetlink-dev libmnl-dev libpq-dev libldap2-dev libsasl2-dev krb5-config libkrb5-dev"
            ["Libraries - Database"]="libsqlite3-dev default-libmysqlclient-dev"
            ["Libraries - Parsing"]="libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev libbz2-dev liblzma-dev"
            ["Libraries - RE"]="libcapstone-dev libcapstone4 libelf-dev libiberty-dev libdwarf-dev binutils-dev libmagic-dev libmagic1"
            ["Runtimes"]="default-jdk default-jre ruby-full ruby-dev cargo rustup golang-go"
            ["CLI Tools"]="vim tmux zsh fzf jq bc tree htop bat ripgrep fd-find"
            ["Network Tools"]="socat netcat-openbsd strace ltrace tcpdump hexedit xxd bsdmainutils net-tools dnsutils whois iproute2 iputils-ping proxychains4"
            ["Security Tools"]="nmap masscan wireshark-qt tshark sqlmap hydra medusa hashcat john steghide exiftool libimage-exiftool-perl binwalk foremost yara"
            ["RE Tools"]="gdb gdb-multiarch gdbserver checksec radare2 rizin cutter"
            ["Wordlists"]="wordlists seclists sublist3r"
            ["Evasion Tools"]="osslsigncode mingw-w64 upx-ucl"
            ["Web Server"]="nginx certbot python3-certbot-nginx"
            ["Forensics"]="sagemath bulk-extractor"
        )
    fi
    
    local total_categories=${#PKG_CATEGORIES[@]}
    local current_category=0
    local total_installed=0
    local total_failed=0
    
    # Sort categories for consistent order
    IFS=$'\n' sorted_categories=($(sort <<<"${!PKG_CATEGORIES[*]}")); unset IFS
    
    for category in "${sorted_categories[@]}"; do
        ((current_category++))
        local packages="${PKG_CATEGORIES[$category]}"
        local pkg_array=($packages)
        local pkg_count=${#pkg_array[@]}
        
        echo ""
        echo -e "  ${BOLD}[${current_category}/${total_categories}]${RESET} ${CYAN}$category${RESET} ${DIM}($pkg_count packages)${RESET}"
        
        # Install in batches
        local batch_size=15
        local i=0
        local category_success=0
        local category_failed=0
        
        while [[ $i -lt $pkg_count ]]; do
            local batch=("${pkg_array[@]:$i:$batch_size}")
            local batch_str="${batch[*]}"
            
            # Show progress
            local progress=$(( (i + batch_size) * 100 / pkg_count ))
            [[ $progress -gt 100 ]] && progress=100
            
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "${batch[@]}" >> "$LOG_FILE" 2>&1; then
                ((category_success += ${#batch[@]}))
            else
                # Try individual installation for failed batch
                warn "Batch failed — trying individual packages..."
                for pkg in "${batch[@]}"; do
                    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$pkg" >> "$LOG_FILE" 2>&1; then
                        ((category_success++))
                    else
                        ((category_failed++))
                        warn "Failed: $pkg"
                    fi
                done
            fi
            
            i=$((i + batch_size))
        done
        
        # Show category summary
        if [[ $category_failed -eq 0 ]]; then
            echo -e "    ${GREEN}✔${RESET} ${category_success} packages installed"
        else
            echo -e "    ${YELLOW}⚠${RESET} ${category_success} installed, ${RED}${category_failed} failed${RESET}"
        fi
        
        total_installed=$((total_installed + category_success))
        total_failed=$((total_failed + category_failed))
    done
    
    # ========================================================
    # Phase 4: Cleanup
    # ========================================================
    echo ""
    echo -e "${BOLD}${CYAN}[PHASE 4/5] CLEANUP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Cleaning package cache..."
    apt-get autoremove -y -qq >> "$LOG_FILE" 2>&1 || true
    apt-get autoclean -y -qq >> "$LOG_FILE" 2>&1 || true
    
    ok "Cleanup complete"
    
    # ========================================================
    # Phase 5: Verification
    # ========================================================
    echo ""
    echo -e "${BOLD}${CYAN}[PHASE 5/5] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical tools
    local critical_tools=("gcc" "g++" "make" "python3" "git" "curl" "wget")
    local verified=0
    local missing_critical=()
    
    for tool in "${critical_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            ((verified++))
        else
            missing_critical+=("$tool")
        fi
    done
    
    if [[ ${#missing_critical[@]} -eq 0 ]]; then
        ok "All critical tools verified (${verified}/${#critical_tools[@]})"
    else
        fail "Missing critical tools: ${missing_critical[*]}"
        warn "Some installations may fail"
    fi
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    local step_minutes=$((step_duration / 60))
    local step_seconds=$((step_duration % 60))
    
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  SYSTEM UPDATE COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${BOLD}Categories:${RESET}     ${total_categories}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} packages"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} packages"
        warn "Check log for details: ${LOG_FILE}"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 packages"
    fi
    
    echo -e "  ${BOLD}Mode:${RESET}           $([[ "$MINIMAL_MODE" == "1" ]] && echo "${YELLOW}MINIMAL${RESET}" || echo "${GREEN}FULL${RESET}")"
    echo ""
    
    # Check if reboot needed
    if [[ -f /var/run/reboot-required ]]; then
        echo -e "  ${YELLOW}${BOLD}⚠  REBOOT REQUIRED${RESET}"
        echo -e "  ${DIM}Run: sudo reboot${RESET}"
        echo ""
    fi
    
    ok "System update step complete"
    echo ""
}

# ============================================================
# STEP 3 — Python Virtual Environment (Professional Edition)
# ============================================================
