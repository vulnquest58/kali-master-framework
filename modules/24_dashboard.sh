#!/usr/bin/env bash
# modules/24_dashboard.sh

do_dashboard() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 24/${STEP_TOTAL} — PROFESSIONAL DASHBOARD${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    
    # ========================================================
    # Phase 1: Create Dashboard Script
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/3] CREATING DASHBOARD SCRIPT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    cat > "${LOCAL_BIN}/kali-master" << 'DASHBOARD'
#!/usr/bin/env bash
# ============================================================
#  KALI MASTER — Professional Dashboard v2.0
#  Features: System info, tools status, C2 frameworks,
#            venvs, labs, OPSEC, cloud tools
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly BLUE='\033[0;34m'; readonly RESET='\033[0m'

readonly VENV_DIR="/opt/kali-venv"
readonly ANGR_VENV="/opt/angr-venv"
readonly FLARE_VENV="/opt/flare-venv"

# ============================================================
# Helpers
# ============================================================
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*"; }
fail() { echo -e "  ${RED}[✗]${RESET} $*"; }
info() { echo -e "  ${CYAN}[*]${RESET} $*"; }

# Check tool with version
check_tool() {
    local tool="$1"
    local path
    
    if path=$(command -v "$tool" 2>/dev/null); then
        local version=""
        case "$tool" in
            nuclei|subfinder|httpx|dnsx|naabu|katana)
                version=$("$tool" -version 2>&1 | head -1 | grep -oP 'v[\d.]+' || echo "")
                ;;
            nmap)
                version=$(nmap --version 2>&1 | head -1 | grep -oP '[\d.]+')
                ;;
            python3)
                version=$(python3 --version 2>&1 | awk '{print $2}')
                ;;
            go)
                version=$(go version 2>&1 | awk '{print $3}' | sed 's/go//')
                ;;
            docker)
                version=$(docker --version 2>&1 | grep -oP '[\d.]+' | head -1)
                ;;
            git)
                version=$(git --version 2>&1 | awk '{print $3}')
                ;;
            *)
                version=$("$tool" --version 2>&1 | head -1 | grep -oP '[\d.]+' | head -1 || echo "")
                ;;
        esac
        
        if [[ -n "$version" ]]; then
            echo -e "  ${GREEN}[✔]${RESET} ${BOLD}$tool${RESET} ${DIM}→ $path${RESET}"
            echo -e "       ${DIM}Version: $version${RESET}"
        else
            echo -e "  ${GREEN}[✔]${RESET} ${BOLD}$tool${RESET} ${DIM}→ $path${RESET}"
        fi
        return 0
    else
        echo -e "  ${RED}[✗]${RESET} ${BOLD}$tool${RESET} ${DIM}[NOT FOUND]${RESET}"
        return 1
    fi
}

# ============================================================
# Banner
# ============================================================
show_banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   KALI MASTER FRAMEWORK — PROFESSIONAL DASHBOARD      ║
  ║   v6.7.0 • Bug Bounty • Red Team • C2 • Labs          ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

# ============================================================
# System Information
# ============================================================
show_system_info() {
    echo -e "${BOLD}${CYAN}[SYSTEM INFORMATION]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local os_name
    os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Unknown")
    echo -e "  ${BOLD}OS:${RESET}       $os_name"
    echo -e "  ${BOLD}Kernel:${RESET}   $(uname -r)"
    echo -e "  ${BOLD}Hostname:${RESET} $(hostname)"
    
    local cpu_info
    cpu_info=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "Unknown")
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || echo "?")
    echo -e "  ${BOLD}CPU:${RESET}      $cpu_info (${cpu_cores} cores)"
    
    local ram_total ram_used
    ram_total=$(free -h | awk '/^Mem:/{print $2}')
    ram_used=$(free -h | awk '/^Mem:/{print $3}')
    echo -e "  ${BOLD}RAM:${RESET}      ${ram_used} / ${ram_total}"
    
    local disk_info
    disk_info=$(df -h / 2>/dev/null | awk 'NR==2{print $3 " / " $2 " (" $5 " used)"}')
    echo -e "  ${BOLD}Disk:${RESET}     $disk_info"
    
    local ip_addr
    ip_addr=$(ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "N/A")
    echo -e "  ${BOLD}IP:${RESET}        $ip_addr"
    
    local uptime_info
    uptime_info=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Unknown")
    echo -e "  ${BOLD}Uptime:${RESET}   $uptime_info"
    
    echo ""
}

