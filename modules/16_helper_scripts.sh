#!/usr/bin/env bash
# modules/16_helper_scripts.sh

do_helper_scripts() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 16/${STEP_TOTAL} — HELPER SCRIPTS SETUP${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    install_missing_bb_tools
    
    local step_start_time
    step_start_time=$(date +%s)
    local tools_installed=0
    
    info "Installing 17 professional helper scripts..."
    echo ""
    
    # ========================================================
    # 1. bb-recon — Professional Bug Bounty Reconnaissance
    # ========================================================
    cat > "${LOCAL_BIN}/bb-recon" << 'BB_RECON'
#!/usr/bin/env bash
# ============================================================
#  BB-RECON v4.0 — Professional Bug Bounty Reconnaissance
#  Comprehensive methodology with 18 steps
#  Fixes: httpx fallback, content discovery, tech fingerprinting
# ============================================================

set -uo pipefail

# Colors
readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'; readonly MAGENTA='\033[0;35m'; readonly BOLD='\033[1m'
readonly DIM='\033[2m'; readonly BLUE='\033[0;34m'; readonly RESET='\033[0m'

readonly VERSION="4.0"
readonly TOTAL_STEPS=18
START_TIME=$(date +%s)
CURRENT_STEP=0
DOMAIN=""
MODE="standard"
OUT_DIR=""
FOUND_COUNT=0
GAU_TIMEOUT=600
AMASS_TIMEOUT=300
SCREENSHOT=false
INSTALL_MISSING=false

# ============================================================
# Helpers
# ============================================================
ok()   { echo -e "  ${GREEN}[✔]${RESET} $*"; }
fail() { echo -e "  ${RED}[✗]${RESET} $*"; }
info() { echo -e "  ${CYAN}[*]${RESET} $*"; }
warn() { echo -e "  ${YELLOW}[!]${RESET} $*"; }
skip() { echo -e "  ${DIM}[~]${RESET} ${DIM}$*${RESET}"; }

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP ${CURRENT_STEP}/${TOTAL_STEPS} — $*${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
}

has_tool() { command -v "$1" &>/dev/null; }

safe_read() {
    local file="$1"
    [[ -f "$file" ]] && [[ -s "$file" ]] && return 0
    return 1
}

safe_wc() {
    local file="$1"
    if safe_read "$file"; then
        wc -l < "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Safe append - creates file if doesn't exist
safe_append() {
    local source="$1"
    local target="$2"
    if safe_read "$source"; then
        cat "$source" >> "$target"
    fi
}

banner() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'

██████╗ ██████╗       ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗      ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝██████╔╝█████╗██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══██╗╚════╝██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██████╔╝██████╔╝      ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═════╝ ╚═════╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝                                                         
EOF
    echo -e "${RESET}"
    echo -e "  ${BOLD}Professional Bug Bounty Reconnaissance — v${VERSION}${RESET}"
    echo -e "  ${DIM}Comprehensive Methodology • 50+ Tools • 18 Steps${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
}

usage() {
    echo -e "${BOLD}Usage:${RESET} bb-recon <domain> [options]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${CYAN}--passive${RESET}        Passive recon only"
    echo -e "  ${CYAN}--quick${RESET}          Quick recon (skip slow steps)"
    echo -e "  ${CYAN}--deep${RESET}           Deep recon (all tools)"
    echo -e "  ${CYAN}--ultra${RESET}          Ultra recon (deep + screenshots + advanced)"
    echo -e "  ${CYAN}--screenshot${RESET}     Enable screenshotting"
    echo -e "  ${CYAN}--install${RESET}        Install missing tools automatically"
    echo -e "  ${CYAN}--gau-timeout <sec>${RESET}  Timeout for gau (default: 600s)"
    echo -e "  ${CYAN}--help${RESET}           Show this help"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  bb-recon example.com"
    echo -e "  bb-recon example.com --deep"
    echo -e "  bb-recon example.com --ultra --screenshot"
    echo -e "  bb-recon example.com --install --deep"
}

# ============================================================
# Parse Arguments
# ============================================================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --passive) MODE="passive"; shift ;;
            --quick) MODE="quick"; shift ;;
            --deep) MODE="deep"; shift ;;
            --ultra) MODE="ultra"; SCREENSHOT=true; shift ;;
            --screenshot) SCREENSHOT=true; shift ;;
            --install) INSTALL_MISSING=true; shift ;;
            --gau-timeout) GAU_TIMEOUT="$2"; shift 2 ;;
            --help|-h) usage; exit 0 ;;
            -*) warn "Unknown option: $1"; shift ;;
            *) [[ -z "$DOMAIN" ]] && DOMAIN="$1"; shift ;;
        esac
    done
    
    [[ -z "$DOMAIN" ]] && { usage; exit 1; }
    
    OUT_DIR="$HOME/bugbounty/${DOMAIN}/recon_$(date +%Y%m%d_%H%M)"
    mkdir -p "$OUT_DIR"/{subdomains,http,ports,vulns,js,urls,params,notes,api,cloud,screenshots,reports,content,tech}
}

# ============================================================
# STEP 1: Install Missing Tools (FIXED - Real Implementation)
# ============================================================
install_tools() {
    [[ "$INSTALL_MISSING" != "true" ]] && return 0
    
    step "INSTALLING MISSING TOOLS"
    info "Checking and installing missing tools..."
    
    # Go tools
    local go_tools=(
        "findomain|github.com/findomain/findomain"
        "httprobe|github.com/tomnomnom/httprobe"
        "kiterunner|github.com/assetnote/kiterunner/v2/cmd/kr"
        "subjack|github.com/haccer/subjack"
    )
    
    for tool_info in "${go_tools[@]}"; do
        IFS='|' read -r tool_name package <<< "$tool_info"
        if ! has_tool "$tool_name"; then
            info "Installing $tool_name via go..."
            if GOPATH="$HOME/go" go install "$package"@latest >> "$LOG_FILE" 2>&1; then
                ok "$tool_name installed"
            else
                warn "$tool_name installation failed"
            fi
        else
            ok "$tool_name already installed"
        fi
    done
    
    # Python tools
    local py_tools=(
        "paramspider|https://github.com/devanshbatham/ParamSpider.git"
        "jsfinder|https://github.com/Threezh1/JSFinder.git"
    )
    
    for tool_info in "${py_tools[@]}"; do
        IFS='|' read -r tool_name repo <<< "$tool_info"
        if ! has_tool "$tool_name"; then
            info "Installing $tool_name via git..."
            local tool_dir="/opt/tools/$tool_name"
            if git clone --depth 1 "$repo" "$tool_dir" >> "$LOG_FILE" 2>&1; then
                if [[ -f "$tool_dir/requirements.txt" ]]; then
                    "${VENV_DIR}/bin/pip" install -r "$tool_dir/requirements.txt" --quiet >> "$LOG_FILE" 2>&1
                fi
                ok "$tool_name installed"
            else
                warn "$tool_name installation failed"
            fi
        else
            ok "$tool_name already installed"
        fi
    done
    
    # APT tools
    local apt_tools=("whatweb" "hakrawler" "massdns")
    for tool in "${apt_tools[@]}"; do
        if ! has_tool "$tool"; then
            info "Installing $tool via apt..."
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$tool" >> "$LOG_FILE" 2>&1; then
                ok "$tool installed"
            else
                warn "$tool installation failed"
            fi
        else
            ok "$tool already installed"
        fi
    done
    
    # Install GF patterns if missing
    if ! [[ -d "$HOME/.gf" ]]; then
        info "Installing GF patterns..."
        if git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns "$HOME/.gf" >> "$LOG_FILE" 2>&1; then
            ok "GF patterns installed"
        else
            warn "GF patterns installation failed"
        fi
    fi
}

# ============================================================
# STEP 2: Passive Subdomain Enumeration
# ============================================================
passive_subdomains() {
    step "PASSIVE SUBDOMAIN ENUMERATION"
    local out="$OUT_DIR/subdomains/passive.txt"
    touch "$out"
    
    # Subfinder
    if has_tool subfinder; then
        info "Running Subfinder..."
        subfinder -d "$DOMAIN" -all -silent -recursive -o "$OUT_DIR/subdomains/subfinder.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/subfinder.txt")
        ok "Subfinder: $count subdomains"
        safe_append "$OUT_DIR/subdomains/subfinder.txt" "$out"
    fi
    
    # Assetfinder
    if has_tool assetfinder; then
        info "Running Assetfinder..."
        assetfinder --subs-only "$DOMAIN" > "$OUT_DIR/subdomains/assetfinder.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/assetfinder.txt")
        ok "Assetfinder: $count subdomains"
        safe_append "$OUT_DIR/subdomains/assetfinder.txt" "$out"
    fi
    
    # Amass
    if has_tool amass; then
        info "Running Amass (passive) [timeout: ${AMASS_TIMEOUT}s]..."
        timeout "$AMASS_TIMEOUT" amass enum -passive -d "$DOMAIN" -o "$OUT_DIR/subdomains/amass.txt" 2>/dev/null || true
        
        if safe_read "$OUT_DIR/subdomains/amass.txt"; then
            local count
            count=$(safe_wc "$OUT_DIR/subdomains/amass.txt")
            ok "Amass: $count subdomains"
            safe_append "$OUT_DIR/subdomains/amass.txt" "$out"
        else
            warn "Amass: timeout or no results"
            touch "$OUT_DIR/subdomains/amass.txt"
        fi
    fi
    
    # Findomain
    if has_tool findomain; then
        info "Running Findomain..."
        findomain -t "$DOMAIN" -u "$OUT_DIR/subdomains/findomain.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/findomain.txt")
        if [[ $count -gt 0 ]]; then
            ok "Findomain: $count subdomains"
            safe_append "$OUT_DIR/subdomains/findomain.txt" "$out"
        fi
    fi
    
    # CRT.sh
    info "Querying CRT.sh..."
    curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" 2>/dev/null | \
        jq -r '.[].name_value' 2>/dev/null | \
        sed 's/\*\.//g' | \
        sort -u > "$OUT_DIR/subdomains/crtsh.txt" || true
    
    local count
    count=$(safe_wc "$OUT_DIR/subdomains/crtsh.txt")
    if [[ $count -gt 0 ]]; then
        ok "CRT.sh: $count subdomains"
        safe_append "$OUT_DIR/subdomains/crtsh.txt" "$out"
    fi
    
    # GitHub subdomains
    if has_tool github-subdomains && [[ -n "${GITHUB_TOKEN:-}" ]]; then
        info "Running GitHub subdomain search..."
        github-subdomains -d "$DOMAIN" -t "$GITHUB_TOKEN" -o "$OUT_DIR/subdomains/github.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/github.txt")
        if [[ $count -gt 0 ]]; then
            ok "GitHub: $count subdomains"
            safe_append "$OUT_DIR/subdomains/github.txt" "$out"
        fi
    fi
    
    sort -u "$out" -o "$out"
    local total
    total=$(safe_wc "$out")
    echo ""
    ok "${BOLD}Total passive subdomains: $total${RESET}"
}

