#!/usr/bin/env bash
# ============================================================
#  KALI MASTER FRAMEWORK v7.0.0 — Main Orchestrator
#  Ultimate Offensive Security Platform
#  Modular Architecture | AI-Ready | OPSEC Edition
# ============================================================
set -uo pipefail

# 1. Determine main directory path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Source configurations and core utilities in order
source "$SCRIPT_DIR/config/globals.sh"
source "$SCRIPT_DIR/config/defaults.sh"
source "$SCRIPT_DIR/core/logger.sh"
source "$SCRIPT_DIR/core/state.sh"
source "$SCRIPT_DIR/core/utils.sh"
source "$SCRIPT_DIR/core/network.sh"
source "$SCRIPT_DIR/core/validator.sh"
source "$SCRIPT_DIR/core/installers.sh"

# 3. Define the ordered modules array
readonly MODULES=(
    "01_preflight"
    "02_system_update"
    "03_python_venv"
    "04_golang"
    "05_docker"
    "06_bugbounty"
    "07_reversing"
    "08_ctf"
    "09_ad_network"
    "10_cloud_security"
    "11_wordlists"
    "12_shell_config"
    "13_secrets"
    "14_vm_hardening"
    "15_update_manager"
    "16_helper_scripts"
    "17_redteam_c2"
    "18_c2_redirector"
    "19_evasion_tools"
    "20_post_exploit"
    "21_lab_manager"
    "22_c2_menu"
    "23_auto_fix"
    "24_dashboard"
    "25_health_check"
    "26_ai_tools"
    "27_opsec_tools"
)

# 4. Map module steps to execution functions
declare -A MODULE_FUNCTIONS=(
    ["preflight"]="do_preflight"
    ["system_update"]="do_system_update"
    ["python_venv"]="do_python_venv"
    ["golang"]="do_golang"
    ["docker"]="do_docker"
    ["bugbounty"]="do_bugbounty"
    ["reversing"]="do_reversing"
    ["ctf"]="do_ctf"
    ["ad_network"]="do_ad_network"
    ["cloud_security"]="do_cloud_security"
    ["wordlists"]="do_wordlists"
    ["shell_config"]="do_shell_config"
    ["secrets"]="do_secrets"
    ["vm_hardening"]="do_vm_hardening"
    ["update_manager"]="do_update_manager"
    ["helper_scripts"]="do_helper_scripts"
    ["redteam_c2"]="do_redteam_c2"
    ["c2_redirector"]="do_c2_redirector"
    ["evasion_tools"]="do_evasion_tools"
    ["post_exploit"]="do_post_exploit"
    ["lab_manager"]="do_lab_manager"
    ["c2_menu"]="do_c2_menu"
    ["auto_fix"]="do_auto_fix"
    ["dashboard"]="do_dashboard"
    ["health_check"]="do_health_check"
    ["ai_tools"]="do_ai_tools"
    ["opsec_tools"]="do_opsec_tools"
)

# Map for disk space requirements per module (GB)
declare -A MODULE_DISK_REQ=(
    ["system_update"]="5"
    ["python_venv"]="3"
    ["golang"]="2"
    ["docker"]="5"
    ["bugbounty"]="3"
    ["reversing"]="8"
    ["ctf"]="4"
    ["ad_network"]="3"
    ["cloud_security"]="3"
    ["wordlists"]="10"
    ["redteam_c2"]="10"
    ["evasion_tools"]="4"
    ["post_exploit"]="3"
    ["ai_tools"]="20"
)

# ─── Argument Parsing ──────────────────────────────────────
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --reset)
                shift
                state_reset "${1:-}"
                [[ $# -gt 0 ]] && shift
                ;;
            --reset-all)
                state_reset
                shift
                ;;
            --step)
                shift
                ONLY_STEP="${1:-}"
                shift
                ;;
            --skip)
                shift
                SKIP_STEPS="${SKIP_STEPS:+$SKIP_STEPS,}${1:-}"
                shift
                ;;
            --force)
                FORCE=1
                shift
                ;;
            --minimal)
                MINIMAL_MODE=1
                shift
                ;;
            --fix)
                AUTO_FIX_MODE=1
                shift
                ;;
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --debug)
                DEBUG_MODE=1
                shift
                ;;
            --no-snapshot)
                SKIP_SNAPSHOT=1
                shift
                ;;
            --list-tools)
                source "$SCRIPT_DIR/tools/check-tools.sh" 2>/dev/null || true
                list_all_tools 2>/dev/null || show_tool_list
                exit 0
                ;;
            --update)
                shift
                local tool_to_update="${1:-}"
                if [[ -n "$tool_to_update" ]]; then
                    source "$SCRIPT_DIR/tools/update-tools.sh" 2>/dev/null || true
                    update_single_tool "$tool_to_update"
                    exit 0
                fi
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                warn "Unknown option: $1"
                echo -e "  ${DIM}Run '$0 --help' for usage information.${RESET}"
                shift
                ;;
        esac
    done
}

