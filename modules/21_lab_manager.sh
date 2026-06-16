#!/usr/bin/env bash
# modules/21_lab_manager.sh

do_lab_manager() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 21/${STEP_TOTAL} — INTERACTIVE LAB MANAGER${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Lab Manager — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # Lab counts (must be defined before heredoc)
    local WEB_COUNT=10
    local API_COUNT=3
    local AD_COUNT=3
    local NET_COUNT=3
    local MOBILE_COUNT=3
    local CLOUD_COUNT=3
    local CTF_COUNT=3
    local RE_COUNT=2
    local TOTAL_LABS=$((WEB_COUNT + API_COUNT + AD_COUNT + NET_COUNT + MOBILE_COUNT + CLOUD_COUNT + CTF_COUNT + RE_COUNT))
    
    # ========================================================
    # Phase 1: Create Main Lab Manager Script
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/4] CREATING LAB MANAGER SCRIPT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ -x "${LOCAL_BIN}/lab-manager" ]]; then
        info "Lab manager already exists — updating..."
    fi
    
    cat > "${LOCAL_BIN}/lab-manager" << 'LAB_MGR'
#!/usr/bin/env bash
# ============================================================
#  LAB-MANAGER — Professional Offensive Docker Lab Manager
#  Version: 2.0
#  Features: 30+ labs, port management, status dashboard,
#            credential display, quick access, logs viewer
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly BLUE='\033[0;34m'; readonly RESET='\033[0m'

readonly VERSION="2.0"
readonly CONFIG_DIR="$HOME/.config/lab-manager"
readonly CUSTOM_LABS_FILE="$CONFIG_DIR/custom_labs.conf"

# ============================================================
# Lab Definitions (Categorized)
# ============================================================
# Format: "name|image|host_port:container_port|category|credentials|description"

# Web Vulnerabilities
readonly WEB_LABS=(
    "dvwa|vulnerables/web-dvwa|8080:80|web|admin:password|Damn Vulnerable Web Application"
    "webgoat|webgoat/webgoat|8081:8080|web|guest:guest|WebGoat OWASP Training"
    "juice-shop|bkimminich/juice-shop|3000:3000|web|admin@juice-sh.op:admin123|OWASP Juice Shop"
    "bwapp|raesene/bwapp|8082:80|web|bee:bug|bWAPP - Buggy Web App"
    "mutillidae|webpwnized/mutillidae|8083:80|web|admin:admin|OWASP Mutillidae II"
    "nodegoat|owasp/nodegoat|4000:4000|web|admin:admin|OWASP NodeGoat"
    "railsgoat|owasp/railsgoat|3001:3000|web|ken@owasp.org:ken123|OWASP RailsGoat"
    "crapi|owasp/crapi|8888:8888|web|user@example.com:Admin123#|Completely Ridiculous API"
    "dvgraphql|dolevf/dvgraphql|5013:5013|web|admin:password|Damn Vulnerable GraphQL"
    "wavsep|raesene/wavsep|8084:8080|web|admin:password|Web Application Vulnerability Scanner"
)

# API Security
readonly API_LABS=(
    "vapi|roottusk/vapi|8085:80|api|admin:password|Vulnerable API (vAPI)"
    "dvws|interference-security/dvws|8086:8080|api|admin:password|Damn Vulnerable Web Sockets"
    "rest-goat|owasp/rest-goat|8087:8080|api|admin:password|OWASP REST Goat"
)

# Active Directory
readonly AD_LABS=(
    "metasploit|metasploitframework/metasploit-framework|host:host|ad|msf:msf|Metasploit Framework"
    "vulnad|frankferrari/vulnad|host:host|ad|admin:Password1|Vulnerable Active Directory"
    "samba-vuln|dperson/samba|445:445|ad|admin:password|Vulnerable Samba Server"
)

# Network Security
readonly NET_LABS=(
    "pfsense|jasonrivers/nagios|8088:80|network|nagiosadmin:nagios|Nagios Network Monitor"
    "elk|sebp/elk|5601:5601|network|elastic:changeme|ELK Stack (SIEM)"
    "security-ninja|opensecurity/security-ninja|8089:80|network|admin:admin|Security Ninja Lab"
)

# Mobile Security
readonly MOBILE_LABS=(
    "insecurebank|dineshshetty/insecurebankv2|9999:8080|mobile|dinesh:Welcome@123|InsecureBankv2"
    "diva|mwlck/diva|8090:8080|mobile|admin:admin|DIVA - Mobile App"
    "uncrackable|owasp/mstg-uncrackable|8091:8080|mobile|admin:admin|OWASP UnCrackable"
)

