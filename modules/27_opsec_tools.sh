#!/usr/bin/env bash
# ============================================================
#  modules/27_opsec_tools.sh — Kali Master Framework v7.0.0
#  Operational Security: Anonymity, Traffic Routing, OPSEC
# ============================================================

do_opsec_tools() {
    clear
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 27/${STEP_TOTAL} — OPSEC & ANONYMITY TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo ""

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "OPSEC Tools — skipped in minimal mode"
        return 0
    fi

    local step_start_time; step_start_time=$(date +%s)
    local total_installed=0 total_failed=0 total_skipped=0

    mkdir -p "$OPSEC_DIR"

    # ══════════════════════════════════════════════════════════
    # Phase 1: Anonymous Routing (TOR + ProxyChains)
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 1/6] ANONYMOUS ROUTING${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local anon_pkgs=("tor" "torsocks" "proxychains4" "nyx")
    for pkg in "${anon_pkgs[@]}"; do
        if smart_find_tool "$pkg" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
            ((total_skipped++))
        else
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                dryrun "apt install $pkg"
            elif DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} $pkg ${DIM}[failed]${RESET}"
                ((total_failed++))
            fi
        fi
    done

    # Configure proxychains4
    local pchain_conf="/etc/proxychains4.conf"
    if [[ -f "$pchain_conf" ]] && ! grep -q "socks5.*127.0.0.1.*9050" "$pchain_conf" 2>/dev/null; then
        info "Configuring proxychains4 for TOR..."
        sed -i 's/^#\s*dynamic_chain/dynamic_chain/' "$pchain_conf" 2>/dev/null || true
        sed -i 's/^strict_chain/#strict_chain/' "$pchain_conf" 2>/dev/null || true
        echo "socks5 127.0.0.1 9050" >> "$pchain_conf"
        ok "proxychains4 configured for TOR (dynamic chain)"
    else
        ok "proxychains4 already configured"
    fi

    # TOR wrapper
    cat > "${LOCAL_BIN}/tor-start" << 'EOF'
#!/usr/bin/env bash
# Start TOR and verify connectivity
systemctl start tor 2>/dev/null || service tor start 2>/dev/null
sleep 3
if curl -sf --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip | grep -q '"IsTor":true'; then
    echo "[✔] TOR is active — IP routed through TOR network"
else
    echo "[!] TOR may not be routing correctly"
