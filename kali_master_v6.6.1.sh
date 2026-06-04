#!/usr/bin/env bash
# ============================================================
#  KALI MASTER FRAMEWORK v6.6.1
#  Ultimate Offensive Security Platform
#  Production + Red Team + C2 + Auto-Fix + OPSEC Edition
#
#  Features:
#   - Powerlevel10k professional theme
#   - Minimal mode for lightweight installs
#   - Full C2 Suite (Sliver, Havoc, Mythic, Covenant, Empire, Merlin, NimPlant)
#   - C2 Redirectors Automation (Nginx + Let's Encrypt SSL)
#   - EDR/AV Evasion Tools (ScareCrow, Donut, SGN, PE-Sieve, Nimcrypt2)
#   - Post-Exploitation Kit (linpeas, winpeas, chisel, pspy, ligolo-ng)
#   - Smart C2 Builders (Havoc with submodules, Mythic safe reset, Covenant libssl1.1)
#   - Universal Auto-Fix Engine (3-tier fallback)
#   - Interactive Lab Manager (Docker)
#   - Smart detection for all tools
#   - GITHUB_TOKEN support for rate limits
#   - State machine with idempotent steps
#   - Auto-calculated step count + ETA
#   - Critical step validation (require_ok)
#   - Comprehensive dashboard
#   - Bug fixes: certbot, ScareCrow, sgn, Merlin
# ============================================================

set -uo pipefail

# ============================================================
# Global Variables
# ============================================================
readonly VERSION="6.6.1"
readonly SCRIPT_NAME="kali_master_v6.6.1.sh"
readonly LOG_FILE="/var/log/kali_master_v6_$(date +%Y%m%d_%H%M%S).log"
readonly STATE_DIR="/root/.kali-master/state"
readonly CONFIG_DIR="/root/.config/kali-master"
readonly TOOLS_DIR="/opt/tools"
readonly GOPATH_BIN="$HOME/go/bin"
readonly CARGO_BIN="$HOME/.cargo/bin"
readonly LOCAL_BIN="/usr/local/bin"
readonly PIP_BIN="$HOME/.local/bin"
readonly VENV_DIR="/opt/kali-venv"
readonly ANGR_VENV="/opt/angr-venv"
readonly FLARE_VENV="/opt/flare-venv"
readonly WRAPPERS_DIR="/usr/local/bin"
readonly C2_DIR="/opt/c2-frameworks"
readonly REDIRECTOR_DIR="/opt/c2-redirectors"
readonly EVASION_DIR="/opt/evasion-tools"
readonly POSTEXPLOIT_DIR="/opt/postexploit"

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

STEP_TOTAL=0
STEP_CURRENT=0
TOOLS_OK=0
TOOLS_FAIL=0
INSTALL_ERRORS=()
START_TIME=0

# Mode flags
MINIMAL_MODE="${MINIMAL_MODE:-0}"
FORCE="${FORCE:-0}"
ONLY_STEP="${ONLY_STEP:-}"
AUTO_FIX_MODE="${AUTO_FIX_MODE:-0}"

# ============================================================
# Logging helpers
# ============================================================
log()  { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE" 2>&1; }
ok()   { echo -e "${BOLD}${GREEN}[✔]${RESET} $*"   | tee -a "$LOG_FILE"; }
fail() { echo -e "${BOLD}${RED}[✗]${RESET} $*"   | tee -a "$LOG_FILE"; }
info() { echo -e "${BOLD}${CYAN}[*]${RESET} $*"     | tee -a "$LOG_FILE"; }
warn() { echo -e "${BOLD}${YELLOW}[!]${RESET} $*"   | tee -a "$LOG_FILE"; }
skip() { echo -e "${DIM}${YELLOW}[~]${RESET} ${DIM}$*${RESET}" | tee -a "$LOG_FILE"; }

# ============================================================
# Critical tool validator
# ============================================================
require_ok() {
    local tool="$1"
    if ! smart_find_tool "$tool" &>/dev/null; then
        fail "Critical tool missing: ${BOLD}$tool${RESET} — aborting."
        exit 1
    fi
}

# ============================================================
# Step banner with ETA
# ============================================================
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

# ============================================================
# State Machine
# ============================================================
state_done()  { mkdir -p "$STATE_DIR"; touch "$STATE_DIR/${1}.done"; }
state_check() { [[ -f "$STATE_DIR/${1}.done" ]]; }
state_reset() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        rm -rf "$STATE_DIR"
        info "All states reset."
    else
        rm -f "$STATE_DIR/${name}.done"
        info "State reset: $name"
    fi
}

run_step() {
    local name="$1"
    local func="$2"
    shift 2

    if state_check "$name" && [[ "${FORCE:-0}" != "1" ]]; then
        skip "$name — already done. Use --reset $name to re-run."
        return 0
    fi

    if $func "$@"; then
        state_done "$name"
    else
        warn "Step failed: $name (continuing)"
        INSTALL_ERRORS+=("$name")
    fi
}

# ============================================================
# Smart tool finder — extended search
# ============================================================
smart_find_tool() {
    local tool="$1"

    if command -v "$tool" &>/dev/null; then
        command -v "$tool"; return 0
    fi

    for search_path in "${SEARCH_PATHS[@]}"; do
        if [[ -x "${search_path}/${tool}" ]]; then
            echo "${search_path}/${tool}"; return 0
        fi
    done

    if [[ -d "$TOOLS_DIR" ]]; then
        local found
        found=$(find "$TOOLS_DIR" -maxdepth 5 -name "$tool" -type f -executable \
                2>/dev/null | head -1)
        [[ -n "$found" ]] && { echo "$found"; return 0; }
    fi

    local pipx_path="$HOME/.local/share/pipx/venvs/${tool}/bin/${tool}"
    [[ -x "$pipx_path" ]] && { echo "$pipx_path"; return 0; }

    for venv_base in "$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV" "/opt/scoutsuite-venv"; do
        [[ -x "${venv_base}/bin/${tool}" ]] && { echo "${venv_base}/bin/${tool}"; return 0; }
    done

    return 1
}

# ============================================================
# Network helpers
# ============================================================
safe_curl() {
    local url="$1" out="$2"
    local attempts=3 delay=5
    for i in $(seq 1 $attempts); do
        if curl -fsSL --max-time 90 --retry 3 --retry-delay 3 \
               --retry-all-errors -o "$out" "$url" >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        warn "curl attempt $i/$attempts failed for $url — retrying in ${delay}s"
        sleep "$delay"
    done
    return 1
}

safe_wget() {
    local url="$1" out="$2"
    wget -q --timeout=90 --tries=3 --waitretry=5 -O "$out" "$url" >> "$LOG_FILE" 2>&1
}

# ============================================================
# Wrapper + PATH helpers
# ============================================================
make_wrapper() {
    local tool_name="$1"
    local tool_real_path="$2"
    local wrapper="${WRAPPERS_DIR}/${tool_name}"

    [[ "$(dirname "$tool_real_path")" == "$WRAPPERS_DIR" ]] && return 0
    [[ -L "$wrapper" ]] && \
        [[ "$(readlink -f "$wrapper")" == "$(readlink -f "$tool_real_path")" ]] && return 0

    cat > "$wrapper" << WRAPPER
#!/usr/bin/env bash
exec "${tool_real_path}" "\$@"
WRAPPER
    chmod +x "$wrapper"
    log "Wrapper: $wrapper -> $tool_real_path"
}

ensure_in_path() {
    local tool="$1"
    local tool_path
    if tool_path=$(smart_find_tool "$tool"); then
        if ! command -v "$tool" &>/dev/null; then
            make_wrapper "$tool" "$tool_path"
        fi
    fi
}

make_venv_wrapper() {
    local cmd_name="$1"
    local venv_dir="$2"
    local script_path="$3"

    cat > "${WRAPPERS_DIR}/${cmd_name}" << WRAPPER
#!/usr/bin/env bash
source "${venv_dir}/bin/activate"
exec python3 "${script_path}" "\$@"
WRAPPER
    chmod +x "${WRAPPERS_DIR}/${cmd_name}"
    ok "${cmd_name} wrapper -> ${script_path}"
}

# ============================================================
# Install helpers
# ============================================================
install_go_tool() {
    local tool_name="$1"
    local go_package="$2"
    local binary_name="${3:-$tool_name}"

    if smart_find_tool "$binary_name" &>/dev/null; then
        local found_path; found_path=$(smart_find_tool "$binary_name")
        ok "${binary_name} — found at ${found_path}"
        ensure_in_path "$binary_name"
        return 0
    fi

    info "Installing ${tool_name} via go install..."
    local proxies=(
        "https://proxy.golang.org,direct"
        "https://goproxy.io,direct"
        "direct"
    )
    for proxy in "${proxies[@]}"; do
        if GOPATH="$HOME/go" GOPROXY="$proxy" GONOSUMDB="*" \
           go install "${go_package}@latest" >> "$LOG_FILE" 2>&1; then
            if [[ -x "$HOME/go/bin/${binary_name}" ]]; then
                ln -sf "$HOME/go/bin/${binary_name}" "/usr/local/bin/${binary_name}" 2>/dev/null
            fi
            ensure_in_path "$binary_name"
            ok "${binary_name} — installed (proxy=${proxy})"
            return 0
        fi
    done

    fail "${binary_name} — go install failed (all proxies exhausted)"
    return 1
}

install_apt_tool() {
    local binary_name="$1"
    local apt_package="${2:-$1}"

    if smart_find_tool "$binary_name" &>/dev/null; then
        ok "${binary_name} — found"
        return 0
    fi

    info "Installing ${apt_package} via apt..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
           --fix-missing "$apt_package" >> "$LOG_FILE" 2>&1; then
        ok "${binary_name} — installed via apt"
    else
        fail "${binary_name} — apt failed"
        return 1
    fi
}

install_cargo_tool() {
    local binary_name="$1"
    local crate_name="${2:-$1}"

    if smart_find_tool "$binary_name" &>/dev/null; then
        ok "${binary_name} — found"
        return 0
    fi

    info "Installing ${crate_name} via cargo..."
    if cargo install "$crate_name" --quiet >> "$LOG_FILE" 2>&1; then
        ensure_in_path "$binary_name"
        ok "${binary_name} — installed via cargo"
    else
        fail "${binary_name} — cargo failed"
        return 1
    fi
}

install_venv_tool() {
    local tool_name="$1"
    local pip_package="${2:-$1}"
    local binary="${3:-$tool_name}"
    local venv="${4:-$VENV_DIR}"

    if [[ -x "${venv}/bin/${binary}" ]] || smart_find_tool "$binary" &>/dev/null; then
        ok "${binary} — found"
        ensure_in_path "$binary"
        return 0
    fi

    info "Installing ${pip_package} in venv (${venv})..."
    if "${venv}/bin/pip" install "$pip_package" --quiet >> "$LOG_FILE" 2>&1; then
        [[ -x "${venv}/bin/${binary}" ]] && make_wrapper "$binary" "${venv}/bin/${binary}"
        ok "${binary} — installed in venv"
    else
        fail "${binary} — venv install failed"
        return 1
    fi
}

install_py_github_tool() {
    local cmd_name="$1"
    local pypi_name="$2"
    local github_url="$3"
    local script_name="${4:-auto}"

    if smart_find_tool "$cmd_name" &>/dev/null; then
        ok "${cmd_name} — found"
        return 0
    fi

    local tool_dir="${TOOLS_DIR}/github/${cmd_name}"

    if [[ -n "$pypi_name" ]]; then
        info "${cmd_name}: trying pip install ${pypi_name}..."
        if "${VENV_DIR}/bin/pip" install "$pypi_name" --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/${cmd_name}" ]]; then
                make_wrapper "$cmd_name" "${VENV_DIR}/bin/${cmd_name}"
                ok "${cmd_name} — installed via pip"
                return 0
            fi
        fi
        log "${cmd_name}: pip install failed, trying GitHub..."
    fi

    info "${cmd_name}: cloning from GitHub..."
    if [[ -d "$tool_dir" ]]; then
        ( cd "$tool_dir" && git pull -q >> "$LOG_FILE" 2>&1 ) || true
    else
        mkdir -p "$(dirname "$tool_dir")"
        local clone_cmd="git clone -q --depth 1"
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            local auth_url
            auth_url=$(echo "$github_url" | sed "s|https://|https://${GITHUB_TOKEN}@|")
            clone_cmd="$clone_cmd ${auth_url}"
        else
            clone_cmd="$clone_cmd ${github_url}"
        fi
        
        if ! eval "$clone_cmd" "$tool_dir" >> "$LOG_FILE" 2>&1; then
            fail "${cmd_name} — git clone failed"
            return 1
        fi
    fi

    if [[ -f "${tool_dir}/requirements.txt" ]]; then
        info "${cmd_name}: installing requirements.txt..."
        "${VENV_DIR}/bin/pip" install -r "${tool_dir}/requirements.txt" \
            --quiet >> "$LOG_FILE" 2>&1 || \
            warn "${cmd_name}: some requirements failed (non-fatal)"
    fi

    local main_script=""
    if [[ "$script_name" == "auto" ]]; then
        if [[ -f "${tool_dir}/${cmd_name}.py" ]]; then
            main_script="${tool_dir}/${cmd_name}.py"
        else
            main_script=$(find "$tool_dir" -maxdepth 2 -name "*.py" \
                -not -name "setup.py" -not -name "test*.py" \
                -not -path "*/test*" \
                | head -1)
        fi
    else
        main_script=$(find "$tool_dir" -maxdepth 3 -name "$script_name" 2>/dev/null | head -1)
    fi

    if [[ -z "$main_script" ]] || [[ ! -f "$main_script" ]]; then
        fail "${cmd_name} — could not find main script in ${tool_dir}"
        return 1
    fi

    chmod +x "$main_script"
    make_venv_wrapper "$cmd_name" "$VENV_DIR" "$main_script"
    ok "${cmd_name} — installed from GitHub (${main_script})"
    return 0
}