# Cloud Security
readonly CLOUD_LABS=(
    "localstack|localstack/localstack|4566:4566|cloud|aws:aws|LocalStack (AWS Mock)"
    "cloudgoat|rhinosecuritylabs/cloudgoat|5000:5000|cloud|admin:admin|CloudGoat AWS Vuln"
    "kube-vuln|vulnerables/cve-2018-1002105|8092:80|cloud|admin:admin|Kubernetes Vulnerable"
)

# CTF / Wargames
readonly CTF_LABS=(
    "hackthebox-skeleton|hackthebox/skeleton|8093:80|ctf|admin:admin|HTB-style Challenge"
    "pwnable|pwncollege/pwnable|8094:80|ctf|admin:admin|Pwnable Challenge"
    "crypto-hack|cryptohack/crypto-hack|8095:80|ctf|admin:admin|CryptoHack Challenges"
)

# Reverse Engineering
readonly RE_LABS=(
    "malware-traffic|malwarestraffic/malware-traffic|8096:80|re|admin:admin|Malware Traffic Analysis"
    "flaws|flaws/flaws.cloud|8097:80|re|admin:admin|flAWS.cloud Challenge"
)

# ============================================================
# Combine all labs
# ============================================================
ALL_LABS=("${WEB_LABS[@]}" "${API_LABS[@]}" "${AD_LABS[@]}" "${NET_LABS[@]}" "${MOBILE_LABS[@]}" "${CLOUD_LABS[@]}" "${CTF_LABS[@]}" "${RE_LABS[@]}")

# ============================================================
# Helpers
# ============================================================
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*"; }
fail() { echo -e "  ${RED}[✗]${RESET} $*"; }
info() { echo -e "  ${CYAN}[*]${RESET} $*"; }
warn() { echo -e "  ${YELLOW}[!]${RESET} $*"; }

# ============================================================
# Check if port is in use
# ============================================================
is_port_in_use() {
    local port=$1
    ss -tlnp 2>/dev/null | grep -q ":${port} " && return 0
    netstat -tlnp 2>/dev/null | grep -q ":${port} " && return 0
    return 1
}

# ============================================================
# Find free port
# ============================================================
find_free_port() {
    local preferred=$1
    if ! is_port_in_use "$preferred"; then
        echo "$preferred"
        return 0
    fi
    
    for port in $(seq $((preferred+1)) $((preferred+100))); do
        if ! is_port_in_use "$port"; then
            echo "$port"
            return 0
        fi
    done
    return 1
}

# ============================================================
# Parse lab info
# ============================================================
parse_lab() {
    local lab_def="$1"
    IFS='|' read -r LAB_NAME LAB_IMAGE LAB_PORTS LAB_CATEGORY LAB_CREDS LAB_DESC <<< "$lab_def"
}

# ============================================================
# Get lab by name
# ============================================================
get_lab() {
    local name="$1"
    for lab in "${ALL_LABS[@]}"; do
        parse_lab "$lab"
        if [[ "$LAB_NAME" == "$name" ]]; then
            echo "$lab"
            return 0
        fi
    done
    return 1
}

# ============================================================
# Get container status
# ============================================================
get_container_status() {
    local name="$1"
    docker ps -a --filter "name=^${name}$" --format "{{.Status}}" 2>/dev/null
}