# ============================================================
# STEP 3: Active Subdomain Enumeration
# ============================================================
active_subdomains() {
    [[ "$MODE" == "passive" ]] && { skip "Active recon skipped (passive mode)"; return 0; }
    step "ACTIVE SUBDOMAIN ENUMERATION"
    
    # DNSX resolution
    if has_tool dnsx && safe_read "$OUT_DIR/subdomains/passive.txt"; then
        info "DNS resolution with dnsx..."
        dnsx -l "$OUT_DIR/subdomains/passive.txt" -silent -resp -o "$OUT_DIR/subdomains/resolved.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/resolved.txt")
        ok "Resolved: $count subdomains"
    fi
    
    # Shuffledns
    if has_tool shuffledns && [[ "$MODE" != "quick" ]]; then
        info "Running Shuffledns..."
        shuffledns -d "$DOMAIN" -list "$OUT_DIR/subdomains/passive.txt" \
            -o "$OUT_DIR/subdomains/shuffledns.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/subdomains/shuffledns.txt")
        if [[ $count -gt 0 ]]; then
            ok "Shuffledns: $count subdomains"
            safe_append "$OUT_DIR/subdomains/shuffledns.txt" "$out"
        fi
    fi
    
    # Merge all into all.txt
    cat "$OUT_DIR/subdomains/"*.txt 2>/dev/null | \
        grep -oP '[a-zA-Z0-9][-a-zA-Z0-9]*\.'"$DOMAIN"'$' | \
        sort -u > "$OUT_DIR/subdomains/all.txt"
    
    local total
    total=$(safe_wc "$OUT_DIR/subdomains/all.txt")
    ok "${BOLD}Total unique subdomains: $total${RESET}"
    
    # Reverse DNS (deep mode)
    if [[ "$MODE" == "deep" ]] || [[ "$MODE" == "ultra" ]]; then
        if has_tool dnsx && safe_read "$OUT_DIR/subdomains/resolved.txt"; then
            info "Running reverse DNS lookup..."
            dnsx -ptr -l "$OUT_DIR/subdomains/resolved.txt" -resp-only \
                -o "$OUT_DIR/subdomains/reverse_dns.txt" 2>/dev/null || true
            local count
            count=$(safe_wc "$OUT_DIR/subdomains/reverse_dns.txt")
            if [[ $count -gt 0 ]]; then
                ok "Reverse DNS: $count additional subdomains"
                safe_append "$OUT_DIR/subdomains/reverse_dns.txt" "$OUT_DIR/subdomains/all.txt"
                sort -u "$OUT_DIR/subdomains/all.txt" -o "$OUT_DIR/subdomains/all.txt"
            fi
        fi
    fi
}

# ============================================================
# STEP 4: Port Scanning (MOVED UP - Before HTTP Probing)
# ============================================================
port_scan() {
    [[ "$MODE" == "passive" ]] && { skip "Port scan skipped (passive mode)"; return 0; }
    step "PORT SCANNING (naabu)"
    
    if ! has_tool naabu; then
        warn "naabu not installed"
        return 0
    fi
    
    if ! safe_read "$OUT_DIR/subdomains/all.txt"; then
        warn "No subdomains to scan"
        return 0
    fi
    
    info "Scanning top ports..."
    naabu -list "$OUT_DIR/subdomains/all.txt" -silent -top-ports 1000 \
        -o "$OUT_DIR/ports/ports.txt" 2>/dev/null || true
    
    local count
    count=$(safe_wc "$OUT_DIR/ports/ports.txt")
    ok "Open ports found: $count"
    
    # Extract unique subdomains with open ports
    if safe_read "$OUT_DIR/ports/ports.txt"; then
        awk -F: '{print $1}' "$OUT_DIR/ports/ports.txt" | sort -u > "$OUT_DIR/ports/hosts_with_ports.txt"
        local hosts_count
        hosts_count=$(safe_wc "$OUT_DIR/ports/hosts_with_ports.txt")
        ok "Hosts with open ports: $hosts_count"
    fi
}

# ============================================================
# STEP 5: HTTP Probing (FIXED - 5 Fallback Methods)
# ============================================================
http_probe() {
    [[ "$MODE" == "passive" ]] && { skip "HTTP probe skipped (passive mode)"; return 0; }
    step "HTTP PROBING"
    
    if ! safe_read "$OUT_DIR/subdomains/all.txt"; then
        warn "No subdomains to probe"
        touch "$OUT_DIR/http/alive.txt"
        touch "$OUT_DIR/http/urls.txt"
        return 0
    fi
    
    local subdomain_count
    subdomain_count=$(safe_wc "$OUT_DIR/subdomains/all.txt")
    info "Probing $subdomain_count subdomains..."
    echo ""
    
    # Method 1: httpx with full options
    if has_tool httpx; then
        info "Method 1: httpx (standard)..."
        httpx -l "$OUT_DIR/subdomains/all.txt" \
            -silent -status-code -title -tech-detect \
            -content-length -web-server -cdn \
            -threads 50 -timeout 10 -retries 2 \
            -o "$OUT_DIR/http/alive.txt" 2>&1 | head -20
        
        if safe_read "$OUT_DIR/http/alive.txt"; then
            local count
            count=$(safe_wc "$OUT_DIR/http/alive.txt")
            if [[ $count -gt 0 ]]; then
                ok "httpx: $count live hosts"
                awk '{print $1}' "$OUT_DIR/http/alive.txt" | sort -u > "$OUT_DIR/http/urls.txt"
                return 0
            fi
        fi
    fi
    
    # Method 2: httprobe (alternative)
    if has_tool httprobe; then
        warn "Method 1 failed. Trying httprobe..."
        rm -f "$OUT_DIR/http/alive.txt"
        
        cat "$OUT_DIR/subdomains/all.txt" | httprobe -c 50 -t 10000 \
            > "$OUT_DIR/http/httprobe.txt" 2>&1
        
        if safe_read "$OUT_DIR/http/httprobe.txt"; then
            local count
            count=$(safe_wc "$OUT_DIR/http/httprobe.txt")
            if [[ $count -gt 0 ]]; then
                ok "httprobe: $count live hosts"
                cp "$OUT_DIR/http/httprobe.txt" "$OUT_DIR/http/urls.txt"
                
                # Convert to alive.txt format
                while IFS= read -r url; do
                    echo "$url [200]" >> "$OUT_DIR/http/alive.txt"
                done < "$OUT_DIR/http/httprobe.txt"
                return 0
            fi
        fi
    fi
    
    # Method 3: Build from naabu results
    if safe_read "$OUT_DIR/ports/ports.txt"; then
        warn "Methods 1-2 failed. Building from port scan results..."
        rm -f "$OUT_DIR/http/alive.txt"
        touch "$OUT_DIR/http/alive.txt"
        
        # Extract HTTP/HTTPS ports
        grep -E ":(80|443|8080|8443|8000|8888)$" "$OUT_DIR/ports/ports.txt" | \
            while IFS=: read -r host port; do
                if [[ "$port" == "443" ]] || [[ "$port" == "8443" ]]; then
                    echo "https://$host:$port [200]" >> "$OUT_DIR/http/alive.txt"
                else
                    echo "http://$host:$port [200]" >> "$OUT_DIR/http/alive.txt"
                fi
            done
        
        if safe_read "$OUT_DIR/http/alive.txt"; then
            local count
            count=$(safe_wc "$OUT_DIR/http/alive.txt")
            if [[ $count -gt 0 ]]; then
                ok "Reconstructed $count live hosts from port scan"
                awk '{print $1}' "$OUT_DIR/http/alive.txt" | sort -u > "$OUT_DIR/http/urls.txt"
                return 0
            fi
        fi
    fi
    
    # Method 4: Manual curl check (sample)
    warn "Methods 1-3 failed. Manual curl check on first 100 subdomains..."
    rm -f "$OUT_DIR/http/alive.txt"
    touch "$OUT_DIR/http/alive.txt"
    
    local checked=0
    local alive=0
    
    while IFS= read -r subdomain && [[ $checked -lt 100 ]]; do
        ((checked++))
        
        # Try HTTPS
        if curl -sI --max-time 5 "https://$subdomain" 2>/dev/null | grep -q "HTTP/"; then
            echo "https://$subdomain [200]" >> "$OUT_DIR/http/alive.txt"
            ((alive++))
        # Try HTTP
        elif curl -sI --max-time 5 "http://$subdomain" 2>/dev/null | grep -q "HTTP/"; then
            echo "http://$subdomain [200]" >> "$OUT_DIR/http/alive.txt"
            ((alive++))
        fi
        
        [[ $((alive % 10)) -eq 0 ]] && [[ $alive -gt 0 ]] && info "  Found $alive live hosts..."
    done < "$OUT_DIR/subdomains/all.txt"
    
    if [[ $alive -gt 0 ]]; then
        ok "Manual check: $alive live hosts"
        awk '{print $1}' "$OUT_DIR/http/alive.txt" | sort -u > "$OUT_DIR/http/urls.txt"
    else
        warn "No live hosts found with any method"
        touch "$OUT_DIR/http/alive.txt"
        touch "$OUT_DIR/http/urls.txt"
    fi
    
    # Status breakdown
    if safe_read "$OUT_DIR/http/alive.txt"; then
        for code in 200 301 302 403 401 500; do
            if grep -q "\[$code\]" "$OUT_DIR/http/alive.txt" 2>/dev/null; then
                local c
                c=$(grep -c "\[$code\]" "$OUT_DIR/http/alive.txt" || echo 0)
                [[ $c -gt 0 ]] && info "  Status $code: $c hosts"
            fi
        done
    fi
}