install_github_release() {
    local tool_name="$1"
    local releases_api="$2"
    local asset_pattern="$3"
    local binary_name="${4:-$tool_name}"
    local binary_subpath="${5:-$binary_name}"

    if smart_find_tool "$binary_name" &>/dev/null; then
        ok "${binary_name} — found"
        return 0
    fi

    info "Installing ${tool_name} from GitHub releases..."
    local release_json="/tmp/${tool_name}_release.json"
    
    local curl_cmd=(curl -fsSL --max-time 90 -o "$release_json")
    [[ -n "${GITHUB_TOKEN:-}" ]] && curl_cmd+=(-H "Authorization: token ${GITHUB_TOKEN}")
    curl_cmd+=("$releases_api")
    
    if ! "${curl_cmd[@]}" >> "$LOG_FILE" 2>&1; then
        warn "${tool_name} — could not fetch release info"
        return 1
    fi

    local asset_url
    asset_url=$(python3 -c "
import json, sys
try:
    data = json.load(open('${release_json}'))
    assets = data.get('assets', [])
    pattern = '${asset_pattern}'
    for a in assets:
        url = a.get('browser_download_url','')
        if pattern in url:
            print(url)
            break
except Exception as e:
    sys.exit(1)
" 2>/dev/null)

    if [[ -z "$asset_url" ]]; then
        warn "${tool_name} — no matching asset (pattern: ${asset_pattern})"
        return 1
    fi

    log "${tool_name} — downloading: ${asset_url}"
    local ext; [[ "$asset_url" == *.zip ]] && ext="zip" || ext="tar.gz"
    local archive="/tmp/${tool_name}.${ext}"
    local extract_dir="/tmp/${tool_name}_extract"

    safe_curl "$asset_url" "$archive" || { warn "${tool_name} — download failed"; return 1; }

    rm -rf "$extract_dir"; mkdir -p "$extract_dir"
    if [[ "$ext" == "zip" ]]; then
        unzip -q "$archive" -d "$extract_dir" >> "$LOG_FILE" 2>&1
    else
        tar -xzf "$archive" -C "$extract_dir" >> "$LOG_FILE" 2>&1
    fi
    rm -f "$archive"

    local found_bin
    found_bin=$(find "$extract_dir" -name "$binary_subpath" -type f 2>/dev/null | head -1)
    [[ -z "$found_bin" ]] && \
        found_bin=$(find "$extract_dir" -maxdepth 3 -type f -executable \
                    -not -name "*.sh" -not -name "LICENSE*" -not -name "README*" \
                    2>/dev/null | head -1)

    if [[ -n "$found_bin" ]]; then
        install -m 755 "$found_bin" "${LOCAL_BIN}/${binary_name}"
        ok "${binary_name} — installed from release"
    else
        warn "${tool_name} — binary not found in archive"
        return 1
    fi
    rm -rf "$extract_dir"
}

# ============================================================
# Pre-flight Checks
# ============================================================
do_preflight() {
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ PRE-FLIGHT CHECKS${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"

    grep -qi "kali" /etc/os-release 2>/dev/null && ok "Kali Linux detected" || \
        warn "Kali Linux not detected — some packages may not be available"

    [[ $EUID -eq 0 ]] && ok "Root confirmed" || { fail "Must run as root"; exit 1; }

    if curl -sf --max-time 5 https://1.1.1.1 &>/dev/null || \
       ping -c1 -W3 8.8.8.8 &>/dev/null; then
        ok "Internet active"
    else
        fail "No internet connection"; exit 1
    fi

    local free_gb; free_gb=$(df -BG / | awk 'NR==2{gsub("G",""); print $4}')
    [[ "$free_gb" -ge 15 ]] && ok "Disk: ${free_gb}GB free" || \
        warn "Low disk space: ${free_gb}GB (15GB+ recommended)"

    local ram_gb; ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    ok "RAM: ${ram_gb}GB"

    local hostname
    hostname=$(hostname)
    if ! grep -q "^127.0.0.1.*${hostname}" /etc/hosts 2>/dev/null; then
        echo "127.0.0.1   ${hostname}" >> /etc/hosts
        ok "Hostname ${hostname} added to /etc/hosts"
    fi

    mkdir -p "$(dirname "$LOG_FILE")" "$STATE_DIR" "$CONFIG_DIR" \
             "${TOOLS_DIR}"/{bin,wordlists,exploits,scripts,payloads,github} \
             "$C2_DIR" "$REDIRECTOR_DIR" "$EVASION_DIR" "$POSTEXPLOIT_DIR"
    info "Log: ${LOG_FILE}"
    
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Mode: ${YELLOW}MINIMAL${RESET} (lightweight installation)"
    else
        info "Mode: ${GREEN}FULL${RESET} (complete installation)"
    fi
    
    info "Setup starts in 3 seconds... (Ctrl+C to cancel)"
    sleep 3
}

# ============================================================
# STEP 0 — Network & DNS Hardening
# ============================================================
do_network_fix() {
    info "Hardening network / DNS for reliable downloads..."

    if ! curl -6 -sf --max-time 5 https://ipv6.google.com &>/dev/null; then
        warn "IPv6 unreachable — disabling for this session"
        sysctl -w net.ipv6.conf.all.disable_ipv6=1     >> "$LOG_FILE" 2>&1 || true
        sysctl -w net.ipv6.conf.default.disable_ipv6=1 >> "$LOG_FILE" 2>&1 || true
        cat >> /etc/sysctl.d/99-kali-master.conf << 'EOF' 2>/dev/null || true
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
        ok "IPv6 disabled"
    else
        ok "IPv6 reachable — keeping enabled"
    fi

    local current_ns
    current_ns=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | \
                 head -1 | awk '{print $2}')
    if ! host -W 3 google.com "${current_ns:-8.8.8.8}" &>/dev/null 2>&1; then
        warn "DNS (${current_ns}) misbehaving — adding fallbacks"
        local tmp_resolv; tmp_resolv=$(mktemp)
        {
            echo "# Added by kali-master v6.6.1 — reliable fallbacks"
            echo "nameserver 1.1.1.1"
            echo "nameserver 8.8.8.8"
            echo "nameserver 9.9.9.9"
            cat /etc/resolv.conf
        } > "$tmp_resolv"
        cp "$tmp_resolv" /etc/resolv.conf
        rm -f "$tmp_resolv"
        ok "DNS fallbacks added (1.1.1.1 / 8.8.8.8 / 9.9.9.9)"
    else
        ok "DNS (${current_ns}) is working"
    fi

    cat > /etc/apt/apt.conf.d/99-force-ipv4 << 'EOF'
Acquire::ForceIPv4 "true";
EOF
    ok "apt forced to IPv4"

    export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
    export GONOSUMDB="*"
    cat > /etc/profile.d/goproxy.sh << 'EOF'
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
EOF
    chmod +x /etc/profile.d/goproxy.sh
    ok "GOPROXY set with fallback chain (GONOSUMDB=*)"

    ok "Network hardening complete"
}

# ============================================================
# STEP 1 — Snapshot
# ============================================================
do_snapshot() {
    pgrep -x vmtoolsd &>/dev/null && \
        info "VMware detected — take a snapshot manually if needed"
    command -v timeshift &>/dev/null && \
        timeshift --create --comments "kali-master-v6.6.1-pre-install" \
                  --yes >> "$LOG_FILE" 2>&1 || true
    ok "Snapshot step complete"
}

# ============================================================
# STEP 2 — System Update + All Build Dependencies
# ============================================================
do_system_update() {
    export DEBIAN_FRONTEND=noninteractive
    info "Updating package lists..."
    apt-get update -qq >> "$LOG_FILE" 2>&1

    info "Upgrading installed packages..."
    apt-get upgrade -y -qq \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1

    local ALL_PKGS=(
        build-essential pkg-config cmake ninja-build meson
        autoconf automake libtool gcc g++ gcc-multilib g++-multilib
        nasm yasm git curl wget
        python3 python3-pip python3-venv python3-dev python3-setuptools
        python3-wheel pipx libpython3-dev
        libcurl4-openssl-dev libcurl4 curl
        libssl-dev libffi-dev libgmp-dev libmpfr-dev libmpc-dev
        libpcap-dev libpcap0.8 libnetfilter-queue-dev libnfnetlink-dev
        libmnl-dev libpq-dev libldap2-dev libsasl2-dev
        krb5-config libkrb5-dev
        libsqlite3-dev default-libmysqlclient-dev
        libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev libbz2-dev liblzma-dev
        libcapstone-dev libcapstone4 libelf-dev libiberty-dev
        libdwarf-dev binutils-dev libmagic-dev libmagic1
        default-jdk default-jre
        ruby-full ruby-dev
        cargo rustup
        golang-go
        vim tmux zsh fzf jq bc tree htop bat ripgrep fd-find
        socat netcat-openbsd strace ltrace tcpdump hexedit xxd
        bsdmainutils unzip p7zip-full tar gzip bzip2
        net-tools dnsutils whois iproute2 iputils-ping
        proxychains4 patchelf elfutils upx-ucl file
        nmap masscan wireshark-qt tshark sqlmap hydra medusa
        hashcat john steghide exiftool libimage-exiftool-perl
        binwalk foremost yara gdb gdb-multiarch gdbserver
        checksec radare2 wordlists seclists
        sublist3r
        nginx certbot python3-certbot-nginx
    )

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        info "Minimal mode: installing core packages only..."
        ALL_PKGS=(
            build-essential pkg-config git curl wget
            python3 python3-pip python3-venv python3-dev
            libcurl4-openssl-dev libssl-dev libffi-dev
            libpcap-dev libxml2-dev libxslt1-dev zlib1g-dev
            default-jdk ruby-full golang-go
            vim tmux zsh fzf jq tree htop
            net-tools dnsutils whois nmap
            sublist3r
        )
    fi

    info "Installing ${#ALL_PKGS[@]} packages..."
    local batch_size=20
    local total=${#ALL_PKGS[@]}
    local i=0
    while [[ $i -lt $total ]]; do
        local batch=("${ALL_PKGS[@]:$i:$batch_size}")
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            --fix-missing "${batch[@]}" >> "$LOG_FILE" 2>&1 || \
            warn "Some packages in batch $((i/batch_size+1)) failed — continuing"
        i=$((i + batch_size))
    done

    ok "System update + build dependencies complete"
}

# ============================================================
# STEP 3 — Python Virtual Environment
# ============================================================
do_python_venv() {
    info "Setting up central Python venv at ${VENV_DIR}..."

    if [[ ! -d "$VENV_DIR" ]]; then
        python3 -m venv "$VENV_DIR" >> "$LOG_FILE" 2>&1
        ok "venv created: ${VENV_DIR}"
    else
        ok "venv already exists: ${VENV_DIR}"
    fi

    "${VENV_DIR}/bin/pip" install --upgrade pip wheel setuptools \
        --quiet >> "$LOG_FILE" 2>&1

    local venv_packages=(
        requests httpx aiohttp flask fastapi uvicorn
        rich click typer pwntools impacket scapy
        cryptography pyOpenSSL paramiko pymongo redis
        sqlalchemy beautifulsoup4 lxml Pillow pycryptodome
        ropgadget r2pipe mitmproxy shodan censys
        arjun waymore dnsgen ldap3 bloodhound
        jwt netexec pysmb neo4j dnspython
        tqdm colorama tabulate xlsxwriter jinja2
        pyyaml toml parameterized
    )

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        venv_packages=(
            requests httpx pwntools impacket
            cryptography beautifulsoup4
            tqdm colorama tabulate
        )
    fi

    info "Installing ${#venv_packages[@]} Python packages in venv..."
    for pkg in "${venv_packages[@]}"; do
        "${VENV_DIR}/bin/pip" install "$pkg" --quiet >> "$LOG_FILE" 2>&1 && \
            ok "  pip: $pkg" || warn "  pip: $pkg — failed (non-critical)"
    done

    apt-get install -y -qq libcurl4-openssl-dev >> "$LOG_FILE" 2>&1 || true
    info "Installing wfuzz (with pycurl/openssl fix)..."
    if PYCURL_SSL_LIBRARY=openssl "${VENV_DIR}/bin/pip" install \
            pycurl --quiet >> "$LOG_FILE" 2>&1 && \
       "${VENV_DIR}/bin/pip" install wfuzz --quiet >> "$LOG_FILE" 2>&1; then
        ok "wfuzz — installed in venv"
    else
        warn "wfuzz pip failed — trying apt..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq wfuzz \
            >> "$LOG_FILE" 2>&1 && ok "wfuzz — installed via apt" || \
            warn "wfuzz — all methods failed"
    fi

    info "Installing frida-tools..."
    "${VENV_DIR}/bin/pip" install "frida-tools" --quiet >> "$LOG_FILE" 2>&1 && \
        ok "frida-tools — installed" || warn "frida-tools — failed"

    for pkg in capstone "keystone-engine" unicorn; do
        "${VENV_DIR}/bin/pip" install "$pkg" --quiet >> "$LOG_FILE" 2>&1 && \
            ok "  pip: $pkg" || warn "  pip: $pkg — failed"
    done

    info "Setting up isolated angr venv at ${ANGR_VENV}..."
    if [[ ! -d "$ANGR_VENV" ]]; then
        python3 -m venv "$ANGR_VENV" >> "$LOG_FILE" 2>&1
        "${ANGR_VENV}/bin/pip" install --upgrade pip wheel \
            --quiet >> "$LOG_FILE" 2>&1
    fi
    if "${ANGR_VENV}/bin/pip" install "protobuf<4" --quiet >> "$LOG_FILE" 2>&1 && \
       "${ANGR_VENV}/bin/pip" install angr --quiet >> "$LOG_FILE" 2>&1; then
        ok "angr — installed in isolated venv"
    else
        warn "angr — install failed"
    fi

    info "Setting up isolated FLARE venv at ${FLARE_VENV}..."
    if [[ ! -d "$FLARE_VENV" ]]; then
        python3 -m venv "$FLARE_VENV" >> "$LOG_FILE" 2>&1
        "${FLARE_VENV}/bin/pip" install --upgrade pip wheel \
            --quiet >> "$LOG_FILE" 2>&1
    fi
    for flare_pkg in flare-capa flare-floss; do
        local flare_bin; [[ "$flare_pkg" == "flare-capa" ]] && flare_bin="capa" || flare_bin="floss"
        if "${FLARE_VENV}/bin/pip" install "$flare_pkg" --quiet >> "$LOG_FILE" 2>&1; then
            [[ -x "${FLARE_VENV}/bin/${flare_bin}" ]] && \
                make_wrapper "$flare_bin" "${FLARE_VENV}/bin/${flare_bin}" && \
                ok "${flare_bin} — installed in FLARE venv"
        else
            warn "${flare_bin} — install failed"
        fi
    done

    if ! smart_find_tool "vol" &>/dev/null && \
       ! smart_find_tool "vol3" &>/dev/null; then
        "${VENV_DIR}/bin/pip" install volatility3 --quiet >> "$LOG_FILE" 2>&1 || true
    fi
    local vol_wrapper_created=0
    for volbin in vol3 vol; do
        if [[ -x "${VENV_DIR}/bin/${volbin}" ]] && [[ $vol_wrapper_created -eq 0 ]]; then
            make_wrapper "vol" "${VENV_DIR}/bin/${volbin}"
            make_wrapper "vol3" "${VENV_DIR}/bin/${volbin}"
            ok "vol/vol3 — wrapper -> ${volbin}"
            vol_wrapper_created=1
        fi
    done

    cat > /etc/profile.d/kali-venv.sh << VENV_PROFILE
# Kali Master v6.6.1 — Auto-activate Python venv
if [[ -f "${VENV_DIR}/bin/activate" ]]; then
    source "${VENV_DIR}/bin/activate"
fi
VENV_PROFILE
    chmod +x /etc/profile.d/kali-venv.sh

    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if ! grep -q "kali-venv" "$rc" 2>/dev/null; then
            cat >> "$rc" << RCEOF

# Kali Master v6.6.1 — Auto-activate Python venv
if [[ -f "${VENV_DIR}/bin/activate" ]]; then
    source "${VENV_DIR}/bin/activate"
fi
RCEOF
        fi
    done

    ok "Python venv ready"
}

# ============================================================
# STEP 4 — Go Lang
# ============================================================
do_golang() {
    if tool_path=$(smart_find_tool "go"); then
        local current_ver; current_ver=$("$tool_path" version 2>/dev/null)
        ok "Go found: $current_ver"
        export PATH="$PATH:$(dirname "$tool_path"):$GOPATH_BIN"
        return 0
    fi

    info "Fetching latest Go version..."
    local GO_VERSION
    GO_VERSION=$(curl -sf "https://go.dev/dl/?mode=json" 2>/dev/null | \
        python3 -c "
import sys,json
data=json.load(sys.stdin)
stable=[x for x in data if x.get('stable',False)]
print(stable[0]['version'] if stable else 'go1.23.4')
" 2>/dev/null) || GO_VERSION="go1.23.4"

    info "Installing ${GO_VERSION}..."
    local ARCH="linux-amd64"
    local go_tar="${GO_VERSION}.${ARCH}.tar.gz"

    safe_wget "https://go.dev/dl/${go_tar}" "/tmp/${go_tar}" || {
        fail "Go download failed"; return 1
    }

    rm -rf /usr/local/go
    tar -C /usr/local -xzf "/tmp/${go_tar}" >> "$LOG_FILE" 2>&1
    rm -f "/tmp/${go_tar}"

    export PATH="$PATH:/usr/local/go/bin:$GOPATH_BIN"

    cat > /etc/profile.d/golang.sh << 'GOEOF'
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
GOEOF
    chmod +x /etc/profile.d/golang.sh

    ok "Go $(go version) installed"
}

# ============================================================
# STEP 5 — Docker
# ============================================================
do_docker() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Docker — skipped in minimal mode"
        return 0
    fi

    if smart_find_tool "docker" &>/dev/null; then
        ok "Docker found: $(docker --version 2>/dev/null)"
        systemctl enable docker --quiet >> "$LOG_FILE" 2>&1 || true
        systemctl start  docker          >> "$LOG_FILE" 2>&1 || true
        return 0
    fi

    info "Installing Docker CE..."
    export DEBIAN_FRONTEND=noninteractive

    apt-get remove -y -qq docker docker-engine docker.io containerd runc \
        2>/dev/null || true

    install -m 0755 -d /etc/apt/keyrings
    safe_curl "https://download.docker.com/linux/debian/gpg" \
              "/etc/apt/keyrings/docker.asc" || {
        warn "Docker GPG key download failed"; return 1
    }
    chmod a+r /etc/apt/keyrings/docker.asc

    local DISTRO_CODENAME
    DISTRO_CODENAME=$(. /etc/os-release && echo "${VERSION_CODENAME:-bookworm}")
    grep -qi "kali" /etc/os-release && DISTRO_CODENAME="bookworm"

    cat > /etc/apt/sources.list.d/docker.list << DOCKER_REPO
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${DISTRO_CODENAME} stable
DOCKER_REPO

    apt-get update -qq >> "$LOG_FILE" 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing \
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin \
        >> "$LOG_FILE" 2>&1

    systemctl enable docker --quiet >> "$LOG_FILE" 2>&1
    systemctl start  docker          >> "$LOG_FILE" 2>&1

    ok "Docker CE installed: $(docker --version 2>/dev/null)"
}

# ============================================================
# STEP 6 — Bug Bounty Tools
# ============================================================
do_bugbounty() {
    info "Installing Bug Bounty tools..."
    local errors=0

    local pd_tools=(
        "subfinder:github.com/projectdiscovery/subfinder/v2/cmd/subfinder:subfinder"
        "httpx:github.com/projectdiscovery/httpx/cmd/httpx:httpx"
        "nuclei:github.com/projectdiscovery/nuclei/v3/cmd/nuclei:nuclei"
        "dnsx:github.com/projectdiscovery/dnsx/cmd/dnsx:dnsx"
        "naabu:github.com/projectdiscovery/naabu/v2/cmd/naabu:naabu"
        "katana:github.com/projectdiscovery/katana/cmd/katana:katana"
        "interactsh-client:github.com/projectdiscovery/interactsh/cmd/interactsh-client:interactsh-client"
        "notify:github.com/projectdiscovery/notify/cmd/notify:notify"
        "mapcidr:github.com/projectdiscovery/mapcidr/cmd/mapcidr:mapcidr"
        "tlsx:github.com/projectdiscovery/tlsx/cmd/tlsx:tlsx"
        "shuffledns:github.com/projectdiscovery/shuffledns/cmd/shuffledns:shuffledns"
        "asnmap:github.com/projectdiscovery/asnmap/cmd/asnmap:asnmap"
        "alterx:github.com/projectdiscovery/alterx/cmd/alterx:alterx"
        "uncover:github.com/projectdiscovery/uncover/cmd/uncover:uncover"
        "cvemap:github.com/projectdiscovery/cvemap/cmd/cvemap:cvemap"
        "pdtm:github.com/projectdiscovery/pdtm/cmd/pdtm:pdtm"
        "cloudlist:github.com/projectdiscovery/cloudlist/cmd/cloudlist:cloudlist"
        "simplehttpserver:github.com/projectdiscovery/simplehttpserver/cmd/simplehttpserver:simplehttpserver"
        "proxify:github.com/projectdiscovery/proxify/cmd/proxify:proxify"
    )

    local other_go_tools=(
        "dalfox:github.com/hahwul/dalfox/v2:dalfox"
        "gobuster:github.com/OJ/gobuster/v3:gobuster"
        "ffuf:github.com/ffuf/ffuf/v2:ffuf"
        "trufflehog:github.com/trufflesecurity/trufflehog/v3:trufflehog"
        "gau:github.com/lc/gau/v2/cmd/gau:gau"
        "hakrawler:github.com/hakluke/hakrawler:hakrawler"
        "anew:github.com/tomnomnom/anew:anew"
        "qsreplace:github.com/tomnomnom/qsreplace:qsreplace"
        "gf:github.com/tomnomnom/gf:gf"
        "waybackurls:github.com/tomnomnom/waybackurls:waybackurls"
        "assetfinder:github.com/tomnomnom/assetfinder:assetfinder"
        "httprobe:github.com/tomnomnom/httprobe:httprobe"
        "meg:github.com/tomnomnom/meg:meg"
        "unfurl:github.com/tomnomnom/unfurl:unfurl"
        "gospider:github.com/jaeles-project/gospider:gospider"
        "gron:github.com/tomnomnom/gron:gron"
        "dsieve:github.com/trickest/dsieve:dsieve"
        "getJS:github.com/003random/getJS:getJS"
        "subjs:github.com/lc/subjs:subjs"
    )

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        pd_tools=(
            "subfinder:github.com/projectdiscovery/subfinder/v2/cmd/subfinder:subfinder"
            "httpx:github.com/projectdiscovery/httpx/cmd/httpx:httpx"
            "nuclei:github.com/projectdiscovery/nuclei/v3/cmd/nuclei:nuclei"
            "dnsx:github.com/projectdiscovery/dnsx/cmd/dnsx:dnsx"
        )
        other_go_tools=(
            "gobuster:github.com/OJ/gobuster/v3:gobuster"
            "ffuf:github.com/ffuf/ffuf/v2:ffuf"
            "gau:github.com/lc/gau/v2/cmd/gau:gau"
        )
    fi

    info "Installing ProjectDiscovery Suite..."
    for entry in "${pd_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        install_go_tool "$name" "$package" "$binary" || \
            errors=$((errors + 1)) || true
    done

    info "Installing other Go tools..."
    for entry in "${other_go_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        install_go_tool "$name" "$package" "$binary" || \
            errors=$((errors + 1)) || true
    done

    info "Installing Bug Bounty tools via apt..."
    local apt_bb=(sqlmap whatweb dirb nikto wpscan amass)
    for t in "${apt_bb[@]}"; do
        install_apt_tool "$t" || errors=$((errors + 1)) || true
    done

    install_cargo_tool "feroxbuster" || errors=$((errors + 1)) || true

    info "Installing Python Bug Bounty tools..."
    install_venv_tool "arjun"     "arjun"     "arjun"     || errors=$((errors + 1)) || true
    install_venv_tool "waymore"   "waymore"   "waymore"   || errors=$((errors + 1)) || true
    install_venv_tool "dnsgen"    "dnsgen"    "dnsgen"    || errors=$((errors + 1)) || true
    install_venv_tool "dirsearch" "dirsearch" "dirsearch" || errors=$((errors + 1)) || true
    install_venv_tool "commix"    "commix"    "commix"    || errors=$((errors + 1)) || true

    if ! smart_find_tool "sublist3r" &>/dev/null; then
        install_py_github_tool "sublist3r" \
            "sublist3r" \
            "https://github.com/aboul3la/Sublist3r.git" \
            "sublist3r.py" || errors=$((errors + 1)) || true
    fi

    install_py_github_tool "xsstrike" \
        "" \
        "https://github.com/s0md3v/XSStrike.git" \
        "xsstrike.py" || errors=$((errors + 1)) || true

    install_py_github_tool "corsy" \
        "" \
        "https://github.com/s0md3v/Corsy.git" \
        "corsy.py" || errors=$((errors + 1)) || true

    install_py_github_tool "linkfinder" \
        "" \
        "https://github.com/GerbenJavado/LinkFinder.git" \
        "linkfinder.py" || errors=$((errors + 1)) || true

    install_py_github_tool "ssrfmap" \
        "" \
        "https://github.com/swisskyrepo/SSRFmap.git" \
        "ssrfmap.py" || errors=$((errors + 1)) || true

    install_py_github_tool "jwt_tool" \
        "" \
        "https://github.com/ticarpi/jwt_tool.git" \
        "jwt_tool.py" || errors=$((errors + 1)) || true

    smart_find_tool "nuclei" &>/dev/null && \
        nuclei -update-templates -silent >> "$LOG_FILE" 2>&1 || true

    if smart_find_tool "gf" &>/dev/null && [[ ! -d "$HOME/.gf" ]]; then
        git clone -q https://github.com/1ndianl33t/Gf-Patterns "$HOME/.gf" \
            >> "$LOG_FILE" 2>&1 || true
        ok "gf patterns installed"
    fi

    [[ $errors -eq 0 ]] && ok "Bug Bounty tools complete" || \
        warn "Bug Bounty: ${errors} tool(s) failed (see log)"
}

# ============================================================
# STEP 7 — Reverse Engineering
# ============================================================
do_reversing() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Reverse Engineering tools — skipped in minimal mode"
        return 0
    fi

    info "Installing Reverse Engineering tools..."
    local errors=0

    local re_apt=(
        gdb gdb-multiarch gdbserver radare2 ltrace strace
        binwalk foremost checksec patchelf elfutils
        nasm yasm yara objdump readelf strings file
        hexedit xxd bsdmainutils upx-ucl
        qemu-user qemu-user-static libc6-dev-i386 valgrind
        ghidra apktool dex2jar jadx rizin cutter iaito
    )

    info "Installing RE apt packages..."
    for pkg in "${re_apt[@]}"; do
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            --fix-missing "$pkg" >> "$LOG_FILE" 2>&1 && \
            ok "  apt: $pkg" || warn "  apt: $pkg — not available"
    done

    if [[ ! -d "$HOME/.pwndbg" ]]; then
        info "Installing pwndbg..."
        git clone -q https://github.com/pwndbg/pwndbg "$HOME/.pwndbg" \
            >> "$LOG_FILE" 2>&1
        ( cd "$HOME/.pwndbg" && \
          VENV_HOME="${TOOLS_DIR}/pwndbg-venv" ./setup.sh >> "$LOG_FILE" 2>&1 ) && \
            ok "pwndbg installed" || warn "pwndbg failed"
    else
        ok "pwndbg — found"
    fi

    if ! grep -q "gef" "$HOME/.gdbinit" 2>/dev/null; then
        info "Installing GEF..."
        safe_wget "https://gef.blah.cat/py" /tmp/gef.py && \
            install -m 644 /tmp/gef.py /usr/local/share/gef.py && \
            echo "source /usr/local/share/gef.py" >> "$HOME/.gdbinit" && \
            ok "GEF installed" || warn "GEF failed"
    else
        ok "GEF — already in .gdbinit"
    fi

    if [[ ! -d "${TOOLS_DIR}/peda" ]]; then
        git clone -q https://github.com/longld/peda.git "${TOOLS_DIR}/peda" \
            >> "$LOG_FILE" 2>&1 && ok "PEDA installed" || warn "PEDA failed"
        cat > "${LOCAL_BIN}/gdb-peda" << GDBPEDA
#!/usr/bin/env bash
exec gdb -q -ix "${TOOLS_DIR}/peda/peda.py" "\$@"
GDBPEDA
        chmod +x "${LOCAL_BIN}/gdb-peda"
    else
        ok "PEDA — found"
    fi

    install_venv_tool "ROPgadget"  "ROPgadget"  "ROPgadget" || errors=$((errors+1)) || true
    install_venv_tool "ropper"     "ropper"     "ropper"    || errors=$((errors+1)) || true
    install_venv_tool "pefile"     "pefile"                 || errors=$((errors+1)) || true
    install_venv_tool "r2pipe"     "r2pipe"                 || errors=$((errors+1)) || true
    install_venv_tool "pwntools"   "pwntools"   "pwn"       || errors=$((errors+1)) || true

    install_venv_tool "oletools" "oletools" "olevba" || errors=$((errors+1)) || true
    for oletool in olevba oledump mraptor oleobj rtfobj; do
        [[ -f "${VENV_DIR}/bin/${oletool}" ]] && \
            make_wrapper "$oletool" "${VENV_DIR}/bin/${oletool}" || true
    done

    for flare_bin in capa floss; do
        smart_find_tool "$flare_bin" &>/dev/null && ok "${flare_bin} — found" || \
            warn "${flare_bin} — not found (check FLARE venv)"
    done

    for gem_name in one_gadget seccomp-tools; do
        if ! smart_find_tool "$gem_name" &>/dev/null; then
            gem install "$gem_name" --quiet >> "$LOG_FILE" 2>&1 && \
                ok "${gem_name} installed" || warn "${gem_name} failed"
        else
            ok "${gem_name} — found"
        fi
    done

    [[ $errors -eq 0 ]] && ok "Reversing tools complete" || \
        warn "RE: ${errors} tool(s) failed (see log)"
}

# ============================================================
# STEP 8 — CTF Tools
# ============================================================
do_ctf() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "CTF tools — skipped in minimal mode"
        return 0
    fi

    info "Installing CTF tools..."

    local ctf_apt=(
        john hashcat hydra medusa steghide exiftool
        binwalk netcat-openbsd socat libimage-exiftool-perl
        outguess testdisk photorec foremost exiv2
        stegseek zsteg
    )
    for pkg in "${ctf_apt[@]}"; do
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            --fix-missing "$pkg" >> "$LOG_FILE" 2>&1 || true
    done

    if [[ ! -d "${TOOLS_DIR}/RsaCtfTool" ]]; then
        git clone -q https://github.com/RsaCtfTool/RsaCtfTool \
            "${TOOLS_DIR}/RsaCtfTool" >> "$LOG_FILE" 2>&1
        "${VENV_DIR}/bin/pip" install \
            -r "${TOOLS_DIR}/RsaCtfTool/requirements.txt" \
            --quiet >> "$LOG_FILE" 2>&1 || true
        make_venv_wrapper "rsactftool" "$VENV_DIR" \
            "${TOOLS_DIR}/RsaCtfTool/RsaCtfTool.py"
        ok "RsaCtfTool installed"
    else
        ok "RsaCtfTool — found"
    fi

    ok "CTF tools complete"
}

