#!/usr/bin/env bash
# modules/13_secrets.sh

do_secrets() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 13/${STEP_TOTAL} — SECRETS MANAGER${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Create Secure Directory Structure
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/8] CREATING SECURE DIRECTORY STRUCTURE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Create main config directory with secure permissions
    if [[ ! -d "$CONFIG_DIR" ]]; then
        mkdir -p "$CONFIG_DIR"
        chmod 700 "$CONFIG_DIR"
        echo -e "    ${GREEN}✔${RESET} Config directory created: ${DIM}$CONFIG_DIR${RESET}"
        ((total_installed++))
    else
        # Fix permissions if needed
        if [[ "$(stat -c '%a' "$CONFIG_DIR" 2>/dev/null)" != "700" ]]; then
            chmod 700 "$CONFIG_DIR"
            echo -e "    ${GREEN}✔${RESET} Config directory permissions fixed (700)${RESET}"
            ((total_installed++))
        else
            echo -e "    ${GREEN}✔${RESET} Config directory ${DIM}[already exists with correct perms]${RESET}"
            ((total_skipped++))
        fi
    fi
    
    # Create subdirectories
    local subdirs=("backups" "gpg-keys" "profiles" "templates")
    for subdir in "${subdirs[@]}"; do
        if [[ ! -d "$CONFIG_DIR/$subdir" ]]; then
            mkdir -p "$CONFIG_DIR/$subdir"
            chmod 700 "$CONFIG_DIR/$subdir"
            echo -e "    ${GREEN}✔${RESET} Created: ${DIM}$subdir/${RESET}"
            ((total_installed++))
        else
            echo -e "    ${GREEN}✔${RESET} ${DIM}$subdir/ [exists]${RESET}"
            ((total_skipped++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 2: Create Comprehensive secrets.env
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/8] CREATING SECRETS ENVIRONMENT FILE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local secrets_file="$CONFIG_DIR/secrets.env"
    
    if [[ ! -f "$secrets_file" ]]; then
        info "Creating comprehensive secrets.env..."
        
        cp "$SCRIPT_DIR/assets/secrets-template.env" "$secrets_file"
        
        chmod 600 "$secrets_file"
        echo -e "    ${GREEN}✔${RESET} secrets.env created with 40+ variables${RESET}"
        ((total_installed++))
    else
        echo -e "    ${GREEN}✔${RESET} secrets.env ${DIM}[already exists]${RESET}"
        ((total_skipped++))
        
        # Check permissions
        if [[ "$(stat -c '%a' "$secrets_file" 2>/dev/null)" != "600" ]]; then
            chmod 600 "$secrets_file"
            echo -e "    ${YELLOW}!${RESET} Fixed permissions to 600${RESET}"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Create Enhanced load_secrets.sh
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/8] CREATING SECRETS LOADER${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local load_script="$CONFIG_DIR/load_secrets.sh"
    
    cat > "$load_script" << 'LOAD_SCRIPT'
#!/usr/bin/env bash
# ============================================================
# Kali Master v6.7.0 — Secrets Loader
# Auto-loads secrets with security checks
# ============================================================

_SECRETS_DIR="${HOME}/.config/kali-master"
_SECRETS_FILE="${_SECRETS_DIR}/secrets.env"
_PROFILE="${KALI_SECRETS_PROFILE:-default}"

# ─── Security Checks ───────────────────────────────────────
_secrets_check_permissions() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local perms
    perms=$(stat -c '%a' "$file" 2>/dev/null)
    
    if [[ "$perms" != "600" ]] && [[ "$perms" != "400" ]]; then
        echo "[!] WARNING: $file has insecure permissions ($perms)" >&2
        echo "    Fix with: chmod 600 $file" >&2
        return 2
    fi
    
    return 0
}

# ─── Load Main Secrets ─────────────────────────────────────
if [[ -f "$_SECRETS_FILE" ]]; then
    if _secrets_check_permissions "$_SECRETS_FILE"; then
        # shellcheck source=/dev/null
        source "$_SECRETS_FILE"
        
        # Count loaded secrets
        _secrets_count=0
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            [[ -n "$value" ]] && ((_secrets_count++))
        done < "$_SECRETS_FILE"
        
        # Export count for status display
        export KALI_SECRETS_LOADED="$_secrets_count"
    fi
