#!/usr/bin/env bash
# ============================================================
#  core/network.sh — Kali Master Framework v7.0.0
#  Network hardening, DNS, connectivity checks, git clone helpers
# ============================================================

# ============================================================
# Test connectivity to key endpoints
# ============================================================
test_connectivity() {
    local endpoints=(
        "https://1.1.1.1|Cloudflare DNS"
        "https://api.github.com|GitHub API"
        "https://proxy.golang.org|Go Proxy"
        "https://pypi.org|PyPI"
        "https://registry.npmjs.org|NPM Registry"
    )

    local passed=0 failed=0
    echo ""
    echo -e "  ${BOLD}${CYAN}Network Connectivity Check${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    for endpoint_info in "${endpoints[@]}"; do
        IFS='|' read -r url label <<< "$endpoint_info"
        if curl -sf --max-time 5 "$url" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $label ${DIM}($url)${RESET}"
            ((passed++))
        else
            echo -e "    ${YELLOW}✗${RESET} $label ${DIM}($url)${RESET} — unreachable"
            ((failed++))
        fi
    done

    echo ""
    if [[ $failed -eq 0 ]]; then
        ok "All connectivity checks passed ($passed/$((passed+failed)))"
    else
        warn "Connectivity: $passed passed, $failed unreachable"
    fi
    return "$failed"
}