# ============================================================
# Status — Main Dashboard
# ============================================================
show_status() {
    show_banner
    show_system_info
    
    local total_tools=0
    local installed_tools=0
    local missing_tools=0
    
    # Bug Bounty Tools
    echo -e "${BOLD}${CYAN}[BUG BOUNTY TOOLS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local bb_tools=(
        "subfinder" "httpx" "nuclei" "dnsx" "naabu" "katana"
        "gobuster" "ffuf" "dalfox" "gau" "hakrawler" "trufflehog"
        "feroxbuster" "amass" "assetfinder" "waybackurls" "anew"
        "qsreplace" "gf" "httprobe" "notify" "interactsh-client"
        "tlsx" "alterx" "uncover" "cvemap" "mapcidr"
        "xsstrike" "corsy" "linkfinder" "sublist3r" "wfuzz"
    )
    
    for tool in "${bb_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    
    if [[ $missing_tools -gt 0 ]]; then
        echo -e "  ${YELLOW}[!]${RESET} ${DIM}$missing_tools tool(s) missing — run: kali-master fix${RESET}"
    fi
    echo ""
    
    # Network / Exploitation
    echo -e "${BOLD}${CYAN}[NETWORK / EXPLOITATION]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local net_tools=(
        "nmap" "masscan" "sqlmap" "hydra" "medusa"
        "crackmapexec" "evil-winrm" "netexec" "nxc"
        "responder" "bettercap" "ettercap"
    )
    
    for tool in "${net_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    echo ""
    
    # Reverse Engineering
    echo -e "${BOLD}${CYAN}[REVERSE ENGINEERING / MALWARE]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local re_tools=(
        "gdb" "radare2" "ghidra" "binwalk" "vol" "jadx" "apktool"
        "capa" "floss" "yara" "hashcat" "john" "checksec"
    )
    
    for tool in "${re_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    echo ""
    
    # C2 Frameworks
    echo -e "${BOLD}${CYAN}[RED TEAM C2 FRAMEWORKS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local c2_tools=(
        "sliver-server" "havoc" "mythic-cli" "covenant"
        "empire" "starkiller" "merlin" "nimplant"
    )
    
    for tool in "${c2_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    
    echo ""
    echo -e "  ${BOLD}C2 Directories:${RESET}"
    for dir in /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant; do
        if [[ -d "$dir" ]]; then
            echo -e "    ${GREEN}[✔]${RESET} $(basename $dir) ${DIM}→ $dir${RESET}"
        else
            echo -e "    ${RED}[✗]${RESET} $(basename $dir) ${DIM}[NOT CLONED]${RESET}"
        fi
    done
    echo ""
    
    # Cloud Security
    echo -e "${BOLD}${CYAN}[CLOUD / CONTAINER SECURITY]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local cloud_tools=(
        "kubectl" "aws" "trivy" "grype" "syft" "pacu" "cloudfox"
    )
    
    for tool in "${cloud_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    echo ""
    
    # Post-Exploitation
    echo -e "${BOLD}${CYAN}[POST-EXPLOITATION]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local postex_tools=(
        "chisel" "ligolo-proxy" "linpeas" "pspy64" "pe-server"
        "pe-transfer" "revshell" "postexploit-menu"
    )
    
    for tool in "${postex_tools[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    
    echo ""
    echo -e "  ${BOLD}Post-Exploit Files:${RESET}"
    for file in /opt/postexploit/linux/linpeas.sh /opt/postexploit/windows/winPEASx64.exe \
                /opt/postexploit/windows/mimikatz.exe /opt/postexploit/windows/Rubeus.exe; do
        if [[ -f "$file" ]]; then
            echo -e "    ${GREEN}[✔]${RESET} $(basename $file) ${DIM}→ $file${RESET}"
        else
            echo -e "    ${RED}[✗]${RESET} $(basename $file) ${DIM}[NOT DOWNLOADED]${RESET}"
        fi
    done
    echo ""
    
    # Runtimes
    echo -e "${BOLD}${CYAN}[RUNTIMES]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local runtimes=("python3" "go" "ruby" "node" "java" "rustc" "docker" "git")
    
    for tool in "${runtimes[@]}"; do
        ((total_tools++))
        if check_tool "$tool" >/dev/null 2>&1; then
            ((installed_tools++))
            check_tool "$tool"
        else
            ((missing_tools++))
        fi
    done
    echo ""
    
    # Summary
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}  STATISTICS${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Total Tools:${RESET}     $total_tools"
    echo -e "  ${GREEN}Installed:${RESET}       $installed_tools"
    echo -e "  ${RED}Missing:${RESET}         $missing_tools"
    
    local percentage=0
    if [[ $total_tools -gt 0 ]]; then
        percentage=$((installed_tools * 100 / total_tools))
    fi
    
    echo -e "  ${BOLD}Completion:${RESET}      ${GREEN}${percentage}%${RESET}"
    
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    echo -n "  ["
    for ((i=0; i<filled; i++)); do echo -n "${GREEN}█${RESET}"; done
    for ((i=0; i<empty; i++)); do echo -n "${DIM}░${RESET}"; done
    echo "]"
    echo ""
    
    if [[ $missing_tools -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}🎉 All tools are installed!${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}⚠ Run 'kali-master fix' to install missing tools${RESET}"
    fi
    echo ""
    
    # Quick Commands
    echo -e "${BOLD}${CYAN}[QUICK COMMANDS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${CYAN}kali-master status${RESET}      ${DIM}→ Show this dashboard${RESET}"
    echo -e "  ${CYAN}kali-master fix${RESET}         ${DIM}→ Install missing tools${RESET}"
    echo -e "  ${CYAN}kali-master tools${RESET}       ${DIM}→ List all installed tools${RESET}"
    echo -e "  ${CYAN}kali-master venvs${RESET}       ${DIM}→ Python environments info${RESET}"
    echo -e "  ${CYAN}kali-master labs${RESET}        ${DIM}→ Docker labs status${RESET}"
    echo -e "  ${CYAN}kali-master c2${RESET}          ${DIM}→ C2 frameworks info${RESET}"
    echo -e "  ${CYAN}kali-master opsec${RESET}       ${DIM}→ OPSEC tools status${RESET}"
    echo -e "  ${CYAN}kali-master cloud${RESET}       ${DIM}→ Cloud tools info${RESET}"
    echo -e "  ${CYAN}kali-master certipy${RESET}     ${DIM}→ AD CS commands${RESET}"
    echo -e "  ${CYAN}kali-master evasion${RESET}     ${DIM}→ Evasion toolkit${RESET}"
    echo -e "  ${CYAN}kali-master postex${RESET}      ${DIM}→ Post-exploitation kit${RESET}"
    echo -e "  ${CYAN}c2-menu${RESET}                 ${DIM}→ Interactive C2 launcher${RESET}"
    echo -e "  ${CYAN}lab-manager${RESET}             ${DIM}→ Interactive lab manager${RESET}"
    echo -e "  ${CYAN}postexploit-menu${RESET}        ${DIM}→ Post-exploitation toolkit${RESET}"
    echo -e "  ${CYAN}update-tools${RESET}            ${DIM}→ Update all tools${RESET}"
    echo -e "  ${CYAN}bb-recon <domain>${RESET}       ${DIM}→ Bug bounty recon${RESET}"
    echo ""
}

# ============================================================
# Fix — Check Missing Tools
# ============================================================
show_fix() {
    show_banner
    echo -e "${BOLD}${CYAN}[CHECKING MISSING TOOLS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local tools=(
        "subfinder" "httpx" "nuclei" "dnsx" "naabu" "katana"
        "gobuster" "ffuf" "dalfox" "gau" "feroxbuster"
        "xsstrike" "corsy" "linkfinder" "sublist3r"
        "sliver-server" "havoc" "mythic-cli" "covenant"
        "empire" "starkiller" "merlin" "nimplant"
        "chisel" "linpeas" "pspy64"
        "aws" "kubectl" "kerbrute"
        "ghauri" "cloudfox" "gitleaks" "pacu" "certipy"
        "pe-server" "pe-transfer" "revshell"
    )
    
    local missing=0
    local missing_list=()
    
    for t in "${tools[@]}"; do
        if command -v "$t" &>/dev/null; then
            echo -e "  ${GREEN}[✔]${RESET} $t"
        else
            echo -e "  ${RED}[✗]${RESET} $t"
            ((missing++))
            missing_list+=("$t")
        fi
    done
    
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "  ${BOLD}Summary:${RESET} ${RED}$missing missing${RESET} out of ${#tools[@]} checked"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    if [[ $missing -gt 0 ]]; then
        echo -e "  ${YELLOW}Missing tools:${RESET}"
        for t in "${missing_list[@]}"; do
            echo -e "    ${DIM}• $t${RESET}"
        done
        echo ""
        echo -e "  ${CYAN}To install missing tools, run:${RESET}"
        echo -e "    ${BOLD}sudo ./kali-master.sh --fix${RESET}"
        echo ""
    else
        echo -e "  ${GREEN}${BOLD}🎉 All checked tools are installed!${RESET}"
        echo ""
    fi
}

# ============================================================
# Tools — List All Installed
# ============================================================
show_tools() {
    show_banner
    echo -e "${BOLD}${CYAN}[ALL INSTALLED TOOLS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local dirs=(
        "$HOME/go/bin"
        "/usr/local/bin"
        "$HOME/.cargo/bin"
        "${VENV_DIR}/bin"
        "/opt/tools/bin"
    )
    
    for dir in "${dirs[@]}"; do
        [[ -d "$dir" ]] || continue
        local count
        count=$(find "$dir" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
        
        echo -e "  ${BOLD}${YELLOW}[${dir}]${RESET} ${DIM}($count tools)${RESET}"
        find "$dir" -maxdepth 1 -type f -executable 2>/dev/null | sort | \
            while read -r t; do
                echo -e "    ${DIM}•${RESET} $(basename "$t")"
            done
        echo ""
    done
}