# ============================================================
# Start a lab
# ============================================================
start_lab() {
    local name="$1"
    local lab_def
    lab_def=$(get_lab "$name")
    
    if [[ -z "$lab_def" ]]; then
        fail "Lab not found: $name"
        return 1
    fi
    
    parse_lab "$lab_def"
    
    # Check if already running
    local status
    status=$(get_container_status "$name")
    if [[ "$status" == *"Up"* ]]; then
        warn "$name is already running"
        return 0
    fi
    
    # Remove if exists
    docker rm -f "$name" >/dev/null 2>&1
    
    # Check port availability
    local host_port="${LAB_PORTS%%:*}"
    local container_port="${LAB_PORTS#*:}"
    
    if [[ "$host_port" != "host" ]]; then
        if is_port_in_use "$host_port"; then
            warn "Port $host_port is in use, finding alternative..."
            local new_port
            new_port=$(find_free_port "$host_port")
            if [[ -n "$new_port" ]]; then
                host_port="$new_port"
                info "Using port $host_port instead"
            else
                fail "No free port available"
                return 1
            fi
        fi
    fi
    
    # Pull image if not exists
    if ! docker image inspect "$LAB_IMAGE" >/dev/null 2>&1; then
        info "Pulling image: $LAB_IMAGE"
        docker pull "$LAB_IMAGE" >> /dev/null 2>&1 || {
            fail "Failed to pull image: $LAB_IMAGE"
            return 1
        }
    fi
    
    # Start container
    info "Starting $name ($LAB_DESC)..."
    
    if [[ "$host_port" == "host" ]]; then
        docker run -d --name "$name" --network host "$LAB_IMAGE" >/dev/null 2>&1
    else
        docker run -d --name "$name" -p "${host_port}:${container_port}" "$LAB_IMAGE" >/dev/null 2>&1
    fi
    
    # Wait for container to start
    sleep 2
    
    # Verify
    status=$(get_container_status "$name")
    if [[ "$status" == *"Up"* ]]; then
        echo ""
        echo -e "  ${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
        echo -e "  ${BOLD}${GREEN}  LAB STARTED SUCCESSFULLY${RESET}"
        echo -e "  ${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "  ${BOLD}Name:${RESET}        $name"
        echo -e "  ${BOLD}Description:${RESET} $LAB_DESC"
        echo -e "  ${BOLD}Category:${RESET}    $LAB_CATEGORY"
        echo -e "  ${BOLD}Image:${RESET}       $LAB_IMAGE"
        
        if [[ "$host_port" == "host" ]]; then
            echo -e "  ${BOLD}Network:${RESET}     host mode"
        else
            echo -e "  ${BOLD}Port:${RESET}        $host_port → $container_port"
            echo -e "  ${BOLD}URL:${RESET}         ${CYAN}http://localhost:${host_port}${RESET}"
        fi
        
        if [[ -n "$LAB_CREDS" ]]; then
            local user="${LAB_CREDS%%:*}"
            local pass="${LAB_CREDS#*:}"
            echo -e "  ${BOLD}Username:${RESET}    $user"
            echo -e "  ${BOLD}Password:${RESET}    $pass"
        fi
        
        echo ""
        echo -e "  ${BOLD}Useful Commands:${RESET}"
        echo -e "    ${DIM}lab-manager logs $name${RESET}"
        echo -e "    ${DIM}lab-manager shell $name${RESET}"
        echo -e "    ${DIM}lab-manager stop $name${RESET}"
        echo ""
        ok "$name is running"
        return 0
    else
        fail "Failed to start $name"
        return 1
    fi
}

# ============================================================
# Stop a lab
# ============================================================
stop_lab() {
    local name="$1"
    
    if [[ "$name" == "all" ]]; then
        info "Stopping all labs..."
        for lab in "${ALL_LABS[@]}"; do
            parse_lab "$lab"
            docker stop "$LAB_NAME" >/dev/null 2>&1 && \
            docker rm "$LAB_NAME" >/dev/null 2>&1 && \
            ok "Stopped $LAB_NAME" || true
        done
        return 0
    fi
    
    local status
    status=$(get_container_status "$name")
    
    if [[ -z "$status" ]]; then
        warn "$name is not running"
        return 0
    fi
    
    info "Stopping $name..."
    docker stop "$name" >/dev/null 2>&1
    docker rm "$name" >/dev/null 2>&1
    ok "$name stopped and removed"
}

