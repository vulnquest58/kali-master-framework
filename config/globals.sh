#!/usr/bin/env bash
# config/globals.sh

readonly VERSION="6.7.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Directories
readonly STATE_DIR="/root/.kali-master/state"
readonly CONFIG_DIR="/root/.config/kali-master"
readonly BACKUP_DIR="/root/.kali-master/backups"
readonly TOOLS_DIR="/opt/tools"
readonly LOCAL_BIN="/usr/local/bin"
readonly WRAPPERS_DIR="/usr/local/bin"
readonly GOPATH_BIN="$HOME/go/bin"
readonly CARGO_BIN="$HOME/.cargo/bin"
readonly PIP_BIN="$HOME/.local/bin"
readonly VENV_DIR="/opt/kali-venv"
readonly ANGR_VENV="/opt/angr-venv"
readonly FLARE_VENV="/opt/flare-venv"
readonly C2_DIR="/opt/c2-frameworks"
readonly REDIRECTOR_DIR="/opt/c2-redirectors"
readonly EVASION_DIR="/opt/evasion-tools"
readonly POSTEXPLOIT_DIR="/opt/postexploit"
readonly WORDLISTS_DIR="/opt/wordlists"

# Search Paths (for smart_find_tool)
readonly SEARCH_PATHS=(
    "$GOPATH_BIN"
    "$LOCAL_BIN"
    "$CARGO_BIN"
    "$PIP_BIN"
    "$VENV_DIR/bin"
    "$ANGR_VENV/bin"
    "$FLARE_VENV/bin"
    "/usr/bin"
    "/usr/sbin"
    "/usr/local/sbin"
    "/opt/tools/bin"
    "$EVASION_DIR"
    "$POSTEXPLOIT_DIR"
    "/snap/bin"
)

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'

# Runtime log and counters
readonly LOG_FILE="/var/log/kali_master_v6_$(date +%Y%m%d_%H%M%S).log"
STEP_TOTAL=0
STEP_CURRENT=0
TOOLS_OK=0
TOOLS_FAIL=0
INSTALL_ERRORS=()
START_TIME=0