# ============================================================
# STEP 9 — Active Directory & Network Tools
# ============================================================
do_ad_network() {
    info "Installing Active Directory and Network tools..."

    local ad_apt=(
        crackmapexec evil-winrm bloodhound neo4j
        impacket-scripts ldap-utils smbclient smbmap
        enum4linux samba-common-bin kerbrute responder
        nbtscan onesixtyone snmpcheck dnschef dnsmasq
        netexec
    )

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        ad_apt=(
            crackmapexec evil-winrm bloodhound neo4j
            impacket-scripts smbclient nxc
        )
    fi

    for pkg in "${ad_apt[@]}"; do
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            --fix-missing "$pkg" >> "$LOG_FILE" 2>&1 || true
    done

    if ! smart_find_tool "kerbrute" &>/dev/null; then
        info "kerbrute not found via apt — trying go install..."
        install_go_tool "kerbrute" \
            "github.com/ropnop/kerbrute" "kerbrute" || \
        install_github_release "kerbrute" \
            "https://api.github.com/repos/ropnop/kerbrute/releases/latest" \
            "linux_amd64" "kerbrute" "kerbrute" || \
            warn "kerbrute — all methods failed"
    else
        ok "kerbrute — found"
    fi

    for pkg in ettercap-text-only bettercap; do
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            --fix-missing "$pkg" >> "$LOG_FILE" 2>&1 && \
            ok "${pkg} installed" || warn "${pkg} — not available"
    done

    "${VENV_DIR}/bin/pip" install impacket --quiet >> "$LOG_FILE" 2>&1 && \
        ok "impacket (library) — in venv" || warn "impacket pip failed"

    for script in psexec smbexec wmiexec secretsdump GetUserSPNs \
                  GetNPUsers lookupsid samrdump rpcdump; do
        local found_script=""
        for search_loc in \
            "/usr/bin/${script}.py" \
            "${VENV_DIR}/bin/${script}.py" \
            "/usr/share/doc/python3-impacket/examples/${script}.py" \
            "/usr/share/impacket/examples/${script}.py"; do
            if [[ -f "$search_loc" ]]; then
                found_script="$search_loc"; break
            fi
        done
        [[ -n "$found_script" ]] && make_wrapper "$script" "$found_script" || true
    done

    if ! smart_find_tool "nxc" &>/dev/null; then
        install_venv_tool "netexec" "netexec" "nxc" || true
    else
        ok "nxc — found"
    fi

    ok "AD & Network tools complete"
}