# ============================================================
# STEP 6: Tech Fingerprinting (NEW)
# ============================================================
tech_fingerprint() {
    [[ "$MODE" == "passive" ]] && { skip "Tech fingerprinting skipped"; return 0; }
    step "TECHNOLOGY FINGERPRINTING"
    
    if ! safe_read "$OUT_DIR/http/urls.txt"; then
        warn "No live hosts for fingerprinting"
        return 0
    fi
    
    # WhatWeb
    if has_tool whatweb; then
        info "Running WhatWeb..."
        while IFS= read -r url; do
            whatweb --no-errors "$url" 2>/dev/null >> "$OUT_DIR/tech/whatweb.txt" || true
        done < "$OUT_DIR/http/urls.txt"
        
        local count
        count=$(safe_wc "$OUT_DIR/tech/whatweb.txt")
        if [[ $count -gt 0 ]]; then
            ok "WhatWeb: $count fingerprints"
        fi
    else
        warn "WhatWeb not installed"
    fi
    
    # Extract tech from httpx if available
    if safe_read "$OUT_DIR/http/alive.txt"; then
        info "Extracting technologies from httpx results..."
        grep -oP 'tech-detect:\K[^\[]+' "$OUT_DIR/http/alive.txt" 2>/dev/null | \
            sort -u > "$OUT_DIR/tech/technologies.txt" || true
        
        local count
        count=$(safe_wc "$OUT_DIR/tech/technologies.txt")
        if [[ $count -gt 0 ]]; then
            ok "Technologies detected: $count"
        fi
    fi
}

# ============================================================
# STEP 7: URL Discovery
# ============================================================
url_discovery() {
    [[ "$MODE" == "passive" ]] && { skip "URL discovery skipped (passive mode)"; return 0; }
    step "URL DISCOVERY"
    touch "$OUT_DIR/urls/all_urls.txt"
    
    if ! safe_read "$OUT_DIR/subdomains/all.txt"; then
        warn "No subdomains for URL discovery"
        return 0
    fi
    
    # GAU
    if has_tool gau; then
        info "Running gau [timeout: ${GAU_TIMEOUT}s]..."
        timeout "$GAU_TIMEOUT" bash -c "cat '$OUT_DIR/subdomains/all.txt' | gau --threads 5" 2>/dev/null | \
            grep -vE '\.(js|css|png|jpg|gif|svg|woff|woff2|ttf|eot|ico)$' | \
            sort -u > "$OUT_DIR/urls/gau.txt" || true
        
        local count
        count=$(safe_wc "$OUT_DIR/urls/gau.txt")
        if [[ $count -gt 0 ]]; then
            ok "gau: $count URLs"
            safe_append "$OUT_DIR/urls/gau.txt" "$OUT_DIR/urls/all_urls.txt"
        fi
    fi
    
    # Waybackurls
    if has_tool waybackurls; then
        info "Running waybackurls..."
        cat "$OUT_DIR/subdomains/all.txt" | waybackurls > "$OUT_DIR/urls/wayback.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/urls/wayback.txt")
        if [[ $count -gt 0 ]]; then
            ok "waybackurls: $count URLs"
            safe_append "$OUT_DIR/urls/wayback.txt" "$OUT_DIR/urls/all_urls.txt"
        fi
    fi
    
    # Katana (if live hosts exist)
    if has_tool katana && [[ "$MODE" != "quick" ]] && safe_read "$OUT_DIR/http/urls.txt"; then
        info "Running katana crawler..."
        head -50 "$OUT_DIR/http/urls.txt" | timeout 300 katana -silent -d 3 \
            -o "$OUT_DIR/urls/katana.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/urls/katana.txt")
        if [[ $count -gt 0 ]]; then
            ok "katana: $count URLs"
            safe_append "$OUT_DIR/urls/katana.txt" "$OUT_DIR/urls/all_urls.txt"
        fi
    fi
    
    # Hakrawler
    if has_tool hakrawler && safe_read "$OUT_DIR/http/urls.txt"; then
        info "Running hakrawler..."
        head -20 "$OUT_DIR/http/urls.txt" | hakrawler -depth 2 -plain \
            > "$OUT_DIR/urls/hakrawler.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/urls/hakrawler.txt")
        if [[ $count -gt 0 ]]; then
            ok "hakrawler: $count URLs"
            safe_append "$OUT_DIR/urls/hakrawler.txt" "$OUT_DIR/urls/all_urls.txt"
        fi
    fi
    
    sort -u "$OUT_DIR/urls/all_urls.txt" -o "$OUT_DIR/urls/all_urls.txt"
    local total
    total=$(safe_wc "$OUT_DIR/urls/all_urls.txt")
    ok "${BOLD}Total unique URLs: $total${RESET}"
}

# ============================================================
# STEP 8: JavaScript Analysis
# ============================================================
js_analysis() {
    [[ "$MODE" == "passive" ]] && { skip "JS analysis skipped (passive mode)"; return 0; }
    step "JAVASCRIPT ANALYSIS"
    
    if ! safe_read "$OUT_DIR/urls/all_urls.txt"; then
        warn "No URLs for JS analysis"
        return 0
    fi
    
    # Extract JS files from URLs
    info "Extracting JavaScript files..."
    grep -iE '\.js($|\?)' "$OUT_DIR/urls/all_urls.txt" | sort -u > "$OUT_DIR/js/js_files.txt"
    local count
    count=$(safe_wc "$OUT_DIR/js/js_files.txt")
    ok "JS files found: $count"
    
    # subjs
    if has_tool subjs && safe_read "$OUT_DIR/http/urls.txt"; then
        info "Running subjs..."
        cat "$OUT_DIR/http/urls.txt" | subjs 2>/dev/null | \
            sort -u >> "$OUT_DIR/js/js_files.txt" || true
        sort -u "$OUT_DIR/js/js_files.txt" -o "$OUT_DIR/js/js_files.txt"
        count=$(safe_wc "$OUT_DIR/js/js_files.txt")
        ok "subjs: total $count JS files"
    fi
    
    # LinkFinder
    if has_tool linkfinder && safe_read "$OUT_DIR/js/js_files.txt"; then
        info "Running LinkFinder..."
        head -20 "$OUT_DIR/js/js_files.txt" | while read -r js; do
            linkfinder -i "$js" -o cli 2>/dev/null >> "$OUT_DIR/js/endpoints.txt" || true
        done
        count=$(safe_wc "$OUT_DIR/js/endpoints.txt")
        if [[ $count -gt 0 ]]; then
            ok "LinkFinder: $count endpoints"
        fi
    fi
    
    # Sensitive patterns in JS
    if safe_read "$OUT_DIR/js/js_files.txt"; then
        info "Searching for sensitive patterns in JS..."
        grep -iE '(api[_-]?key|secret|password|token|auth|aws|firebase)' \
            "$OUT_DIR/js/js_files.txt" > "$OUT_DIR/js/sensitive.txt" 2>/dev/null || true
        count=$(safe_wc "$OUT_DIR/js/sensitive.txt")
        if [[ $count -gt 0 ]]; then
            ok "Sensitive patterns: $count files"
        fi
    fi
}

# ============================================================
# STEP 9: Content Discovery (NEW - Critical Gap)
# ============================================================
content_discovery() {
    [[ "$MODE" == "passive" ]] && { skip "Content discovery skipped"; return 0; }
    [[ "$MODE" == "quick" ]] && { skip "Content discovery skipped (quick mode)"; return 0; }
    step "CONTENT DISCOVERY"
    
    if ! safe_read "$OUT_DIR/http/urls.txt"; then
        warn "No live hosts for content discovery"
        return 0
    fi
    
    local wordlist="/opt/wordlists/SecLists/Discovery/Web-Content/raft-medium-directories.txt"
    [[ ! -f "$wordlist" ]] && wordlist="/usr/share/wordlists/dirb/common.txt"
    
    # Feroxbuster (recursive)
    if has_tool feroxbuster; then
        info "Running feroxbuster (recursive)..."
        cat "$OUT_DIR/http/urls.txt" | feroxbuster --stdin \
            -w "$wordlist" \
            -s 200,301,302,403,401 \
            -t 20 -n \
            -o "$OUT_DIR/content/feroxbuster.txt" 2>/dev/null || true
        
        local count
        count=$(safe_wc "$OUT_DIR/content/feroxbuster.txt")
        if [[ $count -gt 0 ]]; then
            ok "Feroxbuster: $count findings"
        fi
    fi
    
    # Dirsearch (multi-extension)
    if has_tool dirsearch; then
        info "Running dirsearch..."
        head -10 "$OUT_DIR/http/urls.txt" | while read -r url; do
            dirsearch -u "$url" -w "$wordlist" \
                -e php,html,js,json,txt,bak,sql \
                -i 200,301,302,403 \
                --random-agent \
                -o "$OUT_DIR/content/dirsearch.txt" 2>/dev/null || true
        done
        
        local count
        count=$(safe_wc "$OUT_DIR/content/dirsearch.txt")
        if [[ $count -gt 0 ]]; then
            ok "Dirsearch: $count findings"
        fi
    fi
    
    # FFUF (parameter brute)
    if has_tool ffuf; then
        info "Running ffuf..."
        head -5 "$OUT_DIR/http/urls.txt" | while read -r url; do
            ffuf -u "${url}/FUZZ" -w "$wordlist" \
                -mc 200,301,302,403 \
                -t 50 -ac \
                -o "$OUT_DIR/content/ffuf.json" 2>/dev/null || true
        done
        
        if [[ -f "$OUT_DIR/content/ffuf.json" ]]; then
            ok "FFUF: results saved"
        fi
    fi
    
    # Gobuster (vhost discovery)
    if has_tool gobuster && [[ "$MODE" == "ultra" ]]; then
        info "Running gobuster vhost..."
        head -5 "$OUT_DIR/http/urls.txt" | while read -r url; do
            gobuster vhost -u "$url" \
                -w "$wordlist" \
                --append-domain \
                -o "$OUT_DIR/content/gobuster_vhost.txt" 2>/dev/null || true
        done
        
        local count
        count=$(safe_wc "$OUT_DIR/content/gobuster_vhost.txt")
        if [[ $count -gt 0 ]]; then
            ok "Gobuster vhost: $count findings"
        fi
    fi
}

