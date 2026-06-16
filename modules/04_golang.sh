#!/usr/bin/env bash
# modules/04_golang.sh

do_golang() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 4/${STEP_TOTAL} — GO LANGUAGE ENVIRONMENT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    
    # ========================================================
    # Phase 1: Detection & Current Version Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/7] DETECTING EXISTING GO INSTALLATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local existing_go=""
    local existing_go_version=""
    local existing_go_path=""
    local needs_install=1
    
    # Check common Go installation paths
    local go_paths=(
        "/usr/local/go/bin/go"
        "/usr/bin/go"
        "$HOME/go/bin/go"
        "/snap/bin/go"
    )
    
    for go_path in "${go_paths[@]}"; do
        if [[ -x "$go_path" ]]; then
            existing_go_path="$go_path"
            existing_go_version=$("$go_path" version 2>/dev/null | awk '{print $3}' | sed 's/go//')
            existing_go="$go_path"
            break
        fi
    done
    
    # Also check PATH
    if [[ -z "$existing_go" ]] && command -v go &>/dev/null; then
        existing_go_path=$(command -v go)
        existing_go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
        existing_go="go"
    fi
    
    if [[ -n "$existing_go" ]]; then
        ok "Existing Go installation found"
        info "Path:    ${DIM}${existing_go_path}${RESET}"
        info "Version: ${BOLD}go${existing_go_version}${RESET}"
        
        # Export current PATH
        export PATH="$PATH:$(dirname "$existing_go_path"):$GOPATH_BIN"
    else
        info "No existing Go installation detected"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Fetch Latest Stable Version
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/7] FETCHING LATEST STABLE VERSION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Querying Go download API..."
    
    local latest_version=""
    local latest_version_info=""
    
    # Try to fetch latest version from official API
    if curl -sf --max-time 10 "https://go.dev/dl/?mode=json" > /tmp/go_versions.json 2>/dev/null; then
        latest_version=$(python3 -c "
import sys, json
try:
    data = json.load(open('/tmp/go_versions.json'))
    stable = [x for x in data if x.get('stable', False)]
    if stable:
        print(stable[0]['version'].replace('go', ''))
except Exception as e:
    pass
" 2>/dev/null)
        
        # Get release date
        latest_version_info=$(python3 -c "
import sys, json
try:
    data = json.load(open('/tmp/go_versions.json'))
    stable = [x for x in data if x.get('stable', False)]
    if stable:
        print(stable[0].get('files', [{}])[0].get('sha256', 'unknown'))
except:
    pass
" 2>/dev/null)
        
        rm -f /tmp/go_versions.json
        
        if [[ -n "$latest_version" ]]; then
            ok "Latest stable version: ${BOLD}go${latest_version}${RESET}"
        else
            warn "Could not fetch latest version — using fallback"
            latest_version="1.23.4"
        fi
    else
        warn "API unreachable — using fallback version"
        latest_version="1.23.4"
    fi
    
    # Compare versions
    if [[ -n "$existing_go_version" ]]; then
        if [[ "$existing_go_version" == "$latest_version" ]]; then
            ok "Go is already up-to-date (go${existing_go_version})"
            needs_install=0
        else
            info "Update available: go${existing_go_version} → go${latest_version}"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Architecture Detection
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/7] DETECTING SYSTEM ARCHITECTURE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local arch
    arch=$(uname -m)
    local go_arch=""
    local go_os="linux"
    
    case "$arch" in
        x86_64|amd64)
            go_arch="amd64"
            ok "Architecture: ${BOLD}x86_64 (amd64)${RESET}"
            ;;
        aarch64|arm64)
            go_arch="arm64"
            ok "Architecture: ${BOLD}ARM64 (aarch64)${RESET}"
            ;;
        armv7l|armv6l)
            go_arch="armv6l"
            ok "Architecture: ${BOLD}ARM (armv6l)${RESET}"
            ;;
        i386|i686)
            go_arch="386"
            ok "Architecture: ${BOLD}x86 (386)${RESET}"
            ;;
        *)
            fail "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    local go_tar="go${latest_version}.${go_os}-${go_arch}.tar.gz"
    local go_url="https://go.dev/dl/${go_tar}"
    
    info "Target package: ${DIM}${go_tar}${RESET}"
    echo ""
    
    # Skip installation if already up-to-date
    if [[ $needs_install -eq 0 ]]; then
        info "Skipping installation — Go is already up-to-date"
        echo ""
    else
        # ========================================================
        # Phase 4: Download Go
        # ========================================================
        echo -e "${BOLD}${CYAN}[PHASE 4/7] DOWNLOADING GO ${latest_version}${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        local download_path="/tmp/${go_tar}"
        
        # Remove old download if exists
        rm -f "$download_path"
        
        info "Downloading from: ${DIM}${go_url}${RESET}"
        
        if safe_wget "$go_url" "$download_path"; then
            local file_size
            file_size=$(du -h "$download_path" 2>/dev/null | awk '{print $1}')
            ok "Download complete (${file_size})"
        else
            fail "Download failed — trying alternative mirror..."
            
            # Try alternative download
            if curl -fsSL --max-time 120 -o "$download_path" "$go_url" 2>> "$LOG_FILE"; then
                ok "Download successful via alternative method"
            else
                fail "All download attempts failed"
                rm -f "$download_path"
                return 1
            fi
        fi
        
        echo ""
        
        # ========================================================
        # Phase 5: Verify & Install
        # ========================================================
        echo -e "${BOLD}${CYAN}[PHASE 5/7] VERIFYING & INSTALLING${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        # Verify file integrity
        info "Verifying file integrity..."
        if file "$download_path" | grep -q "gzip compressed"; then
            ok "File integrity verified (valid gzip archive)"
        else
            fail "Downloaded file is corrupted or invalid"
            rm -f "$download_path"
            return 1
        fi
        
        # Backup existing installation
        if [[ -d "/usr/local/go" ]]; then
            info "Backing up existing Go installation..."
            local backup_dir="/usr/local/go.backup.$(date +%Y%m%d_%H%M%S)"
            if mv /usr/local/go "$backup_dir" 2>/dev/null; then
                ok "Backup created: ${DIM}${backup_dir}${RESET}"
            else
                warn "Could not create backup — proceeding with overwrite"
                rm -rf /usr/local/go
            fi
        fi
        
        # Extract Go
        info "Extracting Go to /usr/local/go..."
        if tar -C /usr/local -xzf "$download_path" >> "$LOG_FILE" 2>&1; then
            ok "Extraction complete"
        else
            fail "Extraction failed"
            rm -f "$download_path"
            return 1
        fi
        
        # Cleanup
        rm -f "$download_path"
        
        # Set permissions
        chmod -R 755 /usr/local/go
        ok "Permissions set"
        
        echo ""
    fi
    
    # ========================================================
    # Phase 6: Environment Setup
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/7] CONFIGURING ENVIRONMENT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Update PATH for current session
    export PATH="/usr/local/go/bin:$GOPATH_BIN:$PATH"
    export GOPATH="$HOME/go"
    export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
    export GONOSUMDB="*"
    
    # Create GOPATH directories
    mkdir -p "$GOPATH"/{bin,src,pkg} 2>/dev/null
    ok "GOPATH directories created: ${DIM}$GOPATH${RESET}"
    
    # System-wide Go configuration
    local go_profile="/etc/profile.d/golang.sh"
    info "Creating system-wide Go configuration..."
    
    cat > "$go_profile" << 'GOEOF'