# ============================================================
# Show lab status
# ============================================================
show_status() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}       OFFENSIVE LAB MANAGER — STATUS DASHBOARD${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local running=0 stopped=0 total=0
    
    # Group by category
    local categories=("web" "api" "ad" "network" "mobile" "cloud" "ctf" "re")
    local cat_names=("Web Vulnerabilities" "API Security" "Active Directory" "Network Security" "Mobile Security" "Cloud Security" "CTF / Wargames" "Reverse Engineering")
    
    for i in "${!categories[@]}"; do
        local cat="${categories[$i]}"
        local cat_name="${cat_names[$i]}"
        local cat_labs=()
        
        for lab in "${ALL_LABS[@]}"; do
            parse_lab "$lab"
            if [[ "$LAB_CATEGORY" == "$cat" ]]; then
                cat_labs+=("$lab")
            fi
        done
        
        [[ ${#cat_labs[@]} -eq 0 ]] && continue
        
        echo -e "  ${BOLD}${CYAN}[$cat_name]${RESET}"
        
        for lab in "${cat_labs[@]}"; do
            parse_lab "$lab"
            ((total++))
            
            local status
            status=$(get_container_status "$LAB_NAME")
            
            local status_icon
            local status_text
            
            if [[ "$status" == *"Up"* ]]; then
                status_icon="${GREEN}●${RESET}"
                status_text="${GREEN}running${RESET}"
                ((running++))
            elif [[ -n "$status" ]]; then
                status_icon="${RED}●${RESET}"
                status_text="${RED}stopped${RESET}"
                ((stopped++))
            else
                status_icon="${DIM}○${RESET}"
                status_text="${DIM}not created${RESET}"
                ((stopped++))
            fi
            
            local host_port="${LAB_PORTS%%:*}"
            local url_info=""
            if [[ "$host_port" != "host" ]]; then
                url_info=" ${DIM}→ http://localhost:${host_port}${RESET}"
            fi
            
            printf "    %b %-20b %b%b\n" "$status_icon" "$LAB_NAME" "$status_text" "$url_info"
        done
        echo ""
    done
    
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "  ${BOLD}Summary:${RESET} ${GREEN}$running running${RESET} | ${RED}$stopped stopped${RESET} | $total total"
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================
# Show lab details
# ============================================================
show_details() {
    local name="$1"
    local lab_def
    lab_def=$(get_lab "$name")
    
    if [[ -z "$lab_def" ]]; then
        fail "Lab not found: $name"
        return 1
    fi
    
    parse_lab "$lab_def"
    
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  LAB DETAILS — ${LAB_NAME^^}${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Name:${RESET}        $LAB_NAME"
    echo -e "  ${BOLD}Description:${RESET} $LAB_DESC"
    echo -e "  ${BOLD}Category:${RESET}    $LAB_CATEGORY"
    echo -e "  ${BOLD}Image:${RESET}       $LAB_IMAGE"
    echo -e "  ${BOLD}Ports:${RESET}       $LAB_PORTS"
    
    if [[ -n "$LAB_CREDS" ]]; then
        local user="${LAB_CREDS%%:*}"
        local pass="${LAB_CREDS#*:}"
        echo -e "  ${BOLD}Username:${RESET}    $user"
        echo -e "  ${BOLD}Password:${RESET}    $pass"
    fi
    
    echo ""
    
    local status
    status=$(get_container_status "$LAB_NAME")
    
    if [[ "$status" == *"Up"* ]]; then
        echo -e "  ${BOLD}Status:${RESET}      ${GREEN}Running${RESET}"
        echo -e "  ${BOLD}Uptime:${RESET}      $status"
        
        local host_port="${LAB_PORTS%%:*}"
        if [[ "$host_port" != "host" ]]; then
            echo -e "  ${BOLD}URL:${RESET}         ${CYAN}http://localhost:${host_port}${RESET}"
        fi
        
        echo ""
        echo -e "  ${BOLD}${CYAN}Commands:${RESET}"
        echo -e "    ${DIM}lab-manager logs $LAB_NAME${RESET}"
        echo -e "    ${DIM}lab-manager shell $LAB_NAME${RESET}"
        echo -e "    ${DIM}lab-manager stop $LAB_NAME${RESET}"
    else
        echo -e "  ${BOLD}Status:${RESET}      ${RED}Not Running${RESET}"
        echo ""
        echo -e "  ${BOLD}Start with:${RESET}"
        echo -e "    ${DIM}lab-manager start $LAB_NAME${RESET}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================
# View logs
# ============================================================
view_logs() {
    local name="$1"
    local lines="${2:-50}"
    
    local status
    status=$(get_container_status "$name")
    
    if [[ -z "$status" ]]; then
        fail "$name is not running"
        return 1
    fi
    
    echo -e "${BOLD}${CYAN}[*]${RESET} Logs for $name (last $lines lines):"
    echo -e "${DIM}────────────────────────────────────────────────────────${RESET}"
    docker logs --tail "$lines" "$name" 2>&1
    echo -e "${DIM}────────────────────────────────────────────────────────${RESET}"
}

# ============================================================
# Shell access
# ============================================================
shell_access() {
    local name="$1"
    
    local status
    status=$(get_container_status "$name")
    
    if [[ "$status" != *"Up"* ]]; then
        fail "$name is not running"
        return 1
    fi
    
    info "Opening shell in $name..."
    docker exec -it "$name" /bin/bash 2>/dev/null || \
    docker exec -it "$name" /bin/sh 2>/dev/null || \
    fail "Failed to open shell"
}

# ============================================================
# List all labs
# ============================================================
list_labs() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}       ALL AVAILABLE LABS${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    printf "  ${BOLD}%-20s %-15s %-10s %s${RESET}\n" "NAME" "CATEGORY" "PORT" "DESCRIPTION"
    echo -e "  ${DIM}────────────────────────────────────────────────────────────────────────────────${RESET}"
    
    for lab in "${ALL_LABS[@]}"; do
        parse_lab "$lab"
        local host_port="${LAB_PORTS%%:*}"
        [[ "$host_port" == "host" ]] && host_port="host"
        
        printf "  %-20b %-15b %-10b %s\n" \
            "$LAB_NAME" \
            "$LAB_CATEGORY" \
            "$host_port" \
            "${LAB_DESC:0:40}"
    done
    
    echo ""
    echo -e "  ${BOLD}Total:${RESET} ${#ALL_LABS[@]} labs available"
    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================
# Banner
# ============================================================
banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   OFFENSIVE DOCKER LAB MANAGER v2.0                   ║
  ║   30+ Vulnerable Labs • Port Management • Dashboard   ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

# ============================================================
# Interactive Menu
# ============================================================
interactive_menu() {
    while true; do
        banner
        
        # Count running labs
        local running=0
        for lab in "${ALL_LABS[@]}"; do
            parse_lab "$lab"
            local status
            status=$(get_container_status "$LAB_NAME")
            [[ "$status" == *"Up"* ]] && ((running++))
        done
        
        echo -e "  ${BOLD}Status:${RESET} ${GREEN}$running running${RESET} | ${#ALL_LABS[@]} total"
        echo ""
        
        echo -e "  ${BOLD}${CYAN}[LABS]${RESET}"
        echo -e "    ${GREEN}1)${RESET} Web Vulnerabilities      ${DIM}(DVWA, WebGoat, Juice Shop...)${RESET}"
        echo -e "    ${GREEN}2)${RESET} API Security             ${DIM}(vAPI, DVWS, REST Goat...)${RESET}"
        echo -e "    ${GREEN}3)${RESET} Active Directory         ${DIM}(Metasploit, VulnAD...)${RESET}"
        echo -e "    ${GREEN}4)${RESET} Network Security         ${DIM}(Nagios, ELK...)${RESET}"
        echo -e "    ${GREEN}5)${RESET} Mobile Security          ${DIM}(InsecureBank, DIVA...)${RESET}"
        echo -e "    ${GREEN}6)${RESET} Cloud Security           ${DIM}(LocalStack, CloudGoat...)${RESET}"
        echo -e "    ${GREEN}7)${RESET} CTF / Wargames           ${DIM}(HTB-style, Pwnable...)${RESET}"
        echo -e "    ${GREEN}8)${RESET} Reverse Engineering      ${DIM}(Malware Traffic, flAWS...)${RESET}"
        echo ""
        
        echo -e "  ${BOLD}${CYAN}[MANAGEMENT]${RESET}"
        echo -e "    ${YELLOW}9)${RESET} Status Dashboard"
        echo -e "    ${YELLOW}10)${RESET} List All Labs"
        echo -e "    ${YELLOW}11)${RESET} Start Specific Lab"
        echo -e "    ${YELLOW}12)${RESET} Stop Specific Lab"
        echo -e "    ${YELLOW}13)${RESET} View Lab Logs"
        echo -e "    ${YELLOW}14)${RESET} Shell Access"
        echo -e "    ${YELLOW}15)${RESET} Stop ALL Labs"
        echo ""
        echo -e "    ${RED}0)${RESET} Exit"
        echo ""
        
        read -p "  Select [0-15]: " choice
        
        case $choice in
            1) show_category_menu "web" "Web Vulnerabilities" "${WEB_LABS[@]}" ;;
            2) show_category_menu "api" "API Security" "${API_LABS[@]}" ;;
            3) show_category_menu "ad" "Active Directory" "${AD_LABS[@]}" ;;
            4) show_category_menu "network" "Network Security" "${NET_LABS[@]}" ;;
            5) show_category_menu "mobile" "Mobile Security" "${MOBILE_LABS[@]}" ;;
            6) show_category_menu "cloud" "Cloud Security" "${CLOUD_LABS[@]}" ;;
            7) show_category_menu "ctf" "CTF / Wargames" "${CTF_LABS[@]}" ;;
            8) show_category_menu "re" "Reverse Engineering" "${RE_LABS[@]}" ;;
            9) show_status ;;
            10) list_labs ;;
            11)
                read -p "  Lab name: " lab_name
                start_lab "$lab_name"
                read -p "Press Enter..."
                ;;
            12)
                read -p "  Lab name: " lab_name
                stop_lab "$lab_name"
                read -p "Press Enter..."
                ;;
            13)
                read -p "  Lab name: " lab_name
                view_logs "$lab_name"
                read -p "Press Enter..."
                ;;
            14)
                read -p "  Lab name: " lab_name
                shell_access "$lab_name"
                read -p "Press Enter..."
                ;;
            15)
                echo ""
                read -p "  ${RED}Stop ALL labs? [y/N]:${RESET} " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    stop_lab "all"
                fi
                read -p "Press Enter..."
                ;;
            0)
                echo -e "  ${DIM}Exiting...${RESET}"
                exit 0
                ;;
            *)
                warn "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

