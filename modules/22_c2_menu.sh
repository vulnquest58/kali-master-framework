#!/usr/bin/env bash
# modules/22_c2_menu.sh

do_c2_menu() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 22/${STEP_TOTAL} — C2 INTERACTIVE MENU${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    
    # ========================================================
    # Phase 1: Create C2 Menu Script
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/3] CREATING C2 MENU SCRIPT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    cat > /usr/local/bin/c2-menu << 'C2MENU'
#!/usr/bin/env bash
# ============================================================
#  C2-MENU — Professional C2 Framework Launcher
#  Version: 2.0
#  Features: 8 C2 frameworks, status dashboard, connection info
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly BLUE='\033[0;34m'; readonly RESET='\033[0m'

readonly VERSION="2.0"

# ============================================================
# C2 Framework Definitions
# ============================================================
declare -A C2_INFO=(
    ["sliver"]="Sliver|Modern multi-protocol C2|sliver-server|31337|https://github.com/BishopFox/sliver"
    ["havoc"]="Havoc|Modern C2 with great UI|havoc|40056|https://github.com/HavocFramework/Havoc"
    ["mythic"]="Mythic|Cross-platform C2 (Docker)|mythic-cli|7443|https://github.com/its-a-feature/Mythic"
    ["covenant"]="Covenant|.NET-based C2|covenant|7443|https://github.com/cobbr/Covenant"
    ["empire"]="Empire|Post-exploitation framework|empire|1337|https://github.com/BC-SECURITY/Empire"
    ["starkiller"]="Starkiller|Empire GUI|starkiller|4173|https://github.com/BC-SECURITY/Starkiller"
    ["merlin"]="Merlin|HTTP/2 C2|merlin|50051|https://github.com/Ne0nd0g/merlin"
    ["nimplant"]="NimPlant|Nim-based beacon|nimplant|31337|https://github.com/chvancooten/NimPlant"
)

# ============================================================
# Helpers
# ============================================================
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*"; }
fail() { echo -e "  ${RED}[✗]${RESET} $*"; }
info() { echo -e "  ${CYAN}[*]${RESET} $*"; }
warn() { echo -e "  ${YELLOW}[!]${RESET} $*"; }

# ============================================================
# Check if command exists
# ============================================================
check_cmd() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        local path
        path=$(command -v "$cmd")
        echo -e "  ${GREEN}[✔]${RESET} $cmd ${DIM}→ $path${RESET}"
        return 0
    else
        echo -e "  ${RED}[✗]${RESET} $cmd"
        return 1
    fi
}

# ============================================================
# Check if port is in use
# ============================================================
check_port() {
    local port=$1
    if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
        echo -e "  ${GREEN}[●]${RESET} Port $port ${DIM}[LISTENING]${RESET}"
        return 0
    else
        echo -e "  ${RED}[○]${RESET} Port $port ${DIM}[NOT LISTENING]${RESET}"
        return 1
    fi
}