# ============================================================
# Venvs — Python Environments
# ============================================================
show_venvs() {
    show_banner
    echo -e "${BOLD}${CYAN}[PYTHON ENVIRONMENTS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local venvs=(
        "${VENV_DIR}|Main Offensive Venv"
        "${ANGR_VENV}|Angr (Binary Analysis)"
        "${FLARE_VENV}|FLARE (Capa + Floss)"
        "/opt/scoutsuite-venv|ScoutSuite (Cloud)"
    )
    
    for venv_info in "${venvs[@]}"; do
        IFS='|' read -r venv_path venv_name <<< "$venv_info"
        
        echo -e "  ${BOLD}${YELLOW}[${venv_name}]${RESET}"
        echo -e "    ${BOLD}Path:${RESET} $venv_path"
        
        if [[ -f "${venv_path}/bin/python3" ]]; then
            local py_version
            py_version=$("${venv_path}/bin/python3" --version 2>&1)
            echo -e "    ${BOLD}Python:${RESET} $py_version"
            
            local pkg_count
            pkg_count=$("${venv_path}/bin/pip" list 2>/dev/null | wc -l)
            echo -e "    ${BOLD}Packages:${RESET} $((pkg_count - 2))"
            
            echo -e "    ${BOLD}Key Packages:${RESET}"
            for pkg in pwntools impacket requests httpx cryptography beautifulsoup4 angr flare-capa; do
                if "${venv_path}/bin/pip" show "$pkg" &>/dev/null; then
                    local ver
                    ver=$("${venv_path}/bin/pip" show "$pkg" 2>/dev/null | grep Version | awk '{print $2}')
                    echo -e "      ${GREEN}✔${RESET} $pkg ($ver)"
                fi
            done
            
            echo -e "    ${GREEN}[✔] Active${RESET}"
        else
            echo -e "    ${RED}[✗] Not installed${RESET}"
        fi
        echo ""
    done
    
    echo -e "  ${DIM}Main venv auto-activates on every new terminal${RESET}"
    echo ""
}

# ============================================================
# Labs — Docker Labs Status
# ============================================================
show_labs() {
    show_banner
    echo -e "${BOLD}${CYAN}[DOCKER LABS STATUS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    if ! command -v docker &>/dev/null; then
        echo -e "  ${RED}[✗] Docker not installed${RESET}"
        echo ""
        return
    fi
    
    local running
    running=$(docker ps --format '{{.Names}}' 2>/dev/null)
    
    local labs=(
        "dvwa|8080|admin:password"
        "webgoat|8081|guest:guest"
        "juice-shop|3000|admin@juice-sh.op:admin123"
        "bwapp|8082|bee:bug"
        "mutillidae|8083|admin:admin"
        "metasploit|host|msf:msf"
    )
    
    for lab_info in "${labs[@]}"; do
        IFS='|' read -r name port creds <<< "$lab_info"
        
        if echo "$running" | grep -q "^${name}$"; then
            echo -e "  ${GREEN}[●]${RESET} ${BOLD}$name${RESET} ${GREEN}(running)${RESET}"
            if [[ "$port" != "host" ]]; then
                echo -e "       ${DIM}URL: http://localhost:${port}${RESET}"
            fi
            echo -e "       ${DIM}Creds: $creds${RESET}"
        else
            echo -e "  ${DIM}[○]${RESET} ${BOLD}$name${RESET} ${DIM}(stopped)${RESET}"
            echo -e "       ${DIM}Start: lab-manager start $name${RESET}"
        fi
        echo ""
    done
    
    echo -e "  ${BOLD}Commands:${RESET}"
    echo -e "    ${CYAN}lab-manager${RESET}          ${DIM}→ Interactive menu${RESET}"
    echo -e "    ${CYAN}lab-manager start dvwa${RESET} ${DIM}→ Start DVWA${RESET}"
    echo -e "    ${CYAN}lab-manager stop all${RESET}   ${DIM}→ Stop all labs${RESET}"
    echo ""
}

# ============================================================
# C2 — C2 Frameworks Info
# ============================================================
show_c2() {
    show_banner
    echo -e "${BOLD}${CYAN}[C2 FRAMEWORKS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local c2_frameworks=(
        "sliver-server|/usr/local/bin/sliver-server|31337|Modern multi-protocol C2"
        "havoc|/opt/Havoc/havoc|40056|Modern C2 with great UI"
        "mythic-cli|/opt/Mythic/mythic-cli|7443|Cross-platform C2 (Docker)"
        "covenant|/opt/Covenant/Covenant|7443|.NET-based C2"
        "empire|/opt/Empire/ps-empire|1337|Post-exploitation framework"
        "starkiller|/opt/Starkiller|4173|Empire GUI"
        "merlin|/opt/merlin/merlin-server|50051|HTTP/2 C2"
        "nimplant|/opt/NimPlant|31337|Nim-based beacon"
    )
    
    for c2_info in "${c2_frameworks[@]}"; do
        IFS='|' read -r name path port desc <<< "$c2_info"
        
        if command -v "$name" &>/dev/null || [[ -x "$path" ]]; then
            echo -e "  ${GREEN}[✔]${RESET} ${BOLD}$name${RESET}"
            echo -e "       ${DIM}$desc${RESET}"
            echo -e "       ${DIM}Port: $port${RESET}"
            if [[ -x "$path" ]]; then
                echo -e "       ${DIM}Path: $path${RESET}"
            fi
        else
            echo -e "  ${RED}[✗]${RESET} ${BOLD}$name${RESET} ${DIM}[NOT INSTALLED]${RESET}"
            echo -e "       ${DIM}$desc${RESET}"
        fi
        echo ""
    done
    
    echo -e "  ${BOLD}Commands:${RESET}"
    echo -e "    ${CYAN}c2-menu${RESET}              ${DIM}→ Interactive C2 launcher${RESET}"
    echo -e "    ${CYAN}sliver-server${RESET}        ${DIM}→ Start Sliver${RESET}"
    echo -e "    ${CYAN}havoc server${RESET}         ${DIM}→ Start Havoc${RESET}"
    echo -e "    ${CYAN}mythic-cli start${RESET}     ${DIM}→ Start Mythic${RESET}"
    echo ""
}