# ============================================================
# STEP 10 — Cloud & Container Security
# ============================================================
do_cloud_security() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Cloud & Container tools — skipped in minimal mode"
        return 0
    fi

    info "Installing Cloud & Container Security tools..."

    if ! smart_find_tool "trivy" &>/dev/null; then
        install_github_release "trivy" \
            "https://api.github.com/repos/aquasecurity/trivy/releases/latest" \
            "Linux-64bit.tar.gz" "trivy" "trivy" || \
            warn "trivy — all methods failed"
    else
        ok "trivy — found"
    fi

    if ! smart_find_tool "grype" &>/dev/null; then
        install_github_release "grype" \
            "https://api.github.com/repos/anchore/grype/releases/latest" \
            "linux_amd64.tar.gz" "grype" "grype" || \
            warn "grype — all methods failed"
    else
        ok "grype — found"
    fi

    if ! smart_find_tool "syft" &>/dev/null; then
        install_github_release "syft" \
            "https://api.github.com/repos/anchore/syft/releases/latest" \
            "linux_amd64.tar.gz" "syft" "syft" || \
            warn "syft — all methods failed"
    else
        ok "syft — found"
    fi

    if ! smart_find_tool "kubectl" &>/dev/null; then
        info "Installing kubectl..."
        local k8s_ver kubectl_ok=0

        k8s_ver=$(curl -sf --max-time 10 \
            "https://dl.k8s.io/release/stable.txt" 2>/dev/null) || \
            k8s_ver="v1.30.0"

        if safe_curl \
            "https://dl.k8s.io/release/${k8s_ver}/bin/linux/amd64/kubectl" \
            "${LOCAL_BIN}/kubectl"; then
            chmod +x "${LOCAL_BIN}/kubectl"
            kubectl_ok=1
        fi

        if [[ $kubectl_ok -eq 0 ]]; then
            warn "kubectl direct download failed — trying apt..."
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                --fix-missing kubectl >> "$LOG_FILE" 2>&1 && kubectl_ok=1 || true
        fi

        [[ $kubectl_ok -eq 1 ]] && ok "kubectl installed" || \
            warn "kubectl — all methods failed"
    else
        ok "kubectl — found"
    fi

    if ! smart_find_tool "aws" &>/dev/null; then
        info "Installing AWS CLI..."
        local aws_ok=0

        if safe_curl \
            "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
            /tmp/awscliv2.zip; then
            unzip -q /tmp/awscliv2.zip -d /tmp/awsinstall >> "$LOG_FILE" 2>&1 && \
            /tmp/awsinstall/aws/install >> "$LOG_FILE" 2>&1 && aws_ok=1
            rm -rf /tmp/awscliv2.zip /tmp/awsinstall
        fi

        if [[ $aws_ok -eq 0 ]]; then
            warn "AWS official installer failed — trying apt..."
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                awscli >> "$LOG_FILE" 2>&1 && aws_ok=1 || true
        fi

        if [[ $aws_ok -eq 0 ]]; then
            warn "AWS apt failed — trying pip..."
            "${VENV_DIR}/bin/pip" install awscli --quiet >> "$LOG_FILE" 2>&1 && \
            [[ -x "${VENV_DIR}/bin/aws" ]] && \
                make_wrapper "aws" "${VENV_DIR}/bin/aws" && aws_ok=1 || true
        fi

        [[ $aws_ok -eq 1 ]] && ok "AWS CLI installed" || \
            warn "AWS CLI — all methods failed"
    else
        ok "AWS CLI — found"
    fi

    ok "Cloud security tools complete"
}

# ============================================================
# STEP 11 — Wordlists
# ============================================================
do_wordlists() {
    info "Setting up Wordlists..."

    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        wordlists seclists --fix-missing >> "$LOG_FILE" 2>&1 || true

    if [[ ! -d /opt/wordlists/SecLists ]] && \
       [[ ! -d /usr/share/seclists ]]; then
        info "Cloning SecLists..."
        git clone -q --depth 1 https://github.com/danielmiessler/SecLists \
            /opt/wordlists/SecLists >> "$LOG_FILE" 2>&1 && \
            ok "SecLists downloaded" || warn "SecLists — clone failed"
    else
        ok "SecLists — found"
    fi

    [[ -f /usr/share/wordlists/rockyou.txt.gz ]] && \
    [[ ! -f /usr/share/wordlists/rockyou.txt ]] && \
        gunzip /usr/share/wordlists/rockyou.txt.gz && \
        ok "rockyou.txt ready"

    ln -sf /usr/share/wordlists /opt/wordlists/kali 2>/dev/null || true
    [[ -d /usr/share/seclists ]] && \
        ln -sf /usr/share/seclists /opt/wordlists/SecLists 2>/dev/null || true

    ok "Wordlists ready"
}

# ============================================================
# STEP 12 — Shell Configuration (with Powerlevel10k)
# ============================================================
do_shell_config() {
    info "Configuring shell with Powerlevel10k..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL \
                https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended >> "$LOG_FILE" 2>&1
        ok "Oh-My-Zsh installed"
    else
        ok "Oh-My-Zsh — found"
    fi

    local zsh_bin; zsh_bin=$(command -v zsh)
    [[ "$(getent passwd root | cut -d: -f7)" != "$zsh_bin" ]] && \
        chsh -s "$zsh_bin" root >> "$LOG_FILE" 2>&1 || true

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
        ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
    )

    for plugin in "${!plugins[@]}"; do
        local plugin_path="${ZSH_CUSTOM}/plugins/$plugin"
        [[ -d "$plugin_path" ]] && ok "plugin: $plugin — found" && continue
        git clone -q "${plugins[$plugin]}" "$plugin_path" \
            >> "$LOG_FILE" 2>&1 && \
            ok "plugin: $plugin installed" || warn "plugin: $plugin failed"
    done

    info "Installing Powerlevel10k..."
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k" >> "$LOG_FILE" 2>&1 && \
            ok "Powerlevel10k cloned" || warn "Powerlevel10k clone failed"
    else
        ok "Powerlevel10k — found"
    fi

    cat > "$HOME/.p10k.zsh" << 'P10K'
# Powerlevel10k — Professional Kali Hacker Theme
typeset -g POWERLEVEL9K_MODE='nerdfont-complete'
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
(( ! ${+functions[p10k]} )) || p10k reload
P10K

    cat > "$HOME/.kali_env.zsh" << KALI_ENV
# Kali Master v6.6.1 — Environment Configuration
export PATH="\$PATH:/usr/local/go/bin:\$HOME/go/bin:\$HOME/.local/bin"
export PATH="\$PATH:\$HOME/.cargo/bin:/opt/tools/bin:/usr/local/bin"
export PATH="\$PATH:${EVASION_DIR}:${POSTEXPLOIT_DIR}"
export GOPATH="\$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"

if [[ -f "${VENV_DIR}/bin/activate" ]]; then
    source "${VENV_DIR}/bin/activate"
fi

export WORDLISTS="/opt/wordlists"
export SECLISTS="\${WORDLISTS}/SecLists"
export ROCKYOU="/usr/share/wordlists/rockyou.txt"

alias ll='ls -lahF --color=auto'
alias grep='grep --color=auto'
alias c2='c2-menu'
alias lab='lab-manager'
alias evade='evasion-menu'
alias postex='postexploit-menu'

[[ -f "\$HOME/.config/kali-master/load_secrets.sh" ]] && \
    source "\$HOME/.config/kali-master/load_secrets.sh"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
KALI_ENV

    if ! grep -q "kali_env.zsh" "$HOME/.zshrc" 2>/dev/null; then
        printf '\n# Kali Master v6.6.1\n[[ -f "$HOME/.kali_env.zsh" ]] && source "$HOME/.kali_env.zsh"\n' \
            >> "$HOME/.zshrc"
    fi

    if ! grep -q "powerlevel10k" "$HOME/.zshrc" 2>/dev/null; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    fi

    grep -q "^plugins=" "$HOME/.zshrc" 2>/dev/null && \
        sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions colored-man-pages extract z sudo)/' \
        "$HOME/.zshrc" || true

    ok "Shell configuration complete with Powerlevel10k"
}

# ============================================================
# STEP 13 — Secrets Manager
# ============================================================
do_secrets() {
    mkdir -p "$CONFIG_DIR"
    local secrets_file="$CONFIG_DIR/secrets.env"

    if [[ ! -f "$secrets_file" ]]; then
        cat > "$secrets_file" << 'SECRETS'
# Kali Master v6.6.1 — Secrets Manager
export GITHUB_TOKEN=""
export SHODAN_API_KEY=""
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export HACKERONE_TOKEN=""
export BUGCROWD_TOKEN=""
export CLOUDFLARE_API_TOKEN=""
SECRETS
        chmod 600 "$secrets_file"
    fi

    cat > "$CONFIG_DIR/load_secrets.sh" << LOAD
#!/bin/bash
[[ -f "$CONFIG_DIR/secrets.env" ]] && source "$CONFIG_DIR/secrets.env"
LOAD
    chmod 600 "$CONFIG_DIR/load_secrets.sh"
    ok "Secrets manager ready: ${secrets_file}"
}

# ============================================================
# STEP 14 — VM Optimization & Hardening
# ============================================================
do_vm_hardening() {
    info "Applying system settings..."

    cat > /etc/sysctl.d/99-kali-master.conf << 'SYSCTL'
kernel.yama.ptrace_scope = 0
fs.file-max = 500000
net.core.somaxconn = 65535
SYSCTL
    sysctl -p /etc/sysctl.d/99-kali-master.conf >> "$LOG_FILE" 2>&1 || true

    ok "VM hardening complete"
}

# ============================================================
# STEP 15 — Update Manager
# ============================================================
do_update_manager() {
    cat > "${LOCAL_BIN}/update-tools" << 'UPDATE_SCRIPT'
#!/usr/bin/env bash
echo "[*] Updating all tools..."
apt-get update -qq && apt-get upgrade -y -qq
echo "[✔] Update complete"
UPDATE_SCRIPT
    chmod +x "${LOCAL_BIN}/update-tools"

    ok "Update scripts created"
}

