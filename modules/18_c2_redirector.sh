#!/usr/bin/env bash
# modules/18_c2_redirector.sh

do_c2_redirector() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 18/${STEP_TOTAL} — C2 REDIRECTORS & SSL AUTOMATION${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "C2 Redirectors — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    
    # ========================================================
    # Phase 1: Install nginx + certbot
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/5] INSTALLING NGINX + CERTBOT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if command -v nginx &>/dev/null && command -v certbot &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} nginx + certbot ${DIM}[already installed]${RESET}"
    else
        info "Installing nginx and certbot..."
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            nginx certbot python3-certbot-nginx >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} nginx + certbot ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} nginx/certbot ${DIM}[installation failed]${RESET}"
            ((total_failed++))
            return 1
        fi
    fi
    
    # Ensure certbot symlink
    if ! command -v certbot &>/dev/null && [[ -x /usr/bin/certbot ]]; then
        ln -sf /usr/bin/certbot /usr/local/bin/certbot 2>/dev/null || true
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Setup Directory Structure
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/5] SETTING UP DIRECTORY STRUCTURE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    mkdir -p "$REDIRECTOR_DIR"/{sites-available,sites-enabled,templates,logs}
    echo -e "    ${GREEN}✔${RESET} Directory structure created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 3: Create Redirector Template
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/5] CREATING REDIRECTOR TEMPLATE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    cat > "${REDIRECTOR_DIR}/templates/redirector.conf.template" << 'TPL'
# Kali Master v6.7.0 — C2 Redirector
# Domain: __DOMAIN__
# Backend: __BACKEND_PROTO__://__BACKEND_HOST__:__BACKEND_PORT__
# Generated: __DATE__

server {
    listen 80;
    server_name __DOMAIN__;
    return 301 https://$host$request_uri;
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
        try_files $uri $uri/ =404;
    }

    # C2 profile URI — forward to teamserver
    location ~* ^(__C2_URIS__)$ {
        proxy_pass         __BACKEND_PROTO__://__BACKEND_HOST__:__BACKEND_PORT__;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto https;
        proxy_ssl_server_name on;
        proxy_read_timeout 90s;
        proxy_buffering    off;
    }
}
TPL
    
    echo -e "    ${GREEN}✔${RESET} Redirector template created${RESET}"
    ((total_installed++))
    
    # Create fake WordPress index
    mkdir -p /var/www/html
    cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html><html><head><title>Welcome</title></head>
<body><h1>It works!</h1></body></html>
HTML
    
    echo -e "    ${GREEN}✔${RESET} Fake WordPress front created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 4: Create Management Scripts
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/5] CREATING MANAGEMENT SCRIPTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # setup-redirector
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
    echo -e "    ${GREEN}✔${RESET} setup-redirector created${RESET}"
    ((total_installed++))
    
    # list-redirectors
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
    echo -e "    ${GREEN}✔${RESET} list-redirectors created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 5: Auto-renewal & Service Setup
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/5] AUTO-RENEWAL & SERVICE SETUP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Auto-renewal cron
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; \
         echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'") \
            | crontab - 2>/dev/null || true
        echo -e "    ${GREEN}✔${RESET} Certbot auto-renewal cron added${RESET}"
        ((total_installed++))
    else
        echo -e "    ${GREEN}✔${RESET} Certbot cron already exists${RESET}"
    fi
    
    # Enable and start nginx
    systemctl enable nginx --quiet >> "$LOG_FILE" 2>&1
    systemctl start  nginx          >> "$LOG_FILE" 2>&1
    echo -e "    ${GREEN}✔${RESET} nginx service enabled and started${RESET}"
    ((total_installed++))
    
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
    echo -e "${BOLD}${MAGENTA}  C2 REDIRECTORS SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} components"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} components"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 components"
    fi
    
    echo ""
    echo -e "  ${BOLD}Components:${RESET}"
    echo -e "    ${GREEN}●${RESET} nginx + certbot"
    echo -e "    ${GREEN}●${RESET} Redirector template"
    echo -e "    ${GREEN}●${RESET} setup-redirector script"
    echo -e "    ${GREEN}●${RESET} list-redirectors script"
    echo -e "    ${GREEN}●${RESET} Auto-renewal cron"
    echo -e "    ${GREEN}●${RESET} Fake WordPress front"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed"
        info "Check log: ${LOG_FILE}"
    else
        ok "C2 redirector automation ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}setup-redirector${RESET}     ${DIM}→ Setup new redirector${RESET}"
    echo -e "    ${CYAN}list-redirectors${RESET}     ${DIM}→ List active redirectors${RESET}"
    echo ""
    echo -e "  ${BOLD}OPSEC Features:${RESET}"
    echo -e "    ${DIM}• Let's Encrypt SSL certificates${RESET}"
    echo -e "    ${DIM}• Hide nginx version${RESET}"
    echo -e "    ${DIM}• Fake WordPress front${RESET}"
    echo -e "    ${DIM}• Auto-renewal (daily at 3 AM)${RESET}"
    echo -e "    ${DIM}• HTTP → HTTPS redirect${RESET}"
    echo ""
}

# ============================================================
# STEP 19 — EDR/AV Evasion Tools (Professional Edition)
# ============================================================