# ============================================================
# Category Menu
# ============================================================
show_category_menu() {
    local cat="$1"
    local cat_name="$2"
    shift 2
    local labs=("$@")
    
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  $cat_name${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local i=1
    for lab in "${labs[@]}"; do
        parse_lab "$lab"
        local status
        status=$(get_container_status "$LAB_NAME")
        
        local status_icon
        if [[ "$status" == *"Up"* ]]; then
            status_icon="${GREEN}●${RESET}"
        elif [[ -n "$status" ]]; then
            status_icon="${RED}●${RESET}"
        else
            status_icon="${DIM}○${RESET}"
        fi
        
        local host_port="${LAB_PORTS%%:*}"
        local url_info=""
        [[ "$host_port" != "host" ]] && url_info=" ${DIM}→ :${host_port}${RESET}"
        
        printf "  %b ${GREEN}%2d)${RESET} %-20b %b%b\n" \
            "$status_icon" "$i" "$LAB_NAME" "${LAB_DESC:0:35}" "$url_info"
        
        ((i++))
    done
    
    echo ""
    echo -e "  ${DIM}Legend: ${GREEN}●${RESET} running | ${RED}●${RESET} stopped | ${DIM}○${RESET} not created${RESET}"
    echo ""
    
    read -p "  Select lab [1-$((i-1))] or 'b' to go back: " lab_choice
    
    if [[ "$lab_choice" == "b" ]] || [[ "$lab_choice" == "B" ]]; then
        return
    fi
    
    if [[ "$lab_choice" =~ ^[0-9]+$ ]] && [[ "$lab_choice" -ge 1 ]] && [[ "$lab_choice" -lt "$i" ]]; then
        local selected_lab="${labs[$((lab_choice-1))]}"
        parse_lab "$selected_lab"
        
        echo ""
        echo -e "  ${BOLD}Action for ${LAB_NAME}:${RESET}"
        echo -e "    ${GREEN}1)${RESET} Start"
        echo -e "    ${RED}2)${RESET} Stop"
        echo -e "    ${YELLOW}3)${RESET} View Details"
        echo -e "    ${YELLOW}4)${RESET} View Logs"
        echo -e "    ${YELLOW}5)${RESET} Shell Access"
        echo -e "    ${DIM}b)${RESET} Back"
        echo ""
        
        read -p "  Select: " action
        
        case $action in
            1) start_lab "$LAB_NAME"; read -p "Press Enter..." ;;
            2) stop_lab "$LAB_NAME"; read -p "Press Enter..." ;;
            3) show_details "$LAB_NAME" ;;
            4) view_logs "$LAB_NAME"; read -p "Press Enter..." ;;
            5) shell_access "$LAB_NAME"; read -p "Press Enter..." ;;
        esac
    fi
}