fi
EOF
    chmod +x "${LOCAL_BIN}/tor-start"
    ok "tor-start helper created"
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 2: VPN (OpenVPN + WireGuard)
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 2/6] VPN — OPENVPN & WIREGUARD${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local vpn_pkgs=("openvpn" "wireguard" "wireguard-tools")
    for pkg in "${vpn_pkgs[@]}"; do
        if smart_find_tool "${pkg//-tools/}" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
            ((total_skipped++))
        else
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                dryrun "apt install $pkg"
            elif DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${YELLOW}!${RESET} $pkg ${DIM}[failed — may need kernel module]${RESET}"
                ((total_failed++))
            fi
        fi
    done

    # WireGuard quick-connect template
    local wg_dir="${OPSEC_DIR}/wireguard-templates"
    mkdir -p "$wg_dir"
    if [[ ! -f "${wg_dir}/client.conf.template" ]]; then
        cat > "${wg_dir}/client.conf.template" << 'EOF'
# WireGuard Client Config — Kali Master Framework v7.0.0
# Fill in your server details and move to /etc/wireguard/wg0.conf

[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.8.0.2/24
DNS = 1.1.1.1, 8.8.8.8

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <SERVER_IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
        ok "WireGuard config template created: ${wg_dir}/client.conf.template"
    else
        ok "WireGuard template already exists"
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 3: Identity Rotation — MAC Spoofing
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 3/6] IDENTITY ROTATION — MAC SPOOFING${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    if smart_find_tool "macchanger" &>/dev/null || dpkg -l "macchanger" 2>/dev/null | grep -q "^ii"; then
        echo -e "    ${GREEN}✔${RESET} macchanger ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        if [[ "${DRY_RUN:-0}" != "1" ]] && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq macchanger >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} macchanger ${DIM}[installed]${RESET}"
            ((total_installed++))
        fi
    fi

    # MAC randomizer script
    cat > "${LOCAL_BIN}/mac-randomize" << 'SCRIPT'
#!/usr/bin/env bash
IFACE="${1:-$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5;exit}')}"
[[ -z "$IFACE" ]] && { echo "[✗] No interface detected"; exit 1; }
echo "[*] Randomizing MAC for: $IFACE (current: $(cat /sys/class/net/$IFACE/address))"
ip link set "$IFACE" down
macchanger -r "$IFACE"
ip link set "$IFACE" up
echo "[✔] New MAC: $(cat /sys/class/net/$IFACE/address)"
SCRIPT
    chmod +x "${LOCAL_BIN}/mac-randomize"
    ok "mac-randomize helper created"
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 4: Log Sanitization & Anti-Forensics
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 4/6] LOG SANITIZATION${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    # Secure log cleaner script
    cat > "${LOCAL_BIN}/opsec-clean" << 'SCRIPT'
#!/usr/bin/env bash
# OPSEC Log Cleaner — Kali Master Framework v7.0.0
# WARNING: Only use on systems you own/have permission to test

echo "[*] Sanitizing traces..."

# Clear bash history
history -c
> "$HOME/.bash_history"
> "$HOME/.zsh_history"
unset HISTFILE

# Clear shell rc timestamps
touch -t "$(date -d '1 year ago' '+%Y%m%d%H%M.%S')" \
    "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" 2>/dev/null || true

# Clear recent files
> "$HOME/.lesshst" 2>/dev/null || true
rm -f "$HOME/.viminfo" 2>/dev/null || true

# Clear temp files
find /tmp -maxdepth 1 -user "$(whoami)" -delete 2>/dev/null || true

# Truncate auth logs (requires root)
if [[ $EUID -eq 0 ]]; then
    > /var/log/auth.log 2>/dev/null || true
    > /var/log/syslog 2>/dev/null || true
    > /var/log/kern.log 2>/dev/null || true
    journalctl --rotate --vacuum-time=1s 2>/dev/null || true
fi

echo "[✔] Traces sanitized"
SCRIPT
    chmod +x "${LOCAL_BIN}/opsec-clean"
    ok "opsec-clean helper created"
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 5: Secure Communications Setup
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 5/6] SECURE TUNNEL TOOLS${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local tunnel_pkgs=("socat" "netcat-openbsd" "stunnel4")
    for pkg in "${tunnel_pkgs[@]}"; do
        if smart_find_tool "${pkg%4}" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
            ((total_skipped++))
        else
            if [[ "${DRY_RUN:-0}" != "1" ]] && \
               DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
                ((total_installed++))
            fi
        fi
    done

    # Ligolo-ng for advanced tunneling (from Go)
    if smart_find_tool "ligolo-ng" &>/dev/null || smart_find_tool "proxy" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ligolo-ng ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing ligolo-ng (advanced network tunneling)..."
        if install_github_release "ligolo-ng" \
            "https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest" \
            "linux_amd64" "proxy"; then
            echo -e "    ${GREEN}✔${RESET} ligolo-ng ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${YELLOW}!${RESET} ligolo-ng ${DIM}[install failed]${RESET}"
            ((total_failed++))
        fi
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 6: OPSEC Configuration Profile
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 6/6] OPSEC PROFILE & CHECKLIST${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local opsec_profile="${OPSEC_DIR}/opsec-profile.sh"
    if [[ ! -f "$opsec_profile" ]]; then
        cat > "$opsec_profile" << 'PROFILE'
#!/usr/bin/env bash
# OPSEC Pre-Engagement Checklist — Kali Master Framework v7.0.0
# Source this file before any engagement: source /opt/opsec/opsec-profile.sh

export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0

# Aliases for OPSEC-aware operations
alias curl='curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"'
alias wget='wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"'
alias nmap='nmap --randomize-hosts --spoof-mac random'

echo "[*] OPSEC profile loaded"
echo "[*] History: DISABLED | User-Agent: Browser spoofed"
echo "[*] Run 'tor-start' to route through TOR"
echo "[*] Run 'mac-randomize <iface>' to change MAC"
PROFILE
        chmod +x "$opsec_profile"
        ok "OPSEC profile created: $opsec_profile"
        ((total_installed++))
    else
        ok "OPSEC profile already exists"
        ((total_skipped++))
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Final Summary
    # ══════════════════════════════════════════════════════════
    local step_end_time; step_end_time=$(date +%s)
    local step_duration=$(( step_end_time - step_start_time ))
    local step_minutes=$(( step_duration / 60 ))
    local step_seconds=$(( step_duration % 60 ))

    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  OPSEC TOOLKIT SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}   ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}  ${total_installed} components"
    echo -e "  ${DIM}Skipped:${RESET}    ${total_skipped} (already configured)"
    [[ $total_failed -gt 0 ]] && echo -e "  ${YELLOW}Failed:${RESET}     ${total_failed} components"
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}source /opt/opsec/opsec-profile.sh${RESET}  ${DIM}→ Load OPSEC profile${RESET}"
    echo -e "    ${CYAN}tor-start${RESET}                           ${DIM}→ Route traffic via TOR${RESET}"
    echo -e "    ${CYAN}mac-randomize eth0${RESET}                  ${DIM}→ Change MAC address${RESET}"
    echo -e "    ${CYAN}opsec-clean${RESET}                         ${DIM}→ Sanitize logs & traces${RESET}"
    echo -e "    ${CYAN}proxychains4 nmap target${RESET}             ${DIM}→ Nmap via proxy chain${RESET}"
    echo -e "    ${CYAN}wg-quick up wg0${RESET}                     ${DIM}→ Start WireGuard VPN${RESET}"
    echo ""
    ok "OPSEC toolkit ready — stay stealthy"
}