# ============================================================
# OPSEC — Operational Security
# ============================================================
show_opsec() {
    show_banner
    echo -e "${BOLD}${CYAN}[OPSEC STATUS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    echo -e "  ${BOLD}Redirectors:${RESET}"
    if command -v list-redirectors &>/dev/null; then
        list-redirectors 2>/dev/null || echo "    ${DIM}No redirectors configured${RESET}"
    else
        echo -e "    ${DIM}list-redirectors not installed${RESET}"
    fi
    echo ""
    
    echo -e "  ${BOLD}Proxy Configuration:${RESET}"
    if [[ -n "${http_proxy:-}" ]]; then
        echo -e "    ${GREEN}✔${RESET} HTTP Proxy: $http_proxy"
    else
        echo -e "    ${DIM}• No HTTP proxy configured${RESET}"
    fi
    
    if [[ -n "${https_proxy:-}" ]]; then
        echo -e "    ${GREEN}✔${RESET} HTTPS Proxy: $https_proxy"
    else
        echo -e "    ${DIM}• No HTTPS proxy configured${RESET}"
    fi
    
    if [[ -f /etc/proxychains4.conf ]]; then
        echo -e "    ${GREEN}✔${RESET} Proxychains config exists"
    else
        echo -e "    ${DIM}• Proxychains not configured${RESET}"
    fi
    echo ""
    
    echo -e "  ${BOLD}VPN Status:${RESET}"
    if ip addr show | grep -q "tun0\|tap0"; then
        local vpn_ip
        vpn_ip=$(ip addr show tun0 2>/dev/null | grep "inet " | awk '{print $2}')
        echo -e "    ${GREEN}✔${RESET} VPN Active: $vpn_ip"
    else
        echo -e "    ${YELLOW}!${RESET} No VPN detected"
    fi
    echo ""
    
    echo -e "  ${BOLD}Firewall Status:${RESET}"
    if command -v ufw &>/dev/null; then
        local ufw_status
        ufw_status=$(ufw status 2>/dev/null | head -1)
        echo -e "    ${CYAN}•${RESET} UFW: $ufw_status"
    fi
    
    if command -v iptables &>/dev/null; then
        local rules_count
        rules_count=$(iptables -L 2>/dev/null | wc -l)
        echo -e "    ${CYAN}•${RESET} iptables: $rules_count rules"
    fi
    echo ""
}

# ============================================================
# Cloud — Cloud Tools
# ============================================================
show_cloud() {
    show_banner
    echo -e "${BOLD}${CYAN}[CLOUD SECURITY TOOLS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    echo -e "  ${BOLD}AWS CLI:${RESET}"
    if command -v aws &>/dev/null; then
        local aws_ver
        aws_ver=$(aws --version 2>&1 | head -1)
        echo -e "    ${GREEN}[✔]${RESET} $aws_ver"
        
        if [[ -f "$HOME/.aws/credentials" ]]; then
            echo -e "    ${GREEN}✔${RESET} Credentials configured"
            local profiles
            profiles=$(aws configure list-profiles 2>/dev/null | wc -l)
            echo -e "    ${DIM}Profiles: $profiles${RESET}"
        else
            echo -e "    ${YELLOW}!${RESET} No credentials configured"
        fi
    else
        echo -e "    ${RED}[✗]${RESET} Not installed"
    fi
    echo ""
    
    echo -e "  ${BOLD}Kubernetes (kubectl):${RESET}"
    if command -v kubectl &>/dev/null; then
        local k8s_ver
        k8s_ver=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -1)
        echo -e "    ${GREEN}[✔]${RESET} $k8s_ver"
        
        if [[ -f "$HOME/.kube/config" ]]; then
            echo -e "    ${GREEN}✔${RESET} Kubeconfig exists"
            local contexts
            contexts=$(kubectl config get-contexts 2>/dev/null | wc -l)
            echo -e "    ${DIM}Contexts: $((contexts - 1))${RESET}"
        else
            echo -e "    ${YELLOW}!${RESET} No kubeconfig"
        fi
    else
        echo -e "    ${RED}[✗]${RESET} Not installed"
    fi
    echo ""
    
    echo -e "  ${BOLD}Cloud Assessment Tools:${RESET}"
    local cloud_tools=("pacu" "cloudfox" "trivy" "grype" "syft")
    
    for tool in "${cloud_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "    ${GREEN}[✔]${RESET} $tool"
        else
            echo -e "    ${RED}[✗]${RESET} $tool"
        fi
    done
    echo ""
    
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}aws configure${RESET}          ${DIM}→ Configure AWS credentials${RESET}"
    echo -e "    ${CYAN}pacu${RESET}                  ${DIM}→ Launch Pacu (AWS exploitation)${RESET}"
    echo -e "    ${CYAN}cloudfox aws${RESET}          ${DIM}→ Enumerate AWS environment${RESET}"
    echo -e "    ${CYAN}trivy image <image>${RESET}   ${DIM}→ Scan container image${RESET}"
    echo ""
}

# ============================================================
# Certipy — AD CS Commands
# ============================================================
show_certipy() {
    show_banner
    echo -e "${BOLD}${CYAN}[CERTIPY — AD CS ATTACKS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    if ! command -v certipy &>/dev/null; then
        echo -e "  ${RED}[✗] Certipy not installed${RESET}"
        echo -e "  ${DIM}Install: pip install certipy-ad${RESET}"
        echo ""
        return
    fi
    
    local certipy_ver
    certipy_ver=$(certipy --version 2>&1 | head -1 || echo "Unknown")
    echo -e "  ${GREEN}[✔]${RESET} Version: $certipy_ver"
    echo ""
    
    echo -e "  ${BOLD}Common Commands:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    echo -e "  ${BOLD}1. Find vulnerable templates:${RESET}"
    echo -e "    ${DIM}certipy find -u user@domain -p pass -dc-ip 10.0.0.1 -vulnerable -stdout${RESET}"
    echo ""
    
    echo -e "  ${BOLD}2. Request certificate:${RESET}"
    echo -e "    ${DIM}certipy req -u user@domain -p pass -ca CA-NAME -target 10.0.0.1 -template Template${RESET}"
    echo ""
    
    echo -e "  ${BOLD}3. Authenticate with certificate:${RESET}"
    echo -e "    ${DIM}certipy auth -pfx user.pfx -dc-ip 10.0.0.1 -domain domain${RESET}"
    echo ""
    
    echo -e "  ${BOLD}4. Get NT hash from certificate:${RESET}"
    echo -e "    ${DIM}certipy auth -pfx user.pfx -username user -domain domain -dc-ip 10.0.0.1${RESET}"
    echo ""
    
    echo -e "  ${BOLD}5. ESC1 Attack (Vulnerable Template):${RESET}"
    echo -e "    ${DIM}certipy req -u user@domain -p pass -ca CA-NAME -target dc.domain.local -template VulnTemplate -upn admin@domain${RESET}"
    echo ""
    
    echo -e "  ${BOLD}6. ESC4 Attack (Write Permissions):${RESET}"
    echo -e "    ${DIM}certipy template -u user@domain -p pass -template VulnTemplate -save-old${RESET}"
    echo ""
    
    echo -e "  ${BOLD}7. ESC6 Attack (EDITF_ATTRIBUTESUBJECTALTNAME2):${RESET}"
    echo -e "    ${DIM}certipy req -u user@domain -p pass -ca CA-NAME -target dc -template User -upn admin@domain${RESET}"
    echo ""
}