# ============================================================
# STEP 10: Parameter Discovery
# ============================================================
param_discovery() {
    [[ "$MODE" != "deep" ]] && [[ "$MODE" != "ultra" ]] && { skip "Param discovery skipped"; return 0; }
    step "PARAMETER DISCOVERY"
    
    # Arjun
    if has_tool arjun && safe_read "$OUT_DIR/http/urls.txt"; then
        info "Running arjun on top 20 URLs..."
        head -20 "$OUT_DIR/http/urls.txt" | while read -r url; do
            arjun -u "$url" -q 2>/dev/null >> "$OUT_DIR/params/arjun.txt" || true
        done
        local count
        count=$(safe_wc "$OUT_DIR/params/arjun.txt")
        if [[ $count -gt 0 ]]; then
            ok "Arjun: $count parameters"
        fi
    fi
    
    # GF patterns (FIXED - reads from all_urls.txt)
    if has_tool gf && safe_read "$OUT_DIR/urls/all_urls.txt"; then
        info "Running GF patterns..."
        
        # Check if GF patterns are installed
        if [[ ! -d "$HOME/.gf" ]]; then
            warn "GF patterns not installed. Installing..."
            git clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns "$HOME/.gf" >> "$LOG_FILE" 2>&1 || true
        fi
        
        for pattern in xss ssti ssrf redirect idor sqli lfi; do
            if [[ -f "$HOME/.gf/${pattern}.json" ]]; then
                cat "$OUT_DIR/urls/all_urls.txt" | gf "$pattern" > "$OUT_DIR/params/${pattern}.txt" 2>/dev/null || true
                local count
                count=$(safe_wc "$OUT_DIR/params/${pattern}.txt")
                [[ $count -gt 0 ]] && ok "  GF $pattern: $count URLs"
            else
                warn "  GF pattern '$pattern' not found"
            fi
        done
    fi
}

# ============================================================
# STEP 11: Cloud & ASN Enumeration
# ============================================================
cloud_asn_enum() {
    [[ "$MODE" != "deep" ]] && [[ "$MODE" != "ultra" ]] && { skip "Cloud/ASN enum skipped"; return 0; }
    step "CLOUD & ASN ENUMERATION"
    
    # CloudEnum
    if has_tool cloud_enum; then
        info "Running cloud_enum..."
        cloud_enum -k "$DOMAIN" -l "$OUT_DIR/cloud/cloud_enum.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/cloud/cloud_enum.txt")
        if [[ $count -gt 0 ]]; then
            ok "CloudEnum: $count findings"
        fi
    fi
    
    # ASN enumeration
    if has_tool amass && [[ "$MODE" == "ultra" ]]; then
        info "Running ASN enumeration..."
        amass intel -d "$DOMAIN" -o "$OUT_DIR/cloud/asn.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/cloud/asn.txt")
        if [[ $count -gt 0 ]]; then
            ok "ASN: $count findings"
        fi
    fi
}

# ============================================================
# STEP 12: Vulnerability Scanning (Nuclei)
# ============================================================
vuln_scan() {
    [[ "$MODE" == "passive" ]] && { skip "Vuln scan skipped"; return 0; }
    step "VULNERABILITY SCANNING (Nuclei)"
    
    if ! has_tool nuclei; then
        fail "nuclei not installed"
        return 1
    fi
    
    if ! safe_read "$OUT_DIR/http/urls.txt"; then
        warn "No live hosts to scan"
        touch "$OUT_DIR/vulns/nuclei.txt"
        return 1
    fi
    
    local severity="low,medium,high,critical"
    [[ "$MODE" == "quick" ]] && severity="high,critical"
    
    info "Running nuclei (severity: $severity)..."
    nuclei -l "$OUT_DIR/http/urls.txt" -severity "$severity" -silent \
        -o "$OUT_DIR/vulns/nuclei.txt" 2>/dev/null || true
    
    local count
    count=$(safe_wc "$OUT_DIR/vulns/nuclei.txt")
    FOUND_COUNT=$count
    
    if [[ $count -gt 0 ]]; then
        ok "${BOLD}${RED}Vulnerabilities found: $count${RESET}"
        echo ""
        info "Breakdown by severity:"
        for sev in critical high medium low info; do
            local c
            c=$(grep -i "\[$sev\]" "$OUT_DIR/vulns/nuclei.txt" 2>/dev/null | wc -l || echo 0)
            [[ $c -gt 0 ]] && echo -e "    ${DIM}• $sev: $c${RESET}"
        done
    else
        ok "No vulnerabilities found"
    fi
    
    # Subdomain Takeover check
    if has_tool nuclei; then
        info "Checking for subdomain takeover..."
        nuclei -l "$OUT_DIR/http/urls.txt" -tags takeover -silent \
            -o "$OUT_DIR/vulns/takeover.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/vulns/takeover.txt")
        if [[ $count -gt 0 ]]; then
            ok "${BOLD}${RED}Subdomain takeovers: $count${RESET}"
        fi
    fi
}

# ============================================================
# STEP 13: XSS & SQLi Scanning
# ============================================================
xss_sqli_scan() {
    [[ "$MODE" != "deep" ]] && [[ "$MODE" != "ultra" ]] && { skip "XSS/SQLi scan skipped"; return 0; }
    step "XSS & SQLI SCANNING"
    
    # Dalfox (XSS) - FIXED: reads from params/xss.txt
    if has_tool dalfox && safe_read "$OUT_DIR/params/xss.txt"; then
        info "Running Dalfox (XSS)..."
        dalfox file "$OUT_DIR/params/xss.txt" --silence \
            -o "$OUT_DIR/vulns/dalfox.txt" 2>/dev/null || true
        local count
        count=$(safe_wc "$OUT_DIR/vulns/dalfox.txt")
        if [[ $count -gt 0 ]]; then
            ok "Dalfox: $count XSS findings"
        fi
    fi
    
    # Ghauri (SQLi) - FIXED: reads from params/sqli.txt
    if has_tool ghauri && safe_read "$OUT_DIR/params/sqli.txt"; then
        info "Running Ghauri (SQLi)..."
        head -10 "$OUT_DIR/params/sqli.txt" | while read -r url; do
            ghauri -u "$url" --batch --level 2 2>/dev/null >> "$OUT_DIR/vulns/ghauri.txt" || true
        done
        local count
        count=$(safe_wc "$OUT_DIR/vulns/ghauri.txt")
        if [[ $count -gt 0 ]]; then
            ok "Ghauri: $count SQLi findings"
        fi
    fi
}

# ============================================================
# STEP 14: Vuln-Specific Tests (NEW)
# ============================================================
vuln_specific_tests() {
    [[ "$MODE" != "ultra" ]] && { skip "Vuln-specific tests skipped (use --ultra)"; return 0; }
    step "VULNERABILITY-SPECIFIC TESTS"
    
    # SSRF Testing
    if safe_read "$OUT_DIR/params/ssrf.txt"; then
        info "Testing SSRF..."
        cat "$OUT_DIR/params/ssrf.txt" | qsreplace "http://burpcollaborator.net" | \
            while read -r url; do
                curl -s "$url" 2>/dev/null | grep -i "burpcollaborator" >> "$OUT_DIR/vulns/ssrf.txt" || true
            done
        local count
        count=$(safe_wc "$OUT_DIR/vulns/ssrf.txt")
        if [[ $count -gt 0 ]]; then
            ok "SSRF: $count potential findings"
        fi
    fi
    
    # Open Redirect Testing
    if safe_read "$OUT_DIR/params/redirect.txt"; then
        info "Testing Open Redirect..."
        cat "$OUT_DIR/params/redirect.txt" | qsreplace "https://evil.com" | \
            while read -r url; do
                curl -sI "$url" 2>/dev/null | grep -i "evil.com" >> "$OUT_DIR/vulns/redirect.txt" || true
            done
        local count
        count=$(safe_wc "$OUT_DIR/vulns/redirect.txt")
        if [[ $count -gt 0 ]]; then
            ok "Open Redirect: $count potential findings"
        fi
    fi
    
    # LFI Testing
    if safe_read "$OUT_DIR/params/lfi.txt"; then
        info "Testing LFI..."
        cat "$OUT_DIR/params/lfi.txt" | qsreplace "/etc/passwd" | \
            while read -r url; do
                curl -s "$url" 2>/dev/null | grep "root:x:" >> "$OUT_DIR/vulns/lfi.txt" || true
            done
        local count
        count=$(safe_wc "$OUT_DIR/vulns/lfi.txt")
        if [[ $count -gt 0 ]]; then
            ok "LFI: $count potential findings"
        fi
    fi
}

# ============================================================
# STEP 15: API Enumeration (NEW)
# ============================================================
api_enumeration() {
    [[ "$MODE" != "ultra" ]] && { skip "API enumeration skipped (use --ultra)"; return 0; }
    step "API ENUMERATION"
    
    # Kiterunner
    if has_tool kr && safe_read "$OUT_DIR/http/urls.txt"; then
        info "Running Kiterunner..."
        grep -i "api" "$OUT_DIR/http/urls.txt" | head -5 | while read -r url; do
            kr scan "$url" -w /usr/share/kiterunner/routes-large.kite \
                -o "$OUT_DIR/api/kiterunner.txt" 2>/dev/null || true
        done
        local count
        count=$(safe_wc "$OUT_DIR/api/kiterunner.txt")
        if [[ $count -gt 0 ]]; then
            ok "Kiterunner: $count API routes"
        fi
    fi
    
    # Extract API endpoints from URLs
    if safe_read "$OUT_DIR/urls/all_urls.txt"; then
        info "Extracting API endpoints..."
        grep -iE '(/api/|/graphql|/v[0-9]/|/rest/)' "$OUT_DIR/urls/all_urls.txt" | \
            sort -u > "$OUT_DIR/api/endpoints.txt"
        local count
        count=$(safe_wc "$OUT_DIR/api/endpoints.txt")
        if [[ $count -gt 0 ]]; then
            ok "API endpoints: $count"
        fi
    fi
}