# ============================================================
# Show C2 Status
# ============================================================
show_status() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}       C2 FRAMEWORK STATUS DASHBOARD${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local running=0 stopped=0 total=0
    
    echo -e "${BOLD}${CYAN}[COMMANDS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    for c2 in sliver havoc mythic covenant empire starkiller merlin nimplant; do
        ((total++))
        IFS='|' read -r name desc cmd port url <<< "${C2_INFO[$c2]}"
        if check_cmd "$cmd" &>/dev/null; then
            ((running++))
        else
            ((stopped++))
        fi
    done
    echo ""
    
    echo -e "${BOLD}${CYAN}[PORTS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    for c2 in sliver havoc mythic covenant empire starkiller merlin nimplant; do
        IFS='|' read -r name desc cmd port url <<< "${C2_INFO[$c2]}"
        check_port "$port"
    done
    echo ""
    
    echo -e "${BOLD}${CYAN}[DIRECTORIES]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    for dir in /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant; do
        if [[ -d "$dir" ]]; then
            echo -e "  ${GREEN}[✔]${RESET} $(basename $dir) ${DIM}→ $dir${RESET}"
        else
            echo -e "  ${RED}[✗]${RESET} $(basename $dir)"
        fi
    done
    echo ""
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "  ${BOLD}Summary:${RESET} ${GREEN}$running commands${RESET} | ${RED}$stopped missing${RESET} | $total total"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================
# Show C2 Details
# ============================================================
show_details() {
    local c2="$1"
    IFS='|' read -r name desc cmd port url <<< "${C2_INFO[$c2]}"
    
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  $name — DETAILS${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Name:${RESET}        $name"
    echo -e "  ${BOLD}Description:${RESET} $desc"
    echo -e "  ${BOLD}Command:${RESET}     $cmd"
    echo -e "  ${BOLD}Port:${RESET}        $port"
    echo -e "  ${BOLD}URL:${RESET}         ${DIM}$url${RESET}"
    echo ""
    
    echo -e "  ${BOLD}${CYAN}[STATUS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    check_cmd "$cmd"
    check_port "$port"
    echo ""
    
    echo -e "  ${BOLD}${CYAN}[CONNECTION INFO]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    case "$c2" in
        sliver)
            echo -e "    ${DIM}• Start: ${CYAN}sliver-server${RESET}"
            echo -e "    ${DIM}• Generate implant: ${CYAN}generate --os linux --arch amd64 --mtls 10.0.0.1:8888${RESET}"
            ;;
        havoc)
            echo -e "    ${DIM}• Start: ${CYAN}havoc server${RESET}"
            echo -e "    ${DIM}• Client: ${CYAN}havoc client${RESET}"
            echo -e "    ${DIM}• Profile: ${DIM}/opt/Havoc/profiles/havoc.yaotl${RESET}"
            echo -e "    ${DIM}• Credentials: ${CYAN}5pider / password1234${RESET}"
            ;;
        mythic)
            echo -e "    ${DIM}• Start: ${CYAN}mythic-cli start${RESET}"
            echo -e "    ${DIM}• Status: ${CYAN}mythic-cli status${RESET}"
            echo -e "    ${DIM}• URL: ${CYAN}https://127.0.0.1:7443${RESET}"
            echo -e "    ${DIM}• Credentials: ${DIM}/opt/Mythic/.env${RESET}"
            ;;
        covenant)
            echo -e "    ${DIM}• Start: ${CYAN}covenant${RESET}"
            echo -e "    ${DIM}• URL: ${CYAN}https://127.0.0.1:7443${RESET}"
            echo -e "    ${DIM}• First login: Create admin account${RESET}"
            ;;
        empire)
            echo -e "    ${DIM}• Start: ${CYAN}empire server${RESET}"
            echo -e "    ${DIM}• Client: ${CYAN}empire client${RESET}"
            echo -e "    ${DIM}• Default creds: ${CYAN}empireadmin / password123${RESET}"
            ;;
        starkiller)
            echo -e "    ${DIM}• Start: ${CYAN}starkiller${RESET}"
            echo -e "    ${DIM}• URL: ${CYAN}http://127.0.0.1:4173${RESET}"
            echo -e "    ${DIM}• Requires Empire running${RESET}"
            ;;
        merlin)
            echo -e "    ${DIM}• Start server: ${CYAN}merlin server${RESET}"
            echo -e "    ${DIM}• Start client: ${CYAN}merlin client${RESET}"
            echo -e "    ${DIM}• Default port: ${CYAN}50051${RESET}"
            ;;
        nimplant)
            echo -e "    ${DIM}• Start: ${CYAN}nimplant server${RESET}"
            echo -e "    ${DIM}• Compile: ${CYAN}nimplant compile exe${RESET}"
            echo -e "    ${DIM}• UI: ${CYAN}http://127.0.0.1:31337${RESET}"
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
}