# ============================================================
# STEP 16 — Helper Scripts
# ============================================================
do_helper_scripts() {
    cat > "${LOCAL_BIN}/bb-recon" << 'BB_RECON'
#!/usr/bin/env bash
[[ -z "${1:-}" ]] && { echo "Usage: bb-recon <domain>"; exit 1; }
DOMAIN="$1"
OUT="$HOME/bugbounty/${DOMAIN}/recon_$(date +%Y%m%d_%H%M)"
mkdir -p "$OUT"
echo "[*] Recon -> $DOMAIN | Output: $OUT"
subfinder -d "$DOMAIN" -silent -o "$OUT/subfinder.txt" 2>/dev/null || true
echo "[✔] Recon complete -> $OUT"
BB_RECON
    chmod +x "${LOCAL_BIN}/bb-recon"

    cat > "${LOCAL_BIN}/newbb" << 'NEWBB'
#!/usr/bin/env bash
[[ -z "${1:-}" ]] && { echo "Usage: newbb <domain>"; exit 1; }
DOMAIN="$1"
DIR="$HOME/bugbounty/$DOMAIN"
mkdir -p "$DIR"/{recon,exploits,reports,screenshots,loot,notes}
echo "[✔] Bug Bounty workspace -> $DIR"
NEWBB
    chmod +x "${LOCAL_BIN}/newbb"

    cat > "${LOCAL_BIN}/newctf" << 'NEWCTF'
#!/usr/bin/env bash
[[ -z "${1:-}" ]] && { echo "Usage: newctf <name> [htb|thm|ctfd]"; exit 1; }
NAME="$1"; PLATFORM="${2:-ctf}"
DIR="$HOME/ctf/${PLATFORM}/${NAME}"
mkdir -p "$DIR"/{web,pwn,crypto,forensics,misc,re,stego,notes}
echo "[✔] CTF workspace -> $DIR"
NEWCTF
    chmod +x "${LOCAL_BIN}/newctf"

    ok "Helper scripts installed"
}

# ============================================================
# STEP 17 — Red Team / C2 Frameworks
# ============================================================
do_redteam_c2() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Red Team C2 — skipped in minimal mode"
        return 0
    fi

    info "Installing modern C2 frameworks..."

    mkdir -p "$C2_DIR"

    # 1. Sliver
    if ! smart_find_tool "sliver-server" &>/dev/null; then
        info "Installing Sliver C2..."
        if curl -fsSL https://sliver.sh/install | bash >> "$LOG_FILE" 2>&1; then
            if [[ -f /root/sliver-server ]]; then
                mv /root/sliver-server /usr/local/bin/
                chmod +x /usr/local/bin/sliver-server
            fi
            ok "Sliver installed successfully"
        else
            warn "Sliver installation failed"
        fi
    else
        ok "Sliver — already installed"
    fi

    # 2. Havoc — Smart Build with submodules
    if [[ ! -d "/opt/Havoc" ]]; then
        info "Cloning Havoc C2 with submodules..."
        git clone --recurse-submodules \
            https://github.com/HavocFramework/Havoc.git /opt/Havoc \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/Havoc" ]]; then
        info "Building Havoc (smart build)..."
        cd /opt/Havoc || return 1
        
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            build-essential cmake libssl-dev libboost-all-dev \
            qtbase5-dev qt5-qmake golang-go mingw-w64 nasm \
            >> "$LOG_FILE" 2>&1
        
        mkdir -p /opt/Havoc/teamserver/data
        if [[ ! -f /tmp/mingw-musl-64.tgz ]]; then
            wget -q https://musl.cc/x86_64-w64-mingw32-cross.tgz \
                -O /tmp/mingw-musl-64.tgz
        fi
        if [[ ! -f /tmp/mingw-musl-32.tgz ]]; then
            wget -q https://musl.cc/i686-w64-mingw32-cross.tgz \
                -O /tmp/mingw-musl-32.tgz
        fi
        tar zxf /tmp/mingw-musl-64.tgz -C /opt/Havoc/teamserver/data/ 2>/dev/null || true
        tar zxf /tmp/mingw-musl-32.tgz -C /opt/Havoc/teamserver/data/ 2>/dev/null || true
        
        cd /opt/Havoc/teamserver
        export GOPATH="$HOME/go"
        export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
        GO111MODULE="on" go build -ldflags="-s -w" -o ../havoc main.go \
            >> "$LOG_FILE" 2>&1
        
        cd /opt/Havoc/client
        make >> "$LOG_FILE" 2>&1 || true
        
        cat > /usr/local/bin/havoc << 'EOF'
#!/usr/bin/env bash
cd /opt/Havoc
if [[ "$1" == "server" ]]; then
    sudo ./havoc server --profile ./profiles/havoc.yaotl "${@:2}"
else
    ./havoc "$@"
fi
EOF
        chmod +x /usr/local/bin/havoc
        ok "Havoc built and ready"
    fi

    # 3. Mythic — Correct URL + Password Setup + Safe Database Reset
    if [[ ! -d "/opt/Mythic" ]]; then
        info "Cloning Mythic C2..."
        git clone --depth=1 https://github.com/its-a-feature/Mythic.git /opt/Mythic \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/Mythic" ]]; then
        cd /opt/Mythic || return 1
        
        if ! grep -q "MYTHIC_ADMIN_PASSWORD" .env 2>/dev/null; then
            echo 'MYTHIC_ADMIN_PASSWORD="Admin123!"' >> .env
            echo 'POSTGRES_PASSWORD="MythicPostgres123!"' >> .env
            echo 'RABBITMQ_PASSWORD="MythicRabbit123!"' >> .env
        fi
        
        info "Resetting Mythic database (safe)..."
        echo -e "y\ny" | ./mythic-cli database reset \
            >> "$LOG_FILE" 2>&1 || true
        git checkout -- postgres-docker/ >> "$LOG_FILE" 2>&1 || true
        
        info "Starting Mythic..."
        ./mythic-cli start >> "$LOG_FILE" 2>&1
        
        ln -sf /opt/Mythic/mythic-cli /usr/local/bin/mythic-cli 2>/dev/null
        ok "Mythic ready (Login: mythic_admin / Admin123!)"
    fi

    # 4. Covenant — with libssl1.1 fix + dotnet version check
    if [[ ! -d "/opt/Covenant" ]]; then
        info "Cloning Covenant C2..."
        git clone --recurse-submodules \
            https://github.com/cobbr/Covenant.git /opt/Covenant \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/Covenant/Covenant" ]]; then
        info "Installing libssl1.1 for Covenant..."
        wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
            -O /tmp/libssl.deb
        dpkg -i /tmp/libssl.deb >> "$LOG_FILE" 2>&1 || true
        
        cd /opt/Covenant/Covenant
        if command -v dotnet &>/dev/null; then
            local dotnet_ver
            dotnet_ver=$(dotnet --version 2>/dev/null | cut -d. -f1)
            if [[ -n "$dotnet_ver" && "$dotnet_ver" =~ ^[0-9]+$ && "$dotnet_ver" -lt 5 ]]; then
                warn "Covenant requires .NET 5+, current: $(dotnet --version 2>/dev/null)"
                warn "Skipping Covenant build..."
            else
                if [[ ! -f "bin/Debug/netcoreapp3.1/Covenant.dll" ]]; then
                    info "Building Covenant..."
                    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 dotnet build \
                        >> "$LOG_FILE" 2>&1 || true
                fi
                cat > /usr/local/bin/covenant << 'EOF'
#!/usr/bin/env bash
cd /opt/Covenant/Covenant
DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 dotnet run "$@"
EOF
                chmod +x /usr/local/bin/covenant
                ok "Covenant ready"
            fi
        else
            warn "dotnet not found — skipping Covenant build"
        fi
    fi

    # 5. Empire
    if [[ ! -d "/opt/Empire" ]]; then
        info "Cloning Empire..."
        git clone --depth=1 https://github.com/BC-SECURITY/Empire.git /opt/Empire \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/Empire" ]]; then
        if [[ -f "/opt/Empire/ps-empire" ]]; then
            cat > /usr/local/bin/empire << 'EOF'
#!/usr/bin/env bash
cd /opt/Empire
if [[ $EUID -eq 0 ]]; then
    ./ps-empire -f "$@"
else
    ./ps-empire "$@"
fi
EOF
            chmod +x /usr/local/bin/empire
            ok "Empire ready"
        fi
    fi

    # 6. Starkiller
    if [[ ! -d "/opt/Starkiller" ]]; then
        info "Cloning Starkiller..."
        git clone --depth=1 https://github.com/BC-SECURITY/Starkiller.git /opt/Starkiller \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/Starkiller" ]]; then
        cd /opt/Starkiller
        if [[ ! -d "node_modules" ]]; then
            npm install >> "$LOG_FILE" 2>&1 || true
        fi
        cat > /usr/local/bin/starkiller << 'EOF'
#!/usr/bin/env bash
cd /opt/Starkiller
npm run serve
EOF
        chmod +x /usr/local/bin/starkiller
        ok "Starkiller ready"
    fi

    # 7. Merlin — with build verification
    if [[ ! -d "/opt/merlin" ]]; then
        info "Cloning Merlin C2..."
        git clone --depth=1 https://github.com/Ne0nd0g/merlin.git /opt/merlin \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/merlin" ]]; then
        cd /opt/merlin
        if [[ ! -x "merlin-server" ]]; then
            export GOPATH="$HOME/go"
            export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
            info "Building Merlin server..."
            go build -o merlin-server . >> "$LOG_FILE" 2>&1 || {
                warn "Merlin server build failed"
            }
        fi
        
        if [[ -x "merlin-server" ]]; then
            cat > /usr/local/bin/merlin << 'EOF'
#!/usr/bin/env bash
cd /opt/merlin
if [[ "$1" == "server" ]]; then
    ./merlin-server
elif [[ "$1" == "client" ]]; then
    ./merlinCLI-Linux-x64 -addr "${2:-127.0.0.1}:${3:-50051}"
else
    echo "Usage: merlin [server|client]"
fi
EOF
            chmod +x /usr/local/bin/merlin
            ok "Merlin ready"
        else
            warn "Merlin binary not found — wrapper not created"
        fi
    fi

    # 8. NimPlant
    if [[ ! -d "/opt/NimPlant" ]]; then
        info "Cloning NimPlant..."
        git clone --depth=1 https://github.com/chvancooten/NimPlant.git /opt/NimPlant \
            >> "$LOG_FILE" 2>&1
    fi
    
    if [[ -d "/opt/NimPlant" ]]; then
        apt-get install -y -qq python3-dev libev-dev cython3 nim gcc \
            >> "$LOG_FILE" 2>&1
        "${VENV_DIR}/bin/pip" install cryptography==43.0.0 flask_cors==4.0.1 Flask==3.0.3 \
            gevent PyCryptodome==3.20.0 pyyaml==6.0.1 requests==2.32.3 \
            toml==0.10.2 werkzeug==3.0.3 --quiet >> "$LOG_FILE" 2>&1 || true
        
        [[ ! -f "/opt/NimPlant/config.toml" ]] && \
            cp /opt/NimPlant/config.toml.example /opt/NimPlant/config.toml
        
        cat > /usr/local/bin/nimplant << 'EOF'
#!/usr/bin/env bash
cd /opt/NimPlant
source /opt/kali-venv/bin/activate 2>/dev/null || true
if [[ "$1" == "server" ]]; then
    python3 nimplant.py server
elif [[ "$1" == "compile" ]]; then
    python3 nimplant.py compile "${2:-exe}"
else
    echo "Usage: nimplant [server|compile exe|compile dll]"
fi
EOF
        chmod +x /usr/local/bin/nimplant
        ok "NimPlant ready"
    fi

    ok "Red Team C2 Suite complete"
}

# ============================================================
# STEP 18 — C2 Redirectors + SSL Automation (OPSEC)
# ============================================================
do_c2_redirector() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "C2 Redirectors — skipped in minimal mode"
        return 0
    fi

    info "Setting up C2 Redirector automation (Nginx + Let's Encrypt)..."

    # Ensure nginx + certbot are installed
    if ! command -v nginx &>/dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            nginx certbot python3-certbot-nginx >> "$LOG_FILE" 2>&1 || {
            fail "nginx/certbot install failed"; return 1
        }
    fi
    ok "nginx + certbot ready"

    # Ensure certbot symlink exists
    if ! command -v certbot &>/dev/null && [[ -x /usr/bin/certbot ]]; then
        ln -sf /usr/bin/certbot /usr/local/bin/certbot 2>/dev/null || true
    fi

    mkdir -p "$REDIRECTOR_DIR"/{sites-available,sites-enabled,templates,logs}

    # Create default redirector template (WordPress fake front)
    cat > "${REDIRECTOR_DIR}/templates/redirector.conf.template" << 'TPL'
# Kali Master v6.6.1 — C2 Redirector
# Domain: __DOMAIN__
# Backend: __BACKEND_PROTO__://__BACKEND_HOST__:__BACKEND_PORT__
# Generated: __DATE__

server {
    listen 80;
    server_name __DOMAIN__;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name __DOMAIN__;

    # Let's Encrypt SSL
    ssl_certificate     /etc/letsencrypt/live/__DOMAIN__/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/__DOMAIN__/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # OPSEC: hide nginx version
    server_tokens off;
    more_clear_headers Server;

    # Fake WordPress front (for non-C2 traffic)
    location = /wp-login.php { return 404; }
    location = /xmlrpc.php { return 404; }
    location / {
        root /var/www/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }

    # C2 profile URI — forward to teamserver
    location ~* ^(__C2_URIS__)$ {
        proxy_pass         __BACKEND_PROTO__://__BACKEND_HOST__:__BACKEND_PORT__;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_ssl_server_name on;
        proxy_read_timeout 90s;
        proxy_buffering    off;
    }
}
TPL

    # Create fake WordPress index
    mkdir -p /var/www/html
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html><html><head><title>Welcome</title></head>
<body><h1>It works!</h1></body></html>
HTML

    # Setup redirector management script
    cat > "${LOCAL_BIN}/setup-redirector" << 'SETUP_RD'