# ============================================================
# Usage
# ============================================================
usage() {
    echo -e "${BOLD}Usage:${RESET} lab-manager [command] [args]"
    echo ""
    echo -e "${BOLD}Commands:${RESET}"
    echo -e "  ${CYAN}start <lab>${RESET}       Start a specific lab"
    echo -e "  ${CYAN}stop <lab>${RESET}        Stop a specific lab (use 'all' for all)"
    echo -e "  ${CYAN}status${RESET}            Show status dashboard"
    echo -e "  ${CYAN}list${RESET}              List all available labs"
    echo -e "  ${CYAN}details <lab>${RESET}     Show lab details"
    echo -e "  ${CYAN}logs <lab> [lines]${RESET} View lab logs"
    echo -e "  ${CYAN}shell <lab>${RESET}       Open shell in lab"
    echo -e "  ${CYAN}menu${RESET}              Interactive menu (default)"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  lab-manager"
    echo -e "  lab-manager start dvwa"
    echo -e "  lab-manager stop all"
    echo -e "  lab-manager logs webgoat 100"
    echo ""
    echo -e "${BOLD}Available Labs:${RESET}"
    for lab in "${ALL_LABS[@]}"; do
        parse_lab "$lab"
        echo -e "  ${DIM}•${RESET} $LAB_NAME ${DIM}($LAB_CATEGORY)${RESET}"
    done
}