# ============================================================
# Start C2 Framework
# ============================================================
start_c2() {
    local c2="$1"
    IFS='|' read -r name desc cmd port url <<< "${C2_INFO[$c2]}"
    
    echo ""
    echo -e "${BOLD}${GREEN}[+] Starting $name...${RESET}"
    echo ""
    
    case "$c2" in
        sliver)
            if command -v sliver-server &>/dev/null; then
                sliver-server
            else
                fail "Sliver not installed"
            fi
            ;;
        havoc)
            if command -v havoc &>/dev/null; then
                havoc server
            elif [[ -x "/opt/Havoc/havoc" ]]; then
                cd /opt/Havoc && sudo ./havoc server --profile ./profiles/havoc.yaotl
            else
                fail "Havoc not built"
            fi
            ;;
        mythic)
            if command -v mythic-cli &>/dev/null; then
                cd /opt/Mythic
                mythic-cli status
                echo ""
                read -p "Start Mythic? [y/N]: " start
                if [[ "$start" =~ ^[Yy]$ ]]; then
                    mythic-cli start
                    ok "Mythic started"
                    info "Access: https://127.0.0.1:7443"
                    info "Credentials in: /opt/Mythic/.env"
                fi
            else
                fail "Mythic CLI not found"
            fi
            ;;
        covenant)
            if command -v covenant &>/dev/null; then
                covenant
            else
                fail "Covenant not found"
            fi
            ;;
        empire)
            if command -v empire &>/dev/null; then
                empire server
            else
                fail "Empire not found"
            fi
            ;;
        starkiller)
            if command -v starkiller &>/dev/null; then
                starkiller
            else
                fail "Starkiller not found"
            fi
            ;;
        merlin)
            if command -v merlin &>/dev/null; then
                merlin server
            else
                fail "Merlin not built"
            fi
            ;;
        nimplant)
            if command -v nimplant &>/dev/null; then
                nimplant server
            else
                fail "NimPlant not found"
            fi
            ;;
    esac
}

# ============================================================
# Banner
# ============================================================
banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   RED TEAM C2 FRAMEWORK LAUNCHER v2.0                 ║
  ║   8 C2 Frameworks • Status Dashboard • Connection Info║
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
        
        echo -e "${BOLD}${CYAN}[C2 FRAMEWORKS]${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        echo -e "  ${GREEN}1)${RESET} Sliver        ${DIM}— Modern multi-protocol C2${RESET}"
        echo -e "  ${GREEN}2)${RESET} Havoc         ${DIM}— Modern C2 with great UI${RESET}"
        echo -e "  ${GREEN}3)${RESET} Mythic        ${DIM}— Cross-platform C2 (Docker)${RESET}"
        echo -e "  ${GREEN}4)${RESET} Covenant      ${DIM}— .NET-based C2${RESET}"
        echo -e "  ${GREEN}5)${RESET} Empire        ${DIM}— Post-exploitation framework${RESET}"
        echo -e "  ${GREEN}6)${RESET} Starkiller    ${DIM}— Empire GUI${RESET}"
        echo -e "  ${GREEN}7)${RESET} Merlin        ${DIM}— HTTP/2 C2${RESET}"
        echo -e "  ${GREEN}8)${RESET} NimPlant      ${DIM}— Nim-based beacon${RESET}"
        echo ""
        
        echo -e "${BOLD}${CYAN}[MANAGEMENT]${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        echo -e "  ${YELLOW}9)${RESET} Status Dashboard"
        echo -e "  ${YELLOW}10)${RESET} Show C2 Details"
        echo ""
        echo -e "  ${RED}0)${RESET} Exit"
        echo ""
        
        read -p "Select [0-10]: " choice
        
        case $choice in
            1) start_c2 "sliver" ;;
            2) start_c2 "havoc" ;;
            3) start_c2 "mythic" ;;
            4) start_c2 "covenant" ;;
            5) start_c2 "empire" ;;
            6) start_c2 "starkiller" ;;
            7) start_c2 "merlin" ;;
            8) start_c2 "nimplant" ;;
            9) show_status ;;
            10)
                echo ""
                echo -e "${BOLD}Available C2 Frameworks:${RESET}"
                local i=1
                for c2 in sliver havoc mythic covenant empire starkiller merlin nimplant; do
                    IFS='|' read -r name desc cmd port url <<< "${C2_INFO[$c2]}"
                    echo -e "  ${GREEN}$i)${RESET} $name"
                    ((i++))
                done
                echo ""
                read -p "Select C2 [1-8]: " c2_choice
                case $c2_choice in
                    1) show_details "sliver" ;;
                    2) show_details "havoc" ;;
                    3) show_details "mythic" ;;
                    4) show_details "covenant" ;;
                    5) show_details "empire" ;;
                    6) show_details "starkiller" ;;
                    7) show_details "merlin" ;;
                    8) show_details "nimplant" ;;
                    *) warn "Invalid choice" ;;
                esac
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
# Main
# ============================================================
main() {
    local command="${1:-menu}"
    
    case "$command" in
        menu)
            interactive_menu
            ;;
        status)
            show_status
            ;;
        start)
            [[ -z "${2:-}" ]] && { echo "Usage: c2-menu start <c2>"; exit 1; }
            start_c2 "$2"
            ;;
        details)
            [[ -z "${2:-}" ]] && { echo "Usage: c2-menu details <c2>"; exit 1; }
            show_details "$2"
            ;;
        help|--help|-h)
            echo "Usage: c2-menu [command] [args]"
            echo ""
            echo "Commands:"
            echo "  menu              Interactive menu (default)"
            echo "  status            Show status dashboard"
            echo "  start <c2>        Start specific C2"
            echo "  details <c2>      Show C2 details"
            echo ""
            echo "Available C2s:"
            echo "  sliver, havoc, mythic, covenant, empire, starkiller, merlin, nimplant"
            ;;
        *)
            fail "Unknown command: $command"
            exit 1
            ;;
    esac
}