#!/usr/bin/env bash
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}       C2 REDIRECTOR SETUP — OPSEC Automation${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""

read -p "[1/5] Domain (e.g., cdn.example.com): " DOMAIN
[[ -z "$DOMAIN" ]] && { echo -e "${RED}[✗] Domain required${RESET}"; exit 1; }

read -p "[2/5] Backend protocol [https]: " BPROTO
BPROTO="${BPROTO:-https}"

read -p "[3/5] Backend host (teamserver IP) [127.0.0.1]: " BHOST
BHOST="${BHOST:-127.0.0.1}"

read -p "[4/5] Backend port [443]: " BPORT
BPORT="${BPORT:-443}"

read -p "[5/5] C2 URI patterns (regex, comma-separated, e.g. ^/api,^/beacon): " C2URIS
[[ -z "$C2URIS" ]] && C2URIS="^/api"
C2URIS=$(echo "$C2URIS" | sed 's/,/|/g')

CONF="/etc/nginx/sites-available/${DOMAIN}.conf"
cp /opt/c2-redirectors/templates/redirector.conf.template "$CONF"

sed -i "s|__DOMAIN__|${DOMAIN}|g" "$CONF"
sed -i "s|__BACKEND_PROTO__|${BPROTO}|g" "$CONF"
sed -i "s|__BACKEND_HOST__|${BHOST}|g" "$CONF"
sed -i "s|__BACKEND_PORT__|${BPORT}|g" "$CONF"
sed -i "s|__C2_URIS__|${C2URIS}|g" "$CONF"
sed -i "s|__DATE__|$(date -Iseconds)|g" "$CONF"

ln -sf "$CONF" "/etc/nginx/sites-enabled/${DOMAIN}.conf"

echo -e "${CYAN}[*] Testing nginx config...${RESET}"
nginx -t || { echo -e "${RED}[✗] Config error${RESET}"; exit 1; }
systemctl reload nginx

echo -e "${CYAN}[*] Requesting Let's Encrypt SSL for ${BOLD}${DOMAIN}${RESET}..."
echo -e "${YELLOW}[!] Ensure DNS A record for ${DOMAIN} points to this server${RESET}"
read -p "Continue with certbot? [y/N]: " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos \
        --email "admin@${DOMAIN}" --redirect
fi

echo ""
echo -e "${GREEN}[✔] Redirector ready!${RESET}"
echo -e "  ${BOLD}Domain:${RESET}   https://${DOMAIN}"
echo -e "  ${BOLD}Backend:${RESET}  ${BPROTO}://${BHOST}:${BPORT}"
echo -e "  ${BOLD}C2 URIs:${RESET}  ${C2URIS}"
echo -e "  ${BOLD}Config:${RESET}   ${CONF}"
echo ""
echo -e "${DIM}To remove: rm /etc/nginx/sites-enabled/${DOMAIN}.conf && systemctl reload nginx${RESET}"
SETUP_RD
    chmod +x "${LOCAL_BIN}/setup-redirector"

    # List redirectors helper
    cat > "${LOCAL_BIN}/list-redirectors" << 'LIST_RD'
#!/usr/bin/env bash
echo "=== Active C2 Redirectors ==="
for f in /etc/nginx/sites-available/*.conf; do
    [[ -f "$f" ]] || continue
    grep -q "C2 Redirector" "$f" || continue
    domain=$(grep -m1 "server_name" "$f" | awk '{print $2}' | tr -d ';')
    backend=$(grep -m1 "proxy_pass" "$f" | awk '{print $2}' | tr -d ';')
    echo -e "  [✔] ${domain} -> ${backend}"
done
LIST_RD
    chmod +x "${LOCAL_BIN}/list-redirectors"

    # Auto-renewal cron
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; \
         echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'") \
            | crontab - 2>/dev/null || true
        ok "Certbot auto-renewal cron added"
    fi

    systemctl enable nginx --quiet >> "$LOG_FILE" 2>&1
    systemctl start  nginx          >> "$LOG_FILE" 2>&1

    ok "C2 Redirector automation ready"
    info "Commands: ${BOLD}setup-redirector${RESET}, ${BOLD}list-redirectors${RESET}"
}

# ============================================================
# STEP 19 — EDR/AV Evasion Tools (FIXED)
# ============================================================
do_evasion_tools() {
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Evasion tools — skipped in minimal mode"
        return 0
    fi

    info "Installing EDR/AV Evasion toolkit into ${EVASION_DIR}..."
    mkdir -p "$EVASION_DIR"

    # 1. Donut — .NET/PE/VBS -> PIC shellcode
    if [[ ! -d "${EVASION_DIR}/donut" ]]; then
        info "Building Donut..."
        git clone --depth=1 https://github.com/TheWover/donut.git \
            "${EVASION_DIR}/donut" >> "$LOG_FILE" 2>&1
        ( cd "${EVASION_DIR}/donut" && make -j"$(nproc)" >> "$LOG_FILE" 2>&1 )
    fi
    if [[ -x "${EVASION_DIR}/donut/donut" ]]; then
        ln -sf "${EVASION_DIR}/donut/donut" "${LOCAL_BIN}/donut" 2>/dev/null || true
        ok "Donut ready"
    else
        warn "Donut build failed"
    fi

    # 2. ScareCrow — EDR bypass via DLL side-loading (FIXED)
    if [[ ! -d "${EVASION_DIR}/ScareCrow" ]]; then
        info "Building ScareCrow..."
        git clone --depth=1 https://github.com/optiv/ScareCrow.git \
            "${EVASION_DIR}/ScareCrow" >> "$LOG_FILE" 2>&1
        
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            openssl libssl-dev gcc-mingw-w64 x86_64-w64-mingw32-gcc \
            >> "$LOG_FILE" 2>&1 || true
        
        cd "${EVASION_DIR}/ScareCrow"
        # Try main.go first, then fallback to .
        if [[ -f "main.go" ]]; then
            info "Building ScareCrow from main.go..."
            go build -o ScareCrow main.go >> "$LOG_FILE" 2>&1
        else
            info "Building ScareCrow from package..."
            go build -o ScareCrow . >> "$LOG_FILE" 2>&1
        fi
    fi
    if [[ -x "${EVASION_DIR}/ScareCrow/ScareCrow" ]]; then
        ln -sf "${EVASION_DIR}/ScareCrow/ScareCrow" "${LOCAL_BIN}/scarecrow" 2>/dev/null || true
        ok "ScareCrow ready"
    else
        warn "ScareCrow build failed — check ${LOG_FILE}"
    fi

    # 3. SGN (Shikata Ga Nai) — Go port, shellcode encoder (FIXED)
    if ! smart_find_tool "sgn" &>/dev/null; then
        info "Installing SGN (shikata-ga-nai)..."
        if [[ ! -d "${EVASION_DIR}/sgn" ]]; then
            git clone --depth=1 https://github.com/EgeBalci/sgn.git \
                "${EVASION_DIR}/sgn" >> "$LOG_FILE" 2>&1
            cd "${EVASION_DIR}/sgn"
            export GOPATH="$HOME/go"
            export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
            export GOPROXY="https://proxy.golang.org,direct"
            info "Building SGN from source..."
            go build -o sgn . >> "$LOG_FILE" 2>&1 || {
                warn "SGN build from source failed, trying go install..."
                go install github.com/EgeBalci/sgn@latest >> "$LOG_FILE" 2>&1 || true
            }
        fi
    fi
    
    # Create symlink for sgn
    if [[ -x "${EVASION_DIR}/sgn/sgn" ]]; then
        ln -sf "${EVASION_DIR}/sgn/sgn" "${LOCAL_BIN}/sgn" 2>/dev/null || true
        ok "SGN ready"
    elif [[ -x "$HOME/go/bin/sgn" ]]; then
        ln -sf "$HOME/go/bin/sgn" "${LOCAL_BIN}/sgn" 2>/dev/null || true
        ok "SGN ready (from go install)"
    else
        warn "SGN install failed"
    fi

    # 4. PE-Sieve — detect in-memory patches / hooks
    if [[ ! -d "${EVASION_DIR}/pe-sieve" ]]; then
        info "Building PE-Sieve..."
        git clone --depth=1 https://github.com/hasherezade/pe-sieve.git \
            "${EVASION_DIR}/pe-sieve" >> "$LOG_FILE" 2>&1
        ( cd "${EVASION_DIR}/pe-sieve" && \
          cmake -B build -DCMAKE_BUILD_TYPE=Release >> "$LOG_FILE" 2>&1 && \
          cmake --build build -j"$(nproc)" >> "$LOG_FILE" 2>&1 )
    fi
    local pesieve_bin
    pesieve_bin=$(find "${EVASION_DIR}/pe-sieve/build" -name "pe-sieve*" \
        -type f -executable 2>/dev/null | head -1)
    if [[ -n "$pesieve_bin" ]]; then
        ln -sf "$pesieve_bin" "${LOCAL_BIN}/pe-sieve" 2>/dev/null || true
        ok "PE-Sieve ready"
    else
        warn "PE-Sieve build failed (Windows-targeted binary — expected on Linux)"
    fi

    # 5. Hollows_Hunter — find hooked processes
    if [[ ! -d "${EVASION_DIR}/hollows_hunter" ]]; then
        info "Cloning Hollows_Hunter..."
        git clone --depth=1 https://github.com/hasherezade/hollows_hunter.git \
            "${EVASION_DIR}/hollows_hunter" >> "$LOG_FILE" 2>&1
        ( cd "${EVASION_DIR}/hollows_hunter" && \
          cmake -B build -DCMAKE_BUILD_TYPE=Release >> "$LOG_FILE" 2>&1 && \
          cmake --build build -j"$(nproc)" >> "$LOG_FILE" 2>&1 ) || true
    fi
    local hh_bin
    hh_bin=$(find "${EVASION_DIR}/hollows_hunter/build" -name "hollows_hunter*" \
        -type f -executable 2>/dev/null | head -1)
    if [[ -n "$hh_bin" ]]; then
        ln -sf "$hh_bin" "${LOCAL_BIN}/hollows-hunter" 2>/dev/null || true
        ok "Hollows_Hunter ready"
    else
        warn "Hollows_Hunter build failed (expected on Linux)"
    fi

    # 6. Nimcrypt2 — Nim-based PE crypter
    if [[ ! -d "${EVASION_DIR}/nimcrypt2" ]]; then
        info "Building Nimcrypt2..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            nim gcc-mingw-w64-x86-64-win32 \
            >> "$LOG_FILE" 2>&1 || true
        git clone --depth=1 https://github.com/icyguider/Nimcrypt2.git \
            "${EVASION_DIR}/nimcrypt2" >> "$LOG_FILE" 2>&1
        ( cd "${EVASION_DIR}/nimcrypt2" && \
          nim c nimcrypt2.nim >> "$LOG_FILE" 2>&1 )
    fi
    if [[ -x "${EVASION_DIR}/nimcrypt2/nimcrypt2" ]]; then
        ln -sf "${EVASION_DIR}/nimcrypt2/nimcrypt2" "${LOCAL_BIN}/nimcrypt2" 2>/dev/null || true
        ok "Nimcrypt2 ready"
    else
        warn "Nimcrypt2 build failed"
    fi

    # Evasion menu
    cat > "${LOCAL_BIN}/evasion-menu" << 'EVMENU'
#!/usr/bin/env bash
BOLD='\033[1m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; DIM='\033[2m'; RESET='\033[0m'
echo -e "${BOLD}${CYAN}═══ EDR/AV EVASION TOOLKIT ═══${RESET}"
echo -e "  ${GREEN}1)${RESET} donut          ${DIM}— .NET/PE → PIC shellcode${RESET}"
echo -e "  ${GREEN}2)${RESET} scarecrow       ${DIM}— EDR bypass (DLL side-load)${RESET}"
echo -e "  ${GREEN}3)${RESET} sgn             ${DIM}— Shikata Ga Nai encoder${RESET}"
echo -e "  ${GREEN}4)${RESET} pe-sieve        ${DIM}— detect in-memory hooks${RESET}"
echo -e "  ${GREEN}5)${RESET} hollows-hunter  ${DIM}— find hollowed processes${RESET}"
echo -e "  ${GREEN}6)${RESET} nimcrypt2       ${DIM}— Nim-based PE crypter${RESET}"
echo ""
echo -e "${DIM}All binaries in: /opt/evasion-tools${RESET}"
EVMENU
    chmod +x "${LOCAL_BIN}/evasion-menu"

    ok "Evasion toolkit ready — run: ${BOLD}evasion-menu${RESET}"
}

# ============================================================
# STEP 20 — Post-Exploitation Kit (linpeas, winpeas, chisel, pspy, ligolo-ng)
# ============================================================
do_post_exploit() {
    info "Installing Post-Exploitation kit into ${POSTEXPLOIT_DIR}..."
    mkdir -p "$POSTEXPLOIT_DIR"/{linux,windows,tunneling}

    # 1. LinPEAS
    info "Downloading LinPEAS..."
    safe_curl "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" \
        "${POSTEXPLOIT_DIR}/linux/linpeas.sh" && \
        chmod +x "${POSTEXPLOIT_DIR}/linux/linpeas.sh" && \
        ln -sf "${POSTEXPLOIT_DIR}/linux/linpeas.sh" "${LOCAL_BIN}/linpeas" && \
        ok "LinPEAS ready" || warn "LinPEAS download failed"

    # 2. WinPEAS
    info "Downloading WinPEAS..."
    safe_curl "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" \
        "${POSTEXPLOIT_DIR}/windows/winPEASx64.exe" && \
        ok "WinPEAS (x64) ready" || warn "WinPEAS x64 download failed"
    safe_curl "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx86.exe" \
        "${POSTEXPLOIT_DIR}/windows/winPEASx86.exe" && \
        ok "WinPEAS (x86) ready" || warn "WinPEAS x86 download failed"
    safe_curl "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASany.exe" \
        "${POSTEXPLOIT_DIR}/windows/winPEASany.exe" && \
        ok "WinPEAS (any) ready" || true

    # 3. Chisel — fast TCP/UDP tunnel over HTTP
    if ! smart_find_tool "chisel" &>/dev/null; then
        info "Installing Chisel..."
        install_go_tool "chisel" \
            "github.com/jpillora/chisel" "chisel" || \
            warn "Chisel install failed"
    else
        ok "Chisel — found"
    fi

    # 4. pspy — unprivileged Linux process monitoring
    if [[ ! -f "${POSTEXPLOIT_DIR}/linux/pspy64" ]]; then
        info "Downloading pspy..."
        safe_curl "https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64" \
            "${POSTEXPLOIT_DIR}/linux/pspy64" && \
            chmod +x "${POSTEXPLOIT_DIR}/linux/pspy64" && \
            ln -sf "${POSTEXPLOIT_DIR}/linux/pspy64" "${LOCAL_BIN}/pspy64" && \
            ln -sf "${POSTEXPLOIT_DIR}/linux/pspy64" "${LOCAL_BIN}/pspy" && \
            ok "pspy64 ready" || warn "pspy64 download failed"
        safe_curl "https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32" \
            "${POSTEXPLOIT_DIR}/linux/pspy32" && \
            chmod +x "${POSTEXPLOIT_DIR}/linux/pspy32" && \
            ok "pspy32 ready" || true
    else
        ok "pspy — found"
    fi

    # 5. ligolo-ng — advanced tunneling (mutually preferred over chisel in modern ops)
    if [[ ! -d "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng" ]]; then
        info "Installing ligolo-ng..."
        git clone --depth=1 https://github.com/nicocha30/ligolo-ng.git \
            "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng" >> "$LOG_FILE" 2>&1
        ( cd "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng" && \
          go build -o agent   ./cmd/agent   >> "$LOG_FILE" 2>&1 && \
          go build -o proxy   ./cmd/proxy   >> "$LOG_FILE" 2>&1 )
    fi
    if [[ -x "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng/proxy" ]]; then
        ln -sf "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng/proxy" "${LOCAL_BIN}/ligolo-proxy" 2>/dev/null || true
        ln -sf "${POSTEXPLOIT_DIR}/tunneling/ligolo-ng/agent" "${LOCAL_BIN}/ligolo-agent" 2>/dev/null || true
        ok "ligolo-ng ready (ligolo-proxy / ligolo-agent)"
    else
        warn "ligolo-ng build failed"
    fi

    # 6. Socat is already in apt, but ensure static windows build available
    if [[ ! -d "${POSTEXPLOIT_DIR}/tunneling/socat-static" ]]; then
        mkdir -p "${POSTEXPLOIT_DIR}/tunneling/socat-static"
        info "Note: socat is installed via apt. For Windows, use chisel or ligolo-ng."
    fi

    # Post-exploit menu
    cat > "${LOCAL_BIN}/postexploit-menu" << 'PEMENU'
#!/usr/bin/env bash
BOLD='\033[1m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; DIM='\033[2m'; RESET='\033[0m'
echo -e "${BOLD}${CYAN}═══ POST-EXPLOITATION KIT ═══${RESET}"
echo ""
echo -e "${BOLD}Linux:${RESET}"
echo -e "  ${GREEN}linpeas${RESET}        — Linux privilege escalation auditor"
echo -e "  ${GREEN}pspy / pspy64${RESET}  — unprivileged process monitor"
echo ""
echo -e "${BOLD}Windows:${RESET}"
echo -e "  ${DIM}/opt/postexploit/windows/winPEASx64.exe${RESET}"
echo -e "  ${DIM}/opt/postexploit/windows/winPEASx86.exe${RESET}"
echo -e "  ${DIM}/opt/postexploit/windows/winPEASany.exe${RESET}"
echo ""
echo -e "${BOLD}Tunneling:${RESET}"
echo -e "  ${GREEN}chisel${RESET}         — fast TCP tunnel over HTTP"
echo -e "  ${GREEN}ligolo-proxy${RESET}   — ligolo-ng server side"
echo -e "  ${GREEN}ligolo-agent${RESET}   — ligolo-ng agent (deploy on target)"
echo -e "  ${GREEN}socat${RESET}          — multipurpose relay (apt)"
echo ""
echo -e "${DIM}All files: /opt/postexploit/{linux,windows,tunneling}${RESET}"
PEMENU
    chmod +x "${LOCAL_BIN}/postexploit-menu"

    ok "Post-exploitation kit ready — run: ${BOLD}postexploit-menu${RESET}"
}

# ============================================================
# STEP 21 — Interactive Lab Manager
# ============================================================
setup_lab_manager() {
    cat > "${LOCAL_BIN}/lab-manager" << 'LAB_MGR'
#!/usr/bin/env bash
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

declare -A LABS=(
    ["dvwa"]="vulnerables/web-dvwa:8080:80"
    ["webgoat"]="webgoat/webgoat:8081:8080"
    ["juice"]="bkimminich/juice-shop:3000:3000"
    ["msf"]="metasploitframework/metasploit-framework:host:host"
)

action="${1:-menu}"
target="${2:-all}"

start_lab() {
    local name="$1"
    local img="${LABS[$name]%%:*}"
    local ports="${LABS[$name]#*:}"
    local hport="${ports%%:*}"; local cport="${ports#*:}"
    
    echo -e "${CYAN}[*] Starting ${BOLD}$name${RESET} (${img})..."
    if [[ "$hport" == "host" ]]; then
        docker run -d --name "$name" --network host "$img" >> /dev/null 2>&1 || docker start "$name" >> /dev/null 2>&1
    else
        docker run -d --name "$name" -p "${hport}:${cport}" "$img" >> /dev/null 2>&1 || docker start "$name" >> /dev/null 2>&1
    fi
    echo -e "${GREEN}[✔] $name is running${RESET}"
}

stop_lab() {
    local name="$1"
    echo -e "${CYAN}[*] Stopping ${BOLD}$name${RESET}..."
    docker stop "$name" >> /dev/null 2>&1
    docker rm "$name" >> /dev/null 2>&1
    echo -e "${GREEN}[✔] $name stopped and removed${RESET}"
}

if [[ "$action" == "start" && "$target" != "all" && -n "${LABS[$target]}" ]]; then
    start_lab "$target"; exit 0
elif [[ "$action" == "stop" && "$target" != "all" && -n "${LABS[$target]}" ]]; then
    stop_lab "$target"; exit 0
elif [[ "$action" == "start" && "$target" == "all" ]]; then
    for lab in "${!LABS[@]}"; do start_lab "$lab"; done; exit 0
elif [[ "$action" == "stop" && "$target" == "all" ]]; then
    for l in "${!LABS[@]}"; do stop_lab "$l"; done; exit 0
fi

clear
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}          OFFENSIVE DOCKER LAB MANAGER${RESET}"
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${GREEN}1)${RESET} Start DVWA          (http://localhost:8080)"
echo -e "  ${GREEN}2)${RESET} Start WebGoat       (http://localhost:8081/WebGoat)"
echo -e "  ${GREEN}3)${RESET} Start Juice Shop    (http://localhost:3000)"
echo -e "  ${GREEN}4)${RESET} Start Metasploit    (Network Host Mode)"
echo -e "  ${GREEN}5)${RESET} ${BOLD}Start ALL Labs${RESET}"
echo -e "  ${RED}6)${RESET} Stop ALL Labs"
echo -e "  ${RED}0)${RESET} Exit"
echo ""
read -p "Select an option [0-6]: " choice

case $choice in
    1) start_lab "dvwa" ;;
    2) start_lab "webgoat" ;;
    3) start_lab "juice" ;;
    4) start_lab "msf" ;;
    5) for l in "${!LABS[@]}"; do start_lab "$l"; done ;;
    6) for l in "${!LABS[@]}"; do stop_lab "$l"; done ;;
    0) echo -e "${DIM}Exiting...${RESET}"; exit 0 ;;
    *) echo -e "${RED}[✗] Invalid choice${RESET}" ;;
esac
LAB_MGR
    chmod +x "${LOCAL_BIN}/lab-manager"
    
    cat > "${LOCAL_BIN}/start-lab" << 'EOF'
#!/usr/bin/env bash
exec lab-manager start "$1"
EOF
    chmod +x "${LOCAL_BIN}/start-lab"
    
    cat > "${LOCAL_BIN}/stop-lab" << 'EOF'
#!/usr/bin/env bash
exec lab-manager stop "$1"
EOF
    chmod +x "${LOCAL_BIN}/stop-lab"
    
    ok "Interactive Lab Manager installed (Commands: lab-manager, start-lab, stop-lab)"
}

# ============================================================
# STEP 22 — C2 Menu (BUG-FREE VERSION)
# ============================================================
setup_c2_menu() {
    cat > /usr/local/bin/c2-menu << 'C2MENU'
#!/usr/bin/env bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'
DIM='\033[2m'; RESET='\033[0m'

check_cmd() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        local path
        path=$(command -v "$cmd")
        echo -e "  ${GREEN}[✔]${RESET} $cmd ${DIM}-> $path${RESET}"
    else
        echo -e "  ${RED}[✗]${RESET} $cmd"
    fi
}

clear
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${MAGENTA}       RED TEAM C2 FRAMEWORK LAUNCHER — v6.6.1${RESET}"
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${CYAN}Select C2 Framework to launch:${RESET}"
echo ""
echo -e "  ${GREEN}1)${RESET} Sliver        ${DIM}— Modern multi-protocol C2${RESET}"
echo -e "  ${GREEN}2)${RESET} Havoc         ${DIM}— Modern C2 with great UI${RESET}"
echo -e "  ${GREEN}3)${RESET} Mythic        ${DIM}— Cross-platform C2 (Docker)${RESET}"
echo -e "  ${GREEN}4)${RESET} Covenant      ${DIM}— .NET-based C2${RESET}"
echo -e "  ${GREEN}5)${RESET} Empire        ${DIM}— Post-exploitation framework${RESET}"
echo -e "  ${GREEN}6)${RESET} Starkiller    ${DIM}— Empire GUI${RESET}"
echo -e "  ${GREEN}7)${RESET} Merlin        ${DIM}— HTTP/2 C2${RESET}"
echo -e "  ${GREEN}8)${RESET} NimPlant      ${DIM}— Nim-based beacon${RESET}"
echo -e "  ${GREEN}9)${RESET} Status        ${DIM}— Show all C2 status${RESET}"
echo -e "  ${RED}0)${RESET} Exit"
echo ""
read -p "Enter choice [0-9]: " choice

case $choice in
    1)
        echo -e "${GREEN}[+] Starting Sliver Server...${RESET}"
        if command -v sliver-server &>/dev/null; then
            sliver-server
        else
            echo -e "${RED}[✗] Sliver not installed${RESET}"
        fi
        ;;
    2)
        echo -e "${GREEN}[+] Starting Havoc...${RESET}"
        if command -v havoc &>/dev/null; then
            havoc server
        elif [[ -x "/opt/Havoc/havoc" ]]; then
            cd /opt/Havoc && sudo ./havoc server --profile ./profiles/havoc.yaotl
        else
            echo -e "${RED}[✗] Havoc not built${RESET}"
        fi
        ;;
    3)
        echo -e "${GREEN}[+] Starting Mythic...${RESET}"
        if command -v mythic-cli &>/dev/null; then
            cd /opt/Mythic
            mythic-cli status
            echo ""
            read -p "Start Mythic? [y/N]: " start
            if [[ "$start" =~ ^[Yy]$ ]]; then
                mythic-cli start
                echo -e "${GREEN}[✔] Mythic started${RESET}"
                echo -e "${DIM}Access: https://127.0.0.1:7443${RESET}"
                echo -e "${DIM}Credentials in: /opt/Mythic/.env${RESET}"
            fi
        else
            echo -e "${RED}[✗] Mythic CLI not found${RESET}"
        fi
        ;;
    4)
        echo -e "${GREEN}[+] Starting Covenant...${RESET}"
        if command -v covenant &>/dev/null; then
            covenant
        else
            echo -e "${RED}[✗] Covenant not found${RESET}"
        fi
        ;;
    5)
        echo -e "${GREEN}[+] Starting Empire...${RESET}"
        if command -v empire &>/dev/null; then
            empire server
        else
            echo -e "${RED}[✗] Empire not found${RESET}"
        fi
        ;;
    6)
        echo -e "${GREEN}[+] Starting Starkiller...${RESET}"
        if command -v starkiller &>/dev/null; then
            starkiller
        else
            echo -e "${RED}[✗] Starkiller not found${RESET}"
        fi
        ;;
    7)
        echo -e "${GREEN}[+] Starting Merlin...${RESET}"
        if command -v merlin &>/dev/null; then
            merlin server
        else
            echo -e "${RED}[✗] Merlin not built${RESET}"
        fi
        ;;
    8)
        echo -e "${GREEN}[+] Starting NimPlant...${RESET}"
        if command -v nimplant &>/dev/null; then
            nimplant server
        else
            echo -e "${RED}[✗] NimPlant not found${RESET}"
        fi
        ;;
    9)
        echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
        echo -e "${BOLD}${CYAN}       C2 FRAMEWORK STATUS${RESET}"
        echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════${RESET}"
        echo ""
        echo -e "${CYAN}[Commands]${RESET}"
        check_cmd sliver-server
        check_cmd havoc
        check_cmd mythic-cli
        check_cmd covenant
        check_cmd empire
        check_cmd starkiller
        check_cmd merlin
        check_cmd nimplant
        echo ""
        echo -e "${CYAN}[Directories]${RESET}"
        for dir in /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant; do
            if [[ -d "$dir" ]]; then
                echo -e "  ${GREEN}[✔]${RESET} $(basename $dir)"
            else
                echo -e "  ${RED}[✗]${RESET} $(basename $dir)"
            fi
        done
        echo ""
        read -p "Press Enter to continue..."
        ;;
    0)
        echo -e "${DIM}Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}[✗] Invalid choice${RESET}"
        sleep 2
        ;;
esac
C2MENU
    chmod +x /usr/local/bin/c2-menu
    ok "C2 Menu installed (Bug-free version)"
}

# ============================================================
# STEP 23 — Universal Auto-Fix Engine
# ============================================================
do_auto_fix() {
    info "Scanning for missing or broken tools..."
    
    local fix_map=(
        "sublist3r:apt:sublist3r::"
        "xsstrike:pygithub::https://github.com/s0md3v/XSStrike.git:xsstrike.py"
        "corsy:pygithub::https://github.com/s0md3v/Corsy.git:corsy.py"
        "linkfinder:pygithub::https://github.com/GerbenJavado/LinkFinder.git:linkfinder.py"
        "aws:release:aws/aws-cli:awscli-exe-linux-x86_64.zip:aws"
        "kubectl:release:kubernetes/kubernetes:linux/amd64/kubectl:kubectl"
        "kerbrute:go:github.com/ropnop/kerbrute:kerbrute:"
        "sliver-server:release:BishopFox/sliver:sliver-server_linux-amd64:sliver-server"
        "chisel:go:github.com/jpillora/chisel:chisel:"
        "linpeas:curl:https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh::"
        "pspy64:curl:https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64::"
        "certbot:apt:certbot::"
    )
    
    local fixed=0; local failed=0
    
    for entry in "${fix_map[@]}"; do
        IFS=':' read -r tool method arg1 arg2 arg3 <<< "$entry"
        
        smart_find_tool "$tool" &>/dev/null && { ok "$tool is already installed"; continue; }
        
        info "Attempting to repair: ${BOLD}$tool${RESET} (Method: $method)"
        local success=0
        
        case "$method" in
            "apt")
                if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$arg1" >> "$LOG_FILE" 2>&1; then
                    smart_find_tool "$tool" &>/dev/null && success=1
                fi
                ;;
            "go")
                export GOPATH="$HOME/go" GOPROXY="https://proxy.golang.org,direct"
                go install "${arg1}@latest" >> "$LOG_FILE" 2>&1
                if [[ -x "$HOME/go/bin/${arg2}" ]]; then
                    ln -sf "$HOME/go/bin/${arg2}" "/usr/local/bin/${tool}" 2>/dev/null
                    smart_find_tool "$tool" &>/dev/null && success=1
                fi
                ;;
            "release")
                install_github_release "$tool" "https://api.github.com/repos/${arg1}/releases/latest" "$arg2" "${arg3:-$tool}" && success=1
                if [[ "$tool" == "aws" ]] && [[ $success -eq 0 ]]; then
                    safe_curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" "/tmp/aws.zip"
                    unzip -q /tmp/aws.zip -d /tmp/aws >> "$LOG_FILE" 2>&1
                    /tmp/aws/aws/install --update >> "$LOG_FILE" 2>&1 && smart_find_tool "aws" &>/dev/null && success=1
                fi
                ;;
            "pygithub")
                install_py_github_tool "$tool" "" "$arg2" "$arg3" && success=1
                ;;
            "curl")
                if safe_curl "$arg1" "/tmp/${tool}_fix" 2>/dev/null; then
                    install -m 755 "/tmp/${tool}_fix" "${LOCAL_BIN}/${tool}"
                    smart_find_tool "$tool" &>/dev/null && success=1
                fi
                ;;
        esac
        
        if [[ $success -eq 1 ]]; then
            ok "${GREEN}$tool repaired successfully!${RESET}"
            ((fixed++))
        else
            fail "${RED}$tool repair failed.${RESET}"
            ((failed++))
        fi
    done
    
    echo ""
    info "═══════════════════════════════════════════════════════"
    info "Repair Summary: ${GREEN}${fixed} fixed${RESET} | ${RED}${failed} failed${RESET}"
    info "═══════════════════════════════════════════════════════"
}

# ============================================================
# STEP 24 — Dashboard
# ============================================================
do_dashboard() {
    cat > "${LOCAL_BIN}/kali-master" << 'DASHBOARD'
#!/usr/bin/env bash
case "${1:-status}" in
status)
    clear
    echo -e "${BOLD}Kali Master v6.6.1 — Dashboard${RESET}"
    echo "Run: kali-master [tools|fix|venvs|opsec|evasion|postex]"
    ;;
fix)
    echo "Checking missing tools..."
    for t in subfinder httpx nuclei sliver-server aws kubectl kerbrute \
             havoc mythic-cli covenant empire merlin nimplant \
             chisel linpeas pspy donut scarecrow sgn certbot; do
        command -v "$t" &>/dev/null && echo "[✔] $t" || echo "[✗] $t"
    done
    ;;
opsec)
    echo -e "${BOLD}OPSEC Status:${RESET}"
    list-redirectors 2>/dev/null || echo "No redirectors configured"
    ;;
evasion)
    evasion-menu
    ;;
postex)
    postexploit-menu
    ;;
*)
    echo "Usage: kali-master [status|tools|fix|venvs|opsec|evasion|postex]"
    ;;
esac
DASHBOARD
    chmod +x "${LOCAL_BIN}/kali-master"
    ok "Dashboard installed -> kali-master status"
}

# ============================================================
# Final Health Check
# ============================================================
do_health_check() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ FINAL HEALTH CHECK${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"

    export PATH="$PATH:/usr/local/go/bin:$GOPATH_BIN:$LOCAL_BIN:$PIP_BIN:$CARGO_BIN:${VENV_DIR}/bin:${EVASION_DIR}:${POSTEXPLOIT_DIR}"

    local all_tools=(
        nuclei subfinder httpx katana dnsx tlsx gobuster dalfox ffuf
        trufflehog notify interactsh-client feroxbuster alterx uncover
        anew waybackurls gau amass
        sublist3r corsy xsstrike linkfinder wfuzz
        nmap sqlmap hydra hashcat john
        gdb radare2 ghidra binwalk vol jadx apktool
        capa floss
        nxc kerbrute smbclient rpcclient
        kubectl aws
        sliver-server c2-menu havoc mythic-cli covenant empire
        starkiller merlin nimplant
        go python3 docker git java
        nginx certbot
        donut scarecrow sgn nimcrypt2
        chisel linpeas pspy ligolo-proxy
    )

    local ok_count=0 fail_count=0
    local fail_list=()

    for tool in $(echo "${all_tools[@]}" | tr ' ' '\n' | sort -u); do
        if smart_find_tool "$tool" &>/dev/null; then
            local tool_path; tool_path=$(smart_find_tool "$tool")
            echo -e "  ${GREEN}[✔]${RESET} ${BOLD}${tool}${RESET} ${DIM}-> ${tool_path}${RESET}"
            ok_count=$((ok_count + 1))
        else
            echo -e "  ${RED}[✗]${RESET} ${BOLD}${tool}${RESET}"
            fail_count=$((fail_count + 1))
            fail_list+=("$tool")
        fi
    done

    echo ""
    for venv_path in "$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV"; do
        if [[ -f "${venv_path}/bin/python3" ]]; then
            ok "venv: ${venv_path} ($("${venv_path}/bin/python3" --version 2>&1))"
            ok_count=$((ok_count + 1))
        fi
    done

    echo ""
    echo -e "${CYAN}[C2 Frameworks]${RESET}"
    for c2_dir in /opt/Havoc /opt/Mythic /opt/Covenant /opt/Empire /opt/Starkiller /opt/merlin /opt/NimPlant; do
        if [[ -d "$c2_dir" ]]; then
            echo -e "  ${GREEN}[✔]${RESET} $(basename $c2_dir) ${DIM}-> ${c2_dir}${RESET}"
            ok_count=$((ok_count + 1))
        else
            echo -e "  ${RED}[✗]${RESET} $(basename $c2_dir)"
            fail_count=$((fail_count + 1))
        fi
    done

    echo ""
    echo -e "${CYAN}[Post-Exploit Kit]${RESET}"
    for pe_file in "${POSTEXPLOIT_DIR}/linux/linpeas.sh" \
                   "${POSTEXPLOIT_DIR}/linux/pspy64" \
                   "${POSTEXPLOIT_DIR}/windows/winPEASx64.exe"; do
        if [[ -f "$pe_file" ]]; then
            echo -e "  ${GREEN}[✔]${RESET} $(basename $pe_file)"
            ok_count=$((ok_count + 1))
        else
            echo -e "  ${RED}[✗]${RESET} $(basename $pe_file)"
            fail_count=$((fail_count + 1))
        fi
    done

    echo ""
    echo -e "  ${BOLD}Result: ${GREEN}${ok_count}${RESET}${BOLD} passed / ${RED}${fail_count}${RESET}${BOLD} failed${RESET}"
    [[ ${#fail_list[@]} -gt 0 ]] && \
        echo -e "  ${YELLOW}Missing: ${fail_list[*]}${RESET}"

    if [[ $fail_count -gt 0 ]]; then
        echo ""
        warn "Some tools failed to install."
        info "Triggering Universal Auto-Fix Engine..."
        sleep 2
        do_auto_fix
    fi
}

# ============================================================
# Final Summary
# ============================================================
do_final_summary() {
    local end_time; end_time=$(date +%s)
    local duration=$(( end_time - START_TIME ))
    local minutes=$(( duration / 60 ))
    local seconds=$(( duration % 60 ))

    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GREEN}  KALI MASTER FRAMEWORK v${VERSION} — COMPLETE${RESET}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "  Time   : ${CYAN}${minutes}m ${seconds}s${RESET}"
    echo -e "  Log    : ${DIM}${LOG_FILE}${RESET}"
    echo -e "  venv   : ${DIM}${VENV_DIR}${RESET}"
    echo -e "  angr   : ${DIM}${ANGR_VENV}${RESET}"
    echo -e "  flare  : ${DIM}${FLARE_VENV}${RESET}"
    echo -e "  c2     : ${DIM}${C2_DIR}${RESET}"
    echo -e "  evade  : ${DIM}${EVASION_DIR}${RESET}"
    echo -e "  postex : ${DIM}${POSTEXPLOIT_DIR}${RESET}"
    echo -e "  rdir   : ${DIM}${REDIRECTOR_DIR}${RESET}"

    if [[ ${#INSTALL_ERRORS[@]} -gt 0 ]]; then
        echo ""
        echo -e "  ${YELLOW}Failed steps:${RESET}"
        for e in "${INSTALL_ERRORS[@]}"; do
            echo -e "    ${DIM}* $e${RESET}"
        done
    fi

    echo ""
    echo -e "${BOLD}Key commands:${RESET}"
    echo -e "  ${CYAN}kali-master status${RESET}      — full dashboard"
    echo -e "  ${CYAN}kali-master fix${RESET}         — check missing tools"
    echo -e "  ${CYAN}kali-master opsec${RESET}       — list active redirectors"
    echo -e "  ${CYAN}c2-menu${RESET}                 — Red Team C2 launcher"
    echo -e "  ${CYAN}setup-redirector${RESET}        — setup Nginx+C2 redirector w/ SSL"
    echo -e "  ${CYAN}list-redirectors${RESET}        — list active redirectors"
    echo -e "  ${CYAN}evasion-menu${RESET}            — EDR/AV evasion toolkit"
    echo -e "  ${CYAN}postexploit-menu${RESET}        — post-exploitation kit"
    echo -e "  ${CYAN}lab-manager${RESET}             — Interactive Docker Lab Menu"
    echo -e "  ${CYAN}start-lab / stop-lab${RESET}    — Quick lab control"
    echo -e "  ${CYAN}havoc server${RESET}            — Start Havoc teamserver"
    echo -e "  ${CYAN}mythic-cli start${RESET}        — Start Mythic"
    echo -e "  ${CYAN}empire server${RESET}           — Start Empire"
    echo -e "  ${CYAN}merlin server${RESET}           — Start Merlin"
    echo -e "  ${CYAN}nimplant server${RESET}         — Start NimPlant"
    echo -e "  ${CYAN}linpeas / pspy64${RESET}        — Linux post-exploit"
    echo -e "  ${CYAN}chisel / ligolo-proxy${RESET}   — Tunneling"
    echo -e "  ${CYAN}update-tools${RESET}            — update everything"
    echo -e "  ${CYAN}bb-recon <domain>${RESET}       — automated recon"
    echo ""
    echo -e "${YELLOW}[!]${RESET} Open a new terminal or: ${BOLD}source ~/.zshrc${RESET}"
    echo -e "${YELLOW}[!]${RESET} Powerlevel10k theme active — run ${BOLD}p10k configure${RESET} to customize"
    echo -e "${YELLOW}[!]${RESET} Mythic credentials: ${BOLD}/opt/Mythic/.env${RESET}"
    echo -e "${YELLOW}[!]${RESET} Havoc credentials: ${BOLD}5pider / password1234${RESET}"
    echo -e "${YELLOW}[!]${RESET} Edit ${BOLD}${CONFIG_DIR}/secrets.env${RESET} to add API keys"
    echo -e "${YELLOW}[!]${RESET} OPSEC: use ${BOLD}setup-redirector${RESET} before live C2 ops"
    echo ""
}

# ============================================================
# Argument parsing
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --reset)     shift; state_reset "${1:-}"; [[ $# -gt 0 ]] && shift ;;
            --reset-all) state_reset; shift ;;
            --step)      shift; ONLY_STEP="${1:-}"; shift ;;
            --force)     FORCE=1; shift ;;
            --minimal)   MINIMAL_MODE=1; shift ;;
            --fix)       AUTO_FIX_MODE=1; shift ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --minimal        Minimal installation (core tools only)"
                echo "  --fix            Run auto-fix for missing tools only"
                echo "  --step <name>    Run a single step only"
                echo "  --reset <name>   Reset a step state"
                echo "  --reset-all      Reset all step states"
                echo "  --force          Re-run even if state says done"
                echo ""
                echo "Steps: see ordered_steps array in main()"
                exit 0
                ;;
            *) shift ;;
        esac
    done
}

# ============================================================
# Main
# ============================================================
main() {
    START_TIME=$(date +%s)
    FORCE="${FORCE:-0}"
    ONLY_STEP="${ONLY_STEP:-}"
    MINIMAL_MODE="${MINIMAL_MODE:-0}"
    AUTO_FIX_MODE="${AUTO_FIX_MODE:-0}"

    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"

    banner
    parse_args "$@"
    
    if [[ "$AUTO_FIX_MODE" == "1" ]]; then
        do_preflight
        do_auto_fix
        exit 0
    fi

    do_preflight

    local ordered_steps=(
        network_fix
        snapshot system_update python_venv golang
        docker bugbounty reversing ctf
        ad_network cloud_security wordlists shell_config
        secrets vm_hardening update_manager helper_scripts
        redteam_c2 c2_redirector evasion_tools post_exploit
        lab_manager c2_menu auto_fix dashboard
    )

    # Auto-calculate step total
    STEP_TOTAL=${#ordered_steps[@]}

    declare -A steps=(
        ["network_fix"]="do_network_fix"
        ["snapshot"]="do_snapshot"
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
        ["lab_manager"]="setup_lab_manager"
        ["c2_menu"]="setup_c2_menu"
        ["auto_fix"]="do_auto_fix"
        ["dashboard"]="do_dashboard"
    )

    if [[ -n "$ONLY_STEP" ]]; then
        if [[ -n "${steps[$ONLY_STEP]:-}" ]]; then
            step "$ONLY_STEP"
            FORCE=1 run_step "$ONLY_STEP" "${steps[$ONLY_STEP]}"
        else
            fail "Unknown step: $ONLY_STEP"
            echo "Available steps: ${ordered_steps[*]}"
            exit 1
        fi
    else
        for s in "${ordered_steps[@]}"; do
            if [[ "$s" == "network_fix" ]]; then
                step "$s"
                do_network_fix
            else
                step "$s"
                run_step "$s" "${steps[$s]}"
            fi

            # Critical step validation
            case "$s" in
                golang)      require_ok "go" ;;
                python_venv) require_ok "python3" ;;
                docker)      smart_find_tool "docker" &>/dev/null || [[ "$MINIMAL_MODE" == "1" ]] || warn "Docker missing" ;;
            esac
        done
    fi

    do_health_check
    do_final_summary
}

# ============================================================
# Entry Point
# ============================================================
parse_args "$@"
main