# ============================================================
# STEP 16: Screenshotting
# ============================================================
screenshotting() {
    [[ "$SCREENSHOT" != "true" ]] && { skip "Screenshotting disabled"; return 0; }
    step "SCREENSHOTTING"
    
    if ! safe_read "$OUT_DIR/http/urls.txt"; then
        warn "No live hosts for screenshots"
        return 0
    fi
    
    # Aquatone
    if has_tool aquatone; then
        info "Running Aquatone..."
        cat "$OUT_DIR/http/urls.txt" | aquatone -out "$OUT_DIR/screenshots/aquatone/" -silent 2>/dev/null || true
        local count
        count=$(find "$OUT_DIR/screenshots/aquatone/" -name "*.png" 2>/dev/null | wc -l)
        if [[ $count -gt 0 ]]; then
            ok "Aquatone: $count screenshots"
        fi
    fi
    
    # Gowitness
    if has_tool gowitness; then
        info "Running Gowitness..."
        gowitness scan file -f "$OUT_DIR/http/urls.txt" --threads 10 \
            --screenshot-path "$OUT_DIR/screenshots/gowitness/" 2>/dev/null || true
        local count
        count=$(find "$OUT_DIR/screenshots/gowitness/" -name "*.png" 2>/dev/null | wc -l)
        if [[ $count -gt 0 ]]; then
            ok "Gowitness: $count screenshots"
        fi
    fi
}

# ============================================================
# STEP 17: Generate Comprehensive Report (FIXED)
# ============================================================
generate_report() {
    step "GENERATING COMPREHENSIVE REPORT"
    
    local report_file="$OUT_DIR/report.md"
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - START_TIME ))
    
    cat > "$report_file" << EOF
# Bug Bounty Reconnaissance Report

## Executive Summary
- **Target**: $DOMAIN
- **Mode**: $MODE
- **Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Duration**: $((duration/60))m $((duration%60))s
- **Output Directory**: $OUT_DIR

## Summary Statistics

| Category | Count |
|----------|-------|
| Subdomains | $(safe_wc "$OUT_DIR/subdomains/all.txt") |
| Live Hosts | $(safe_wc "$OUT_DIR/http/urls.txt") |
| URLs | $(safe_wc "$OUT_DIR/urls/all_urls.txt") |
| JS Files | $(safe_wc "$OUT_DIR/js/js_files.txt") |
| Parameters | $(safe_wc "$OUT_DIR/params/arjun.txt") |
| Content Findings | $(safe_wc "$OUT_DIR/content/feroxbuster.txt") |
| Vulnerabilities | $(safe_wc "$OUT_DIR/vulns/nuclei.txt") |
| Screenshots | $(find "$OUT_DIR/screenshots/" -name "*.png" 2>/dev/null | wc -l) |

## Key Findings