# ============================================================
# Network & DNS Hardening (Pre-Flight)
# ============================================================
do_network_fix() {
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  NETWORK & DNS HARDENING                              ${RESET}"
    echo -e "${BOLD}${MAGENTA}  Optimizing connectivity for reliable downloads       ${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""

    local changes_made=0

    # ─────────────────────────────────────────────────────────
    # 1. IPv6 Connectivity Check & Disable (if unreachable)
    # ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}[1/5] IPv6 CONNECTIVITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    if curl -6 -sf --max-time 4 https://ipv6.google.com &>/dev/null; then
        ok "IPv6 is reachable — keeping enabled"
    else
        warn "IPv6 is unreachable — disabling to prevent download hangs"
        sysctl -w net.ipv6.conf.all.disable_ipv6=1 >> "$LOG_FILE" 2>&1 || true
        sysctl -w net.ipv6.conf.default.disable_ipv6=1 >> "$LOG_FILE" 2>&1 || true

        if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.d/99-kali-master.conf 2>/dev/null; then
            cat >> /etc/sysctl.d/99-kali-master.conf << 'EOF' 2>/dev/null || true
# Added by Kali Master Framework v7.0.0
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
            sysctl -p /etc/sysctl.d/99-kali-master.conf >> "$LOG_FILE" 2>&1 || true
        fi
        ok "IPv6 disabled successfully"
        ((changes_made++))
    fi
    echo ""

    # ─────────────────────────────────────────────────────────
    # 2. DNS Health Check & Fallback Configuration
    # ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}[2/5] DNS RESOLUTION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    local current_ns
    current_ns=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    current_ns="${current_ns:-8.8.8.8}"

    info "Testing current DNS resolver: ${current_ns}"

    if host -W 3 google.com "${current_ns}" &>/dev/null 2>&1; then
        ok "Current DNS (${current_ns}) is working properly"
    else
        warn "Current DNS (${current_ns}) is misbehaving — adding fallback resolvers"
        cp /etc/resolv.conf /etc/resolv.conf.backup."$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true

        local tmp_resolv
        tmp_resolv=$(mktemp)
        {
            echo "# Added by Kali Master Framework v7.0.0 — Reliable DNS Fallbacks"
            echo "nameserver 1.1.1.1"
            echo "nameserver 8.8.8.8"
            echo "nameserver 9.9.9.9"
            grep '^nameserver' /etc/resolv.conf 2>/dev/null || true
        } > "$tmp_resolv"
        awk '!seen[$0]++' "$tmp_resolv" > /etc/resolv.conf
        rm -f "$tmp_resolv"

        ok "DNS fallbacks configured (1.1.1.1, 8.8.8.8, 9.9.9.9)"
        ((changes_made++))
    fi
    echo ""

    # ─────────────────────────────────────────────────────────
    # 3. Force APT to use IPv4
    # ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}[3/5] APT CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    local apt_conf="/etc/apt/apt.conf.d/99-force-ipv4"
    if [[ ! -f "$apt_conf" ]] || ! grep -q 'Acquire::ForceIPv4 "true"' "$apt_conf" 2>/dev/null; then
        info "Forcing APT to use IPv4..."
        cat > "$apt_conf" << 'EOF'
# Added by Kali Master Framework v7.0.0
Acquire::ForceIPv4 "true";
Acquire::http::Timeout "120";
Acquire::https::Timeout "120";
Acquire::Retries "3";
EOF
        ok "APT configured: IPv4 forced + timeouts set"
        ((changes_made++))
    else
        ok "APT IPv4 configuration already in place"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────
    # 4. Go Proxy Configuration
    # ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}[4/5] GO PROXY CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    local go_conf="/etc/profile.d/goproxy.sh"
    if [[ ! -f "$go_conf" ]] || ! grep -q "proxy.golang.org" "$go_conf" 2>/dev/null; then
        cat > "$go_conf" << 'EOF'
# Added by Kali Master Framework v7.0.0
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
export GOPRIVATE=""
export GO111MODULE="on"
EOF
        chmod +x "$go_conf"
        export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
        export GONOSUMDB="*"
        ok "Go proxy chain configured"
        ((changes_made++))
    else
        ok "Go proxy already configured"
    fi
    echo ""

    # ─────────────────────────────────────────────────────────
    # 5. Git Global Configuration (Performance & Security)
    # ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}[5/5] GIT CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    # Faster clones
    git config --global http.lowSpeedLimit 1024 2>/dev/null || true
    git config --global http.lowSpeedTime 60 2>/dev/null || true
    git config --global core.compression 6 2>/dev/null || true

    # Token auth for GitHub if configured
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" 2>/dev/null || true
        ok "Git: GITHUB_TOKEN configured for authentication"
        ((changes_made++))
    else
        info "Git: No GITHUB_TOKEN set (rate limited to 60 req/h)"
    fi

    ok "Git performance settings applied"
    echo ""

    # ─── Final Summary ────────────────────────────────────────
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    if [[ $changes_made -gt 0 ]]; then
        ok "Network hardening complete (${changes_made} changes applied)"
    else
        ok "Network already optimally configured — no changes needed"
    fi
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ============================================================
# Git clone helper with auth, retries, depth control
# ============================================================
git_clone() {
    local url="$1"
    local dest="$2"
    local depth="${3:-1}"
    local recurse="${4:-0}"

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "git clone $url -> $dest"; return 0; }

    if [[ -d "$dest" ]]; then
        info "$(basename "$dest"): already cloned — pulling latest"
        ( cd "$dest" && git pull -q --ff-only >> "$LOG_FILE" 2>&1 ) || \
            warn "git pull failed for $dest (may be a detached HEAD or modified)"
        return 0
    fi

    mkdir -p "$(dirname "$dest")"

    local auth_url="$url"
    if [[ -n "${GITHUB_TOKEN:-}" && "$url" == "https://github.com/"* ]]; then
        auth_url="${url/https:\/\/github.com\//https:\/\/${GITHUB_TOKEN}@github.com\/}"
    fi

    local clone_args=(-q --depth "$depth")
    [[ "$recurse" == "1" ]] && clone_args+=(--recurse-submodules)

    local attempts="${MAX_RETRIES:-3}"
    for i in $(seq 1 "$attempts"); do
        if git clone "${clone_args[@]}" "$auth_url" "$dest" >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        warn "git clone attempt $i/$attempts failed for $url — retrying..."
        sleep "${RETRY_DELAY:-5}"
        rm -rf "$dest"
    done

    fail "git clone failed after $attempts attempts: $url"
    return 1
}