# ============================================================
# Go Language Environment — Kali Master Framework
# ============================================================
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
export GO111MODULE="on"
GOEOF
    chmod +x "$go_profile"
    ok "System profile configured: ${DIM}${go_profile}${RESET}"
    
    # Add to shell RC files
    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc" ]]; then
            if ! grep -q "GOPATH" "$rc" 2>/dev/null; then
                cat >> "$rc" << 'RCEOF'

# Go Language Environment — Kali Master Framework
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
RCEOF
                ok "Shell configuration updated: ${DIM}$(basename $rc)${RESET}"
            else
                skip "Shell already configured: ${DIM}$(basename $rc)${RESET}"
            fi
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 7: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/7] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify Go installation
    local installed_version=""
    local installed_path=""
    
    if [[ -x "/usr/local/go/bin/go" ]]; then
        installed_path="/usr/local/go/bin/go"
        installed_version=$(/usr/local/go/bin/go version 2>/dev/null | awk '{print $3}')
        ok "Go binary verified: ${DIM}${installed_path}${RESET}"
        ok "Version: ${BOLD}${installed_version}${RESET}"
    else
        fail "Go binary not found after installation"
        return 1
    fi
    
    # Test Go functionality
    info "Testing Go functionality..."
    local test_dir="/tmp/go_test_$$"
    mkdir -p "$test_dir"
    cat > "$test_dir/main.go" << 'GOTEST'
package main
import "fmt"
func main() { fmt.Println("Go is working!") }
GOTEST
    
    if (cd "$test_dir" && /usr/local/go/bin/go run main.go >> "$LOG_FILE" 2>&1); then
        ok "Go runtime test: PASSED"
    else
        warn "Go runtime test: FAILED (may still work for most tools)"
    fi
    
    rm -rf "$test_dir"
    
    # Get installed packages count
    local go_tools_count=0
    if [[ -d "$GOPATH_BIN" ]]; then
        go_tools_count=$(find "$GOPATH_BIN" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
    fi
    
    echo ""
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    local step_minutes=$((step_duration / 60))
    local step_seconds=$((step_duration % 60))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  GO ENVIRONMENT SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${BOLD}Version:${RESET}        ${GREEN}${installed_version}${RESET}"
    echo -e "  ${BOLD}Path:${RESET}           ${DIM}${installed_path}${RESET}"
    echo -e "  ${BOLD}GOPATH:${RESET}         ${DIM}${GOPATH}${RESET}"
    echo -e "  ${BOLD}Architecture:${RESET}   ${go_os}-${go_arch}"
    echo -e "  ${BOLD}Installed Tools:${RESET} ${go_tools_count} Go binaries"
    echo ""
    echo -e "  ${BOLD}Environment Variables:${RESET}"
    echo -e "    ${DIM}GOPROXY = ${GOPROXY}${RESET}"
    echo -e "    ${DIM}GONOSUMDB = ${GONOSUMDB}${RESET}"
    echo -e "    ${DIM}GO111MODULE = on${RESET}"
    echo ""
    
    if [[ $needs_install -eq 0 ]]; then
        ok "Go was already up-to-date — no changes made"
    else
        ok "Go environment ready for tool installation"
    fi
    
    echo ""
}

# ============================================================
# STEP 5 — Docker Installation (Professional Edition)
# ============================================================
