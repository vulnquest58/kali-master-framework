#!/usr/bin/env bash
# ============================================================
#  KALI MASTER FRAMEWORK v6.7.0 — Main Orchestrator
#  Modular Architecture Edition
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
)

# 4. Map module steps to corresponding execution functions
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
)

# 5. Argument Parsing
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
    echo -e "${BOLD}Usage:${RESET} $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}--minimal${RESET}        Minimal installation (core tools only)"
    echo -e "  ${CYAN}--fix${RESET}            Run auto-fix engine for missing tools"
    echo -e "  ${CYAN}--step <name>${RESET}    Run a single specific step only"
    echo -e "  ${CYAN}--reset <name>${RESET}   Reset status file of a step to rerun"
    echo -e "  ${CYAN}--reset-all${RESET}      Reset all status files"
    echo -e "  ${CYAN}--force${RESET}          Force step execution even if completed"
    echo -e "  ${CYAN}--help, -h${RESET}       Show this help message"
    echo ""
    echo -e "${BOLD}Available Steps:${RESET}"
    for module_file in "${MODULES[@]}"; do
        local step_name="${module_file#*_}"
        echo -e "  - ${CYAN}${step_name}${RESET}"
    done
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  ${CYAN}sudo ./kali-master.sh --minimal${RESET}"
    echo -e "  ${CYAN}sudo ./kali-master.sh --step docker --force${RESET}"
    echo -e "  ${CYAN}sudo ./kali-master.sh --fix${RESET}"
}

# 6. Main execution function
main() {
    START_TIME=$(date +%s)
    
    # Ensure script is run as root
    if [[ $EUID -ne 0 ]]; then
        echo -e "${BOLD}${RED}[✗]${RESET} This script must be run as root."
        echo -e "${DIM}Usage: sudo $0 [OPTIONS]${RESET}"
        exit 1
    fi

    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    # Set up trap for Ctrl+C or termination
    trap 'echo -e "\n${BOLD}${YELLOW}[!]${RESET} Operation interrupted by user. Exiting..."; exit 130' INT TERM

    # Print logo banner
    banner
    
    # Parse CLI arguments
    parse_args "$@"
    
    # Calculate step totals
    STEP_TOTAL=${#MODULES[@]}

    # Initialize state directory
    init_state

    # 1. Handle auto-fix mode exclusively
    if [[ "$AUTO_FIX_MODE" == "1" ]]; then
        source "$SCRIPT_DIR/modules/01_preflight.sh"
        source "$SCRIPT_DIR/modules/23_auto_fix.sh"
        do_preflight
        do_auto_fix
        exit 0
    fi

    # 2. Run modules
    if [[ -n "$ONLY_STEP" ]]; then
        # Find module file
        local matched=0
        for module_file in "${MODULES[@]}"; do
            local step_name="${module_file#*_}"
            if [[ "$step_name" == "$ONLY_STEP" ]]; then
                matched=1
                source "$SCRIPT_DIR/modules/${module_file}.sh"
                local func_name="${MODULE_FUNCTIONS[$step_name]}"
                step "$step_name"
                FORCE=1 run_step "$step_name" "$func_name"
                
                # Post-execution check for critical items
                case "$step_name" in
                    golang)      require_ok "go" ;;
                    python_venv) require_ok "python3" ;;
                esac
                break
            fi
        done
        if [[ $matched -eq 0 ]]; then
            fail "Unknown step: $ONLY_STEP"
            exit 1
        fi
    else
        # Normal sequential run of all modules
        for module_file in "${MODULES[@]}"; do
            local step_name="${module_file#*_}"
            source "$SCRIPT_DIR/modules/${module_file}.sh"
            local func_name="${MODULE_FUNCTIONS[$step_name]}"
            
            step "$step_name"
            run_step "$step_name" "$func_name"
            
            # Post-execution validation
            case "$step_name" in
                golang)      require_ok "go" ;;
                python_venv) require_ok "python3" ;;
            esac
        done

        # Health check and final summary (both in 25_health_check.sh)
        source "$SCRIPT_DIR/modules/25_health_check.sh"
        do_health_check
        do_final_summary
    fi
}

# Entry Point execution
main "$@"