main "$@"
C2MENU
    
    chmod +x /usr/local/bin/c2-menu
    
    if [[ -x /usr/local/bin/c2-menu ]]; then
        echo -e "    ${GREEN}✔${RESET} c2-menu ${DIM}[created - 8 C2 frameworks]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} c2-menu ${DIM}[creation failed]${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Verification
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/3] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ -x /usr/local/bin/c2-menu ]]; then
        echo -e "    ${GREEN}✔${RESET} c2-menu executable"
    else
        echo -e "    ${RED}✗${RESET} c2-menu not executable"
    fi
    
    # Check C2 commands
    local c2_count=0
    for cmd in sliver-server havoc mythic-cli covenant empire starkiller merlin nimplant; do
        if command -v "$cmd" &>/dev/null; then
            ((c2_count++))
        fi
    done
    
    info "C2 commands available: $c2_count/8"
    
    echo ""
    
    # ========================================================
    # Phase 3: Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  C2 MENU SETUP COMPLETE${RESET}"
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
    echo -e "  ${BOLD}C2 Frameworks:${RESET}"
    echo -e "    ${GREEN}●${RESET} Sliver — Modern multi-protocol C2"
    echo -e "    ${GREEN}●${RESET} Havoc — Modern C2 with great UI"
    echo -e "    ${GREEN}●${RESET} Mythic — Cross-platform C2 (Docker)"
    echo -e "    ${GREEN}●${RESET} Covenant — .NET-based C2"
    echo -e "    ${GREEN}●${RESET} Empire — Post-exploitation framework"
    echo -e "    ${GREEN}●${RESET} Starkiller — Empire GUI"
    echo -e "    ${GREEN}●${RESET} Merlin — HTTP/2 C2"
    echo -e "    ${GREEN}●${RESET} NimPlant — Nim-based beacon"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed"
        info "Check log: ${LOG_FILE}"
    else
        ok "C2 Menu ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}c2-menu${RESET}                  ${DIM}→ Interactive menu${RESET}"
    echo -e "    ${CYAN}c2-menu status${RESET}           ${DIM}→ Status dashboard${RESET}"
    echo -e "    ${CYAN}c2-menu start sliver${RESET}     ${DIM}→ Start Sliver${RESET}"
    echo -e "    ${CYAN}c2-menu start havoc${RESET}      ${DIM}→ Start Havoc${RESET}"
    echo -e "    ${CYAN}c2-menu start mythic${RESET}     ${DIM}→ Start Mythic${RESET}"
    echo -e "    ${CYAN}c2-menu details havoc${RESET}    ${DIM}→ Show Havoc details${RESET}"
    echo ""
}

# ============================================================
# STEP 23 — Universal Auto-Fix Engine (Professional & Safe Edition)
# ============================================================
