#!/usr/bin/env bash
# ============================================================
#  core/logger.sh — Kali Master Framework v7.0.0
#  Logging, banner, step tracking & progress utilities
# ============================================================

# ─── Core Logging Helpers ────────────────────────────────────
log()     { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE" 2>&1; }
ok()      { echo -e "${BOLD}${GREEN}[✔]${RESET} $*"  | tee -a "$LOG_FILE"; ((TOOLS_OK++)) || true; }
fail()    { echo -e "${BOLD}${RED}[✗]${RESET} $*"    | tee -a "$LOG_FILE"; ((TOOLS_FAIL++)) || true; }
info()    { echo -e "${BOLD}${CYAN}[*]${RESET} $*"   | tee -a "$LOG_FILE"; }
warn()    { echo -e "${BOLD}${YELLOW}[!]${RESET} $*" | tee -a "$LOG_FILE"; }
skip()    { echo -e "${DIM}${YELLOW}[~]${RESET} ${DIM}$*${RESET}" | tee -a "$LOG_FILE"; ((TOOLS_SKIP++)) || true; }
debug()   { [[ "${DEBUG_MODE:-0}" == "1" ]] && echo -e "${DIM}${BLUE}[DBG]${RESET} ${DIM}$*${RESET}" | tee -a "$LOG_FILE"; }
dryrun()  { [[ "${DRY_RUN:-0}" == "1" ]] && echo -e "${BOLD}${BLUE}[DRY]${RESET} Would run: $*" | tee -a "$LOG_FILE"; }

# ─── Section Separator ───────────────────────────────────────
section() {
    local title="${1:-}"
    echo ""
    echo -e "${BOLD}${BLUE}┌──────────────────────────────────────────────────────┐${RESET}"
    echo -e "${BOLD}${BLUE}│  ${title}$(printf '%*s' $((52 - ${#title})) '')│${RESET}"
    echo -e "${BOLD}${BLUE}└──────────────────────────────────────────────────────┘${RESET}"
    log "=== SECTION: $title ==="
}

# ─── Progress Bar ────────────────────────────────────────────
progress_bar() {
    local current="$1"
    local total="$2"
    local label="${3:-Progress}"
    local width=40

    [[ "$total" -le 0 ]] && return
    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    printf "\r  ${BOLD}${CYAN}%-20s${RESET} [" "$label"
    printf '%*s' "$filled" '' | tr ' ' '█'
    printf '%*s' "$empty" '' | tr ' ' '░'
    printf "] ${BOLD}%3d%%${RESET} (%d/%d)" "$percent" "$current" "$total"

    if [[ "$current" -ge "$total" ]]; then
        echo ""
    fi
}

# ─── Step Banner with ETA Calculation ────────────────────────
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
    if [[ $STEP_CURRENT -gt 1 && $remaining -gt 0 ]]; then
        echo -e "${BOLD}${MAGENTA}  ▶ STEP ${STEP_CURRENT}/${STEP_TOTAL} — $* ${DIM}(~${rem_min}m ${rem_sec}s remaining)${RESET}"
    else
        echo -e "${BOLD}${MAGENTA}  ▶ STEP ${STEP_CURRENT}/${STEP_TOTAL} — $*${RESET}"
    fi
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    log "=== STEP ${STEP_CURRENT}: $* ==="

    # DRY RUN notice
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo -e "  ${BOLD}${BLUE}[DRY-RUN MODE]${RESET} ${DIM}No changes will be made${RESET}"
    fi
}

# ─── Main Startup Banner ─────────────────────────────────────
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
    echo -e "  ${BOLD}${MAGENTA}Offensive Security Platform — v${VERSION}${RESET}"
    echo -e "  ${DIM}Bug Bounty | Red Team | RE | CTF | AD Attacks | Cloud${RESET}"
    echo -e "  ${DIM}C2 Suite: Sliver + Havoc + Mythic + AdaptixC2 + Empire${RESET}"
    echo -e "  ${DIM}EDR Evasion | Post-Exploit | AI Recon | OPSEC Ready${RESET}"
    echo -e "  ${DIM}Powerlevel10k | Auto-Fix | State Machine | ETA Tracking${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo -e "  ${BOLD}${BLUE}━━━ DRY-RUN MODE — No changes will be made ━━━${RESET}"
    fi
    if [[ "${MINIMAL_MODE:-0}" == "1" ]]; then
        echo -e "  ${BOLD}${YELLOW}━━━ MINIMAL MODE — Core tools only ━━━${RESET}"
    fi
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        echo -e "  ${GREEN}✔${RESET}${DIM} GITHUB_TOKEN configured (rate limit: 5000/h)${RESET}"
    fi
    echo ""
}

# ─── Final Duration Formatter ─────────────────────────────────
format_duration() {
    local seconds="$1"
    local h=$(( seconds / 3600 ))
    local m=$(( (seconds % 3600) / 60 ))
    local s=$(( seconds % 60 ))
    if [[ $h -gt 0 ]]; then
        printf "%dh %dm %ds" "$h" "$m" "$s"
    elif [[ $m -gt 0 ]]; then
        printf "%dm %ds" "$m" "$s"
    else
        printf "%ds" "$s"
    fi
}
