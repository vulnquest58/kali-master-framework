#!/usr/bin/env bash
# ============================================================
#  config/globals.sh — Kali Master Framework v7.0.0
#  Global constants and path definitions
# ============================================================

# ─── Version & Script Info ───────────────────────────────────
readonly VERSION="7.0.0"
readonly FRAMEWORK_NAME="Kali Master Framework"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ─── Configuration Directories ──────────────────────────────
readonly STATE_DIR="/root/.kali-master/state"
readonly CONFIG_DIR="/root/.config/kali-master"
readonly BACKUP_DIR="/root/.kali-master/backups"
readonly CACHE_DIR="/root/.kali-master/cache"

# ─── Tools & Binaries Directories ───────────────────────────
readonly TOOLS_DIR="/opt/tools"
readonly LOCAL_BIN="/usr/local/bin"
readonly WRAPPERS_DIR="/usr/local/bin"
readonly GOPATH_BIN="$HOME/go/bin"
readonly CARGO_BIN="$HOME/.cargo/bin"
readonly PIP_BIN="$HOME/.local/bin"
readonly NIMBLE_BIN="$HOME/.nimble/bin"
readonly DOTNET_BIN="$HOME/.dotnet/tools"
readonly NPM_BIN="/usr/local/lib/node_modules/.bin"

# ─── Python Virtual Environments ────────────────────────────
readonly VENV_DIR="/opt/kali-venv"
readonly ANGR_VENV="/opt/angr-venv"
readonly FLARE_VENV="/opt/flare-venv"
readonly SCOUTSUITE_VENV="/opt/scoutsuite-venv"
readonly PROWLER_VENV="/opt/prowler-venv"

# ─── Specialized Directories ────────────────────────────────
readonly C2_DIR="/opt/c2-frameworks"
readonly REDIRECTOR_DIR="/opt/c2-redirectors"
readonly EVASION_DIR="/opt/evasion-tools"
readonly POSTEXPLOIT_DIR="/opt/postexploit"
readonly WORDLISTS_DIR="/opt/wordlists"
readonly AI_TOOLS_DIR="/opt/ai-tools"
readonly OPSEC_DIR="/opt/opsec"
readonly ADAPTIX_DIR="/opt/AdaptixC2"

# ─── Search Paths (for smart_find_tool) ─────────────────────
readonly SEARCH_PATHS=(
    "$GOPATH_BIN"
    "$LOCAL_BIN"
    "$CARGO_BIN"
    "$PIP_BIN"
    "$NIMBLE_BIN"
    "$DOTNET_BIN"
    "$VENV_DIR/bin"
    "$ANGR_VENV/bin"
    "$FLARE_VENV/bin"
    "$SCOUTSUITE_VENV/bin"
    "$PROWLER_VENV/bin"
    "/usr/bin"
    "/usr/sbin"
    "/usr/local/sbin"
    "/opt/tools/bin"
    "$EVASION_DIR"
    "$POSTEXPLOIT_DIR"
    "/snap/bin"
    "/opt/pdtm/bin"
)

# ─── Color Definitions ──────────────────────────────────────
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly UNDERLINE='\033[4m'
readonly RESET='\033[0m'

# ─── Runtime Log & Counters ─────────────────────────────────
readonly LOG_FILE="/var/log/kali_master_v7_$(date +%Y%m%d_%H%M%S).log"
STEP_TOTAL=0
STEP_CURRENT=0
TOOLS_OK=0
TOOLS_FAIL=0
TOOLS_SKIP=0
INSTALL_ERRORS=()
START_TIME=0

# ─── Mode Flags (User-configurable via env or CLI) ──────────
MINIMAL_MODE="${MINIMAL_MODE:-0}"
FORCE="${FORCE:-0}"
ONLY_STEP="${ONLY_STEP:-}"
SKIP_STEPS="${SKIP_STEPS:-}"
AUTO_FIX_MODE="${AUTO_FIX_MODE:-0}"
DRY_RUN="${DRY_RUN:-0}"
DEBUG_MODE="${DEBUG_MODE:-0}"
PARALLEL_JOBS="${PARALLEL_JOBS:-4}"
SKIP_SNAPSHOT="${SKIP_SNAPSHOT:-0}"

# ─── Export Critical Paths ──────────────────────────────────
export PATH="$PATH:$LOCAL_BIN:$GOPATH_BIN:$CARGO_BIN:$PIP_BIN:$NIMBLE_BIN:$DOTNET_BIN:$VENV_DIR/bin"
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
export GO111MODULE="on"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PYTHONDONTWRITEBYTECODE=1
