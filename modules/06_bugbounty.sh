#!/usr/bin/env bash
# modules/06_bugbounty.sh

do_bugbounty() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 6/${STEP_TOTAL} — BUG BOUNTY TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: ProjectDiscovery Suite (Go)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/8] PROJECTDISCOVERY SUITE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local pd_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Mode: ${YELLOW}MINIMAL${RESET} — Core PD tools only"
        pd_tools=(
            "subfinder:github.com/projectdiscovery/subfinder/v2/cmd/subfinder:subfinder"
            "httpx:github.com/projectdiscovery/httpx/cmd/httpx:httpx"
            "nuclei:github.com/projectdiscovery/nuclei/v3/cmd/nuclei:nuclei"
            "dnsx:github.com/projectdiscovery/dnsx/cmd/dnsx:dnsx"
        )
    else
        info "Mode: ${GREEN}FULL${RESET} — Complete PD suite"
        pd_tools=(
            # Core Recon
            "subfinder:github.com/projectdiscovery/subfinder/v2/cmd/subfinder:subfinder"
            "httpx:github.com/projectdiscovery/httpx/cmd/httpx:httpx"
            "nuclei:github.com/projectdiscovery/nuclei/v3/cmd/nuclei:nuclei"
            "dnsx:github.com/projectdiscovery/dnsx/cmd/dnsx:dnsx"
            "naabu:github.com/projectdiscovery/naabu/v2/cmd/naabu:naabu"
            "katana:github.com/projectdiscovery/katana/cmd/katana:katana"
            # Advanced Recon
            "mapcidr:github.com/projectdiscovery/mapcidr/cmd/mapcidr:mapcidr"
            "tlsx:github.com/projectdiscovery/tlsx/cmd/tlsx:tlsx"
            "shuffledns:github.com/projectdiscovery/shuffledns/cmd/shuffledns:shuffledns"
            "asnmap:github.com/projectdiscovery/asnmap/cmd/asnmap:asnmap"
            "uncover:github.com/projectdiscovery/uncover/cmd/uncover:uncover"
            # Utilities
            "interactsh-client:github.com/projectdiscovery/interactsh/cmd/interactsh-client:interactsh-client"
            "notify:github.com/projectdiscovery/notify/cmd/notify:notify"
            "alterx:github.com/projectdiscovery/alterx/cmd/alterx:alterx"
            "cvemap:github.com/projectdiscovery/cvemap/cmd/cvemap:cvemap"
            "pdtm:github.com/projectdiscovery/pdtm/cmd/pdtm:pdtm"
            "cloudlist:github.com/projectdiscovery/cloudlist/cmd/cloudlist:cloudlist"
            "simplehttpserver:github.com/projectdiscovery/simplehttpserver/cmd/simplehttpserver:simplehttpserver"
            "proxify:github.com/projectdiscovery/proxify/cmd/proxify:proxify"
        )
    fi
    
    local pd_count=${#pd_tools[@]}
    local pd_installed=0
    local pd_failed=0
    
    info "Installing ${pd_count} ProjectDiscovery tools..."
    
    for entry in "${pd_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        
        # Check if already installed
        if smart_find_tool "$binary" &>/dev/null; then
            local tool_path
            tool_path=$(smart_find_tool "$binary")
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((pd_installed++))
            continue
        fi
        
        # Install tool
        if install_go_tool "$name" "$package" "$binary" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((pd_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((pd_failed++))
        fi
    done
    
    echo ""
    if [[ $pd_failed -eq 0 ]]; then
        ok "ProjectDiscovery suite: ${pd_installed}/${pd_count} tools ready"
    else
        warn "ProjectDiscovery suite: ${pd_installed}/${pd_count} installed, ${pd_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Advanced Go Tools (Recon & Fuzzing)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/8] ADVANCED GO TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local go_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        go_tools=(
            "gobuster:github.com/OJ/gobuster/v3:gobuster"
            "ffuf:github.com/ffuf/ffuf/v2:ffuf"
            "gau:github.com/lc/gau/v2/cmd/gau:gau"
        )
    else
        go_tools=(
            # XSS & Injection
            "dalfox:github.com/hahwul/dalfox/v2:dalfox"
            "ghauri:github.com/r0oth3x49/ghauri:ghauri"
            # Directory Fuzzing
            "gobuster:github.com/OJ/gobuster/v3:gobuster"
            "ffuf:github.com/ffuf/ffuf/v2:ffuf"
            # URL Discovery
            "gau:github.com/lc/gau/v2/cmd/gau:gau"
            "hakrawler:github.com/hakluke/hakrawler:hakrawler"
            "waybackurls:github.com/tomnomnom/waybackurls:waybackurls"
            "gospider:github.com/jaeles-project/gospider:gospider"
            "getJS:github.com/003random/getJS:getJS"
            "subjs:github.com/lc/subjs:subjs"
            # Subdomain Tools
            "assetfinder:github.com/tomnomnom/assetfinder:assetfinder"
            "dsieve:github.com/trickest/dsieve:dsieve"
            # HTTP Utilities
            "httprobe:github.com/tomnomnom/httprobe:httprobe"
            "anew:github.com/tomnomnom/anew:anew"
            "qsreplace:github.com/tomnomnom/qsreplace:qsreplace"
            "meg:github.com/tomnomnom/meg:meg"
            "unfurl:github.com/tomnomnom/unfurl:unfurl"
            "gron:github.com/tomnomnom/gron:gron"
            # Secret Discovery
            "trufflehog:github.com/trufflesecurity/trufflehog/v3:trufflehog"
            # Bypass & Evasion
            "nomore403:github.com/iamj0ker/bypass-403:nomore403"
            # Template Management
            "cent:github.com/xm1k3/cent:cent"
            # Bug Bounty Platform Integration
            "shosubgo:github.com/incogbyte/shosubgo:shosubgo"
        )
    fi
    
    local go_count=${#go_tools[@]}
    local go_installed=0
    local go_failed=0
    
    info "Installing ${go_count} Go tools..."
    
    for entry in "${go_tools[@]}"; do
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
        ok "Go tools: ${go_installed}/${go_count} tools ready"
    else
        warn "Go tools: ${go_installed}/${go_count} installed, ${go_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: APT Security Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/8] APT SECURITY TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local apt_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        apt_tools=("sqlmap" "nikto")
    else
        apt_tools=("sqlmap" "whatweb" "dirb" "nikto" "wpscan" "amass")
    fi
    
    local apt_count=${#apt_tools[@]}
    local apt_installed=0
    local apt_failed=0
    
    info "Installing ${apt_count} APT tools..."
    
    for tool in "${apt_tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $tool ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((apt_installed++))
            continue
        fi
        
        if install_apt_tool "$tool" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $tool ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((apt_installed++))
        else
            echo -e "    ${RED}✗${RESET} $tool ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((apt_failed++))
        fi
    done
    
    echo ""
    if [[ $apt_failed -eq 0 ]]; then
        ok "APT tools: ${apt_installed}/${apt_count} tools ready"
    else
        warn "APT tools: ${apt_installed}/${apt_count} installed, ${apt_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Rust Tools (Cargo)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/8] RUST TOOLS (CARGO)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Installing feroxbuster via cargo..."
    
    if smart_find_tool "feroxbuster" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} feroxbuster ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        ok "feroxbuster ready"
    else
        if install_cargo_tool "feroxbuster" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} feroxbuster ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "feroxbuster installed successfully"
        else
            echo -e "    ${RED}✗${RESET} feroxbuster ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "feroxbuster installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Python Venv Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/8] PYTHON VENV TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local venv_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        venv_tools=(
            "arjun:arjun:arjun"
            "dirsearch:dirsearch:dirsearch"
        )
    else
        venv_tools=(
            "arjun:arjun:arjun"
            "waymore:waymore:waymore"
            "dnsgen:dnsgen:dnsgen"
            "dirsearch:dirsearch:dirsearch"
            "commix:commix:commix"
        )
    fi
    
    local venv_count=${#venv_tools[@]}
    local venv_installed=0
    local venv_failed=0
    
    info "Installing ${venv_count} Python venv tools..."
    
    for entry in "${venv_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        
        if smart_find_tool "$binary" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((venv_installed++))
            continue
        fi
        
        if install_venv_tool "$name" "$package" "$binary" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((venv_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((venv_failed++))
        fi
    done
    
    echo ""
    if [[ $venv_failed -eq 0 ]]; then
        ok "Python venv tools: ${venv_installed}/${venv_count} tools ready"
    else
        warn "Python venv tools: ${venv_installed}/${venv_count} installed, ${venv_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: Python GitHub Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/8] PYTHON GITHUB TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local py_github_tools=()
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        py_github_tools=(
            "xsstrike::https://github.com/s0md3v/XSStrike.git:xsstrike.py"
            "linkfinder::https://github.com/GerbenJavado/LinkFinder.git:linkfinder.py"
        )
    else
        py_github_tools=(
            # Subdomain Enumeration
            "sublist3r:sublist3r:https://github.com/aboul3la/Sublist3r.git:sublist3r.py"
            # XSS Scanning
            "xsstrike::https://github.com/s0md3v/XSStrike.git:xsstrike.py"
            # CORS Testing
            "corsy::https://github.com/s0md3v/Corsy.git:corsy.py"
            # JavaScript Analysis
            "linkfinder::https://github.com/GerbenJavado/LinkFinder.git:linkfinder.py"
            # SSRF Testing
            "ssrfmap::https://github.com/swisskyrepo/SSRFmap.git:ssrfmap.py"
            # JWT Attacks
            "jwt_tool::https://github.com/ticarpi/jwt_tool.git:jwt_tool.py"
            # HTTP Request Smuggling
            "smuggler::https://github.com/defparam/smuggler.git:smuggler.py"
            # GitHub Dorking
            "github-dorker::https://github.com/ainsi/github-dorks.git:github-dorks.py"
            # Cloud Enumeration
            "cloud_enum::https://github.com/initstring/cloud_enum.git:cloud_enum.py"
        )
    fi
    
    local py_count=${#py_github_tools[@]}
    local py_installed=0
    local py_failed=0
    
    info "Installing ${py_count} Python GitHub tools..."
    
    for entry in "${py_github_tools[@]}"; do
        IFS=':' read -r name pypi url script <<< "$entry"
        
        if smart_find_tool "$name" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((py_installed++))
            continue
        fi
        
        if install_py_github_tool "$name" "$pypi" "$url" "$script" 2>&1 | grep -q "installed"; then
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
        ok "Python GitHub tools: ${py_installed}/${py_count} tools ready"
    else
        warn "Python GitHub tools: ${py_installed}/${py_count} installed, ${py_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Templates & Patterns
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/8] TEMPLATES & PATTERNS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Update Nuclei templates
    if smart_find_tool "nuclei" &>/dev/null; then
        info "Updating Nuclei templates..."
        if nuclei -update-templates -silent >> "$LOG_FILE" 2>&1; then
            local template_count
            template_count=$(find "$HOME/.config/nuclei-templates" -type f 2>/dev/null | wc -l || echo "0")
            ok "Nuclei templates updated (${template_count} templates)"
        else
            warn "Nuclei template update failed"
        fi
    else
        skip "Nuclei not installed — skipping template update"
    fi
    
    # Install GF patterns
    if smart_find_tool "gf" &>/dev/null; then
        if [[ ! -d "$HOME/.gf" ]]; then
            info "Installing GF patterns..."
            if git clone -q https://github.com/1ndianl33t/Gf-Patterns "$HOME/.gf" >> "$LOG_FILE" 2>&1; then
                local pattern_count
                pattern_count=$(find "$HOME/.gf" -name "*.json" 2>/dev/null | wc -l || echo "0")
                ok "GF patterns installed (${pattern_count} patterns)"
            else
                warn "GF patterns installation failed"
            fi
        else
            ok "GF patterns already installed"
        fi
    else
        skip "gf not installed — skipping patterns"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/8] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical tools
    local critical_tools=("nuclei" "subfinder" "httpx" "ffuf" "sqlmap")
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
        ok "Critical tools verified (${verified}/${#critical_tools[@]})"
    else
        warn "Missing critical tools: ${missing_critical[*]}"
    fi
    
    # Get version info for key tools
    info "Tool versions:"
    for tool in nuclei subfinder httpx ffuf; do
        if smart_find_tool "$tool" &>/dev/null; then
            local version
            version=$("$tool" -version 2>&1 | head -1 | grep -oP 'v[\d.]+' || echo "unknown")
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
    echo -e "${BOLD}${MAGENTA}  BUG BOUNTY TOOLKIT SETUP COMPLETE${RESET}"
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
    echo -e "    ${GREEN}●${RESET} ProjectDiscovery Suite: ${pd_installed} tools"
    echo -e "    ${GREEN}●${RESET} Advanced Go Tools: ${go_installed} tools"
    echo -e "    ${GREEN}●${RESET} APT Security Tools: ${apt_installed} tools"
    echo -e "    ${GREEN}●${RESET} Rust Tools: 1 tool"
    echo -e "    ${GREEN}●${RESET} Python Venv Tools: ${venv_installed} tools"
    echo -e "    ${GREEN}●${RESET} Python GitHub Tools: ${py_installed} tools"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All Bug Bounty tools installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}nuclei -u target.com${RESET}        ${DIM}→ Vulnerability scan${RESET}"
    echo -e "    ${CYAN}subfinder -d target.com${RESET}     ${DIM}→ Subdomain enumeration${RESET}"
    echo -e "    ${CYAN}httpx -l urls.txt${RESET}           ${DIM}→ HTTP probing${RESET}"
    echo -e "    ${CYAN}ffuf -u URL -w wordlist${RESET}     ${DIM}→ Fuzzing${RESET}"
    echo -e "    ${CYAN}bb-recon target.com${RESET}         ${DIM}→ Full recon (custom script)${RESET}"
    echo ""
}

# ============================================================
# STEP 7 — Reverse Engineering Toolkit (Professional Edition)
# ============================================================
