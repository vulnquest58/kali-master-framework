#!/usr/bin/env bash
# modules/09_ad_network.sh

do_ad_network() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 9/${STEP_TOTAL} — ACTIVE DIRECTORY & NETWORK TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Core AD Tools (APT) - Categorized
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/9] CORE AD TOOLS (APT)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local apt_categories=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Mode: ${YELLOW}MINIMAL${RESET} — Core AD tools only"
        apt_categories=(
            "AD Exploitation|crackmapexec evil-winrm netexec"
            "AD Enumeration|bloodhound"
            "Database|neo4j"
            "Impacket|impacket-scripts"
            "SMB|smbclient"
        )
    else
        info "Mode: ${GREEN}FULL${RESET} — Complete AD & Network suite"
        apt_categories=(
            "AD Exploitation|crackmapexec evil-winrm netexec"
            "AD Enumeration|bloodhound enum4linux"
            "Database|neo4j"
            "Impacket|impacket-scripts"
            "SMB/CIFS|smbclient smbmap samba-common-bin"
            "LDAP|ldap-utils"
            "Kerberos|kerbrute"
            "MITM/Poisoning|responder"
            "NetBIOS|nbtscan"
            "SNMP|onesixtyone snmpcheck"
            "DNS|dnschef dnsmasq"
        )
    fi
    
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
        ok "Core AD tools: ${apt_installed}/${apt_total} packages ready"
    else
        warn "Core AD tools: ${apt_installed}/${apt_total} installed, ${apt_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Network Sniffing & MITM
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/9] NETWORK SNIFFING & MITM${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local network_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        network_tools=("ettercap-text-only")
    else
        network_tools=("ettercap-text-only" "bettercap" "mitm6")
    fi
    
    local net_count=${#network_tools[@]}
    local net_installed=0
    local net_failed=0
    
    for pkg in "${network_tools[@]}"; do
        if smart_find_tool "$pkg" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((net_installed++))
            continue
        fi
        
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$pkg" >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((net_installed++))
        else
            echo -e "    ${RED}✗${RESET} $pkg ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((net_failed++))
        fi
    done
    
    echo ""
    if [[ $net_failed -eq 0 ]]; then
        ok "Network tools: ${net_installed}/${net_count} tools ready"
    else
        warn "Network tools: ${net_installed}/${net_count} installed, ${net_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Kerberos Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/9] KERBEROS TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # kerbrute (with multiple fallback methods)
    if smart_find_tool "kerbrute" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kerbrute ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kerbrute..."
        
        # Method 1: Go install
        if install_go_tool "kerbrute" "github.com/ropnop/kerbrute" "kerbrute" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} kerbrute ${DIM}[installed via Go]${RESET}"
            ((total_installed++))
        # Method 2: GitHub release
        elif install_github_release "kerbrute" \
            "https://api.github.com/repos/ropnop/kerbrute/releases/latest" \
            "linux_amd64" "kerbrute" "kerbrute" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} kerbrute ${DIM}[installed from release]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} kerbrute ${DIM}[all methods failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # GetNPUsers wrapper (from impacket)
    if smart_find_tool "GetNPUsers" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} GetNPUsers ${DIM}[already available]${RESET}"
        ((total_skipped++))
    fi
    
    # GetUserSPNs wrapper
    if smart_find_tool "GetUserSPNs" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} GetUserSPNs ${DIM}[already available]${RESET}"
        ((total_skipped++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Impacket Suite & Wrappers
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/9] IMPACKET SUITE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Install impacket library in venv
    if "${VENV_DIR}/bin/pip" show impacket &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} impacket library ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing impacket library in venv..."
        if "${VENV_DIR}/bin/pip" install impacket --quiet >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} impacket library ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "impacket library installed"
        else
            echo -e "    ${RED}✗${RESET} impacket library ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Create wrappers for impacket scripts
    info "Creating impacket wrappers..."
    local impacket_scripts=(
        "psexec" "smbexec" "wmiexec" "atexec"
        "secretsdump" "GetUserSPNs" "GetNPUsers"
        "lookupsid" "samrdump" "rpcdump" "netview"
        "ntlmrelayx" "mssqlclient" "mssqlinstance"
        "ticketer" "goldenPac" "raiseChild"
        "addcomputer" "dumpifs" "rbcd"
    )
    
    local wrapper_count=0
    for script in "${impacket_scripts[@]}"; do
        local found_script=""
        for search_loc in \
            "/usr/bin/${script}.py" \
            "${VENV_DIR}/bin/${script}" \
            "${VENV_DIR}/bin/${script}.py" \
            "/usr/share/doc/python3-impacket/examples/${script}.py" \
            "/usr/share/impacket/examples/${script}.py"; do
            if [[ -f "$search_loc" ]]; then
                found_script="$search_loc"
                break
            fi
        done
        
        if [[ -n "$found_script" ]]; then
            if [[ ! -x "${WRAPPERS_DIR}/${script}" ]]; then
                make_wrapper "$script" "$found_script" 2>/dev/null
                ((wrapper_count++))
            fi
        fi
    done
    
    if [[ $wrapper_count -gt 0 ]]; then
        ok "Created $wrapper_count impacket wrappers"
    else
        ok "Impacket wrappers already configured"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Advanced AD Exploitation (Python)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/9] ADVANCED AD EXPLOITATION (PYTHON)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local py_ad_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        py_ad_tools=(
            "certipy-ad:certipy-ad:certipy"
            "bloodyad:bloodyad:bloodyAD"
        )
    else
        py_ad_tools=(
            "certipy-ad:certipy-ad:certipy"
            "ldeep:ldeep:ldeep"
            "bloodyad:bloodyad:bloodyAD"
            "ldapdomaindump:ldapdomaindump:ldapdomaindump"
            "donpapi:donpapi:DonPAPI"
            "ntlmrecon:ntlmrecon:ntlmrecon"
        )
    fi
    
    local py_count=${#py_ad_tools[@]}
    local py_installed=0
    local py_failed=0
    
    for entry in "${py_ad_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        
        if smart_find_tool "$binary" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((py_installed++))
            continue
        fi
        
        if install_venv_tool "$name" "$package" "$binary" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((py_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((py_failed++))
        fi
    done
    
    echo ""
    if [[ $py_failed -eq 0 ]]; then
        ok "Python AD tools: ${py_installed}/${py_count} tools ready"
    else
        warn "Python AD tools: ${py_installed}/${py_count} installed, ${py_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: AD Attack Frameworks (GitHub Python)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/9] AD ATTACK FRAMEWORKS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local github_ad_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        github_ad_tools=(
            "pywhisker::https://github.com/ShutdownRepo/pywhisker.git:pywhisker.py"
            "targetedKerberoast::https://github.com/ShutdownRepo/targetedKerberoast.git:targetedKerberoast.py"
        )
    else
        github_ad_tools=(
            "pywhisker::https://github.com/ShutdownRepo/pywhisker.git:pywhisker.py"
            "targetedKerberoast::https://github.com/ShutdownRepo/targetedKerberoast.git:targetedKerberoast.py"
            "adidnsdump::https://github.com/dirkjanm/adidnsdump.git:adidnsdump.py"
            "manspider::https://github.com/blacklanternsecurity/MANSPIDER.git:manspider.py"
            "roastinthemiddle::https://github.com/Tw1sm/RITM.git:roastinthemiddle.py"
        )
    fi
    
    local gh_count=${#github_ad_tools[@]}
    local gh_installed=0
    local gh_failed=0
    
    for entry in "${github_ad_tools[@]}"; do
        IFS=':' read -r name pypi url script <<< "$entry"
        
        if smart_find_tool "$name" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((gh_installed++))
            continue
        fi
        
        if install_py_github_tool "$name" "$pypi" "$url" "$script" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((gh_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((gh_failed++))
        fi
    done
    
    echo ""
    if [[ $gh_failed -eq 0 ]]; then
        ok "AD attack frameworks: ${gh_installed}/${gh_count} tools ready"
    else
        warn "AD attack frameworks: ${gh_installed}/${gh_count} installed, ${gh_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Go-based AD Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/9] GO-BASED AD TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local go_ad_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        go_ad_tools=(
            "windapsearch:github.com/ropnop/go-windapsearch:windapsearch"
        )
    else
        go_ad_tools=(
            "windapsearch:github.com/ropnop/go-windapsearch:windapsearch"
            "silenthound:github.com/AmberWolfLabs/silenthound:silenthound"
            "adenum:github.com/CGA-computing/ADEnum:ADEnum"
        )
    fi
    
    local go_count=${#go_ad_tools[@]}
    local go_installed=0
    local go_failed=0
    
    for entry in "${go_ad_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        
        if smart_find_tool "$binary" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((go_installed++))
            continue
        fi
        
        if install_go_tool "$name" "$package" "$binary" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((go_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((go_failed++))
        fi
    done
    
    echo ""
    if [[ $go_failed -eq 0 ]]; then
        ok "Go AD tools: ${go_installed}/${go_count} tools ready"
    else
        warn "Go AD tools: ${go_installed}/${go_count} installed, ${go_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: Rust-based AD Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/9] RUST-BASED AD TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # RustHound (BloodHound collector in Rust)
    if smart_find_tool "rusthound" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} rusthound ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing rusthound..."
        if install_cargo_tool "rusthound" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} rusthound ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "rusthound installed (fast BloodHound collector)"
        else
            echo -e "    ${RED}✗${RESET} rusthound ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "rusthound installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 9: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 9/9] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical AD tools
    local critical_tools=("crackmapexec" "bloodhound" "evil-winrm" "impacket" "responder" "certipy")
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
        ok "Critical AD tools verified (${verified}/${#critical_tools[@]})"
    else
        warn "Missing critical tools: ${missing_critical[*]}"
    fi
    
    # Get version info for key tools
    info "Tool versions:"
    for tool in crackmapexec evil-winrm bloodhound; do
        if smart_find_tool "$tool" &>/dev/null; then
            local version
            case "$tool" in
                crackmapexec|nxc)
                    version=$(crackmapexec --version 2>&1 | head -1 || nxc --version 2>&1 | head -1 || echo "unknown")
                    ;;
                evil-winrm)
                    version=$(evil-winrm -h 2>&1 | head -1 | grep -oP 'v[\d.]+' || echo "unknown")
                    ;;
                bloodhound)
                    version=$(bloodhound --version 2>&1 | head -1 || echo "unknown")
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
    echo -e "${BOLD}${MAGENTA}  AD & NETWORK TOOLKIT SETUP COMPLETE${RESET}"
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
    echo -e "    ${GREEN}●${RESET} Core AD Tools (APT): ${apt_installed} packages"
    echo -e "    ${GREEN}●${RESET} Network Sniffing: ${net_installed} tools"
    echo -e "    ${GREEN}●${RESET} Kerberos Tools: kerbrute, GetNPUsers, GetUserSPNs"
    echo -e "    ${GREEN}●${RESET} Impacket Suite: 20+ wrappers"
    echo -e "    ${GREEN}●${RESET} Python AD Tools: ${py_installed} tools"
    echo -e "    ${GREEN}●${RESET} AD Attack Frameworks: ${gh_installed} tools"
    echo -e "    ${GREEN}●${RESET} Go AD Tools: ${go_installed} tools"
    echo -e "    ${GREEN}●${RESET} Rust AD Tools: rusthound"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All AD & Network tools installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}crackmapexec smb 10.0.0.0/24 -u user -p pass${RESET}"
    echo -e "        ${DIM}→ SMB enumeration${RESET}"
    echo -e "    ${CYAN}evil-winrm -i 10.0.0.1 -u admin -H hash${RESET}"
    echo -e "        ${DIM}→ WinRM shell with Pass-the-Hash${RESET}"
    echo -e "    ${CYAN}bloodhound-python -d domain -u user -p pass -c all${RESET}"
    echo -e "        ${DIM}→ Collect AD data for BloodHound${RESET}"
    echo -e "    ${CYAN}rusthound -d domain -u user -p pass --zip${RESET}"
    echo -e "        ${DIM}→ Fast BloodHound collection (Rust)${RESET}"
    echo -e "    ${CYAN}certipy find -u user@domain -p pass -dc-ip 10.0.0.1 -vulnerable${RESET}"
    echo -e "        ${DIM}→ Find vulnerable AD CS templates${RESET}"
    echo -e "    ${CYAN}GetNPUsers.py domain/ -usersfile users.txt -no-pass${RESET}"
    echo -e "        ${DIM}→ AS-REP Roasting attack${RESET}"
    echo -e "    ${CYAN}GetUserSPNs.py domain/user:pass -request${RESET}"
    echo -e "        ${DIM}→ Kerberoasting attack${RESET}"
    echo -e "    ${CYAN}secretsdump.py domain/user:pass@10.0.0.1${RESET}"
    echo -e "        ${DIM}→ Dump credentials (DCSync)${RESET}"
    echo -e "    ${CYAN}kerbrute userenum users.txt -d domain --dc 10.0.0.1${RESET}"
    echo -e "        ${DIM}→ Kerberos user enumeration${RESET}"
    echo -e "    ${CYAN}responder -I eth0${RESET}"
    echo -e "        ${DIM}→ LLMNR/NBT-NS poisoning${RESET}"
    echo -e "    ${CYAN}mitm6 -d domain.local${RESET}"
    echo -e "        ${DIM}→ IPv6 MITM for WPAD${RESET}"
    echo -e "    ${CYAN}ntlmrelayx.py -t smb://10.0.0.1 -smb2${RESET}"
    echo -e "        ${DIM}→ NTLM relay attack${RESET}"
    echo -e "    ${CYAN}bloodyAD --host 10.0.0.1 -d domain -u user -p pass get children 'DC=domain,DC=local'${RESET}"
    echo -e "        ${DIM}→ AD object manipulation${RESET}"
    echo ""
}

# ============================================================
# STEP 10 — Cloud & Container Security Toolkit (Professional)
# ============================================================