show_help() {
    echo -e "${BOLD}${MAGENTA}KALI MASTER FRAMEWORK v${VERSION}${RESET}"
    echo -e "${DIM}Ultimate Offensive Security Platform${RESET}"
    echo ""
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}--minimal${RESET}          Minimal install (core tools only, ~15-20 min)"
    echo -e "  ${CYAN}--fix${RESET}              Run auto-fix engine for broken/missing tools"
    echo -e "  ${CYAN}--dry-run${RESET}          Show what would happen without making changes"
    echo -e "  ${CYAN}--debug${RESET}            Enable verbose debug output"
    echo -e "  ${CYAN}--no-snapshot${RESET}      Skip VM snapshot creation"
    echo -e "  ${CYAN}--step <name>${RESET}      Run a single specific step only"
    echo -e "  ${CYAN}--skip <name>${RESET}      Skip a specific step (can repeat)"
    echo -e "  ${CYAN}--reset <name>${RESET}     Reset state of a step to re-run it"
    echo -e "  ${CYAN}--reset-all${RESET}        Reset all state files (fresh install)"
    echo -e "  ${CYAN}--force${RESET}            Force execution even if step completed"
    echo -e "  ${CYAN}--list-tools${RESET}       List all tools and their status"
    echo -e "  ${CYAN}--update <tool>${RESET}    Update a specific tool"
    echo -e "  ${CYAN}--help, -h${RESET}         Show this help message"
    echo ""
    echo -e "${BOLD}Environment Variables:${RESET}"
    echo -e "  ${CYAN}GITHUB_TOKEN${RESET}       GitHub personal token (5000 req/h vs 60)"
    echo -e "  ${CYAN}MINIMAL_MODE=1${RESET}     Same as --minimal"
    echo -e "  ${CYAN}FORCE=1${RESET}            Same as --force"
    echo -e "  ${CYAN}DRY_RUN=1${RESET}          Same as --dry-run"
    echo -e "  ${CYAN}DEBUG_MODE=1${RESET}       Same as --debug"
    echo -e "  ${CYAN}PARALLEL_JOBS=4${RESET}    Number of parallel installs (default: 4)"
    echo ""
    echo -e "${BOLD}Available Steps:${RESET}"
    for module_file in "${MODULES[@]}"; do
        local step_name="${module_file#*_}"
        local disk_req="${MODULE_DISK_REQ[$step_name]:-1}GB"
        printf "  ${CYAN}%-20s${RESET} ${DIM}(~%s disk)${RESET}\n" "$step_name" "$disk_req"
    done
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}sudo ./kali-master.sh${RESET}                    # Full installation"
    echo -e "  ${CYAN}sudo ./kali-master.sh --minimal${RESET}          # Lightweight install"
    echo -e "  ${CYAN}sudo ./kali-master.sh --dry-run${RESET}          # Preview without changes"
    echo -e "  ${CYAN}sudo ./kali-master.sh --step bugbounty${RESET}   # Run only bug bounty"
    echo -e "  ${CYAN}sudo ./kali-master.sh --skip ai_tools${RESET}    # Skip AI tools"
    echo -e "  ${CYAN}GITHUB_TOKEN=xxx sudo ./kali-master.sh${RESET}   # With GitHub auth"
}

show_tool_list() {
    echo -e "${BOLD}${CYAN}Available modules and tools:${RESET}"
    for module_file in "${MODULES[@]}"; do
        local step_name="${module_file#*_}"
        local mod_path="$SCRIPT_DIR/modules/${module_file}.sh"
        echo ""
        echo -e "  ${BOLD}${MAGENTA}[$step_name]${RESET}"
        [[ -f "$mod_path" ]] && \
            grep -oP "(?<=smart_find_tool \")[^\"]+(?=\")" "$mod_path" 2>/dev/null | \
            sort -u | \
            while read -r tool; do
                if smart_find_tool "$tool" &>/dev/null; then
                    echo -e "    ${GREEN}✔${RESET} $tool"
                else
                    echo -e "    ${RED}✗${RESET} $tool ${DIM}[not installed]${RESET}"
                fi
            done
    done
}