# ============================================================
# Main
# ============================================================
main() {
    local command="${1:-menu}"
    shift || true
    
    case "$command" in
        start)
            [[ -z "${1:-}" ]] && { usage; exit 1; }
            start_lab "$1"
            ;;
        stop)
            [[ -z "${1:-}" ]] && { usage; exit 1; }
            stop_lab "$1"
            ;;
        status)
            show_status
            ;;
        list)
            list_labs
            ;;
        details)
            [[ -z "${1:-}" ]] && { usage; exit 1; }
            show_details "$1"
            ;;
        logs)
            [[ -z "${1:-}" ]] && { usage; exit 1; }
            view_logs "$1" "${2:-50}"
            ;;
        shell)
            [[ -z "${1:-}" ]] && { usage; exit 1; }
            shell_access "$1"
            ;;
        menu)
            interactive_menu
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            fail "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
LAB_MGR
    
    chmod +x "${LOCAL_BIN}/lab-manager"
    
    if [[ -x "${LOCAL_BIN}/lab-manager" ]]; then
        echo -e "    ${GREEN}✔${RESET} lab-manager ${DIM}[created - ${TOTAL_LABS} labs in 8 categories]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} lab-manager ${DIM}[creation failed]${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Create Quick Start Scripts
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/4] CREATING QUICK START SCRIPTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # start-lab
    if [[ -x "${LOCAL_BIN}/start-lab" ]]; then
        echo -e "    ${GREEN}✔${RESET} start-lab ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    else
        cat > "${LOCAL_BIN}/start-lab" << 'EOF'
#!/usr/bin/env bash
# Quick start wrapper
if [[ -z "${1:-}" ]]; then
    exec lab-manager menu
else
    exec lab-manager start "$@"
fi
EOF
        chmod +x "${LOCAL_BIN}/start-lab"
        echo -e "    ${GREEN}✔${RESET} start-lab ${DIM}[created]${RESET}"
        ((total_installed++))
    fi
    
    # stop-lab
    if [[ -x "${LOCAL_BIN}/stop-lab" ]]; then
        echo -e "    ${GREEN}✔${RESET} stop-lab ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    else
        cat > "${LOCAL_BIN}/stop-lab" << 'EOF'
#!/usr/bin/env bash
# Quick stop wrapper
if [[ -z "${1:-}" ]]; then
    exec lab-manager stop all
else
    exec lab-manager stop "$@"
fi
EOF
        chmod +x "${LOCAL_BIN}/stop-lab"
        echo -e "    ${GREEN}✔${RESET} stop-lab ${DIM}[created]${RESET}"
        ((total_installed++))
    fi
    
    # lab-status
    if [[ -x "${LOCAL_BIN}/lab-status" ]]; then
        echo -e "    ${GREEN}✔${RESET} lab-status ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    else
        cat > "${LOCAL_BIN}/lab-status" << 'EOF'