# ============================================================
# Evasion — Evasion Tools Menu
# ============================================================
show_evasion() {
    if command -v evasion-menu &>/dev/null; then
        evasion-menu
    else
        show_banner
        echo -e "${BOLD}${CYAN}[EVASION TOOLS]${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        echo ""
        
        local evasion_tools=(
            "sgn|Shikata Ga Nai - Encoder"
            "donut|Donut - Shellcode Generator"
            "scarecrow|Scarecrow - EDR Bypass"
            "freeze|Freeze - Payload Generator"
        )
        
        for tool_info in "${evasion_tools[@]}"; do
            IFS='|' read -r name desc <<< "$tool_info"
            
            if command -v "$name" &>/dev/null; then
                echo -e "  ${GREEN}[✔]${RESET} ${BOLD}$name${RESET}"
                echo -e "       ${DIM}$desc${RESET}"
            else
                echo -e "  ${RED}[✗]${RESET} ${BOLD}$name${RESET}"
                echo -e "       ${DIM}$desc${RESET}"
            fi
            echo ""
        done
        
        echo -e "  ${BOLD}Commands:${RESET}"
        echo -e "    ${CYAN}sgn <binary>${RESET}              ${DIM}→ Encode binary${RESET}"
        echo -e "    ${CYAN}donut -f <exe>${RESET}            ${DIM}→ Generate shellcode${RESET}"
        echo -e "    ${CYAN}scarecrow -loader=...${RESET}     ${DIM}→ EDR bypass${RESET}"
        echo ""
    fi
}