fi

# ─── Load Profile-specific Secrets ─────────────────────────
if [[ "$_PROFILE" != "default" ]]; then
    _profile_file="${_SECRETS_DIR}/profiles/${_PROFILE}.env"
    if [[ -f "$_profile_file" ]]; then
        if _secrets_check_permissions "$_profile_file"; then
            # shellcheck source=/dev/null
            source "$_profile_file"
        fi
    fi
fi

# ─── Load Encrypted Secrets (if GPG available) ────────────
_encrypted_file="${_SECRETS_DIR}/secrets.env.gpg"
if [[ -f "$_encrypted_file" ]] && command -v gpg &>/dev/null; then
    if gpg --quiet --decrypt "$_encrypted_file" 2>/dev/null | \
       grep -v '^#' | grep '=' | while IFS='=' read -r key value; do
        [[ -n "$value" ]] && export "$key=$value"
    done; then
        : # Encrypted secrets loaded
    fi
fi

# ─── Cleanup ───────────────────────────────────────────────
unset _SECRETS_DIR _SECRETS_FILE _PROFILE _secrets_count _encrypted_file
unset -f _secrets_check_permissions 2>/dev/null
LOAD_SCRIPT
    
    chmod 600 "$load_script"
    echo -e "    ${GREEN}✔${RESET} load_secrets.sh created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 4: Create secrets-manager CLI Tool
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/8] CREATING SECRETS-MANAGER CLI${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    cat > "${LOCAL_BIN}/secrets-manager" << 'SECRETS_CLI'
#!/usr/bin/env bash
# ============================================================
# secrets-manager — Professional Secrets Manager CLI
# Part of Kali Master Framework v6.7.0
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly RESET='\033[0m'

readonly CONFIG_DIR="$HOME/.config/kali-master"
readonly SECRETS_FILE="$CONFIG_DIR/secrets.env"
readonly BACKUP_DIR="$CONFIG_DIR/backups"
readonly PROFILES_DIR="$CONFIG_DIR/profiles"

# ─── Helpers ───────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*"; }
fail() { echo -e "  ${RED}[✗]${RESET} $*"; }
info() { echo -e "  ${CYAN}[*]${RESET} $*"; }
warn() { echo -e "  ${YELLOW}[!]${RESET} $*"; }

banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   KALI MASTER — SECRETS MANAGER v2.0                  ║
  ║   Secure API Keys & Credentials Management            ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

# ─── Security Check ────────────────────────────────────────
check_security() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        fail "File not found: $file"
        return 1
    fi
    
    local perms
    perms=$(stat -c '%a' "$file" 2>/dev/null)
    
    if [[ "$perms" == "600" ]] || [[ "$perms" == "400" ]]; then
        ok "Permissions OK: $perms"
        return 0
    else
        fail "Insecure permissions: $perms (should be 600)"
        return 1
    fi
}

