#!/usr/bin/env bash
# modules/25_health_check.sh

do_health_check() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ FINAL HEALTH CHECK${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    
    # Update PATH
    export PATH="$PATH:/usr/local/go/bin:$GOPATH_BIN:$LOCAL_BIN:$PIP_BIN:$CARGO_BIN:${VENV_DIR}/bin:${EVASION_DIR}:${POSTEXPLOIT_DIR}"
    
    # ========================================================
    # Phase 1: Initialize Categories
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/7] INITIALIZING HEALTH CHECK${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Define tools by category
    declare -A CATEGORY_TOOLS=(
        ["bugbounty"]="nuclei subfinder httpx katana dnsx tlsx gobuster dalfox ffuf trufflehog notify interactsh-client feroxbuster alterx uncover anew waybackurls gau amass sublist3r corsy xsstrike linkfinder wfuzz ghauri nomore403 cent shosubgo smuggler"
        ["network"]="nmap sqlmap hydra hashcat john nxc kerbrute smbclient rpcclient"
        ["reversing"]="gdb radare2 ghidra binwalk vol jadx apktool capa floss pwninit rizin cutter imhex"
        ["c2"]="sliver-server c2-menu havoc mythic-cli covenant empire starkiller merlin nimplant"
        ["cloud"]="kubectl aws cloudfox gitleaks scoutsuite pacu"
        ["evasion"]="donut scarecrow sgn nimcrypt2 freeze inceptor pezor"
        ["postex"]="chisel linpeas pspy ligolo-proxy"
        ["ad"]="certipy pywhisker ldeep windapsearch"
        ["runtimes"]="go python3 docker git java nginx certbot"
    )
    
    declare -A CATEGORY_NAMES=(
        ["bugbounty"]="Bug Bounty Tools"
        ["network"]="Network & Exploitation"
        ["reversing"]="Reverse Engineering"
        ["c2"]="C2 Frameworks"
        ["cloud"]="Cloud Security"
        ["evasion"]="EDR/AV Evasion"
        ["postex"]="Post-Exploitation"
        ["ad"]="Active Directory"
        ["runtimes"]="Runtimes & Core"
    )
    
    local total_categories=${#CATEGORY_TOOLS[@]}
    echo -e "    ${GREEN}✔${RESET} Health check initialized"
    echo -e "    ${DIM}• $total_categories categories${RESET}"
    echo -e "    ${DIM}• Smart auto-fix enabled${RESET}"
    
    echo ""
    
    # ========================================================
    # Phase 2: Scan Tools by Category
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/7] SCANNING TOOLS BY CATEGORY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local total_tools=0
    local total_ok=0
    local total_fail=0
    local all_fail_list=()
    
    declare -A CATEGORY_STATS
    
    for category in bugbounty network reversing c2 cloud evasion postex ad runtimes; do
        local cat_name="${CATEGORY_NAMES[$category]}"
        local tools_str="${CATEGORY_TOOLS[$category]}"
        local tools_array=($tools_str)
        local cat_count=${#tools_array[@]}
        local cat_ok=0
        local cat_fail=0
        local cat_fail_list=()
        
        echo ""
        echo -e "  ${BOLD}${YELLOW}[$cat_name]${RESET} ${DIM}($cat_count tools)${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        for tool in "${tools_array[@]}"; do
            ((total_tools++))
            
            if smart_find_tool "$tool" &>/dev/null; then
                local tool_path
                tool_path=$(smart_find_tool "$tool")
                echo -e "    ${GREEN}[✔]${RESET} ${BOLD}$tool${RESET} ${DIM}→ $tool_path${RESET}"
                ((total_ok++))
                ((cat_ok++))
            else
                echo -e "    ${RED}[✗]${RESET} ${BOLD}$tool${RESET}"
                ((total_fail++))
                ((cat_fail++))
                cat_fail_list+=("$tool")
                all_fail_list+=("$tool")
            fi
        done
        
        # Category summary
        local cat_percentage=0
        [[ $cat_count -gt 0 ]] && cat_percentage=$((cat_ok * 100 / cat_count))
        
        echo ""
        echo -e "    ${BOLD}Category Status:${RESET} ${GREEN}$cat_ok${RESET}/${cat_count} ${DIM}(${cat_percentage}%)${RESET}"
        
        if [[ ${#cat_fail_list[@]} -gt 0 ]]; then
            echo -e "    ${RED}Missing:${RESET} ${cat_fail_list[*]}"
        fi
        
        # Store stats
        CATEGORY_STATS["${category}_ok"]=$cat_ok
        CATEGORY_STATS["${category}_fail"]=$cat_fail
        CATEGORY_STATS["${category}_total"]=$cat_count
    done
    
    echo ""
    
    # ========================================================
    # Phase 3: Check Python Virtual Environments
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/7] CHECKING PYTHON VIRTUAL ENVIRONMENTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local venvs=("$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV")
    local venv_names=("Main Offensive" "Angr (Binary Analysis)" "FLARE (Malware)")
    
    for i in "${!venvs[@]}"; do
        local venv_path="${venvs[$i]}"
        local venv_name="${venv_names[$i]}"
        
        if [[ -f "${venv_path}/bin/python3" ]]; then
            local py_version
            py_version=$("${venv_path}/bin/python3" --version 2>&1)
            local pkg_count
            pkg_count=$("${venv_path}/bin/pip" list 2>/dev/null | wc -l)
            pkg_count=$((pkg_count - 2))
            
            echo -e "    ${GREEN}[✔]${RESET} ${BOLD}$venv_name${RESET}"
            echo -e "         ${DIM}Path: $venv_path${RESET}"
            echo -e "         ${DIM}Python: $py_version${RESET}"
            echo -e "         ${DIM}Packages: $pkg_count${RESET}"
            ((total_ok++))
            ((total_tools++))
        else
            echo -e "    ${RED}[✗]${RESET} ${BOLD}$venv_name${RESET} ${DIM}→ Not installed${RESET}"
            ((total_fail++))
            ((total_tools++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 4: Check C2 Framework Directories
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/7] CHECKING C2 FRAMEWORK DIRECTORIES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local c2_dirs=("/opt/Havoc" "/opt/Mythic" "/opt/Covenant" "/opt/Empire" "/opt/Starkiller" "/opt/merlin" "/opt/NimPlant")
    
    for c2_dir in "${c2_dirs[@]}"; do
        if [[ -d "$c2_dir" ]]; then
            local dir_size
            dir_size=$(du -sh "$c2_dir" 2>/dev/null | awk '{print $1}')
            echo -e "    ${GREEN}[✔]${RESET} ${BOLD}$(basename $c2_dir)${RESET} ${DIM}→ $c2_dir ($dir_size)${RESET}"
            ((total_ok++))
            ((total_tools++))
        else
            echo -e "    ${RED}[✗]${RESET} ${BOLD}$(basename $c2_dir)${RESET} ${DIM}→ Not cloned${RESET}"
            ((total_fail++))
            ((total_tools++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 5: Check Post-Exploit Kit Files
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/7] CHECKING POST-EXPLOIT KIT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local pe_files=(
        "${POSTEXPLOIT_DIR}/linux/linpeas.sh"
        "${POSTEXPLOIT_DIR}/linux/pspy64"
        "${POSTEXPLOIT_DIR}/linux/pspy32"
        "${POSTEXPLOIT_DIR}/linux/linux-exploit-suggester.sh"
        "${POSTEXPLOIT_DIR}/windows/winPEASx64.exe"
        "${POSTEXPLOIT_DIR}/windows/winPEASx86.exe"
        "${POSTEXPLOIT_DIR}/windows/mimikatz.exe"
        "${POSTEXPLOIT_DIR}/windows/Rubeus.exe"
        "${POSTEXPLOIT_DIR}/windows/SafetyKatz.exe"
        "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng/proxy"
    )
    
    for pe_file in "${pe_files[@]}"; do
        if [[ -f "$pe_file" ]]; then
            local file_size
            file_size=$(du -h "$pe_file" 2>/dev/null | awk '{print $1}')
            echo -e "    ${GREEN}[✔]${RESET} ${BOLD}$(basename $pe_file)${RESET} ${DIM}($file_size)${RESET}"
            ((total_ok++))
            ((total_tools++))
        else
            echo -e "    ${RED}[✗]${RESET} ${BOLD}$(basename $pe_file)${RESET}"
            ((total_fail++))
            ((total_tools++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 6: Generate Comprehensive Report
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/7] GENERATING HEALTH REPORT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Calculate overall percentage
    local overall_percentage=0
    [[ $total_tools -gt 0 ]] && overall_percentage=$((total_ok * 100 / total_tools))
    
    # Category breakdown
    echo ""
    echo -e "  ${BOLD}${YELLOW}CATEGORY BREAKDOWN${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    for category in bugbounty network reversing c2 cloud evasion postex ad runtimes; do
        local cat_name="${CATEGORY_NAMES[$category]}"
        local cat_ok=${CATEGORY_STATS["${category}_ok"]:-0}
        local cat_fail=${CATEGORY_STATS["${category}_fail"]:-0}
        local cat_total=${CATEGORY_STATS["${category}_total"]:-0}
        
        if [[ $cat_total -gt 0 ]]; then
            local cat_percentage=$((cat_ok * 100 / cat_total))
            
            local status_icon
            if [[ $cat_fail -eq 0 ]]; then
                status_icon="${GREEN}✔${RESET}"
            elif [[ $cat_ok -eq 0 ]]; then
                status_icon="${RED}✗${RESET}"
            else
                status_icon="${YELLOW}!${RESET}"
            fi
            
            echo -e "    $status_icon ${cat_name}: ${GREEN}${cat_ok}${RESET}/${cat_total} ${DIM}(${cat_percentage}%)${RESET}"
        fi
    done
    
    echo ""
    
    # Overall status bar
    echo -e "  ${BOLD}${YELLOW}OVERALL STATUS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -n "    ["
    local filled=$((overall_percentage / 2))
    local empty=$((50 - filled))
    for ((i=0; i<filled; i++)); do echo -ne "${GREEN}█${RESET}"; done
    for ((i=0; i<empty; i++)); do echo -ne "${DIM}░${RESET}"; done
    echo -e "] ${overall_percentage}%"
    echo ""
    
    # ========================================================
    # Phase 7: Auto-Fix Decision
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/7] AUTO-FIX DECISION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local fail_percentage=0
    [[ $total_tools -gt 0 ]] && fail_percentage=$((total_fail * 100 / total_tools))
    
    if [[ $fail_percentage -gt 10 ]]; then
        echo -e "    ${YELLOW}[!]${RESET} High failure rate detected: ${fail_percentage}%"
        echo -e "    ${YELLOW}[!]${RESET} Triggering Universal Auto-Fix Engine..."
        echo ""
        sleep 2
        do_auto_fix
    elif [[ $total_fail -gt 0 ]]; then
        echo -e "    ${YELLOW}[!]${RESET} ${total_fail} tool(s) missing"
        echo -e "    ${DIM}Run: kali-master --fix to install missing tools${RESET}"
    else
        echo -e "    ${GREEN}[✔]${RESET} All tools installed successfully!"
    fi
    
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
    echo -e "${BOLD}${MAGENTA}  HEALTH CHECK COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${BOLD}Total Checked:${RESET}  ${total_tools} items"
    echo -e "  ${GREEN}Passed:${RESET}          ${total_ok} items"
    
    if [[ $total_fail -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}          ${total_fail} items"
    else
        echo -e "  ${GREEN}Failed:${RESET}          0 items"
    fi
    
    echo -e "  ${BOLD}Success Rate:${RESET}   ${GREEN}${overall_percentage}%${RESET}"
    echo ""
    
    # Missing tools list
    if [[ ${#all_fail_list[@]} -gt 0 ]]; then
        echo -e "  ${BOLD}${RED}MISSING TOOLS (${#all_fail_list[@]})${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        for tool in "${all_fail_list[@]}"; do
            echo -e "    ${RED}•${RESET} $tool"
        done
        echo ""
        echo -e "  ${BOLD}To fix missing tools:${RESET}"
        echo -e "    ${CYAN}kali-master --fix${RESET}         ${DIM}→ Fix all missing${RESET}"
        echo -e "    ${CYAN}./kali-master.sh --fix${RESET}  ${DIM}→ Alternative command${RESET}"
    else
        echo -e "  ${GREEN}${BOLD}🎉 All tools are installed!${RESET}"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}kali-master status${RESET}       ${DIM}→ Show dashboard${RESET}"
    echo -e "    ${CYAN}kali-master fix${RESET}          ${DIM}→ Check missing tools${RESET}"
    echo -e "    ${CYAN}kali-master tools${RESET}        ${DIM}→ List all tools${RESET}"
    echo -e "    ${CYAN}c2-menu${RESET}                  ${DIM}→ C2 launcher${RESET}"
    echo -e "    ${CYAN}lab-manager${RESET}              ${DIM}→ Lab manager${RESET}"
    echo ""
}

# ============================================================
# Final Summary (Professional Edition)
# ============================================================

do_final_summary() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ FINAL SUMMARY${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - START_TIME ))
    local minutes=$(( duration / 60 ))
    local seconds=$(( duration % 60 ))
    
    # ========================================================
    # Phase 1: Calculate Statistics
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/4] CALCULATING STATISTICS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Count installed tools in each directory
    local usr_local_count=$(find /usr/local/bin -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
    local go_bin_count=$(find "$GOPATH_BIN" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
    local cargo_bin_count=$(find "$CARGO_BIN" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
    local venv_count=$("${VENV_DIR}/bin/pip" list 2>/dev/null | wc -l)
    venv_count=$((venv_count - 2))
    
    # Count C2 frameworks
    local c2_count=0
    for dir in /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant; do
        [[ -d "$dir" ]] && ((c2_count++))
    done
    
    # Count post-exploit files
    local postex_count=0
    [[ -d "$POSTEXPLOIT_DIR" ]] && postex_count=$(find "$POSTEXPLOIT_DIR" -type f 2>/dev/null | wc -l)
    
    # Count evasion tools
    local evasion_count=0
    [[ -d "$EVASION_DIR" ]] && evasion_count=$(find "$EVASION_DIR" -maxdepth 1 -type d 2>/dev/null | wc -l)
    evasion_count=$((evasion_count - 1))
    
    # Calculate total disk usage
    local total_size="N/A"
    if command -v du &>/dev/null; then
        local usr_size=$(du -sh /usr/local/bin 2>/dev/null | awk '{print $1}')
        local go_size=$(du -sh "$GOPATH_BIN" 2>/dev/null | awk '{print $1}')
        local opt_size=$(du -sh /opt/tools /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant /opt/evasion-tools /opt/postexploit /opt/wordlists 2>/dev/null | awk '{sum+=$1} END {print sum"M"}')
        total_size="${usr_size:-?} + ${go_size:-?} + ${opt_size:-?}"
    fi
    
    echo -e "    ${GREEN}✔${RESET} Statistics calculated"
    echo -e "    ${DIM}• /usr/local/bin: $usr_local_count tools${RESET}"
    echo -e "    ${DIM}• Go binaries: $go_bin_count tools${RESET}"
    echo -e "    ${DIM}• Cargo binaries: $cargo_bin_count tools${RESET}"
    echo -e "    ${DIM}• Python packages: $venv_count packages${RESET}"
    echo -e "    ${DIM}• C2 frameworks: $c2_count frameworks${RESET}"
    echo -e "    ${DIM}• Post-exploit files: $postex_count files${RESET}"
    echo -e "    ${DIM}• Evasion tools: $evasion_count tools${RESET}"
    
    echo ""
    
    # ========================================================
    # Phase 2: Generate Main Banner
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/4] GENERATING SUMMARY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Main completion banner
    echo -e "${BOLD}${GREEN}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════════╗
  ║                                                           ║
  ║            ██╗  ██╗ █████╗ ██╗     ██╗                  ║
  ║            ██║ ██╔╝██╔══██╗██║     ██║                 ║
  ║            █████╔╝ ███████║██║     ██║                ║
  ║            ██╔═██╗ ██╔══██║██║     ██║                 ║
  ║            ██║  ██╗██║  ██║███████╗██║                 ║
  ║            ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝                ║
  ║                                                       ║
  ║   ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗   ║
  ║   ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗  ║
  ║   ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝  ║
  ║   ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗  ║
  ║   ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║    ║   
  ║   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ║
  ║                                                           ║
  ║                 INSTALLATION COMPLETE! 🎉                 ║
  ║                                                           ║
  ╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo ""
    
    # ========================================================
    # Phase 3: Detailed Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/4] DETAILED SUMMARY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Installation info
    echo -e "  ${BOLD}${MAGENTA}INSTALLATION INFO${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${BOLD}Version:${RESET}       ${GREEN}Kali Master Framework v${VERSION}${RESET}"
    echo -e "  ${BOLD}Duration:${RESET}      ${CYAN}${minutes}m ${seconds}s${RESET}"
    echo -e "  ${BOLD}Log File:${RESET}      ${DIM}${LOG_FILE}${RESET}"
    echo -e "  ${BOLD}Completed:${RESET}     $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Directories
    echo -e "  ${BOLD}${MAGENTA}KEY DIRECTORIES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${BOLD}Python venv:${RESET}   ${DIM}${VENV_DIR}${RESET}"
    echo -e "  ${BOLD}Angr venv:${RESET}     ${DIM}${ANGR_VENV}${RESET}"
    echo -e "  ${BOLD}FLARE venv:${RESET}    ${DIM}${FLARE_VENV}${RESET}"
    echo -e "  ${BOLD}C2 Frameworks:${RESET} ${DIM}${C2_DIR}${RESET}"
    echo -e "  ${BOLD}Evasion Tools:${RESET} ${DIM}${EVASION_DIR}${RESET}"
    echo -e "  ${BOLD}Post-Exploit:${RESET}  ${DIM}${POSTEXPLOIT_DIR}${RESET}"
    echo -e "  ${BOLD}Redirectors:${RESET}   ${DIM}${REDIRECTOR_DIR}${RESET}"
    echo -e "  ${BOLD}Wordlists:${RESET}     ${DIM}/opt/wordlists${RESET}"
    echo -e "  ${BOLD}Custom Tools:${RESET}  ${DIM}/opt/tools${RESET}"
    echo ""
    
    # Statistics
    echo -e "  ${BOLD}${MAGENTA}STATISTICS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}●${RESET} /usr/local/bin:     ${BOLD}$usr_local_count${RESET} tools"
    echo -e "  ${GREEN}●${RESET} Go binaries:        ${BOLD}$go_bin_count${RESET} tools"
    echo -e "  ${GREEN}●${RESET} Cargo binaries:     ${BOLD}$cargo_bin_count${RESET} tools"
    echo -e "  ${GREEN}●${RESET} Python packages:    ${BOLD}$venv_count${RESET} packages"
    echo -e "  ${GREEN}●${RESET} C2 frameworks:      ${BOLD}$c2_count${RESET} frameworks"
    echo -e "  ${GREEN}●${RESET} Post-exploit files: ${BOLD}$postex_count${RESET} files"
    echo -e "  ${GREEN}●${RESET} Evasion tools:      ${BOLD}$evasion_count${RESET} tools"
    echo -e "  ${GREEN}●${RESET} Total disk usage:   ${BOLD}$total_size${RESET}"
    echo ""
    
    # Failed steps
    if [[ ${#INSTALL_ERRORS[@]} -gt 0 ]]; then
        echo -e "  ${BOLD}${RED}FAILED STEPS (${#INSTALL_ERRORS[@]})${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        for e in "${INSTALL_ERRORS[@]}"; do
            echo -e "    ${RED}✗${RESET} $e"
        done
        echo ""
        echo -e "  ${DIM}Run: ${CYAN}kali-master --fix${RESET} to retry failed steps${RESET}"
        echo ""
    fi
    
    # ========================================================
    # Phase 4: Quick Commands & Important Info
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/4] QUICK COMMANDS & INFO${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Dashboard commands
    echo -e "  ${BOLD}${YELLOW}DASHBOARD & MANAGEMENT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}kali-master status${RESET}          ${DIM}→ Full dashboard${RESET}"
    echo -e "    ${CYAN}kali-master fix${RESET}             ${DIM}→ Check missing tools${RESET}"
    echo -e "    ${CYAN}kali-master tools${RESET}           ${DIM}→ List all tools${RESET}"
    echo -e "    ${CYAN}kali-master venvs${RESET}           ${DIM}→ Python venvs info${RESET}"
    echo -e "    ${CYAN}kali-master labs${RESET}            ${DIM}→ Docker labs status${RESET}"
    echo -e "    ${CYAN}kali-master opsec${RESET}           ${DIM}→ OPSEC status${RESET}"
    echo -e "    ${CYAN}kali-master cloud${RESET}           ${DIM}→ Cloud tools info${RESET}"
    echo -e "    ${CYAN}kali-master certipy${RESET}         ${DIM}→ AD CS commands${RESET}"
    echo -e "    ${CYAN}kali-master evasion${RESET}         ${DIM}→ Evasion toolkit${RESET}"
    echo -e "    ${CYAN}kali-master postex${RESET}          ${DIM}→ Post-exploitation kit${RESET}"
    echo -e "    ${CYAN}update-tools${RESET}                ${DIM}→ Update everything${RESET}"
    echo ""
    
    # C2 commands
    echo -e "  ${BOLD}${YELLOW}C2 FRAMEWORKS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}c2-menu${RESET}                   ${DIM}→ Interactive C2 launcher${RESET}"
    echo -e "    ${CYAN}havoc server${RESET}              ${DIM}→ Start Havoc teamserver${RESET}"
    echo -e "    ${CYAN}mythic-cli start${RESET}          ${DIM}→ Start Mythic${RESET}"
    echo -e "    ${CYAN}covenant${RESET}                  ${DIM}→ Start Covenant${RESET}"
    echo -e "    ${CYAN}empire server${RESET}             ${DIM}→ Start Empire${RESET}"
    echo -e "    ${CYAN}starkiller${RESET}                ${DIM}→ Start Starkiller${RESET}"
    echo -e "    ${CYAN}merlin server${RESET}             ${DIM}→ Start Merlin server${RESET}"
    echo -e "    ${CYAN}merlin client${RESET}             ${DIM}→ Start Merlin client${RESET}"
    echo -e "    ${CYAN}nimplant server${RESET}           ${DIM}→ Start NimPlant${RESET}"
    echo -e "    ${CYAN}sliver-server${RESET}             ${DIM}→ Start Sliver${RESET}"
    echo ""
    
    # Lab commands
    echo -e "  ${BOLD}${YELLOW}DOCKER LABS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}lab-manager${RESET}               ${DIM}→ Interactive lab menu${RESET}"
    echo -e "    ${CYAN}start-lab dvwa${RESET}            ${DIM}→ Start DVWA${RESET}"
    echo -e "    ${CYAN}start-lab webgoat${RESET}         ${DIM}→ Start WebGoat${RESET}"
    echo -e "    ${CYAN}stop-lab all${RESET}              ${DIM}→ Stop all labs${RESET}"
    echo ""
    
    # Recon commands
    echo -e "  ${BOLD}${YELLOW}RECONNAISSANCE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}bb-recon <domain>${RESET}         ${DIM}→ Bug bounty recon${RESET}"
    echo -e "    ${CYAN}sub-enum <domain>${RESET}         ${DIM}→ Subdomain enumeration${RESET}"
    echo -e "    ${CYAN}api-recon <url>${RESET}           ${DIM}→ API reconnaissance${RESET}"
    echo -e "    ${CYAN}cloud-recon <target>${RESET}      ${DIM}→ Cloud enumeration${RESET}"
    echo -e "    ${CYAN}port-scan <target>${RESET}        ${DIM}→ Port scanning${RESET}"
    echo -e "    ${CYAN}dir-fuzz <url>${RESET}            ${DIM}→ Directory fuzzing${RESET}"
    echo -e "    ${CYAN}vuln-scan <target>${RESET}        ${DIM}→ Vulnerability scanning${RESET}"
    echo ""
    
    # Workspace creators
    echo -e "  ${BOLD}${YELLOW}WORKSPACE CREATORS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}newbb <domain>${RESET}            ${DIM}→ Bug Bounty workspace${RESET}"
    echo -e "    ${CYAN}newctf <name>${RESET}             ${DIM}→ CTF workspace${RESET}"
    echo -e "    ${CYAN}newad <domain>${RESET}            ${DIM}→ Active Directory workspace${RESET}"
    echo -e "    ${CYAN}newpayload <name>${RESET}         ${DIM}→ Payload dev workspace${RESET}"
    echo -e "    ${CYAN}newredteam <name>${RESET}         ${DIM}→ Red Team operation${RESET}"
    echo ""
    
    # Post-exploitation
    echo -e "  ${BOLD}${YELLOW}POST-EXPLOITATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}postexploit-menu${RESET}          ${DIM}→ Post-exploitation menu${RESET}"
    echo -e "    ${CYAN}pe-server${RESET}                 ${DIM}→ Start HTTP server${RESET}"
    echo -e "    ${CYAN}pe-transfer <file>${RESET}        ${DIM}→ Quick file transfer${RESET}"
    echo -e "    ${CYAN}revshell IP PORT${RESET}          ${DIM}→ Generate reverse shell${RESET}"
    echo -e "    ${CYAN}linpeas${RESET}                   ${DIM}→ Linux privilege escalation${RESET}"
    echo -e "    ${CYAN}pspy64${RESET}                    ${DIM}→ Process monitoring${RESET}"
    echo -e "    ${CYAN}chisel${RESET}                    ${DIM}→ TCP tunnel over HTTP${RESET}"
    echo -e "    ${CYAN}ligolo-proxy${RESET}              ${DIM}→ Ligolo-ng proxy${RESET}"
    echo ""
    
    # Evasion
    echo -e "  ${BOLD}${YELLOW}EDR/AV EVASION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}evasion-menu${RESET}              ${DIM}→ Evasion toolkit menu${RESET}"
    echo -e "    ${CYAN}donut -f <exe>${RESET}            ${DIM}→ Generate shellcode${RESET}"
    echo -e "    ${CYAN}scarecrow -in <dll>${RESET}       ${DIM}→ EDR bypass${RESET}"
    echo -e "    ${CYAN}sgn <binary>${RESET}              ${DIM}→ Shikata Ga Nai encoder${RESET}"
    echo -e "    ${CYAN}freeze -o out.bin <exe>${RESET}   ${DIM}→ Payload obfuscation${RESET}"
    echo -e "    ${CYAN}pezor <exe>${RESET}               ${DIM}→ PE packer${RESET}"
    echo -e "    ${CYAN}nimcrypt2 -f <exe>${RESET}        ${DIM}→ Nim-based encryption${RESET}"
    echo ""
    
    # OPSEC
    echo -e "  ${BOLD}${YELLOW}OPSEC & REDIRECTORS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${CYAN}setup-redirector${RESET}          ${DIM}→ Setup Nginx+C2 redirector${RESET}"
    echo -e "    ${CYAN}list-redirectors${RESET}          ${DIM}→ List active redirectors${RESET}"
    echo -e "    ${CYAN}secrets-manager${RESET}           ${DIM}→ Manage API keys${RESET}"
    echo -e "    ${CYAN}notify-recon${RESET}              ${DIM}→ Send notifications${RESET}"
    echo ""
    
    # Credentials
    echo -e "  ${BOLD}${YELLOW}CREDENTIALS & ACCESS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${BOLD}Mythic:${RESET}"
    echo -e "      ${DIM}URL:  ${CYAN}https://127.0.0.1:7443${RESET}"
    echo -e "      ${DIM}User: ${CYAN}mythic_admin${RESET}"
    echo -e "      ${DIM}Pass: ${CYAN}Admin123!${RESET}"
    echo -e "      ${DIM}File: ${DIM}/opt/Mythic/.env${RESET}"
    echo ""
    echo -e "    ${BOLD}Havoc:${RESET}"
    echo -e "      ${DIM}User: ${CYAN}5pider${RESET}"
    echo -e "      ${DIM}Pass: ${CYAN}password1234${RESET}"
    echo -e "      ${DIM}Port: ${CYAN}40056${RESET}"
    echo ""
    echo -e "    ${BOLD}Merlin:${RESET}"
    echo -e "      ${DIM}Pass: ${CYAN}merlin${RESET}"
    echo -e "      ${DIM}Port: ${CYAN}50051${RESET}"
    echo ""
    echo -e "    ${BOLD}Covenant:${RESET}"
    echo -e "      ${DIM}URL:  ${CYAN}https://127.0.0.1:7443${RESET}"
    echo -e "      ${DIM}Note: ${DIM}Create admin on first login${RESET}"
    echo ""
    echo -e "    ${BOLD}API Keys:${RESET}"
    echo -e "      ${DIM}Edit: ${DIM}${CONFIG_DIR}/secrets.env${RESET}"
    echo -e "      ${DIM}Use:  ${DIM}secrets-manager${RESET}"
    echo ""
    
    # Important warnings
    echo -e "  ${BOLD}${RED}⚠  IMPORTANT REMINDERS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${YELLOW}1.${RESET} Open a new terminal or run: ${BOLD}source ~/.zshrc${RESET}"
    echo -e "    ${YELLOW}2.${RESET} Powerlevel10k active — run: ${BOLD}p10k configure${RESET}"
    echo -e "    ${YELLOW}3.${RESET} OPSEC: Use ${BOLD}setup-redirector${RESET} before live C2 ops"
    echo -e "    ${YELLOW}4.${RESET} Windows tools: ${DIM}${POSTEXPLOIT_DIR}/windows/${RESET}"
    echo -e "    ${YELLOW}5.${RESET} Evasion tools: ${DIM}${EVASION_DIR}/${RESET}"
    echo -e "    ${YELLOW}6.${RESET} Wordlists: ${DIM}/opt/wordlists/${RESET}"
    echo -e "    ${YELLOW}7.${RESET} Never commit ${BOLD}secrets.env${RESET} to version control"
    echo -e "    ${YELLOW}8.${RESET} Use tools only on authorized systems"
    echo ""
    
    # Next steps
    echo -e "  ${BOLD}${GREEN}🚀 NEXT STEPS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "    ${GREEN}1.${RESET} Open a new terminal to activate all tools"
    echo -e "    ${GREEN}2.${RESET} Run ${CYAN}p10k configure${RESET} to customize your shell"
    echo -e "    ${GREEN}3.${RESET} Configure API keys: ${CYAN}secrets-manager${RESET}"
    echo -e "    ${GREEN}4.${RESET} Check status: ${CYAN}kali-master status${RESET}"
    echo -e "    ${GREEN}5.${RESET} Start exploring: ${CYAN}c2-menu${RESET} or ${CYAN}lab-manager${RESET}"
    echo ""
    
    # Final banner
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GREEN}  🎉 KALI MASTER FRAMEWORK v${VERSION} — READY FOR ACTION! 🎉${RESET}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${DIM}Thank you for using Kali Master Framework!${RESET}"
    echo -e "  ${DIM}Happy hacking! 🚀${RESET}"
    echo ""
}

# ============================================================
# Argument parsing (Professional Edition)
# ============================================================

