#!/usr/bin/env bash
# modules/15_update_manager.sh

do_update_manager() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 15/${STEP_TOTAL} — UPDATE MANAGER SETUP${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    
    info "Creating professional update manager v2.0..."
    
    # ========================================================
    # Create the update-tools script
    # ========================================================
    cat > "${LOCAL_BIN}/update-tools" << 'UPDATE_SCRIPT'
#!/usr/bin/env bash
# ============================================================
#  KALI MASTER — PROFESSIONAL UPDATE MANAGER v6.7.1
#  Comprehensive system & tools update with selective modes
#  FIXED: All arithmetic errors, wordlists, nuclei, rust, docker
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly BLUE='\033[0;34m'; readonly RESET='\033[0m'

readonly LOG_FILE="/var/log/kali_update_$(date +%Y%m%d_%H%M%S).log"
readonly VENV_DIR="/opt/kali-venv"
readonly ANGR_VENV="/opt/angr-venv"
readonly FLARE_VENV="/opt/flare-venv"
readonly GOPATH_BIN="$HOME/go/bin"
readonly CARGO_BIN="$HOME/.cargo/bin"
readonly BACKUP_DIR="/root/.kali-master/backups"

START_TIME=$(date +%s)
STEPS_TOTAL=18
STEP_CURRENT=0
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
UPDATED_COUNT=0

# Mode flags
DRY_RUN="${DRY_RUN:-0}"
SELECTIVE_MODE="${SELECTIVE_MODE:-}"
SKIP_BACKUP="${SKIP_BACKUP:-0}"

# ============================================================
# Helpers
# ============================================================
log()  { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE" 2>&1; }
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*" | tee -a "$LOG_FILE"; ((SUCCESS_COUNT++)) || true; }
fail() { echo -e "  ${RED}[✗]${RESET} $*" | tee -a "$LOG_FILE"; ((FAIL_COUNT++)) || true; }
info() { echo -e "  ${CYAN}[*]${RESET} $*" | tee -a "$LOG_FILE"; }
warn() { echo -e "  ${YELLOW}[!]${RESET} $*" | tee -a "$LOG_FILE"; }
skip() { echo -e "  ${DIM}[~]${RESET} ${DIM}$*${RESET}" | tee -a "$LOG_FILE"; ((SKIP_COUNT++)) || true; }
updated() { ((UPDATED_COUNT++)) || true; }

# ✅ FIX: Safe count function to avoid arithmetic errors
safe_count() {
    local count
    count=$(echo "$1" | tr -cd '0-9' | head -c 10)
    echo "${count:-0}"
}

step() {
    STEP_CURRENT=$((STEP_CURRENT + 1))
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP ${STEP_CURRENT}/${STEPS_TOTAL} — $*${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
}

banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   KALI MASTER — UPDATE MANAGER v6.7.1                 ║
  ║   18-Step Comprehensive Update System (FIXED)         ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo -e "  ${DIM}Log: ${LOG_FILE}${RESET}"
    echo -e "  ${DIM}Started: $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "  ${YELLOW}${BOLD}MODE: DRY RUN (no changes will be made)${RESET}"
    fi
    
    if [[ -n "$SELECTIVE_MODE" ]]; then
        echo -e "  ${CYAN}${BOLD}MODE: SELECTIVE ($SELECTIVE_MODE)${RESET}"
    fi
    
    echo ""
}

usage() {
    echo -e "${BOLD}Usage:${RESET} update-tools [OPTIONS] [COMPONENT]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}--dry-run${RESET}        Simulate update without making changes"
    echo -e "  ${CYAN}--skip-backup${RESET}    Skip pre-update backup"
    echo -e "  ${CYAN}--help${RESET}           Show this help"
    echo ""
    echo -e "${BOLD}Components (selective update):${RESET}"
    echo -e "  ${CYAN}system${RESET}           APT packages only"
    echo -e "  ${CYAN}go${RESET}               Go tools only"
    echo -e "  ${CYAN}python${RESET}           Python venvs only"
    echo -e "  ${CYAN}rust${RESET}             Rust/Cargo tools only"
    echo -e "  ${CYAN}c2${RESET}               C2 frameworks only"
    echo -e "  ${CYAN}docker${RESET}           Docker images only"
    echo -e "  ${CYAN}nuclei${RESET}           Nuclei templates only"
    echo -e "  ${CYAN}wordlists${RESET}        Wordlists only"
    echo -e "  ${CYAN}shell${RESET}            Shell plugins & themes"
    echo -e "  ${CYAN}all${RESET}              Update everything (default)"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  update-tools                   ${DIM}# Full update${RESET}"
    echo -e "  update-tools --dry-run         ${DIM}# Simulate update${RESET}"
    echo -e "  update-tools system            ${DIM}# Update APT only${RESET}"
    echo -e "  update-tools go python         ${DIM}# Update Go & Python${RESET}"
    echo -e "  update-tools c2 docker         ${DIM}# Update C2 & Docker${RESET}"
    echo ""
}

# ============================================================
# Parse Arguments
# ============================================================
parse_args() {
    local components=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=1
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=1
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            system|go|python|rust|c2|docker|nuclei|wordlists|shell|all)
                components+=("$1")
                shift
                ;;
            *)
                warn "Unknown argument: $1"
                shift
                ;;
        esac
    done
    
    if [[ ${#components[@]} -gt 0 ]]; then
        SELECTIVE_MODE="${components[*]}"
    fi
}

# ============================================================
# Check if component should be updated
# ============================================================
should_update() {
    local component="$1"
    
    if [[ -z "$SELECTIVE_MODE" ]] || [[ "$SELECTIVE_MODE" == *"all"* ]]; then
        return 0
    fi
    
    if [[ "$SELECTIVE_MODE" == *"$component"* ]]; then
        return 0
    fi
    
    return 1
}

# ============================================================
# Pre-flight
# ============================================================
preflight() {
    [[ $EUID -eq 0 ]] || { echo -e "${RED}[✗] Must run as root${RESET}"; exit 1; }
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
}

# ============================================================
# STEP 1: Pre-Update Backup
# ============================================================
pre_backup() {
    should_update "backup" || { skip "Backup (skipped)"; return 0; }
    
    step "PRE-UPDATE BACKUP"
    
    if [[ "$SKIP_BACKUP" == "1" ]]; then
        skip "Backup skipped (--skip-backup)"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would create backup"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/system_state_$timestamp.tar.gz"
    
    info "Creating system state backup..."
    
    local files_to_backup=(
        "/etc/apt/sources.list"
        "/etc/apt/sources.list.d"
        "/etc/sysctl.d/99-kali-master*.conf"
        "/root/.zshrc"
        "/root/.bashrc"
        "/root/.p10k.zsh"
        "/root/.kali_env.zsh"
        "/root/.config/kali-master/secrets.env"
    )
    
    local tar_args=()
    for file in "${files_to_backup[@]}"; do
        if [[ -e "$file" ]]; then
            tar_args+=("$file")
        fi
    done
    
    if [[ ${#tar_args[@]} -gt 0 ]]; then
        if tar -czf "$backup_file" "${tar_args[@]}" 2>> "$LOG_FILE"; then
            local size
            size=$(du -h "$backup_file" | awk '{print $1}')
            ok "Backup created: $backup_file ($size)"
            
            local backup_count
            backup_count=$(ls "$BACKUP_DIR"/system_state_*.tar.gz 2>/dev/null | wc -l)
            backup_count=$(safe_count "$backup_count")
            if [[ "$backup_count" -gt 5 ]]; then
                ls -t "$BACKUP_DIR"/system_state_*.tar.gz | tail -n +6 | xargs rm -f
                info "Cleaned old backups (kept last 5)"
            fi
        else
            fail "Backup creation failed"
        fi
    else
        warn "No files to backup"
    fi
}

# ============================================================
# STEP 2: Fix Broken Packages
# ============================================================
fix_broken() {
    should_update "system" || { skip "Fix broken (not selected)"; return 0; }
    
    step "FIX BROKEN PACKAGES"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would fix broken packages"
        return 0
    fi
    
    info "Fixing interrupted dpkg operations..."
    if dpkg --configure -a >> "$LOG_FILE" 2>&1; then
        ok "dpkg --configure -a completed"
    else
        warn "dpkg --configure -a had issues"
    fi
    
    info "Fixing broken dependencies..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-broken >> "$LOG_FILE" 2>&1; then
        ok "apt --fix-broken install completed"
    else
        warn "apt --fix-broken install had issues"
    fi
}

# ============================================================
# STEP 3: Update Package Lists
# ============================================================
update_packages() {
    should_update "system" || { skip "Update packages (not selected)"; return 0; }
    
    step "UPDATE PACKAGE LISTS"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update package lists"
        return 0
    fi
    
    info "Fetching latest package lists..."
    if apt-get update -qq >> "$LOG_FILE" 2>&1; then
        ok "Package lists updated"
    else
        fail "apt-get update failed"
        return 1
    fi
}

# ============================================================
# STEP 4: Upgrade Packages (FIXED)
# ============================================================
upgrade_packages() {
    should_update "system" || { skip "Upgrade packages (not selected)"; return 0; }
    
    step "UPGRADE PACKAGES"
    
    # ✅ FIX: Use safe_count to avoid arithmetic errors
    local before_count
    before_count=$(apt list --upgradable 2>/dev/null | grep "upgradable" | wc -l)
    before_count=$(safe_count "$before_count")
    
    if [[ "$before_count" -eq 0 ]]; then
        skip "All packages are up-to-date"
        return 0
    fi
    
    info "Packages to upgrade: $before_count"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would upgrade $before_count packages"
        apt list --upgradable 2>/dev/null | grep "upgradable" | head -10
        return 0
    fi
    
    if DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1; then
        ok "apt upgrade completed ($before_count packages)"
        updated
    else
        fail "apt upgrade failed"
    fi
}

# ============================================================
# STEP 5: Full Upgrade (FIXED)
# ============================================================
full_upgrade() {
    should_update "system" || { skip "Full upgrade (not selected)"; return 0; }
    
    step "FULL UPGRADE (DIST-UPGRADE)"
    
    # ✅ FIX: Use safe_count
    local before_count
    before_count=$(apt list --upgradable 2>/dev/null | grep "upgradable" | wc -l)
    before_count=$(safe_count "$before_count")
    
    if [[ "$before_count" -eq 0 ]]; then
        skip "No packages need full upgrade"
        return 0
    fi
    
    info "Packages for full upgrade: $before_count"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would perform full upgrade"
        return 0
    fi
    
    if DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y -qq \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1; then
        ok "apt full-upgrade completed"
        updated
    else
        fail "apt full-upgrade failed"
    fi
}

# ============================================================
# STEP 6: Auto-remove & Clean (FIXED)
# ============================================================
autoclean() {
    should_update "system" || { skip "Auto-clean (not selected)"; return 0; }
    
    step "AUTO-REMOVE & CLEAN"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would clean packages"
        return 0
    fi
    
    # ✅ FIX: Use safe_count
    local orphan_count
    orphan_count=$(apt-get --dry-run autoremove 2>/dev/null | grep "^Remv" | wc -l)
    orphan_count=$(safe_count "$orphan_count")
    
    if [[ "$orphan_count" -gt 0 ]]; then
        info "Removing $orphan_count orphaned packages..."
        if DEBIAN_FRONTEND=noninteractive apt-get autoremove -y -qq >> "$LOG_FILE" 2>&1; then
            ok "Removed $orphan_count orphaned packages"
        else
            warn "autoremove had issues"
        fi
    else
        skip "No orphaned packages"
    fi
    
    # Clean cache
    local cache_size
    cache_size=$(du -sh /var/cache/apt/archives 2>/dev/null | awk '{print $1}')
    
    if apt-get autoclean -y -qq >> "$LOG_FILE" 2>&1 && \
       apt-get clean -y -qq >> "$LOG_FILE" 2>&1; then
        local new_size
        new_size=$(du -sh /var/cache/apt/archives 2>/dev/null | awk '{print $1}')
        ok "Cache cleaned (${cache_size:-?} → ${new_size:-?})"
    else
        fail "Cache clean failed"
    fi
}

# ============================================================
# STEP 7: Update Go Language
# ============================================================
update_go_language() {
    should_update "system" || { skip "Go language (not selected)"; return 0; }
    
    step "UPDATE GO LANGUAGE"
    
    if ! command -v go &>/dev/null; then
        skip "Go not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would check for Go updates"
        return 0
    fi
    
    info "Checking for Go updates..."
    
    local current_version
    current_version=$(go version | awk '{print $3}' | sed 's/go//')
    
    local latest_version
    latest_version=$(curl -sf "https://go.dev/dl/?mode=json" 2>/dev/null | \
        python3 -c "import sys,json; data=json.load(sys.stdin); print([x for x in data if x.get('stable',False)][0]['version'].replace('go',''))" 2>/dev/null) || latest_version=""
    
    if [[ -n "$latest_version" ]] && [[ "$current_version" != "$latest_version" ]]; then
        info "Go update available: $current_version → $latest_version"
        warn "Run 'kali-master --step golang --force' to update Go"
    else
        ok "Go is up-to-date ($current_version)"
    fi
}

# ============================================================
# STEP 8: Update Docker Engine (FIXED)
# ============================================================
update_docker_engine() {
    should_update "system" || { skip "Docker engine (not selected)"; return 0; }
    
    step "UPDATE DOCKER ENGINE"
    
    if ! command -v docker &>/dev/null; then
        skip "Docker not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Docker via APT"
        return 0
    fi
    
    info "Updating Docker packages via APT..."
    
    # ✅ FIX: Update each package individually for better error handling
    local docker_packages=(
        "docker-ce"
        "docker-ce-cli"
        "containerd.io"
        "docker-buildx-plugin"
        "docker-compose-plugin"
    )
    
    local updated_count=0
    for pkg in "${docker_packages[@]}"; do
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --only-upgrade "$pkg" >> "$LOG_FILE" 2>&1; then
            ((updated_count++)) || true
        fi
    done
    
    if [[ $updated_count -gt 0 ]]; then
        ok "Docker packages updated ($updated_count packages)"
        updated
    else
        info "Docker packages already up-to-date"
    fi
}

# ============================================================
# STEP 9: Update Go Tools (IMPROVED)
# ============================================================
update_go_tools() {
    should_update "go" || { skip "Go tools (not selected)"; return 0; }
    
    step "UPDATE GO TOOLS"
    
    if ! command -v go &>/dev/null; then
        skip "Go not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Go tools"
        ls "$GOPATH_BIN" 2>/dev/null | head -10
        return 0
    fi
    
    export GOPATH="$HOME/go"
    export PATH="$PATH:/usr/local/go/bin:$GOPATH_BIN"
    export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
    export GONOSUMDB="*"
    
    local updated_count=0
    local failed=0
    local total=0
    local up_to_date=0
    
    if [[ -d "$GOPATH_BIN" ]]; then
        for bin in "$GOPATH_BIN"/*; do
            [[ -x "$bin" ]] || continue
            ((total++)) || true
            local tool
            tool=$(basename "$bin")
            local mod
            mod=$(go version -m "$bin" 2>/dev/null | awk '/^mod/{print $2}') || continue
            [[ -z "$mod" ]] && continue
            
            info "Updating $tool..."
            if GOPATH="$HOME/go" go install "${mod}@latest" >> "$LOG_FILE" 2>&1; then
                # Check if actually updated
                if go version -m "$bin" 2>/dev/null | grep -q "build.*vcs.time"; then
                    ok "  $tool updated"
                    ((updated_count++)) || true
                else
                    info "  $tool already up-to-date"
                    ((up_to_date++)) || true
                fi
            else
                warn "  $tool failed"
                ((failed++)) || true
            fi
        done
    fi
    
    if [[ $total -eq 0 ]]; then
        skip "No Go tools to update"
    elif [[ $updated_count -eq 0 && $failed -eq 0 ]]; then
        ok "Go tools: All $total tools already up-to-date"
    elif [[ $failed -eq 0 ]]; then
        ok "Go tools: $updated_count updated, $up_to_date up-to-date"
    else
        warn "Go tools: $updated_count updated, $up_to_date up-to-date, $failed failed"
    fi
}

# ============================================================
# STEP 10: Update Python Packages (All Venvs)
# ============================================================
update_python_packages() {
    should_update "python" || { skip "Python packages (not selected)"; return 0; }
    
    step "UPDATE PYTHON PACKAGES"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Python packages"
        return 0
    fi
    
    local venvs=("$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV")
    
    for venv_path in "${venvs[@]}"; do
        if [[ -x "${venv_path}/bin/pip" ]]; then
            local venv_name
            venv_name=$(basename "$venv_path")
            info "Updating packages in $venv_name..."
            
            "${venv_path}/bin/pip" install --upgrade pip --quiet >> "$LOG_FILE" 2>&1 || true
            
            local outdated
            outdated=$("${venv_path}/bin/pip" list --outdated --format=freeze 2>/dev/null | grep -v '^\-e' | wc -l)
            outdated=$(safe_count "$outdated")
            
            if [[ "$outdated" -gt 0 ]]; then
                info "  Found $outdated outdated packages"
                if "${venv_path}/bin/pip" list --outdated --format=freeze 2>/dev/null | \
                   grep -v '^\-e' | cut -d= -f1 | \
                   xargs -r "${venv_path}/bin/pip" install -U --quiet >> "$LOG_FILE" 2>&1; then
                    ok "  Updated $outdated packages in $venv_name"
                    updated
                else
                    warn "  Some packages failed to update in $venv_name"
                fi
            else
                skip "  $venv_name — all packages up-to-date"
            fi
        fi
    done
}

# ============================================================
# STEP 11: Update Rust Tools (FIXED - Auto-install cargo-update)
# ============================================================
update_rust_tools() {
    should_update "rust" || { skip "Rust tools (not selected)"; return 0; }
    
    step "UPDATE RUST TOOLS"
    
    if ! command -v rustup &>/dev/null; then
        skip "Rust not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Rust tools"
        return 0
    fi
    
    info "Updating Rust toolchain..."
    if rustup update >> "$LOG_FILE" 2>&1; then
        ok "Rust toolchain updated"
        updated
    else
        warn "Rust toolchain update had issues"
    fi
    
    # Update cargo-installed tools
    if [[ -d "$CARGO_BIN" ]]; then
        local cargo_tools
        cargo_tools=$(ls "$CARGO_BIN" 2>/dev/null | wc -l)
        cargo_tools=$(safe_count "$cargo_tools")
        
        if [[ "$cargo_tools" -gt 0 ]]; then
            # ✅ FIX: Auto-install cargo-update if missing
            if ! command -v cargo-install-update &>/dev/null; then
                info "Installing cargo-update..."
                if cargo install cargo-update >> "$LOG_FILE" 2>&1; then
                    ok "cargo-update installed"
                else
                    warn "cargo-update installation failed"
                    return 0
                fi
            fi
            
            info "Updating $cargo_tools cargo-installed tools..."
            if cargo install-update -a >> "$LOG_FILE" 2>&1; then
                ok "Cargo tools updated"
                updated
            else
                warn "Some cargo tools failed to update"
            fi
        fi
    fi
}

# ============================================================
# STEP 12: Update C2 Frameworks
# ============================================================
update_c2_frameworks() {
    should_update "c2" || { skip "C2 frameworks (not selected)"; return 0; }
    
    step "UPDATE C2 FRAMEWORKS"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update C2 frameworks"
        return 0
    fi
    
    local c2_dirs=(
        "/opt/Havoc"
        "/opt/Mythic"
        "/opt/Covenant"
        "/opt/Empire"
        "/opt/Starkiller"
        "/opt/merlin"
        "/opt/NimPlant"
    )
    
    local updated_count=0
    local failed=0
    
    for c2_dir in "${c2_dirs[@]}"; do
        if [[ -d "$c2_dir" ]]; then
            local c2_name
            c2_name=$(basename "$c2_dir")
            info "Updating $c2_name..."
            
            if (cd "$c2_dir" && git pull -q >> "$LOG_FILE" 2>&1); then
                ok "  $c2_name updated"
                ((updated_count++)) || true
            else
                warn "  $c2_name update failed"
                ((failed++)) || true
            fi
        fi
    done
    
    if [[ $updated_count -gt 0 ]]; then
        ok "C2 frameworks: $updated_count updated"
    fi
    
    if [[ $failed -gt 0 ]]; then
        warn "C2 frameworks: $failed failed"
    fi
}

# ============================================================
# STEP 13: Update Docker Images (IMPROVED)
# ============================================================
update_docker_images() {
    should_update "docker" || { skip "Docker images (not selected)"; return 0; }
    
    step "UPDATE DOCKER IMAGES"
    
    if ! command -v docker &>/dev/null; then
        skip "Docker not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Docker images"
        docker images --format "{{.Repository}}:{{.Tag}}" | head -10
        return 0
    fi
    
    info "Pulling latest Docker images..."
    
    local images
    images=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | grep -v "local")
    
    local updated_count=0
    local failed=0
    local failed_images=()
    
    while IFS= read -r image; do
        [[ -z "$image" ]] && continue
        info "Pulling $image..."
        if docker pull "$image" >> "$LOG_FILE" 2>&1; then
            ok "  $image updated"
            ((updated_count++)) || true
        else
            warn "  $image failed (may be deprecated or unavailable)"
            ((failed++)) || true
            failed_images+=("$image")
        fi
    done <<< "$images"
    
    # Prune unused images
    info "Pruning unused Docker resources..."
    if docker system prune -f >> "$LOG_FILE" 2>&1; then
        ok "Docker resources pruned"
    fi
    
    if [[ $updated_count -gt 0 ]]; then
        ok "Docker images: $updated_count updated"
    fi
    
    if [[ $failed -gt 0 ]]; then
        warn "Docker images: $failed failed (may be deprecated)"
        info "Failed images: ${failed_images[*]}"
    fi
}

# ============================================================
# STEP 14: Update Nuclei Templates (FIXED - Multiple paths)
# ============================================================
update_nuclei() {
    should_update "nuclei" || { skip "Nuclei templates (not selected)"; return 0; }
    
    step "UPDATE NUCLEI TEMPLATES"
    
    if ! command -v nuclei &>/dev/null; then
        skip "Nuclei not installed"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update Nuclei templates"
        return 0
    fi
    
    info "Updating Nuclei templates..."
    if nuclei -update-templates -silent >> "$LOG_FILE" 2>&1; then
        # ✅ FIX: Check multiple possible template paths
        local template_count=0
        local template_paths=(
            "$HOME/.config/nuclei-templates"
            "$HOME/nuclei-templates"
            "/root/.config/nuclei-templates"
            "/root/nuclei-templates"
        )
        
        for path in "${template_paths[@]}"; do
            if [[ -d "$path" ]]; then
                local count
                count=$(find "$path" -type f -name "*.yaml" 2>/dev/null | wc -l)
                count=$(safe_count "$count")
                if [[ "$count" -gt "$template_count" ]]; then
                    template_count=$count
                fi
            fi
        done
        
        if [[ "$template_count" -gt 0 ]]; then
            ok "Nuclei templates updated ($template_count templates)"
            updated
        else
            info "Nuclei templates updated (count unknown)"
            info "Run: nuclei -update-templates to verify"
        fi
    else
        fail "Nuclei templates update failed"
    fi
}

# ============================================================
# STEP 15: Update Wordlists (FIXED - Better output)
# ============================================================
update_wordlists() {
    should_update "wordlists" || { skip "Wordlists (not selected)"; return 0; }
    
    step "UPDATE WORDLISTS"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update wordlists"
        return 0
    fi
    
    local updated_count=0
    
    # ✅ FIX: Check if directories exist and are git repos
    local wordlist_dirs=(
        "/opt/wordlists/SecLists"
        "/opt/wordlists/web/fuzzdb"
        "/opt/wordlists/web/PayloadsAllTheThings"
        "/usr/share/seclists"
        "/usr/share/wordlists"
    )
    
    local found_any=false
    
    for dir in "${wordlist_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            found_any=true
            local dir_name
            dir_name=$(basename "$dir")
            
            # Check if it's a git repo
            if [[ -d "$dir/.git" ]]; then
                info "Updating $dir_name..."
                if (cd "$dir" && git pull -q >> "$LOG_FILE" 2>&1); then
                    ok "$dir_name updated"
                    ((updated_count++)) || true
                else
                    warn "$dir_name update failed"
                fi
            else
                info "$dir_name exists but is not a git repo (skipping)"
            fi
        fi
    done
    
    if [[ "$found_any" == "false" ]]; then
        info "No wordlist directories found"
        info "Run: kali-master --step wordlists --force to install"
    elif [[ $updated_count -gt 0 ]]; then
        ok "Wordlists: $updated_count updated"
    else
        info "Wordlists: All up-to-date or not git repos"
    fi
}

# ============================================================
# STEP 16: Update Shell Plugins & Themes
# ============================================================
update_shell() {
    should_update "shell" || { skip "Shell plugins (not selected)"; return 0; }
    
    step "UPDATE SHELL PLUGINS & THEMES"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would update shell plugins"
        return 0
    fi
    
    local updated_count=0
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        info "Updating Oh-My-Zsh..."
        if (cd "$HOME/.oh-my-zsh" && git pull -q >> "$LOG_FILE" 2>&1); then
            ok "Oh-My-Zsh updated"
            ((updated_count++)) || true
        else
            warn "Oh-My-Zsh update failed"
        fi
    fi
    
    if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        info "Updating Powerlevel10k..."
        if (cd "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" && git pull -q >> "$LOG_FILE" 2>&1); then
            ok "Powerlevel10k updated"
            ((updated_count++)) || true
        else
            warn "Powerlevel10k update failed"
        fi
    fi
    
    local plugins=(
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "zsh-completions"
        "fast-syntax-highlighting"
        "zsh-history-substring-search"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin"
        if [[ -d "$plugin_dir" ]]; then
            info "Updating $plugin..."
            if (cd "$plugin_dir" && git pull -q >> "$LOG_FILE" 2>&1); then
                ok "  $plugin updated"
                ((updated_count++)) || true
            else
                warn "  $plugin update failed"
            fi
        fi
    done
    
    if [[ $updated_count -gt 0 ]]; then
        ok "Shell components: $updated_count updated"
    fi
}

# ============================================================
# STEP 17: Verification
# ============================================================
verification() {
    step "POST-UPDATE VERIFICATION"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Skipping verification"
        return 0
    fi
    
    local checks=0
    local passed=0
    
    local critical_tools=("nuclei" "subfinder" "httpx" "kubectl" "docker" "python3" "go")
    
    for tool in "${critical_tools[@]}"; do
        ((checks++)) || true
        if command -v "$tool" &>/dev/null; then
            ((passed++)) || true
        else
            warn "$tool not found"
        fi
    done
    
    ok "Verification: $passed/$checks critical tools available"
}

# ============================================================
# STEP 18: System Cleanup
# ============================================================
system_cleanup() {
    step "SYSTEM CLEANUP"
    
    if [[ "$DRY_RUN" == "1" ]]; then
        info "[DRY RUN] Would clean system"
        return 0
    fi
    
    info "Cleaning old log files..."
    find /var/log -name "*.gz" -delete 2>/dev/null
    find /var/log -name "*.old" -delete 2>/dev/null
    find /var/log -name "*.[0-9]" -delete 2>/dev/null
    ok "Old logs cleaned"
    
    info "Cleaning temp files..."
    rm -rf /tmp/aws* /tmp/kali* /tmp/mingw* /tmp/go* 2>/dev/null
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    ok "Temp files cleaned"
    
    if [[ -f /var/run/reboot-required ]]; then
        warn "System reboot required!"
        if [[ -f /var/run/reboot-required.pkgs ]]; then
            cat /var/run/reboot-required.pkgs 2>/dev/null | head -5 | while read -r pkg; do
                echo -e "    ${DIM}• $pkg${RESET}"
            done
        fi
    else
        ok "No reboot required"
    fi
}

# ============================================================
# Final Summary
# ============================================================
final_summary() {
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - START_TIME ))
    local minutes=$(( duration / 60 ))
    local seconds=$(( duration % 60 ))
    
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GREEN}  UPDATE COMPLETE${RESET}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}      ${CYAN}${minutes}m ${seconds}s${RESET}"
    echo -e "  ${BOLD}Log:${RESET}           ${DIM}${LOG_FILE}${RESET}"
    echo ""
    echo -e "  ${GREEN}✔ Success:${RESET}     ${SUCCESS_COUNT}"
    echo -e "  ${RED}✗ Failed:${RESET}      ${FAIL_COUNT}"
    echo -e "  ${YELLOW}~ Skipped:${RESET}    ${SKIP_COUNT}"
    echo -e "  ${BLUE}↑ Updated:${RESET}     ${UPDATED_COUNT} components"
    echo ""
    
    if [[ "$DRY_RUN" == "1" ]]; then
        echo -e "  ${YELLOW}${BOLD}MODE: DRY RUN — No changes were made${RESET}"
        echo ""
    fi
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "  ${BOLD}${GREEN}🎉 All updates completed successfully!${RESET}"
    else
        echo -e "  ${BOLD}${YELLOW}⚠ Some operations had issues. Check log for details.${RESET}"
    fi
    
    if [[ -f /var/run/reboot-required ]]; then
        echo ""
        echo -e "  ${BOLD}${YELLOW}⚠ REBOOT REQUIRED${RESET}"
        echo -e "  Run: ${CYAN}sudo reboot${RESET}"
    fi
    
    echo ""
}

# ============================================================
# Main
# ============================================================
main() {
    parse_args "$@"
    banner
    preflight
    
    pre_backup
    
    fix_broken
    update_packages
    upgrade_packages
    full_upgrade
    autoclean
    
    update_go_language
    update_docker_engine
    
    update_go_tools
    update_python_packages
    update_rust_tools
    
    update_c2_frameworks
    update_docker_images
    
    update_nuclei
    update_wordlists
    
    update_shell
    
    verification
    system_cleanup
    
    final_summary
}

main "$@"
UPDATE_SCRIPT
    
    chmod +x "${LOCAL_BIN}/update-tools"
    
    # ========================================================
    # Create update alias
    # ========================================================
    if ! grep -q "alias update=" /root/.kali_env.zsh 2>/dev/null; then
        cat >> /root/.kali_env.zsh << 'ALIAS'

# Update Manager alias
alias update='update-tools'
alias update-dry='DRY_RUN=1 update-tools'
alias update-sys='update-tools system'
alias update-go='update-tools go'
alias update-py='update-tools python'
ALIAS
    fi
    
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  UPDATE MANAGER SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}$((step_duration / 60))m $((step_duration % 60))s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      update-tools v6.7.0"
    echo ""
    echo -e "  ${BOLD}Features:${RESET}"
    echo -e "    ${GREEN}●${RESET} 18-step comprehensive update"
    echo -e "    ${GREEN}●${RESET} Selective component updates"
    echo -e "    ${GREEN}●${RESET} Dry-run mode"
    echo -e "    ${GREEN}●${RESET} Pre-update backup"
    echo -e "    ${GREEN}●${RESET} Post-update verification"
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}update-tools${RESET}              ${DIM}→ Full update${RESET}"
    echo -e "    ${CYAN}update-tools --dry-run${RESET}    ${DIM}→ Simulate update${RESET}"
    echo -e "    ${CYAN}update-tools system${RESET}       ${DIM}→ Update APT only${RESET}"
    echo -e "    ${CYAN}update-tools go python${RESET}    ${DIM}→ Update Go & Python${RESET}"
    echo -e "    ${CYAN}update-tools c2 docker${RESET}    ${DIM}→ Update C2 & Docker${RESET}"
    echo -e "    ${CYAN}update${RESET}                    ${DIM}→ Alias for update-tools${RESET}"
    echo -e "    ${CYAN}update-dry${RESET}                ${DIM}→ Dry-run alias${RESET}"
    echo ""
    
    ok "Update manager ready"
    echo ""
}

# ============================================================
# STEP 16 — Helper Scripts (Professional Edition v2.0)
# ============================================================
