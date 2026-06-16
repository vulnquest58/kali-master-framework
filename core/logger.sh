#!/usr/bin/env bash
# core/logger.sh

# Logging helpers
log()  { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE" 2>&1; }
ok()   { echo -e "${BOLD}${GREEN}[✔]${RESET} $*"   | tee -a "$LOG_FILE"; }
fail() { echo -e "${BOLD}${RED}[✗]${RESET} $*"   | tee -a "$LOG_FILE"; }
info() { echo -e "${BOLD}${CYAN}[*]${RESET} $*"     | tee -a "$LOG_FILE"; }
warn() { echo -e "${BOLD}${YELLOW}[!]${RESET} $*"   | tee -a "$LOG_FILE"; }
skip() { echo -e "${DIM}${YELLOW}[~]${RESET} ${DIM}$*${RESET}" | tee -a "$LOG_FILE"; }

# Step banner with ETA calculation
step() {
    STEP_CURRENT=$((STEP_CURRENT + 1))
    local elapsed=$(( $(date +%s) - START_TIME ))
    local divisor=$(( STEP_CURRENT > 1 ? STEP_CURRENT - 1 : 1 ))
    local avg=$(( elapsed / divisor ))
    local remaining=$(( avg * (STEP_TOTAL - STEP_CURRENT + 1) ))
    local rem_min=$(( remaining / 60 ))
    local rem_sec=$(( remaining % 60 ))

    echo ""
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    if [[ $STEP_CURRENT -gt 1 && $rem_min -ge 0 ]]; then
        echo -e "${BOLD}${MAGENTA}  ▶ STEP ${STEP_CURRENT}/${STEP_TOTAL} — $* ${DIM}(~${rem_min}m ${rem_sec}s remaining)${RESET}"
    else
        echo -e "${BOLD}${MAGENTA}  ▶ STEP ${STEP_CURRENT}/${STEP_TOTAL} — $*${RESET}"
    fi
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    log "=== STEP ${STEP_CURRENT}: $* ==="
}

# Main startup banner
banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ██╗ ██╗  █████╗ ██╗     ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗
  ██║ ██╔╝██╔══██╗██║     ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
  █████╔╝ ███████║██║     ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
  ██╔═██╗ ██╔══██║██║     ██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
  ██║ ██╗ ██║  ██║███████╗██║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
  ╚═╝ ╚═╝ ╚═╝  ╚═╝╚══════╝╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${RESET}"
    echo -e "  ${BOLD}Offensive Security Platform — v${VERSION}${RESET}"
    echo -e "  ${DIM}Bug Bounty | Red Team | RE | CTF | Malware | AD | Cloud${RESET}"
    echo -e "  ${DIM}C2 Redirectors + SSL | EDR Evasion | Post-Exploitation Kit${RESET}"
    echo -e "  ${DIM}Powerlevel10k | Auto-Fix Engine | ETA Tracking | OPSEC Ready${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
}