# ─── List Secrets ──────────────────────────────────────────
cmd_list() {
    banner
    echo -e "${BOLD}${CYAN}[SECRETS STATUS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    check_security "$SECRETS_FILE"
    echo ""
    
    local total=0
    local configured=0
    local empty=0
    
    echo -e "  ${BOLD}Configured Secrets:${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        ((total++))
        
        # Clean value
        value=$(echo "$value" | tr -d '"' | tr -d "'")
        
        if [[ -n "$value" ]]; then
            ((configured++))
            # Mask value (show first 4 and last 4 chars)
            local len=${#value}
            local masked
            if [[ $len -gt 12 ]]; then
                masked="${value:0:4}$(printf '*%.0s' $(seq 1 $((len-8))))${value: -4}"
            else
                masked="****"
            fi
            echo -e "    ${GREEN}●${RESET} ${BOLD}$key${RESET} ${DIM}= $masked${RESET}"
        else
            ((empty++))
            echo -e "    ${DIM}○${RESET} ${DIM}$key${RESET} ${RED}[NOT SET]${RESET}"
        fi
    done < "$SECRETS_FILE"
    
    echo ""
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "  ${BOLD}Summary:${RESET}"
    echo -e "    Total:       $total"
    echo -e "    ${GREEN}Configured:${RESET} $configured"
    echo -e "    ${RED}Empty:${RESET}      $empty"
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ─── Set Secret ────────────────────────────────────────────
cmd_set() {
    local key="$1"
    local value="$2"
    
    if [[ -z "$key" ]] || [[ -z "$value" ]]; then
        fail "Usage: secrets-manager set <KEY> <VALUE>"
        return 1
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    # Backup first
    cmd_backup silent
    
    # Check if key exists
    if grep -q "^export $key=" "$SECRETS_FILE"; then
        # Update existing
        sed -i "s|^export $key=.*|export $key=\"$value\"|" "$SECRETS_FILE"
        ok "Updated: $key"
    else
        # Add new
        echo "export $key=\"$value\"" >> "$SECRETS_FILE"
        ok "Added: $key"
    fi
    
    # Fix permissions
    chmod 600 "$SECRETS_FILE"
}

# ─── Get Secret ────────────────────────────────────────────
cmd_get() {
    local key="$1"
    
    if [[ -z "$key" ]]; then
        fail "Usage: secrets-manager get <KEY>"
        return 1
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    local value
    value=$(grep "^export $key=" "$SECRETS_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        fail "Key not found or empty: $key"
        return 1
    fi
}

# ─── Delete Secret ─────────────────────────────────────────
cmd_delete() {
    local key="$1"
    
    if [[ -z "$key" ]]; then
        fail "Usage: secrets-manager delete <KEY>"
        return 1
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    if grep -q "^export $key=" "$SECRETS_FILE"; then
        sed -i "/^export $key=/d" "$SECRETS_FILE"
        ok "Deleted: $key"
    else
        warn "Key not found: $key"
    fi
}

# ─── Test Secrets ──────────────────────────────────────────
cmd_test() {
    banner
    echo -e "${BOLD}${CYAN}[TESTING SECRETS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    # Source secrets
    # shellcheck source=/dev/null
    source "$SECRETS_FILE" 2>/dev/null
    
    # Test GitHub Token
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        info "Testing GitHub Token..."
        local response
        response=$(curl -sf -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/rate_limit" 2>/dev/null)
        if [[ -n "$response" ]]; then
            local remaining
            remaining=$(echo "$response" | grep -oP '"remaining":\K\d+' | head -1)
            ok "GitHub Token: VALID (remaining: $remaining requests)"
        else
            fail "GitHub Token: INVALID"
        fi
    else
        warn "GitHub Token: NOT SET"
    fi
    
    # Test Shodan API
    if [[ -n "${SHODAN_API_KEY:-}" ]]; then
        info "Testing Shodan API..."
        local response
        response=$(curl -sf "https://api.shodan.io/api-info?key=$SHODAN_API_KEY" 2>/dev/null)
        if [[ -n "$response" ]]; then
            ok "Shodan API: VALID"
        else
            fail "Shodan API: INVALID"
        fi
    else
        warn "Shodan API: NOT SET"
    fi
    
    # Test VirusTotal
    if [[ -n "${VIRUSTOTAL_API_KEY:-}" ]]; then
        info "Testing VirusTotal API..."
        local response
        response=$(curl -sf -H "x-apikey: $VIRUSTOTAL_API_KEY" \
            "https://www.virustotal.com/api/v3/users/$VIRUSTOTAL_API_KEY/overall_quotas" 2>/dev/null)
        if [[ -n "$response" ]]; then
            ok "VirusTotal API: VALID"
        else
            fail "VirusTotal API: INVALID"
        fi
    else
        warn "VirusTotal API: NOT SET"
    fi
    
    # Test AWS credentials
    if [[ -n "${AWS_ACCESS_KEY_ID:-}" ]] && [[ -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
        info "Testing AWS credentials..."
        if command -v aws &>/dev/null; then
            if aws sts get-caller-identity --quiet 2>/dev/null; then
                ok "AWS Credentials: VALID"
            else
                fail "AWS Credentials: INVALID"
            fi
        else
            warn "AWS CLI not installed — cannot test"
        fi
    else
        warn "AWS Credentials: NOT SET"
    fi
    
    echo ""
}

# ─── Backup Secrets ────────────────────────────────────────
cmd_backup() {
    local silent="${1:-}"
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    mkdir -p "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"
    
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/secrets.env.$timestamp"
    
    cp "$SECRETS_FILE" "$backup_file"
    chmod 600 "$backup_file"
    
    # Keep only last 10 backups
    ls -t "$BACKUP_DIR"/secrets.env.* 2>/dev/null | tail -n +11 | xargs -r rm -f
    
    if [[ "$silent" != "silent" ]]; then
        ok "Backup created: $backup_file"
        
        local backup_count
        backup_count=$(ls "$BACKUP_DIR"/secrets.env.* 2>/dev/null | wc -l)
        info "Total backups: $backup_count"
    fi
}

# ─── Restore Secrets ──────────────────────────────────────
cmd_restore() {
    banner
    echo -e "${BOLD}${CYAN}[AVAILABLE BACKUPS]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local backups=()
    local i=1
    
    while IFS= read -r backup; do
        backups+=("$backup")
        local date
        date=$(stat -c '%y' "$backup" | cut -d'.' -f1)
        local size
        size=$(du -h "$backup" | awk '{print $1}')
        echo -e "  ${GREEN}$i)${RESET} $(basename "$backup") ${DIM}($date, $size)${RESET}"
        ((i++))
    done < <(ls -t "$BACKUP_DIR"/secrets.env.* 2>/dev/null)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        warn "No backups found"
        return 1
    fi
    
    echo ""
    read -p "  Select backup to restore [1-$((i-1))] or 'q' to quit: " choice
    
    if [[ "$choice" == "q" ]] || [[ -z "$choice" ]]; then
        return 0
    fi
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -lt "$i" ]]; then
        local selected="${backups[$((choice-1))]}"
        
        echo ""
        warn "This will overwrite current secrets.env"
        read -p "  Continue? [y/N]: " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            cmd_backup silent
            cp "$selected" "$SECRETS_FILE"
            chmod 600 "$SECRETS_FILE"
            ok "Restored from: $(basename "$selected")"
        fi
    fi
}

# ─── Encrypt with GPG ─────────────────────────────────────
cmd_encrypt() {
    if ! command -v gpg &>/dev/null; then
        fail "GPG not installed"
        return 1
    fi
    
    if [[ ! -f "$SECRETS_FILE" ]]; then
        fail "secrets.env not found"
        return 1
    fi
    
    info "Encrypting secrets.env with GPG..."
    
    if gpg --symmetric --cipher-algo AES256 -o "$SECRETS_FILE.gpg" "$SECRETS_FILE" 2>/dev/null; then
        chmod 600 "$SECRETS_FILE.gpg"
        ok "Encrypted: $SECRETS_FILE.gpg"
        info "Decrypt with: gpg --decrypt $SECRETS_FILE.gpg"
    else
        fail "Encryption failed"
        return 1
    fi
}

# ─── Security Audit ───────────────────────────────────────
cmd_audit() {
    banner
    echo -e "${BOLD}${CYAN}[SECURITY AUDIT]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    echo ""
    
    local issues=0
    
    # Check secrets.env permissions
    info "Checking secrets.env permissions..."
    if [[ -f "$SECRETS_FILE" ]]; then
        local perms
        perms=$(stat -c '%a' "$SECRETS_FILE" 2>/dev/null)
        if [[ "$perms" == "600" ]] || [[ "$perms" == "400" ]]; then
            ok "Permissions: $perms (secure)"
        else
            fail "Permissions: $perms (INSECURE - should be 600)"
            ((issues++))
        fi
    else
        warn "secrets.env not found"
    fi
    
    # Check for world-readable files
    info "Scanning for insecure files..."
    local insecure_files
    insecure_files=$(find "$CONFIG_DIR" -type f -perm -o=r 2>/dev/null | wc -l)
    if [[ $insecure_files -gt 0 ]]; then
        fail "Found $insecure_files world-readable files"
        ((issues++))
    else
        ok "No world-readable files"
    fi
    
    # Check for empty secrets
    info "Checking for empty secrets..."
    local empty_count=0
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        value=$(echo "$value" | tr -d '"' | tr -d "'")
        [[ -z "$value" ]] && ((empty_count++))
    done < "$SECRETS_FILE"
    
    if [[ $empty_count -gt 0 ]]; then
        warn "Found $empty_count empty secrets"
    else
        ok "All secrets have values"
    fi
    
    # Check for weak patterns
    info "Checking for weak patterns..."
    local weak_patterns=0
    if grep -qE '(password=|secret=|key=)(123456|password|admin|test)' "$SECRETS_FILE" 2>/dev/null; then
        fail "Found weak password patterns"
        ((issues++))
        ((weak_patterns++))
    fi
    [[ $weak_patterns -eq 0 ]] && ok "No weak patterns detected"
    
    # Check for backup encryption
    info "Checking backup encryption..."
    if [[ -f "$SECRETS_FILE.gpg" ]]; then
        ok "Encrypted backup exists"
    else
        warn "No encrypted backup (run: secrets-manager encrypt)"
    fi
    
    echo ""
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    if [[ $issues -eq 0 ]]; then
        echo -e "  ${GREEN}${BOLD}✔ Security audit passed${RESET}"
    else
        echo -e "  ${RED}${BOLD}✗ Found $issues security issue(s)${RESET}"
    fi
    echo -e "  ${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ─── Create Profile ────────────────────────────────────────
cmd_profile() {
    local action="${1:-list}"
    local profile="${2:-}"
    
    case "$action" in
        list)
            echo -e "${BOLD}Available profiles:${RESET}"
            if [[ -d "$PROFILES_DIR" ]]; then
                for profile_file in "$PROFILES_DIR"/*.env; do
                    [[ -f "$profile_file" ]] || continue
                    local name
                    name=$(basename "$profile_file" .env)
                    echo -e "  ${GREEN}●${RESET} $name"
                done
            else
                echo -e "  ${DIM}No profiles found${RESET}"
            fi
            ;;
        create)
            if [[ -z "$profile" ]]; then
                fail "Usage: secrets-manager profile create <name>"
                return 1
            fi
            mkdir -p "$PROFILES_DIR"
            local profile_file="$PROFILES_DIR/$profile.env"
            if [[ -f "$profile_file" ]]; then
                fail "Profile already exists: $profile"
                return 1
            fi
            cat > "$profile_file" << EOF
# Profile: $profile
# Created: $(date)
EOF
            chmod 600 "$profile_file"
            ok "Created profile: $profile"
            ;;
        use)
            if [[ -z "$profile" ]]; then
                fail "Usage: secrets-manager profile use <name>"
                return 1
            fi
            local profile_file="$PROFILES_DIR/$profile.env"
            if [[ ! -f "$profile_file" ]]; then
                fail "Profile not found: $profile"
                return 1
            fi
            # shellcheck source=/dev/null
            source "$profile_file"
            export KALI_SECRETS_PROFILE="$profile"
            ok "Activated profile: $profile"
            ;;
        *)
            fail "Unknown action: $action"
            ;;
    esac
}

# ─── Usage ─────────────────────────────────────────────────
usage() {
    echo -e "${BOLD}Usage:${RESET} secrets-manager <command> [args]"
    echo ""
    echo -e "${BOLD}Commands:${RESET}"
    echo -e "  ${CYAN}list${RESET}                    List all secrets (masked)"
    echo -e "  ${CYAN}set <KEY> <VALUE>${RESET}       Set a secret value"
    echo -e "  ${CYAN}get <KEY>${RESET}               Get a secret value"
    echo -e "  ${CYAN}delete <KEY>${RESET}            Delete a secret"
    echo -e "  ${CYAN}test${RESET}                    Test API keys validity"
    echo -e "  ${CYAN}backup${RESET}                  Create backup"
    echo -e "  ${CYAN}restore${RESET}                 Restore from backup"
    echo -e "  ${CYAN}encrypt${RESET}                 Encrypt with GPG"
    echo -e "  ${CYAN}audit${RESET}                   Security audit"
    echo -e "  ${CYAN}profile list${RESET}            List profiles"
    echo -e "  ${CYAN}profile create <name>${RESET}   Create profile"
    echo -e "  ${CYAN}profile use <name>${RESET}      Activate profile"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  secrets-manager list"
    echo -e "  secrets-manager set GITHUB_TOKEN ghp_xxxxx"
    echo -e "  secrets-manager get GITHUB_TOKEN"
    echo -e "  secrets-manager test"
    echo -e "  secrets-manager audit"
    echo ""
}

# ─── Main ──────────────────────────────────────────────────
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        list)       cmd_list ;;
        set)        cmd_set "$@" ;;
        get)        cmd_get "$@" ;;
        delete)     cmd_delete "$@" ;;
        test)       cmd_test ;;
        backup)     cmd_backup ;;
        restore)    cmd_restore ;;
        encrypt)    cmd_encrypt ;;
        audit)      cmd_audit ;;
        profile)    cmd_profile "$@" ;;
        help|--help|-h) usage ;;
        *)
            fail "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
SECRETS_CLI
    
    chmod +x "${LOCAL_BIN}/secrets-manager"
    echo -e "    ${GREEN}✔${RESET} secrets-manager CLI installed${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 5: Create Templates for Common Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/8] CREATING TOOL INTEGRATION TEMPLATES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Create tool-specific config templates
    local templates_dir="$CONFIG_DIR/templates"
    mkdir -p "$templates_dir"
    
    # AWS credentials template
    cat > "$templates_dir/aws_credentials.tpl" << 'AWS_TPL'
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
region = ${AWS_DEFAULT_REGION:-us-east-1}
output = json
AWS_TPL
    
    # subfinder config template
    cat > "$templates_dir/subfinder_config.tpl" << 'SF_TPL'
resolvers:
  - 1.1.1.1
  - 8.8.8.8
  - 9.9.9.9
sources:
  - shodan
  - censys
  - binaryedge
  - securitytrails
  - virustotal
shodan:
  - ${SHODAN_API_KEY}
censys:
  - ${CENSYS_API_ID}:${CENSYS_API_SECRET}
binaryedge:
  - ${BINARYEDGE_API_KEY}
securitytrails:
  - ${SECURITYTRAILS_API_KEY}
virustotal:
  - ${VIRUSTOTAL_API_KEY}
SF_TPL
    
    # nuclei config template
    cat > "$templates_dir/nuclei_config.tpl" << 'NUCLEI_TPL'
# Nuclei Configuration
# Generated by Kali Master Framework

# API Keys
shodan: ${SHODAN_API_KEY}
github: ${GITHUB_TOKEN}

# Notification Config
slack:
  - ${SLACK_WEBHOOK_URL}
discord:
  - ${DISCORD_WEBHOOK_URL}
telegram:
  - chat_id: ${TELEGRAM_CHAT_ID}
    token: ${TELEGRAM_BOT_TOKEN}
NUCLEI_TPL
    
    echo -e "    ${GREEN}✔${RESET} Created 3 tool templates${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 6: Security Hardening
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/8] SECURITY HARDENING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Ensure all files have correct permissions
    info "Setting secure permissions..."
    find "$CONFIG_DIR" -type f -exec chmod 600 {} \; 2>/dev/null
    find "$CONFIG_DIR" -type d -exec chmod 700 {} \; 2>/dev/null
    ok "Permissions hardened (600 for files, 700 for dirs)"
    ((total_installed++))
    
    # Create .gitignore for config dir
    if [[ ! -f "$CONFIG_DIR/.gitignore" ]]; then
        cat > "$CONFIG_DIR/.gitignore" << 'GITIGNORE'
# Ignore all secrets
*.env
*.gpg
*.key
*.pem
*.p12

# Ignore backups (too sensitive)
backups/

# Allow templates (no secrets)
!templates/*.tpl

# Ignore profiles
profiles/
GITIGNORE
        echo -e "    ${GREEN}✔${RESET} Created .gitignore${RESET}"
        ((total_installed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Verification
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/8] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local verified=0
    local total_checks=0
    
    # Check secrets.env
    ((total_checks++))
    if [[ -f "$SECRETS_FILE" ]] && [[ "$(stat -c '%a' "$SECRETS_FILE" 2>/dev/null)" == "600" ]]; then
        echo -e "    ${GREEN}✔${RESET} secrets.env exists with correct permissions"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} secrets.env issue"
    fi
    
    # Check load_secrets.sh
    ((total_checks++))
    if [[ -f "$CONFIG_DIR/load_secrets.sh" ]]; then
        echo -e "    ${GREEN}✔${RESET} load_secrets.sh exists"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} load_secrets.sh missing"
    fi
    
    # Check secrets-manager CLI
    ((total_checks++))
    if command -v secrets-manager &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} secrets-manager CLI available"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} secrets-manager CLI missing"
    fi
    
    # Test loading secrets
    ((total_checks++))
    if (source "$CONFIG_DIR/load_secrets.sh" 2>/dev/null); then
        echo -e "    ${GREEN}✔${RESET} Secrets load successfully"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} Secrets load failed"
    fi
    
    # Count variables
    local var_count
    var_count=$(grep -c "^export " "$SECRETS_FILE" 2>/dev/null || echo "0")
    info "Total secret variables: $var_count"
    
    echo ""
    
    # ========================================================
    # Phase 8: Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    local step_minutes=$((step_duration / 60))
    local step_seconds=$((step_duration % 60))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  SECRETS MANAGER SETUP COMPLETE${RESET}"
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
    echo -e "  ${BOLD}Components:${RESET}"
    echo -e "    ${GREEN}●${RESET} Secure directory structure (700)"
    echo -e "    ${GREEN}●${RESET} secrets.env ($var_count variables)"
    echo -e "    ${GREEN}●${RESET} load_secrets.sh (auto-loader)"
    echo -e "    ${GREEN}●${RESET} secrets-manager CLI (11 commands)"
    echo -e "    ${GREEN}●${RESET} Tool templates (AWS, subfinder, nuclei)"
    echo -e "    ${GREEN}●${RESET} Security hardening"
    echo -e "    ${GREEN}●${RESET} .gitignore protection"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed"
        info "Check log: ${LOG_FILE}"
    else
        ok "Secrets manager ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}secrets-manager${RESET}               ${DIM}→ Open secrets manager${RESET}"
    echo -e "    ${CYAN}secrets-manager list${RESET}          ${DIM}→ List all secrets (masked)${RESET}"
    echo -e "    ${CYAN}secrets-manager set KEY VALUE${RESET} ${DIM}→ Set a secret${RESET}"
    echo -e "    ${CYAN}secrets-manager get KEY${RESET}       ${DIM}→ Get a secret${RESET}"
    echo -e "    ${CYAN}secrets-manager test${RESET}          ${DIM}→ Test API keys${RESET}"
    echo -e "    ${CYAN}secrets-manager backup${RESET}        ${DIM}→ Create backup${RESET}"
    echo -e "    ${CYAN}secrets-manager restore${RESET}       ${DIM}→ Restore from backup${RESET}"
    echo -e "    ${CYAN}secrets-manager encrypt${RESET}       ${DIM}→ Encrypt with GPG${RESET}"
    echo -e "    ${CYAN}secrets-manager audit${RESET}         ${DIM}→ Security audit${RESET}"
    echo -e "    ${CYAN}secrets-manager profile list${RESET}  ${DIM}→ List profiles${RESET}"
    echo ""
    echo -e "  ${BOLD}Edit secrets directly:${RESET}"
    echo -e "    ${CYAN}nano ~/.config/kali-master/secrets.env${RESET}"
    echo -e "    ${CYAN}vim ~/.config/kali-master/secrets.env${RESET}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}⚠  SECURITY REMINDER${RESET}"
    echo -e "  ${DIM}• Never commit secrets.env to version control${RESET}"
    echo -e "  ${DIM}• Keep permissions at 600 (owner only)${RESET}"
    echo -e "  ${DIM}• Use GPG encryption for extra security${RESET}"
    echo -e "  ${DIM}• Run 'secrets-manager audit' regularly${RESET}"
    echo ""
}

# ============================================================
# STEP 14 — VM Optimization & Hardening (Professional Edition)
# ============================================================