# ─── Should we skip this step? ──────────────────────────────
should_skip_step() {
    local step_name="$1"
    IFS=',' read -ra skip_list <<< "${SKIP_STEPS:-}"
    for skip_item in "${skip_list[@]}"; do
        [[ "$skip_item" == "$step_name" ]] && return 0
    done
    return 1
}

# ─── Main execution function ────────────────────────────────
main() {
    START_TIME=$(date +%s)

    # Root check
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BOLD}${RED}[✗]${RESET} This script must be run as root."
        echo -e "${DIM}Usage: sudo $0 [OPTIONS]${RESET}"
        exit 1
    fi

    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    # Trap for clean exit
    trap 'echo -e "\n${BOLD}${YELLOW}[!]${RESET} Operation interrupted. State preserved — resume with: sudo $0"; exit 130' INT TERM

    # Print banner
    banner

    # Parse CLI arguments
    parse_args "$@"

    # Load custom tools from config
    load_custom_tools

    # Calculate step totals
    STEP_TOTAL=${#MODULES[@]}

    # Initialize state directory
    init_state

    # Validate kernel features
    check_kernel_features

    # ── Auto-fix mode ─────────────────────────────────────────
    if [[ "$AUTO_FIX_MODE" == "1" ]]; then
        source "$SCRIPT_DIR/modules/01_preflight.sh"
        source "$SCRIPT_DIR/modules/23_auto_fix.sh"
        do_preflight
        do_auto_fix
        exit 0
    fi

    # ── Single step mode ──────────────────────────────────────
    if [[ -n "$ONLY_STEP" ]]; then
        local matched=0
        for module_file in "${MODULES[@]}"; do
            local step_name="${module_file#*_}"
            if [[ "$step_name" == "$ONLY_STEP" ]]; then
                matched=1
                source "$SCRIPT_DIR/modules/${module_file}.sh"
                local func_name="${MODULE_FUNCTIONS[$step_name]}"

                # Pre-install disk check
                local disk_req="${MODULE_DISK_REQ[$step_name]:-1}"
                check_disk_space "$disk_req" "$step_name"

                step "$step_name"
                FORCE=1 run_step "$step_name" "$func_name"

                # Post-execution validation
                case "$step_name" in
                    golang)      require_ok "go" ;;
                    python_venv) require_ok "python3" ;;
                esac
                break
            fi
        done
        if [[ $matched -eq 0 ]]; then
            fail "Unknown step: $ONLY_STEP"
            echo -e "${DIM}Available steps:${RESET}"
            for m in "${MODULES[@]}"; do echo -e "  ${CYAN}${m#*_}${RESET}"; done
            exit 1
        fi

    # ── Full sequential run ───────────────────────────────────
    else
        for module_file in "${MODULES[@]}"; do
            local step_name="${module_file#*_}"

            # Skip steps if requested
            if should_skip_step "$step_name"; then
                info "Skipping step: $step_name (--skip)"
                continue
            fi

            # Skip AI tools in minimal mode
            if [[ "$MINIMAL_MODE" == "1" ]] && [[ "$step_name" =~ ^(ai_tools|opsec_tools|redteam_c2|evasion_tools|lab_manager)$ ]]; then
                skip "$step_name — skipped in minimal mode"
                continue
            fi

            source "$SCRIPT_DIR/modules/${module_file}.sh"
            local func_name="${MODULE_FUNCTIONS[$step_name]}"

            # Pre-install disk check (warn but don't abort)
            local disk_req="${MODULE_DISK_REQ[$step_name]:-1}"
            check_disk_space "$disk_req" "$step_name" || true

            step "$step_name"
            run_step "$step_name" "$func_name"

            # Post-execution validation of critical steps
            case "$step_name" in
                golang)      require_ok "go" ;;
                python_venv) require_ok "python3" ;;
            esac
        done

        # Final health check and summary
        source "$SCRIPT_DIR/modules/25_health_check.sh"
        do_health_check
        do_final_summary
    fi

    # ── Show installation errors if any ──────────────────────
    if [[ ${#INSTALL_ERRORS[@]} -gt 0 ]]; then
        echo ""
        warn "Steps with errors: ${INSTALL_ERRORS[*]}"
        info "Run: sudo ./kali-master.sh --fix"
        info "Log: $LOG_FILE"
    fi
}

# Entry Point
main "$@"