### Live Hosts (Top 20)
\`\`\`
$(head -20 "$OUT_DIR/http/alive.txt" 2>/dev/null || echo "No live hosts found")
\`\`\`

### Top Vulnerabilities
\`\`\`
$(head -20 "$OUT_DIR/vulns/nuclei.txt" 2>/dev/null || echo "No vulnerabilities found")
\`\`\`

### XSS Findings
\`\`\`
$(head -20 "$OUT_DIR/vulns/dalfox.txt" 2>/dev/null || echo "No XSS findings")
\`\`\`

### SQLi Findings
\`\`\`
$(head -20 "$OUT_DIR/vulns/ghauri.txt" 2>/dev/null || echo "No SQLi findings")
\`\`\`

### Subdomain Takeovers
\`\`\`
$(head -20 "$OUT_DIR/vulns/takeover.txt" 2>/dev/null || echo "No takeovers found")
\`\`\`

## File Structure
\`\`\`
$OUT_DIR/
├── subdomains/          # Subdomain enumeration
├── http/                # HTTP probing
├── ports/               # Port scanning
├── urls/                # URL discovery
├── js/                  # JavaScript analysis
├── params/              # Parameter discovery
├── content/             # Content discovery
├── vulns/               # Vulnerability findings
├── screenshots/         # Screenshots
├── cloud/               # Cloud enumeration
├── api/                 # API enumeration
├── tech/                # Technology fingerprinting
└── report.md            # This report
\`\`\`

## Recommendations

### Immediate Actions
1. Review all critical and high severity vulnerabilities
2. Test XSS and SQLi findings manually
3. Investigate exposed endpoints and parameters
4. Review screenshots for interesting findings
5. Check content discovery for sensitive files

### Next Steps
1. Manual testing of identified endpoints
2. Advanced exploitation of confirmed vulnerabilities
3. POC creation for valid findings
4. Report submission to bug bounty platform

---
Generated by BB-Recon v$VERSION
EOF
    
    ok "Report saved: ${BOLD}$report_file${RESET}"
}

# ============================================================
# STEP 18: Final Summary
# ============================================================
final_summary() {
    step "FINAL SUMMARY"
    
    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - START_TIME ))
    
    echo ""
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${GREEN}  RECONNAISSANCE COMPLETE${RESET}"
    echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Target:${RESET}    $DOMAIN"
    echo -e "  ${BOLD}Mode:${RESET}      $MODE"
    echo -e "  ${BOLD}Duration:${RESET}  $((duration/60))m $((duration%60))s"
    echo -e "  ${BOLD}Output:${RESET}    ${DIM}$OUT_DIR${RESET}"
    echo ""
    echo -e "  ${CYAN}Results:${RESET}"
    echo -e "    • Subdomains:       $(safe_wc "$OUT_DIR/subdomains/all.txt")"
    echo -e "    • Live Hosts:       $(safe_wc "$OUT_DIR/http/urls.txt")"
    echo -e "    • URLs:             $(safe_wc "$OUT_DIR/urls/all_urls.txt")"
    echo -e "    • JS Files:         $(safe_wc "$OUT_DIR/js/js_files.txt")"
    echo -e "    • Parameters:       $(safe_wc "$OUT_DIR/params/arjun.txt")"
    echo -e "    • Content Findings: $(safe_wc "$OUT_DIR/content/feroxbuster.txt")"
    echo -e "    • Vulnerabilities:  ${FOUND_COUNT}"
    echo -e "    • Screenshots:      $(find "$OUT_DIR/screenshots/" -name "*.png" 2>/dev/null | wc -l)"
    echo ""
    
    if [[ $FOUND_COUNT -gt 0 ]]; then
        echo -e "  ${BOLD}${RED}⚠ Review vulnerabilities in: $OUT_DIR/vulns/nuclei.txt${RESET}"
    else
        echo -e "  ${BOLD}${GREEN}✓ No vulnerabilities detected${RESET}"
    fi
    
    echo ""
    echo -e "  ${BOLD}Useful commands:${RESET}"
    echo -e "    ${DIM}cat $OUT_DIR/vulns/nuclei.txt${RESET}"
    echo -e "    ${DIM}cat $OUT_DIR/http/alive.txt${RESET}"
    echo -e "    ${DIM}cat $OUT_DIR/report.md${RESET}"
    echo -e "    ${DIM}ls -la $OUT_DIR/screenshots/${RESET}"
    echo ""
}

# ============================================================
# Main
# ============================================================
main() {
    banner
    parse_args "$@"
    
    echo ""
    echo -e "${BOLD}${CYAN}Target: ${DOMAIN}${RESET}"
    echo -e "${BOLD}${CYAN}Mode:   ${MODE}${RESET}"
    echo -e "${BOLD}${CYAN}Output: ${OUT_DIR}${RESET}"
    echo ""
    info "Starting recon in 3 seconds... (Ctrl+C to cancel)"
    sleep 3
    
    # Execute all 18 steps
    install_tools
    passive_subdomains
    active_subdomains
    port_scan
    http_probe
    tech_fingerprint
    url_discovery
    js_analysis
    content_discovery
    param_discovery
    cloud_asn_enum
    vuln_scan
    xss_sqli_scan
    vuln_specific_tests
    api_enumeration
    screenshotting
    generate_report
    final_summary
}

main "$@"
BB_RECON
    chmod +x "${LOCAL_BIN}/bb-recon"
    echo -e "  ${GREEN}[✔]${RESET} bb-recon — Professional Bug Bounty Recon"
    ((tools_installed++))
    
    # ========================================================
    # 2. newbb — Bug Bounty Workspace Creator
    # ========================================================
    cat > "${LOCAL_BIN}/newbb" << 'NEWBB'
#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
    echo "Usage: newbb <domain>"
    exit 1
fi
BASE_DIR="$HOME/bugbounty/$DOMAIN"
mkdir -p "$BASE_DIR"/{subdomains,http,ports,vulns,js,urls,params,notes,api,cloud,screenshots,reports,content,tech}
cat > "$BASE_DIR/notes/notes.txt" << EOF
Target: $DOMAIN
Created: $(date)
EOF
echo "[✔] Workspace created for Bug Bounty: $BASE_DIR"
NEWBB
    chmod +x "${LOCAL_BIN}/newbb"
    echo -e "  ${GREEN}[✔]${RESET} newbb — Bug Bounty Workspace Creator"
    ((tools_installed++))

    # ========================================================
    # 3. newctf — CTF Workspace Creator
    # ========================================================
    cat > "${LOCAL_BIN}/newctf" << 'NEWCTF'
#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-}"
if [[ -z "$NAME" ]]; then
    echo "Usage: newctf <name>"
    exit 1
fi
BASE_DIR="$HOME/ctf/$NAME"
mkdir -p "$BASE_DIR"/{nmap,exploits,payloads,loot,notes,web,pwn,crypto,re}
cat > "$BASE_DIR/notes/notes.txt" << EOF
CTF: $NAME
Created: $(date)
EOF
echo "[✔] Workspace created for CTF: $BASE_DIR"
NEWCTF
    chmod +x "${LOCAL_BIN}/newctf"
    echo -e "  ${GREEN}[✔]${RESET} newctf — CTF Workspace Creator"
    ((tools_installed++))

    # ========================================================
    # 4. newad — Active Directory Workspace Creator
    # ========================================================
    cat > "${LOCAL_BIN}/newad" << 'NEWAD'
#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
    echo "Usage: newad <domain>"
    exit 1
fi
BASE_DIR="$HOME/ad/$DOMAIN"
mkdir -p "$BASE_DIR"/{recon,bloodhound,ldap,kerberos,loot,credentials,notes,exploits}
cat > "$BASE_DIR/notes/notes.txt" << EOF
Domain: $DOMAIN
Created: $(date)
EOF
echo "[✔] Workspace created for AD: $BASE_DIR"
NEWAD
    chmod +x "${LOCAL_BIN}/newad"
    echo -e "  ${GREEN}[✔]${RESET} newad — AD Workspace Creator"
    ((tools_installed++))

    # ========================================================
    # 5. newpayload — Payload Project Creator
    # ========================================================
    cat > "${LOCAL_BIN}/newpayload" << 'NEWPAYLOAD'
#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-}"
if [[ -z "$NAME" ]]; then
    echo "Usage: newpayload <name>"
    exit 1
fi
BASE_DIR="$HOME/payloads/$NAME"
mkdir -p "$BASE_DIR"/{src,bin,obfuscation,templates,notes}
cat > "$BASE_DIR/notes/notes.txt" << EOF
Payload Project: $NAME
Created: $(date)
EOF
echo "[✔] Workspace created for Payload Development: $BASE_DIR"
NEWPAYLOAD
    chmod +x "${LOCAL_BIN}/newpayload"
    echo -e "  ${GREEN}[✔]${RESET} newpayload — Payload Project Creator"
    ((tools_installed++))

    # ========================================================
    # 6. newredteam — Red Team Operation Creator
    # ========================================================
    cat > "${LOCAL_BIN}/newredteam" << 'NEWREDTEAM'
#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-}"
if [[ -z "$NAME" ]]; then
    echo "Usage: newredteam <name>"
    exit 1
fi
BASE_DIR="$HOME/redteam/$NAME"
mkdir -p "$BASE_DIR"/{recon,c2,redirectors,payloads,postexploit,credentials,loot,reports,notes}
cat > "$BASE_DIR/notes/notes.txt" << EOF
Red Team Project: $NAME
Created: $(date)
EOF
echo "[✔] Workspace created for Red Team Operation: $BASE_DIR"
NEWREDTEAM
    chmod +x "${LOCAL_BIN}/newredteam"
    echo -e "  ${GREEN}[✔]${RESET} newredteam — Red Team Operation Creator"
    ((tools_installed++))

    # ========================================================
    # 7. sub-enum — Subdomain Enumeration
    # ========================================================
    cat > "${LOCAL_BIN}/sub-enum" << 'SUB_ENUM'
#!/usr/bin/env bash
set -euo pipefail
DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
    echo "Usage: sub-enum <domain> [output_file]"
    exit 1
fi
OUT_FILE="${2:-subdomains.txt}"
echo "[*] Starting subdomain enumeration for $DOMAIN..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

if command -v subfinder &>/dev/null; then
    echo "[*] Running subfinder..."
    subfinder -d "$DOMAIN" -silent -o "$TEMP_DIR/subfinder.txt" || true
fi

if command -v assetfinder &>/dev/null; then
    echo "[*] Running assetfinder..."
    assetfinder --subs-only "$DOMAIN" > "$TEMP_DIR/assetfinder.txt" || true
fi

echo "[*] Querying CRT.sh..."
curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" | jq -r '.[].name_value' 2>/dev/null | sed 's/\*\.//g' | sort -u > "$TEMP_DIR/crtsh.txt" || true

cat "$TEMP_DIR"/*.txt 2>/dev/null | sort -u > "$OUT_FILE"
TOTAL=$(wc -l < "$OUT_FILE" 2>/dev/null || echo 0)
echo "[✔] Enumeration complete. Found $TOTAL unique subdomains. Results saved to $OUT_FILE"
SUB_ENUM
    chmod +x "${LOCAL_BIN}/sub-enum"
    echo -e "  ${GREEN}[✔]${RESET} sub-enum — Subdomain Enumeration Wrapper"
    ((tools_installed++))

    # ========================================================
    # 8. js-recon — JavaScript Analysis Tool
    # ========================================================
    cat > "${LOCAL_BIN}/js-recon" << 'JS_RECON'
#!/usr/bin/env bash
set -euo pipefail
URL="${1:-}"
if [[ -z "$URL" ]]; then
    echo "Usage: js-recon <url> [output_dir]"
    exit 1
fi
OUT_DIR="${2:-js-recon-out}"
mkdir -p "$OUT_DIR"
echo "[*] Starting JavaScript analysis for $URL..."

if command -v subjs &>/dev/null; then
    echo "[*] Running subjs..."
    echo "$URL" | subjs > "$OUT_DIR/js_links.txt" || true
else
    echo "[*] Fetching URL and extracting JS links..."
    curl -s "$URL" | grep -oE 'src="[^"]+\.js"' | cut -d'"' -f2 > "$OUT_DIR/js_links.txt" || true
fi

if [[ -f "$OUT_DIR/js_links.txt" ]]; then
    echo "[*] Found $(wc -l < "$OUT_DIR/js_links.txt") JS links. Fetching and scanning for secrets..."
    while read -r link; do
        [[ "$link" != http* ]] && link="${URL%/}/${link#/}"
        echo "  [~] Checking: $link"
        curl -s "$link" | grep -E -o "([a-zA-Z0-9_-]{24,40})" >> "$OUT_DIR/potential_keys.txt" || true
    done < "$OUT_DIR/js_links.txt"
fi
echo "[✔] JS analysis complete. Results saved in $OUT_DIR/"
JS_RECON
    chmod +x "${LOCAL_BIN}/js-recon"
    echo -e "  ${GREEN}[✔]${RESET} js-recon — JavaScript Analysis Wrapper"
    ((tools_installed++))

    # ========================================================
    # 9. port-scan — Fast Port Scanner
    # ========================================================
    cat > "${LOCAL_BIN}/port-scan" << 'PORT_SCAN'
#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
    echo "Usage: port-scan <target> [output_file]"
    exit 1
fi
OUT_FILE="${2:-ports.txt}"

if command -v naabu &>/dev/null; then
    echo "[*] Running naabu scan on $TARGET..."
    naabu -host "$TARGET" -silent -top-ports 1000 -o "$OUT_FILE" || true
elif command -v nmap &>/dev/null; then
    echo "[*] Running nmap scan on $TARGET..."
    nmap -Pn -T4 --top-ports 1000 "$TARGET" -oG - | grep "Ports:" > "$OUT_FILE" || true
else
    echo "[✗] Neither naabu nor nmap is installed!"
    exit 1
fi
echo "[✔] Port scan complete. Results saved to $OUT_FILE"
PORT_SCAN
    chmod +x "${LOCAL_BIN}/port-scan"
    echo -e "  ${GREEN}[✔]${RESET} port-scan — Port Scanner Wrapper"
    ((tools_installed++))

    # ========================================================
    # 10. vuln-scan — Vulnerability Scanner Wrapper
    # ========================================================
    cat > "${LOCAL_BIN}/vuln-scan" << 'VULN_SCAN'
#!/usr/bin/env bash
set -euo pipefail
TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
    echo "Usage: vuln-scan <target> [output_file]"
    exit 1
fi
OUT_FILE="${2:-vulns.txt}"

if command -v nuclei &>/dev/null; then
    echo "[*] Running Nuclei scan on $TARGET..."
    nuclei -u "$TARGET" -severity low,medium,high,critical -silent -o "$OUT_FILE" || true
else
    echo "[✗] Nuclei is not installed!"
    exit 1
fi
echo "[✔] Vulnerability scan complete. Results saved to $OUT_FILE"
VULN_SCAN
    chmod +x "${LOCAL_BIN}/vuln-scan"
    echo -e "  ${GREEN}[✔]${RESET} vuln-scan — Vulnerability Scanner Wrapper"
    ((tools_installed++))

    # ========================================================
    # 11. dir-fuzz — Directory Fuzzing Wrapper
    # ========================================================
    cat > "${LOCAL_BIN}/dir-fuzz" << 'DIR_FUZZ'
#!/usr/bin/env bash
set -euo pipefail
URL="${1:-}"
if [[ -z "$URL" ]]; then
    echo "Usage: dir-fuzz <url> [wordlist]"
    exit 1
fi
WORDLIST="${2:-}"
if [[ -z "$WORDLIST" ]]; then
    WORDLIST="/usr/share/wordlists/dirb/common.txt"
    [[ ! -f "$WORDLIST" ]] && WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
fi

if [[ ! -f "$WORDLIST" ]]; then
    echo "[✗] Wordlist not found: $WORDLIST"
    exit 1
fi
OUT_FILE="fuzz_results.txt"
echo "[*] Starting directory fuzzing on $URL using $WORDLIST..."

if command -v ffuf &>/dev/null; then
    [[ "$URL" != *FUZZ* ]] && URL="${URL%/}/FUZZ"
    ffuf -u "$URL" -w "$WORDLIST" -mc 200,204,301,302,307,401,403 -ac -o "$OUT_FILE" -of md || true
elif command -v dirsearch &>/dev/null; then
    dirsearch -u "$URL" -w "$WORDLIST" -o "$OUT_FILE" || true
else
    echo "[✗] Neither ffuf nor dirsearch is installed!"
    exit 1
fi
echo "[✔] Fuzzing complete. Results saved to $OUT_FILE"
DIR_FUZZ
    chmod +x "${LOCAL_BIN}/dir-fuzz"
    echo -e "  ${GREEN}[✔]${RESET} dir-fuzz — Directory Fuzzer Wrapper"
    ((tools_installed++))

    # ========================================================
    # 12. report-gen — Workspace Report Generator
    # ========================================================
    cat > "${LOCAL_BIN}/report-gen" << 'REPORT_GEN'
#!/usr/bin/env bash
set -euo pipefail
DIR="${1:-.}"
if [[ ! -d "$DIR" ]]; then
    echo "Usage: report-gen <directory>"
    exit 1
fi
REPORT="$DIR/workspace_report.md"
echo "[*] Generating report for $DIR..."
cat > "$REPORT" << EOF
# Workspace Report
- Generated: \$(date)
- Target Directory: $DIR

## Workspace Contents
EOF

find "$DIR" -maxdepth 2 -not -path '*/.*' | sort | while read -r path; do
    if [[ -d "$path" ]]; then
        echo "### \$(basename "\$path")/" >> "\$REPORT"
    elif [[ -f "$path" ]]; then
        echo "- \$(basename "\$path") (\$(du -sh "\$path" | cut -f1))" >> "\$REPORT"
    fi
done
echo "[✔] Report generated: $REPORT"
REPORT_GEN
    chmod +x "${LOCAL_BIN}/report-gen"
    echo -e "  ${GREEN}[✔]${RESET} report-gen — Workspace Report Generator"
    ((tools_installed++))

    
    # ========================================================
    # 13. NEW: api-recon — API Reconnaissance
    # ========================================================
    cat > "${LOCAL_BIN}/api-recon" << 'API_RECON'
#!/usr/bin/env bash
# ============================================================
#  API-RECON — Professional API Reconnaissance Tool
#  Usage: api-recon <domain|url> [--deep|--quick]
# ============================================================

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

[[ -z "${1:-}" ]] && { echo "Usage: api-recon <domain|url> [--deep|--quick]"; exit 1; }

TARGET="$1"
MODE="${2:-standard}"
OUT_DIR="$HOME/api-recon/${TARGET//[:\/]/_}_$(date +%Y%m%d_%H%M)"
mkdir -p "$OUT_DIR"/{endpoints,params,auth,docs}

echo -e "${BOLD}${CYAN}[*]${RESET} Target: $TARGET"
echo -e "${BOLD}${CYAN}[*]${RESET} Output: $OUT_DIR"
echo ""

# Step 1: Find API endpoints
echo -e "${YELLOW}[1/5]${RESET} Discovering API endpoints..."
if command -v katana &>/dev/null; then
    katana -u "$TARGET" -silent -d 3 -jc | grep -iE "(api|v[0-9]|graphql)" | sort -u > "$OUT_DIR/endpoints/katana.txt"
fi

if command -v gau &>/dev/null; then
    echo "$TARGET" | gau | grep -iE "(api|v[0-9]|graphql)" | sort -u > "$OUT_DIR/endpoints/gau.txt"
fi

# Merge endpoints
cat "$OUT_DIR/endpoints/"*.txt 2>/dev/null | sort -u > "$OUT_DIR/endpoints/all.txt"
TOTAL=$(wc -l < "$OUT_DIR/endpoints/all.txt" 2>/dev/null || echo 0)
echo -e "${GREEN}[✔]${RESET} Found $TOTAL API endpoints"

# Step 2: Check for common API documentation
echo -e "${YELLOW}[2/5]${RESET} Checking for API documentation..."
for doc in swagger.json openapi.json api-docs graphql docs/api; do
    if curl -sf "$TARGET/$doc" > "$OUT_DIR/docs/$doc" 2>/dev/null; then
        echo -e "${GREEN}[✔]${RESET} Found: $doc"
    fi
done

# Step 3: Test authentication
echo -e "${YELLOW}[3/5]${RESET} Testing authentication..."
head -20 "$OUT_DIR/endpoints/all.txt" | while read -r endpoint; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)
    echo "$endpoint|$status" >> "$OUT_DIR/auth/responses.txt"
done

# Step 4: Parameter discovery
echo -e "${YELLOW}[4/5]${RESET} Discovering parameters..."
if command -v arjun &>/dev/null; then
    head -10 "$OUT_DIR/endpoints/all.txt" | while read -r endpoint; do
        arjun -u "$endpoint" -q 2>/dev/null >> "$OUT_DIR/params/arjun.txt"
    done
fi

# Step 5: Generate report
echo -e "${YELLOW}[5/5]${RESET} Generating report..."
cat > "$OUT_DIR/report.md" << EOF
# API Reconnaissance Report

## Target: $TARGET
## Date: $(date)

## Summary
- API Endpoints: $TOTAL
- Documentation: $(ls "$OUT_DIR/docs/" 2>/dev/null | wc -l) files

## Endpoints
\`\`\`
$(cat "$OUT_DIR/endpoints/all.txt" 2>/dev/null)
\`\`\`
EOF

echo ""
echo -e "${BOLD}${GREEN}[✔] API Recon Complete${RESET}"
echo -e "${BOLD}[✔]${RESET} Results: $OUT_DIR/"
API_RECON
    chmod +x "${LOCAL_BIN}/api-recon"
    echo -e "  ${GREEN}[✔]${RESET} api-recon — API Reconnaissance (NEW)"
    ((tools_installed++))
    
    # ========================================================
    # 14. NEW: cloud-recon — Cloud Enumeration
    # ========================================================
    cat > "${LOCAL_BIN}/cloud-recon" << 'CLOUD_RECON'
#!/usr/bin/env bash
# ============================================================
#  CLOUD-RECON — Cloud Infrastructure Enumeration
#  Usage: cloud-recon <target> [aws|azure|gcp|all]
# ============================================================

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

[[ -z "${1:-}" ]] && { echo "Usage: cloud-recon <target> [aws|azure|gcp|all]"; exit 1; }

TARGET="$1"
PROVIDER="${2:-all}"
OUT_DIR="$HOME/cloud-recon/${TARGET}_$(date +%Y%m%d_%H%M)"
mkdir -p "$OUT_DIR"/{aws,azure,gcp,buckets,results}

echo -e "${BOLD}${CYAN}[*]${RESET} Target: $TARGET"
echo -e "${BOLD}${CYAN}[*]${RESET} Provider: $PROVIDER"
echo -e "${BOLD}${CYAN}[*]${RESET} Output: $OUT_DIR"
echo ""

# AWS Enumeration
if [[ "$PROVIDER" == "aws" ]] || [[ "$PROVIDER" == "all" ]]; then
    echo -e "${YELLOW}[1/4]${RESET} AWS Enumeration..."
    
    # S3 bucket enumeration
    if command -v cloud_enum &>/dev/null; then
        cloud_enum -k "$TARGET" --disable-azure --disable-gcp -l "$OUT_DIR/aws/s3_buckets.txt" 2>/dev/null
    fi
    
    # Check if AWS CLI is configured
    if command -v aws &>/dev/null; then
        if aws sts get-caller-identity &>/dev/null; then
            echo -e "${GREEN}[✔]${RESET} AWS CLI configured"
            aws s3 ls > "$OUT_DIR/aws/s3_list.txt" 2>/dev/null
            aws iam list-users > "$OUT_DIR/aws/iam_users.json" 2>/dev/null
        fi
    fi
    
    # CloudFox
    if command -v cloudfox &>/dev/null; then
        cloudfox aws s3 -p default -o "$OUT_DIR/aws/cloudfox/" 2>/dev/null
    fi
fi

# Azure Enumeration
if [[ "$PROVIDER" == "azure" ]] || [[ "$PROVIDER" == "all" ]]; then
    echo -e "${YELLOW}[2/4]${RESET} Azure Enumeration..."
    
    if command -v cloud_enum &>/dev/null; then
        cloud_enum -k "$TARGET" --disable-aws --disable-gcp -l "$OUT_DIR/azure/blobs.txt" 2>/dev/null
    fi
    
    if command -v az &>/dev/null; then
        if az account show &>/dev/null; then
            echo -e "${GREEN}[✔]${RESET} Azure CLI configured"
            az storage account list > "$OUT_DIR/azure/storage_accounts.json" 2>/dev/null
        fi
    fi
fi

# GCP Enumeration
if [[ "$PROVIDER" == "gcp" ]] || [[ "$PROVIDER" == "all" ]]; then
    echo -e "${YELLOW}[3/4]${RESET} GCP Enumeration..."
    
    if command -v cloud_enum &>/dev/null; then
        cloud_enum -k "$TARGET" --disable-aws --disable-azure -l "$OUT_DIR/gcp/buckets.txt" 2>/dev/null
    fi
    
    if command -v gcloud &>/dev/null; then
        if gcloud auth list &>/dev/null; then
            echo -e "${GREEN}[✔]${RESET} GCloud CLI configured"
            gcloud storage buckets list > "$OUT_DIR/gcp/buckets_list.txt" 2>/dev/null
        fi
    fi
fi

# Generate report
echo -e "${YELLOW}[4/4]${RESET} Generating report..."
cat > "$OUT_DIR/report.md" << EOF
# Cloud Enumeration Report

## Target: $TARGET
## Provider: $PROVIDER
## Date: $(date)

## Findings
- AWS S3 Buckets: $(wc -l < "$OUT_DIR/aws/s3_buckets.txt" 2>/dev/null || echo 0)
- Azure Blobs: $(wc -l < "$OUT_DIR/azure/blobs.txt" 2>/dev/null || echo 0)
- GCP Buckets: $(wc -l < "$OUT_DIR/gcp/buckets.txt" 2>/dev/null || echo 0)
EOF

echo ""
echo -e "${BOLD}${GREEN}[✔] Cloud Recon Complete${RESET}"
echo -e "${BOLD}[✔]${RESET} Results: $OUT_DIR/"
CLOUD_RECON
    chmod +x "${LOCAL_BIN}/cloud-recon"
    echo -e "  ${GREEN}[✔]${RESET} cloud-recon — Cloud Enumeration (NEW)"
    ((tools_installed++))
    
    # ========================================================
    # 15. NEW: notify-recon — Notification System
    # ========================================================
    cat > "${LOCAL_BIN}/notify-recon" << 'NOTIFY_RECON'
#!/usr/bin/env bash
# ============================================================
#  NOTIFY-RECON — Send Notifications (Slack/Telegram/Discord)
#  Usage: notify-recon <title> <message> [slack|telegram|discord|all]
# ============================================================

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

[[ -z "${1:-}" ]] && { echo "Usage: notify-recon <title> <message> [slack|telegram|discord|all]"; exit 1; }

TITLE="$1"
MESSAGE="$2"
CHANNEL="${3:-all}"

# Load secrets
[[ -f "$HOME/.config/kali-master/secrets.env" ]] && source "$HOME/.config/kali-master/secrets.env"

echo -e "${BOLD}${CYAN}[*]${RESET} Sending notification..."
echo -e "  Title: $TITLE"
echo -e "  Message: $MESSAGE"
echo ""

# Slack
if [[ "$CHANNEL" == "slack" ]] || [[ "$CHANNEL" == "all" ]]; then
    if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"*$TITLE*\n$MESSAGE\"}" \
            "$SLACK_WEBHOOK_URL" >/dev/null 2>&1
        echo -e "${GREEN}[✔]${RESET} Slack notification sent"
    fi
fi

# Telegram
if [[ "$CHANNEL" == "telegram" ]] || [[ "$CHANNEL" == "all" ]]; then
    if [[ -n "${TELEGRAM_BOT_TOKEN:-}" ]] && [[ -n "${TELEGRAM_CHAT_ID:-}" ]]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            -d "text=*${TITLE}*%0A${MESSAGE}" \
            -d "parse_mode=Markdown" >/dev/null 2>&1
        echo -e "${GREEN}[✔]${RESET} Telegram notification sent"
    fi
fi

# Discord
if [[ "$CHANNEL" == "discord" ]] || [[ "$CHANNEL" == "all" ]]; then
    if [[ -n "${DISCORD_WEBHOOK_URL:-}" ]]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"content\":\"**${TITLE}**\n${MESSAGE}\"}" \
            "$DISCORD_WEBHOOK_URL" >/dev/null 2>&1
        echo -e "${GREEN}[✔]${RESET} Discord notification sent"
    fi
fi

echo ""
echo -e "${BOLD}${GREEN}[✔] Notifications sent${RESET}"
NOTIFY_RECON
    chmod +x "${LOCAL_BIN}/notify-recon"
    echo -e "  ${GREEN}[✔]${RESET} notify-recon — Notification System (NEW)"
    ((tools_installed++))
    
    # ========================================================
    # 16. NEW: merge-results — Merge Scan Results
    # ========================================================
    cat > "${LOCAL_BIN}/merge-results" << 'MERGE_RESULTS'
#!/usr/bin/env bash
# ============================================================
#  MERGE-RESULTS — Merge Results from Multiple Scans
#  Usage: merge-results <output_file> <input_files...>
# ============================================================

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

[[ $# -lt 2 ]] && { echo "Usage: merge-results <output_file> <input_files...>"; exit 1; }

OUTPUT="$1"
shift
INPUTS=("$@")

echo -e "${BOLD}${CYAN}[*]${RESET} Merging $((${#INPUTS[@]})) files..."
echo -e "  Output: $OUTPUT"
echo ""

# Create output directory
mkdir -p "$(dirname "$OUTPUT")"

# Merge files
total_lines=0
for input in "${INPUTS[@]}"; do
    if [[ -f "$input" ]]; then
        lines=$(wc -l < "$input")
        cat "$input" >> "$OUTPUT"
        echo -e "  ${GREEN}[+]${RESET} $input ($lines lines)"
        total_lines=$((total_lines + lines))
    else
        echo -e "  ${RED}[!]${RESET} $input (not found)"
    fi
done

# Remove duplicates
if [[ -f "$OUTPUT" ]]; then
    sort -u "$OUTPUT" -o "$OUTPUT"
    unique_lines=$(wc -l < "$OUTPUT")
    echo ""
    echo -e "${BOLD}${GREEN}[✔]${RESET} Merge complete"
    echo -e "  Total lines: $total_lines"
    echo -e "  Unique lines: $unique_lines"
    echo -e "  Duplicates removed: $((total_lines - unique_lines))"
fi
MERGE_RESULTS
    chmod +x "${LOCAL_BIN}/merge-results"
    echo -e "  ${GREEN}[✔]${RESET} merge-results — Merge Scan Results (NEW)"
    ((tools_installed++))
    
    # ========================================================
    # 17. NEW: helper-menu — Interactive Helper Menu
    # ========================================================
    cat > "${LOCAL_BIN}/helper-menu" << 'HELPER_MENU'
#!/usr/bin/env bash
# ============================================================
#  HELPER-MENU — Interactive Helper Scripts Menu
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'
DIM='\033[2m'; RESET='\033[0m'

clear
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${MAGENTA}       KALI MASTER — HELPER SCRIPTS MENU${RESET}"
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[WORKSPACE CREATORS]${RESET}"
echo -e "  ${GREEN}1)${RESET} newbb <domain>          ${DIM}→ Bug Bounty workspace${RESET}"
echo -e "  ${GREEN}2)${RESET} newctf <name>           ${DIM}→ CTF workspace${RESET}"
echo -e "  ${GREEN}3)${RESET} newad <domain>          ${DIM}→ Active Directory workspace${RESET}"
echo -e "  ${GREEN}4)${RESET} newpayload <name>       ${DIM}→ Payload development workspace${RESET}"
echo -e "  ${GREEN}5)${RESET} newredteam <name>       ${DIM}→ Red Team operation workspace${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[RECONNAISSANCE]${RESET}"
echo -e "  ${GREEN}6)${RESET} bb-recon <domain>       ${DIM}→ Bug Bounty recon (12 steps)${RESET}"
echo -e "  ${GREEN}7)${RESET} sub-enum <domain>       ${DIM}→ Subdomain enumeration${RESET}"
echo -e "  ${GREEN}8)${RESET} api-recon <url>         ${DIM}→ API reconnaissance${RESET}"
echo -e "  ${GREEN}9)${RESET} cloud-recon <target>    ${DIM}→ Cloud enumeration${RESET}"
echo -e "  ${GREEN}10)${RESET} js-recon <url>         ${DIM}→ JavaScript analysis${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[SCANNING]${RESET}"
echo -e "  ${GREEN}11)${RESET} port-scan <target>     ${DIM}→ Port scanning${RESET}"
echo -e "  ${GREEN}12)${RESET} dir-fuzz <url>         ${DIM}→ Directory fuzzing${RESET}"
echo -e "  ${GREEN}13)${RESET} vuln-scan <target>     ${DIM}→ Vulnerability scanning${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[UTILITIES]${RESET}"
echo -e "  ${GREEN}14)${RESET} merge-results          ${DIM}→ Merge scan results${RESET}"
echo -e "  ${GREEN}15)${RESET} report-gen <dir>       ${DIM}→ Generate report${RESET}"
echo -e "  ${GREEN}16)${RESET} notify-recon           ${DIM}→ Send notifications${RESET}"
echo ""
echo -e "  ${RED}0)${RESET} Exit"
echo ""
read -p "Select [0-16]: " choice

case $choice in
    1) read -p "Domain: " domain; newbb "$domain" ;;
    2) read -p "CTF Name: " name; newctf "$name" ;;
    3) read -p "Domain: " domain; newad "$domain" ;;
    4) read -p "Payload Name: " name; newpayload "$name" ;;
    5) read -p "Operation Name: " name; newredteam "$name" ;;
    6) read -p "Domain: " domain; bb-recon "$domain" ;;
    7) read -p "Domain: " domain; sub-enum "$domain" ;;
    8) read -p "URL: " url; api-recon "$url" ;;
    9) read -p "Target: " target; cloud-recon "$target" ;;
    10) read -p "URL: " url; js-recon "$url" ;;
    11) read -p "Target: " target; port-scan "$target" ;;
    12) read -p "URL: " url; dir-fuzz "$url" ;;
    13) read -p "Target: " target; vuln-scan "$target" ;;
    14) read -p "Output: " output; read -p "Inputs (space-separated): " inputs; merge-results "$output" $inputs ;;
    15) read -p "Project Dir: " dir; report-gen "$dir" ;;
    16) read -p "Title: " title; read -p "Message: " msg; notify-recon "$title" "$msg" ;;
    0) exit 0 ;;
    *) echo -e "${RED}[✗] Invalid choice${RESET}" ;;
esac
HELPER_MENU
    chmod +x "${LOCAL_BIN}/helper-menu"
    echo -e "  ${GREEN}[✔]${RESET} helper-menu — Interactive Helper Menu (NEW)"
    ((tools_installed++))
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  HELPER SCRIPTS SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}$((step_duration / 60))m $((step_duration % 60))s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${tools_installed} helper scripts"
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Workspace Creators: 5 tools (newbb, newctf, newad, newpayload, newredteam)"
    echo -e "    ${GREEN}●${RESET} Reconnaissance: 5 tools (bb-recon, sub-enum, api-recon, cloud-recon, js-recon)"
    echo -e "    ${GREEN}●${RESET} Scanning: 3 tools (port-scan, dir-fuzz, vuln-scan)"
    echo -e "    ${GREEN}●${RESET} Utilities: 4 tools (merge-results, report-gen, notify-recon, helper-menu)"
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}helper-menu${RESET}              ${DIM}→ Interactive menu${RESET}"
    echo -e "    ${CYAN}bb-recon example.com --deep${RESET} ${DIM}→ Full recon${RESET}"
    echo -e "    ${CYAN}api-recon https://api.example.com${RESET} ${DIM}→ API recon${RESET}"
    echo -e "    ${CYAN}cloud-recon example.com aws${RESET} ${DIM}→ AWS enumeration${RESET}"
    echo -e "    ${CYAN}notify-recon "Alert" "Message"${RESET} ${DIM}→ Send notification${RESET}"
    echo ""
    
    ok "Helper scripts ready"
    echo ""
}

# ============================================================
# STEP 17 — Red Team / C2 Frameworks (Professional Edition)
# ============================================================