#!/usr/bin/env bash
exec lab-manager status "$@"
EOF
        chmod +x "${LOCAL_BIN}/lab-status"
        echo -e "    ${GREEN}✔${RESET} lab-status ${DIM}[created]${RESET}"
        ((total_installed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Docker Integration Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/4] DOCKER INTEGRATION CHECK${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if command -v docker &>/dev/null; then
        if docker info &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} Docker is running${RESET}"
            ((total_installed++))
        else
            echo -e "    ${YELLOW}!${RESET} Docker installed but not running${RESET}"
            echo -e "    ${DIM}Start with: sudo systemctl start docker${RESET}"
        fi
        
        # Count existing containers
        local container_count
        container_count=$(docker ps -a --format "{{.Names}}" 2>/dev/null | wc -l)
        info "Existing containers: $container_count"
        
        # Count existing images
        local image_count
        image_count=$(docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | wc -l)
        info "Existing images: $image_count"
    else
        echo -e "    ${RED}✗${RESET} Docker not installed${RESET}"
        echo -e "    ${DIM}Install with: kali-master --step docker --force${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Verification
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/4] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local verified=0
    local total_checks=4
    
    # Check lab-manager
    if [[ -x "${LOCAL_BIN}/lab-manager" ]]; then
        echo -e "    ${GREEN}✔${RESET} lab-manager executable"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} lab-manager not executable"
    fi
    
    # Check start-lab
    if [[ -x "${LOCAL_BIN}/start-lab" ]]; then
        echo -e "    ${GREEN}✔${RESET} start-lab executable"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} start-lab not executable"
    fi
    
    # Check stop-lab
    if [[ -x "${LOCAL_BIN}/stop-lab" ]]; then
        echo -e "    ${GREEN}✔${RESET} stop-lab executable"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} stop-lab not executable"
    fi
    
    # Check lab-status
    if [[ -x "${LOCAL_BIN}/lab-status" ]]; then
        echo -e "    ${GREEN}✔${RESET} lab-status executable"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} lab-status not executable"
    fi
    
    ok "Lab Manager verified: $verified/$total_checks"
    
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
    echo -e "${BOLD}${MAGENTA}  LAB MANAGER SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} components"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} components"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} components"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 components"
    fi
    
    echo ""
    echo -e "  ${BOLD}Lab Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Web Vulnerabilities: ${WEB_COUNT} labs (DVWA, WebGoat, Juice Shop...)"
    echo -e "    ${GREEN}●${RESET} API Security: ${API_COUNT} labs (vAPI, DVWS, REST Goat)"
    echo -e "    ${GREEN}●${RESET} Active Directory: ${AD_COUNT} labs (Metasploit, VulnAD, Samba)"
    echo -e "    ${GREEN}●${RESET} Network Security: ${NET_COUNT} labs (Nagios, ELK, Security Ninja)"
    echo -e "    ${GREEN}●${RESET} Mobile Security: ${MOBILE_COUNT} labs (InsecureBank, DIVA, UnCrackable)"
    echo -e "    ${GREEN}●${RESET} Cloud Security: ${CLOUD_COUNT} labs (LocalStack, CloudGoat, Kube-vuln)"
    echo -e "    ${GREEN}●${RESET} CTF / Wargames: ${CTF_COUNT} labs (HTB-style, Pwnable, CryptoHack)"
    echo -e "    ${GREEN}●${RESET} Reverse Engineering: ${RE_COUNT} labs (Malware Traffic, flAWS)"
    echo ""
    echo -e "  ${BOLD}Total:${RESET} ${TOTAL_LABS} vulnerable labs available"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed to install"
        info "Check log: ${LOG_FILE}"
    else
        ok "Lab Manager ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}lab-manager${RESET}              ${DIM}→ Interactive menu${RESET}"
    echo -e "    ${CYAN}lab-manager start dvwa${RESET}   ${DIM}→ Start DVWA${RESET}"
    echo -e "    ${CYAN}lab-manager start webgoat${RESET} ${DIM}→ Start WebGoat${RESET}"
    echo -e "    ${CYAN}lab-manager status${RESET}       ${DIM}→ Status dashboard${RESET}"
    echo -e "    ${CYAN}lab-manager list${RESET}         ${DIM}→ List all labs${RESET}"
    echo -e "    ${CYAN}lab-manager logs dvwa${RESET}    ${DIM}→ View DVWA logs${RESET}"
    echo -e "    ${CYAN}lab-manager shell dvwa${RESET}   ${DIM}→ Shell into DVWA${RESET}"
    echo -e "    ${CYAN}lab-manager stop all${RESET}     ${DIM}→ Stop all labs${RESET}"
    echo -e "    ${CYAN}start-lab dvwa${RESET}           ${DIM}→ Quick start DVWA${RESET}"
    echo -e "    ${CYAN}stop-lab dvwa${RESET}            ${DIM}→ Quick stop DVWA${RESET}"
    echo -e "    ${CYAN}lab-status${RESET}               ${DIM}→ Quick status check${RESET}"
    echo ""
}

# ============================================================
# STEP 22 — C2 Menu (Professional Edition)
# ============================================================