# ============================================================
# Post-Exploitation
# ============================================================
show_postex() {
    if command -v postexploit-menu &>/dev/null; then
        postexploit-menu
    else
        show_banner
        echo -e "${BOLD}${CYAN}[POST-EXPLOITATION TOOLKIT]${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        echo ""
        
        echo -e "  ${BOLD}HTTP Server:${RESET}"
        check_tool "pe-server"
        check_tool "pe-transfer"
        echo ""
        
        echo -e "  ${BOLD}Linux Tools:${RESET}"
        check_tool "linpeas"
        check_tool "pspy64"
        check_tool "linux-exploit-suggester"
        echo ""
        
        echo -e "  ${BOLD}Windows Tools:${RESET}"
        for f in /opt/postexploit/windows/*.exe; do
            [[ -f "$f" ]] && echo -e "  ${GREEN}[✔]${RESET} $(basename $f) ${DIM}→ $f${RESET}"
        done
        echo ""
        
        echo -e "  ${BOLD}Tunneling:${RESET}"
        check_tool "chisel"
        check_tool "ligolo-proxy"
        echo ""
        
        echo -e "  ${BOLD}Reverse Shell:${RESET}"
        check_tool "revshell"
        echo ""
    fi
}

# ============================================================
# Main
# ============================================================
case "${1:-status}" in
    status)     show_status ;;
    fix)        show_fix ;;
    tools)      show_tools ;;
    venvs)      show_venvs ;;
    labs)       show_labs ;;
    c2)         show_c2 ;;
    opsec)      show_opsec ;;
    cloud)      show_cloud ;;
    certipy)    show_certipy ;;
    evasion)    show_evasion ;;
    postex)     show_postex ;;
    help|--help|-h)
        echo -e "${BOLD}Usage:${RESET} kali-master [command]"
        echo ""
        echo -e "${BOLD}Commands:${RESET}"
        echo -e "  ${CYAN}status${RESET}     Show full dashboard (default)"
        echo -e "  ${CYAN}fix${RESET}        Check missing tools"
        echo -e "  ${CYAN}tools${RESET}      List all installed tools"
        echo -e "  ${CYAN}venvs${RESET}      Python environments info"
        echo -e "  ${CYAN}labs${RESET}       Docker labs status"
        echo -e "  ${CYAN}c2${RESET}         C2 frameworks info"
        echo -e "  ${CYAN}opsec${RESET}      OPSEC status"
        echo -e "  ${CYAN}cloud${RESET}      Cloud tools info"
        echo -e "  ${CYAN}certipy${RESET}    Certipy AD CS commands"
        echo -e "  ${CYAN}evasion${RESET}    Evasion tools"
        echo -e "  ${CYAN}postex${RESET}     Post-exploitation toolkit"
        echo ""
        ;;
    *)
        echo -e "${RED}[✗]${RESET} Unknown command: $1"
        echo -e "${DIM}Run: kali-master help${RESET}"
        exit 1
        ;;
esac
DASHBOARD
    
    chmod +x "${LOCAL_BIN}/kali-master"
    
    if [[ -x "${LOCAL_BIN}/kali-master" ]]; then
        echo -e "    ${GREEN}✔${RESET} kali-master ${DIM}[created - 11 commands]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} kali-master ${DIM}[creation failed]${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Verification
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/3] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ -x "${LOCAL_BIN}/kali-master" ]]; then
        echo -e "    ${GREEN}✔${RESET} kali-master executable"
    else
        echo -e "    ${RED}✗${RESET} kali-master not executable"
    fi
    
    # Test help command
    if "${LOCAL_BIN}/kali-master" help &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kali-master help works"
    else
        echo -e "    ${RED}✗${RESET} kali-master help failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  DASHBOARD SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}$((step_duration / 60))m $((step_duration % 60))s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} components"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} components"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 components"
    fi
    
    echo ""
    echo -e "  ${BOLD}Dashboard Commands:${RESET}"
    echo -e "    ${GREEN}●${RESET} status     — Full dashboard with system info"
    echo -e "    ${GREEN}●${RESET} fix        — Check missing tools"
    echo -e "    ${GREEN}●${RESET} tools      — List all installed tools"
    echo -e "    ${GREEN}●${RESET} venvs      — Python environments info"
    echo -e "    ${GREEN}●${RESET} labs       — Docker labs status"
    echo -e "    ${GREEN}●${RESET} c2         — C2 frameworks info"
    echo -e "    ${GREEN}●${RESET} opsec      — OPSEC status"
    echo -e "    ${GREEN}●${RESET} cloud      — Cloud tools info"
    echo -e "    ${GREEN}●${RESET} certipy    — Certipy AD CS commands"
    echo -e "    ${GREEN}●${RESET} evasion    — Evasion tools"
    echo -e "    ${GREEN}●${RESET} postex     — Post-exploitation toolkit"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed"
        info "Check log: ${LOG_FILE}"
    else
        ok "Dashboard ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}kali-master${RESET}              ${DIM}→ Show full dashboard${RESET}"
    echo -e "    ${CYAN}kali-master status${RESET}       ${DIM}→ Show status${RESET}"
    echo -e "    ${CYAN}kali-master fix${RESET}          ${DIM}→ Check missing tools${RESET}"
    echo -e "    ${CYAN}kali-master tools${RESET}        ${DIM}→ List all tools${RESET}"
    echo -e "    ${CYAN}kali-master venvs${RESET}        ${DIM}→ Python venvs info${RESET}"
    echo -e "    ${CYAN}kali-master labs${RESET}         ${DIM}→ Docker labs status${RESET}"
    echo -e "    ${CYAN}kali-master c2${RESET}           ${DIM}→ C2 frameworks info${RESET}"
    echo -e "    ${CYAN}kali-master opsec${RESET}        ${DIM}→ OPSEC status${RESET}"
    echo -e "    ${CYAN}kali-master cloud${RESET}        ${DIM}→ Cloud tools info${RESET}"
    echo -e "    ${CYAN}kali-master help${RESET}         ${DIM}→ Show help${RESET}"
    echo ""
}

# ============================================================
# Quick Tool Status Check (Professional Edition)
# ============================================================
check_tools_status() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  TOOL STATUS CHECK${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    
    # ========================================================
    # Parse Arguments
    # ========================================================
    local mode="${1:-all}"  # all, critical, missing, category
    
    case "$mode" in
        --help|-h)
            echo -e "${BOLD}Usage:${RESET} check_tools_status [mode]"
            echo ""
            echo -e "${BOLD}Modes:${RESET}"
            echo -e "  ${CYAN}all${RESET}       Check all tools (default)"
            echo -e "  ${CYAN}critical${RESET}  Check only critical tools"
            echo -e "  ${CYAN}missing${RESET}   Show only missing tools"
            echo -e "  ${CYAN}bugbounty${RESET} Check Bug Bounty tools"
            echo -e "  ${CYAN}network${RESET}   Check Network/AD tools"
            echo -e "  ${CYAN}cloud${RESET}     Check Cloud tools"
            echo -e "  ${CYAN}postex${RESET}    Check Post-Exploitation tools"
            echo ""
            return 0
            ;;
    esac
    
    # ========================================================
    # Phase 1: Initialize Tool Map
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/4] INITIALIZING TOOL DATABASE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # ============================================================
    # Smart Tool Finder (Corrected & Optimized)
    # ============================================================
    smart_find_tool() {
        local tool="$1"
        
        # 1. Exact match in PATH
        if command -v "$tool" &>/dev/null; then
            command -v "$tool"
            return 0
        fi
        
        # 2. Search in all known paths (case-insensitive)
        for search_path in "${SEARCH_PATHS[@]}"; do
            [[ -d "$search_path" ]] || continue
            
            # Exact match
            if [[ -x "${search_path}/${tool}" ]]; then
                echo "${search_path}/${tool}"
                return 0
            fi
            
            # Case-insensitive match
            local found
            found=$(find "$search_path" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
            if [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        done
        
        # 3. Deep search in tools directory
        if [[ -d "$TOOLS_DIR" ]]; then
            local found
            found=$(find "$TOOLS_DIR" -maxdepth 5 -type f -executable -iname "$tool" 2>/dev/null | head -1)
            if [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        fi
        
        # 4. Search in Python venvs
        for venv_base in "$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV"; do
            if [[ -d "${venv_base}/bin" ]]; then
                local found
                found=$(find "${venv_base}/bin" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
                if [[ -n "$found" ]]; then
                    echo "$found"
                    return 0
                fi
            fi
        done  # ✅ تم التصحيح هنا: كانت `fi` وأصبحت `done`
        
        # 5. Search in Go bin
        if [[ -d "$GOPATH_BIN" ]]; then
            local found
            found=$(find "$GOPATH_BIN" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
            if [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        fi
        
        # 6. Search in Cargo bin
        if [[ -d "$CARGO_BIN" ]]; then
            local found
            found=$(find "$CARGO_BIN" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
            if [[ -n "$found" ]]; then
                echo "$found"
                return 0
            fi
        fi
        
        return 1
    }
    
    # Comprehensive Tool Map with Categories
    declare -A TOOL_INSTALL_MAP=(
        # Bug Bounty - ProjectDiscovery
        ["subfinder"]="go|bugbounty|github.com/projectdiscovery/subfinder/v2/cmd/subfinder|subfinder"
        ["httpx"]="go|bugbounty|github.com/projectdiscovery/httpx/cmd/httpx|httpx"
        ["nuclei"]="go|bugbounty|github.com/projectdiscovery/nuclei/v3/cmd/nuclei|nuclei"
        ["dnsx"]="go|bugbounty|github.com/projectdiscovery/dnsx/cmd/dnsx|dnsx"
        ["naabu"]="go|bugbounty|github.com/projectdiscovery/naabu/v2/cmd/naabu|naabu"
        ["katana"]="go|bugbounty|github.com/projectdiscovery/katana/cmd/katana|katana"
        ["interactsh-client"]="go|bugbounty|github.com/projectdiscovery/interactsh/cmd/interactsh-client|interactsh-client"
        ["notify"]="go|bugbounty|github.com/projectdiscovery/notify/cmd/notify|notify"
        ["mapcidr"]="go|bugbounty|github.com/projectdiscovery/mapcidr/cmd/mapcidr|mapcidr"
        ["tlsx"]="go|bugbounty|github.com/projectdiscovery/tlsx/cmd/tlsx|tlsx"
        ["shuffledns"]="go|bugbounty|github.com/projectdiscovery/shuffledns/cmd/shuffledns|shuffledns"
        ["asnmap"]="go|bugbounty|github.com/projectdiscovery/asnmap/cmd/asnmap|asnmap"
        ["alterx"]="go|bugbounty|github.com/projectdiscovery/alterx/cmd/alterx|alterx"
        ["uncover"]="go|bugbounty|github.com/projectdiscovery/uncover/cmd/uncover|uncover"
        ["cvemap"]="go|bugbounty|github.com/projectdiscovery/cvemap/cmd/cvemap|cvemap"
        ["pdtm"]="go|bugbounty|github.com/projectdiscovery/pdtm/cmd/pdtm|pdtm"
        ["cloudlist"]="go|bugbounty|github.com/projectdiscovery/cloudlist/cmd/cloudlist|cloudlist"
        ["proxify"]="go|bugbounty|github.com/projectdiscovery/proxify/cmd/proxify|proxify"
        
        # Bug Bounty - Other Go Tools
        ["dalfox"]="go|bugbounty|github.com/hahwul/dalfox/v2|dalfox"
        ["gobuster"]="go|bugbounty|github.com/OJ/gobuster/v3|gobuster"
        ["ffuf"]="go|bugbounty|github.com/ffuf/ffuf/v2|ffuf"
        ["trufflehog"]="go|bugbounty|github.com/trufflesecurity/trufflehog/v3|trufflehog"
        ["gau"]="go|bugbounty|github.com/lc/gau/v2/cmd/gau|gau"
        ["hakrawler"]="go|bugbounty|github.com/hakluke/hakrawler|hakrawler"
        ["anew"]="go|bugbounty|github.com/tomnomnom/anew|anew"
        ["qsreplace"]="go|bugbounty|github.com/tomnomnom/qsreplace|qsreplace"
        ["gf"]="go|bugbounty|github.com/tomnomnom/gf|gf"
        ["waybackurls"]="go|bugbounty|github.com/tomnomnom/waybackurls|waybackurls"
        ["assetfinder"]="go|bugbounty|github.com/tomnomnom/assetfinder|assetfinder"
        ["httprobe"]="go|bugbounty|github.com/tomnomnom/httprobe|httprobe"
        ["meg"]="go|bugbounty|github.com/tomnomnom/meg|meg"
        ["unfurl"]="go|bugbounty|github.com/tomnomnom/unfurl|unfurl"
        ["gospider"]="go|bugbounty|github.com/jaeles-project/gospider|gospider"
        ["gron"]="go|bugbounty|github.com/tomnomnom/gron|gron"
        ["dsieve"]="go|bugbounty|github.com/trickest/dsieve|dsieve"
        ["getJS"]="go|bugbounty|github.com/003random/getJS|getJS"
        ["subjs"]="go|bugbounty|github.com/lc/subjs|subjs"
        ["chisel"]="go|bugbounty|github.com/jpillora/chisel|chisel"
        ["kerbrute"]="go|bugbounty|github.com/ropnop/kerbrute|kerbrute"
        ["ghauri"]="go|bugbounty|github.com/r0oth3x49/ghauri|ghauri"
        ["cloudfox"]="go|bugbounty|github.com/BishopFox/cloudfox|cloudfox"
        ["gitleaks"]="go|bugbounty|github.com/gitleaks/gitleaks|gitleaks"
        ["windapsearch"]="go|bugbounty|github.com/ropnop/go-windapsearch|windapsearch"
        ["freeze"]="go|bugbounty|github.com/optiv/Freeze|freeze"
        
        # Bug Bounty - Cargo
        ["feroxbuster"]="cargo|bugbounty|feroxbuster"
        
        # Bug Bounty - Python GitHub
        ["xsstrike"]="pygithub|bugbounty||https://github.com/s0md3v/XSStrike.git|xsstrike.py"
        ["corsy"]="pygithub|bugbounty||https://github.com/s0md3v/Corsy.git|corsy.py"
        ["linkfinder"]="pygithub|bugbounty||https://github.com/GerbenJavado/LinkFinder.git|linkfinder.py"
        ["ssrfmap"]="pygithub|bugbounty||https://github.com/swisskyrepo/SSRFmap.git|ssrfmap.py"
        ["jwt_tool"]="pygithub|bugbounty||https://github.com/ticarpi/jwt_tool.git|jwt_tool.py"
        ["sublist3r"]="pip|bugbounty|sublist3r"
        ["arjun"]="pip|bugbounty|arjun"
        ["waymore"]="pip|bugbounty|waymore"
        ["dnsgen"]="pip|bugbounty|dnsgen"
        ["dirsearch"]="pip|bugbounty|dirsearch"
        ["commix"]="pip|bugbounty|commix"
        
        # Bug Bounty - APT
        ["sqlmap"]="apt|bugbounty|sqlmap"
        ["amass"]="apt|bugbounty|amass"
        ["whatweb"]="apt|bugbounty|whatweb"
        ["dirb"]="apt|bugbounty|dirb"
        ["nikto"]="apt|bugbounty|nikto"
        ["wpscan"]="apt|bugbounty|wpscan"
        
        # Network / AD
        ["crackmapexec"]="apt|network|crackmapexec"
        ["evil-winrm"]="apt|network|evil-winrm"
        ["bloodhound"]="apt|network|bloodhound"
        ["neo4j"]="apt|network|neo4j"
        ["smbclient"]="apt|network|smbclient"
        ["smbmap"]="apt|network|smbmap"
        ["enum4linux"]="apt|network|enum4linux"
        ["responder"]="apt|network|responder"
        ["netexec"]="apt|network|netexec"
        ["nxc"]="apt|network|netexec"
        ["ettercap-text-only"]="apt|network|ettercap-text-only"
        ["bettercap"]="apt|network|bettercap"
        
        # RE / Malware
        ["gdb"]="apt|network|gdb"
        ["radare2"]="apt|network|radare2"
        ["ghidra"]="apt|network|ghidra"
        ["binwalk"]="apt|network|binwalk"
        ["vol"]="pip|network|volatility3"
        ["vol3"]="pip|network|volatility3"
        ["capa"]="pip|network|flare-capa"
        ["floss"]="pip|network|flare-floss"
        ["jadx"]="apt|network|jadx"
        ["apktool"]="apt|network|apktool"
        ["yara"]="apt|network|yara"
        ["hashcat"]="apt|network|hashcat"
        ["john"]="apt|network|john"
        ["hydra"]="apt|network|hydra"
        ["medusa"]="apt|network|medusa"
        ["nmap"]="apt|network|nmap"
        ["masscan"]="apt|network|masscan"
        
        # Cloud / Container
        ["kubectl"]="binary|cloud|https://dl.k8s.io/release/stable.txt|kubectl"
        ["aws"]="binary|cloud|https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip|aws"
        ["trivy"]="github|cloud|aquasecurity/trivy|Linux-64bit.tar.gz|trivy"
        ["grype"]="github|cloud|anchore/grype|linux_amd64.tar.gz|grype"
        ["syft"]="github|cloud|anchore/syft|linux_amd64.tar.gz|syft"
        
        # C2 Frameworks
        ["sliver-server"]="binary|c2|https://sliver.sh/install|sliver-server"
        ["havoc"]="binary|c2|/opt/Havoc/havoc|havoc"
        ["mythic-cli"]="binary|c2|/opt/Mythic/mythic-cli|mythic-cli"
        ["covenant"]="binary|c2|/usr/local/bin/covenant|covenant"
        ["empire"]="binary|c2|/usr/local/bin/empire|empire"
        ["starkiller"]="binary|c2|/usr/local/bin/starkiller|starkiller"
        ["merlin"]="binary|c2|/usr/local/bin/merlin|merlin"
        ["nimplant"]="binary|c2|/usr/local/bin/nimplant|nimplant"
        
        # Post-Exploitation
        ["linpeas"]="curl|postex|https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh"
        ["pspy64"]="curl|postex|https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64"
        ["pspy32"]="curl|postex|https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32"
        
        # System Tools
        ["certbot"]="apt|system|certbot"
        ["docker"]="apt|system|docker.io"
        ["git"]="apt|system|git"
        ["curl"]="apt|system|curl"
        ["wget"]="apt|system|wget"
    )
    
    local total_tools=${#TOOL_INSTALL_MAP[@]}
    echo -e "    ${GREEN}✔${RESET} Tool database loaded"
    echo -e "    ${DIM}• $total_tools tools configured${RESET}"
    echo -e "    ${DIM}• 7 categories${RESET}"
    echo -e "    ${DIM}• Mode: ${CYAN}${mode}${RESET}"
    
    echo ""
    
    # ========================================================
    # Phase 2: Filter Tools by Mode
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/4] FILTERING TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local tools_to_check=()
    
    case "$mode" in
        all)
            tools_to_check=("${!TOOL_INSTALL_MAP[@]}")
            echo -e "    ${GREEN}✔${RESET} Checking all ${total_tools} tools"
            ;;
        critical)
            local critical_tools=("nuclei" "subfinder" "httpx" "sliver-server" "kubectl" "aws" "docker" "git" "python3" "go")
            tools_to_check=("${critical_tools[@]}")
            echo -e "    ${GREEN}✔${RESET} Checking ${#critical_tools[@]} critical tools"
            ;;
        missing)
            # First pass - find missing
            for tool in "${!TOOL_INSTALL_MAP[@]}"; do
                if ! smart_find_tool "$tool" &>/dev/null; then
                    tools_to_check+=("$tool")
                fi
            done
            echo -e "    ${GREEN}✔${RESET} Found ${#tools_to_check[@]} missing tools"
            ;;
        bugbounty|network|cloud|postex|c2|system)
            for tool in "${!TOOL_INSTALL_MAP[@]}"; do
                local info="${TOOL_INSTALL_MAP[$tool]}"
                local category
                category=$(echo "$info" | cut -d'|' -f2)
                if [[ "$category" == "$mode" ]]; then
                    tools_to_check+=("$tool")
                fi
            done
            echo -e "    ${GREEN}✔${RESET} Checking ${#tools_to_check[@]} ${mode} tools"
            ;;
        *)
            warn "Unknown mode: $mode"
            tools_to_check=("${!TOOL_INSTALL_MAP[@]}")
            ;;
    esac
    
    # Sort tools
    IFS=$'\n' sorted_tools=($(sort <<<"${tools_to_check[*]}")); unset IFS
    
    echo ""
    
    # ========================================================
    # Phase 3: Check Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/4] CHECKING TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local total=0
    local found=0
    local missing_count=0
    local missing_tools=()
    local found_tools=()
    
    # Group by category for display
    declare -A category_stats
    
    for tool in "${sorted_tools[@]}"; do
        ((total++))
        
        local info="${TOOL_INSTALL_MAP[$tool]}"
        local category
        category=$(echo "$info" | cut -d'|' -f2)
        
        local tool_path
        tool_path=$(smart_find_tool "$tool")
        
        if [[ -n "$tool_path" ]]; then
            ((found++))
            found_tools+=("$tool|$tool_path|$category")
            
            # Update category stats
            local cat_found=${category_stats["${category}_found"]:-0}
            category_stats["${category}_found"]=$((cat_found + 1))
        else
            ((missing_count++))
            missing_tools+=("$tool|$category")
            
            # Update category stats
            local cat_missing=${category_stats["${category}_missing"]:-0}
            category_stats["${category}_missing"]=$((cat_missing + 1))
        fi
        
        # Progress bar
        local progress=$((total * 100 / ${#sorted_tools[@]}))
        printf "\r  ${DIM}Progress: ${RESET}["
        local filled=$((progress / 2))
        local empty=$((50 - filled))
        for ((i=0; i<filled; i++)); do printf "${GREEN}█${RESET}"; done
        for ((i=0; i<empty; i++)); do printf "${DIM}░${RESET}"; done
        printf "] ${progress}%%"
    done
    echo ""
    echo ""
    
    # ========================================================
    # Phase 4: Display Results
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/4] RESULTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Show found tools
    if [[ ${#found_tools[@]} -gt 0 ]]; then
        echo -e "  ${BOLD}${GREEN}INSTALLED TOOLS (${#found_tools[@]})${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        for entry in "${found_tools[@]}"; do
            IFS='|' read -r tool path category <<< "$entry"
            echo -e "    ${GREEN}✔${RESET} ${tool} ${DIM}→ ${path}${RESET}"
        done
        echo ""
    fi
    
    # Show missing tools
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "  ${BOLD}${RED}MISSING TOOLS (${#missing_tools[@]})${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        for entry in "${missing_tools[@]}"; do
            IFS='|' read -r tool category <<< "$entry"
            echo -e "    ${RED}✗${RESET} ${tool} ${DIM}[${category}]${RESET}"
        done
        echo ""
    fi
    
    # Category breakdown
    echo -e "  ${BOLD}${CYAN}CATEGORY BREAKDOWN${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local categories=("bugbounty" "network" "cloud" "c2" "postex" "system")
    local cat_names=("Bug Bounty" "Network/AD" "Cloud" "C2 Frameworks" "Post-Exploitation" "System")
    
    for i in "${!categories[@]}"; do
        local cat="${categories[$i]}"
        local cat_name="${cat_names[$i]}"
        local cat_found=${category_stats["${cat}_found"]:-0}
        local cat_missing=${category_stats["${cat}_missing"]:-0}
        local cat_total=$((cat_found + cat_missing))
        
        if [[ $cat_total -gt 0 ]]; then
            local percentage=0
            [[ $cat_total -gt 0 ]] && percentage=$((cat_found * 100 / cat_total))
            
            local status_icon
            if [[ $cat_missing -eq 0 ]]; then
                status_icon="${GREEN}✔${RESET}"
            elif [[ $cat_found -eq 0 ]]; then
                status_icon="${RED}✗${RESET}"
            else
                status_icon="${YELLOW}!${RESET}"
            fi
            
            echo -e "    $status_icon ${cat_name}: ${GREEN}${cat_found}${RESET}/${cat_total} ${DIM}(${percentage}%)${RESET}"
        fi
    done
    
    echo ""
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  TOOL STATUS CHECK COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}$((step_duration / 60))m $((step_duration % 60))s${RESET}"
    echo -e "  ${BOLD}Mode:${RESET}           ${CYAN}${mode}${RESET}"
    echo -e "  ${BOLD}Total Checked:${RESET}  ${total} tools"
    echo -e "  ${GREEN}Found:${RESET}          ${found} tools"
    
    if [[ $missing_count -gt 0 ]]; then
        echo -e "  ${RED}Missing:${RESET}        ${missing_count} tools"
    else
        echo -e "  ${GREEN}Missing:${RESET}        0 tools"
    fi
    
    echo ""
    
    # Overall status
    local overall_percentage=0
    [[ $total -gt 0 ]] && overall_percentage=$((found * 100 / total))
    
    echo -e "  ${BOLD}Overall Status:${RESET}"
    echo -n "    ["
    local filled=$((overall_percentage / 2))
    local empty=$((50 - filled))
    for ((i=0; i<filled; i++)); do echo -ne "${GREEN}█${RESET}"; done
    for ((i=0; i<empty; i++)); do echo -ne "${DIM}░${RESET}"; done
    echo -e "] ${overall_percentage}%"
    echo ""
    
    if [[ $missing_count -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}🎉 All tools are installed!${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}⚠ ${missing_count} tool(s) missing${RESET}"
        echo ""
        echo -e "  ${BOLD}To fix missing tools:${RESET}"
        echo -e "    ${CYAN}./kali-master.sh --fix${RESET}     ${DIM}→ Fix all missing${RESET}"
        echo -e "    ${CYAN}kali-master --fix${RESET}                 ${DIM}→ Alternative command${RESET}"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}check_tools_status${RESET}              ${DIM}→ Check all tools${RESET}"
    echo -e "    ${CYAN}check_tools_status critical${RESET}     ${DIM}→ Check critical only${RESET}"
    echo -e "    ${CYAN}check_tools_status missing${RESET}      ${DIM}→ Show missing only${RESET}"
    echo -e "    ${CYAN}check_tools_status bugbounty${RESET}    ${DIM}→ Check Bug Bounty tools${RESET}"
    echo -e "    ${CYAN}check_tools_status network${RESET}      ${DIM}→ Check Network tools${RESET}"
    echo -e "    ${CYAN}check_tools_status cloud${RESET}        ${DIM}→ Check Cloud tools${RESET}"
    echo -e "    ${CYAN}check_tools_status c2${RESET}           ${DIM}→ Check C2 frameworks${RESET}"
    echo -e "    ${CYAN}check_tools_status postex${RESET}       ${DIM}→ Check Post-Exploitation${RESET}"
    echo ""
}

# ============================================================
# Final Health Check (Professional Edition)
# ============================================================
