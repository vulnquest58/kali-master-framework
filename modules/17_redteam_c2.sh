#!/usr/bin/env bash
# modules/17_redteam_c2.sh

do_redteam_c2() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 17/${STEP_TOTAL} — RED TEAM C2 FRAMEWORKS${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Red Team C2 — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    mkdir -p "$C2_DIR"
    
    # ========================================================
    # Phase 1: Sliver C2 (Modern Multi-Protocol)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/8] SLIVER C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if smart_find_tool "sliver-server" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} Sliver ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Sliver C2..."
        if curl -fsSL https://sliver.sh/install | bash >> "$LOG_FILE" 2>&1; then
            if [[ -f /root/sliver-server ]]; then
                mv /root/sliver-server /usr/local/bin/
                chmod +x /usr/local/bin/sliver-server
            fi
            echo -e "    ${GREEN}✔${RESET} Sliver ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Sliver ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Havoc C2 (Modern UI)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/8] HAVOC C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/Havoc" ]]; then
        info "Cloning Havoc C2 with submodules..."
        if git clone --recurse-submodules \
            https://github.com/HavocFramework/Havoc.git /opt/Havoc \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Havoc cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Havoc clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Havoc ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/Havoc" ]]; then
        info "Building Havoc (smart build)..."
        cd /opt/Havoc || return 1
        
        # Install dependencies
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            build-essential cmake libssl-dev libboost-all-dev \
            qtbase5-dev qt5-qmake golang-go mingw-w64 nasm \
            >> "$LOG_FILE" 2>&1
        
        # Download MinGW compilers
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
        
        # Build teamserver
        cd /opt/Havoc/teamserver
        export GOPATH="$HOME/go"
        export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
        if GO111MODULE="on" go build -ldflags="-s -w" -o ../havoc main.go \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Teamserver built${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Teamserver build failed${RESET}"
        fi
        
        # Build client
        cd /opt/Havoc/client
        if make >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Client built${RESET}"
        else
            echo -e "    ${YELLOW}!${RESET} Client build had issues (non-critical)${RESET}"
        fi
        
        # Create wrapper
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
        
        if [[ -x "/opt/Havoc/havoc" ]]; then
            echo -e "    ${GREEN}✔${RESET} Havoc ${DIM}[built and ready]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Havoc ${DIM}[build incomplete]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Mythic C2 (Cross-Platform)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/8] MYTHIC C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/Mythic" ]]; then
        info "Cloning Mythic C2..."
        if git clone --depth=1 https://github.com/its-a-feature/Mythic.git /opt/Mythic \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Mythic cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Mythic clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Mythic ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/Mythic" ]]; then
        cd /opt/Mythic || return 1
        
        # Setup credentials
        if ! grep -q "MYTHIC_ADMIN_PASSWORD" .env 2>/dev/null; then
            echo 'MYTHIC_ADMIN_PASSWORD="Admin123!"' >> .env
            echo 'POSTGRES_PASSWORD="MythicPostgres123!"' >> .env
            echo 'RABBITMQ_PASSWORD="MythicRabbit123!"' >> .env
        fi
        
        # Safe database reset
        info "Resetting Mythic database (safe)..."
        echo -e "y\ny" | ./mythic-cli database reset \
            >> "$LOG_FILE" 2>&1 || true
        git checkout -- postgres-docker/ >> "$LOG_FILE" 2>&1 || true
        
        # Start Mythic
        info "Starting Mythic..."
        if ./mythic-cli start >> "$LOG_FILE" 2>&1; then
            ln -sf /opt/Mythic/mythic-cli /usr/local/bin/mythic-cli 2>/dev/null
            echo -e "    ${GREEN}✔${RESET} Mythic ${DIM}[running]${RESET}"
            ((total_installed++))
            info "Login: mythic_admin / Admin123!"
        else
            echo -e "    ${RED}✗${RESET} Mythic ${DIM}[start failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Covenant C2 (.NET-based)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/8] COVENANT C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/Covenant" ]]; then
        info "Cloning Covenant C2..."
        if git clone --recurse-submodules \
            https://github.com/cobbr/Covenant.git /opt/Covenant \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Covenant cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Covenant clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Covenant ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/Covenant/Covenant" ]]; then
        # Install libssl1.1
        info "Installing libssl1.1 for Covenant..."
        wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
            -O /tmp/libssl.deb
        dpkg -i /tmp/libssl.deb >> "$LOG_FILE" 2>&1 || true
        
        cd /opt/Covenant/Covenant
        
        if command -v dotnet &>/dev/null; then
            local dotnet_ver
            dotnet_ver=$(dotnet --version 2>/dev/null | cut -d. -f1)
            
            if [[ -n "$dotnet_ver" && "$dotnet_ver" =~ ^[0-9]+$ && "$dotnet_ver" -lt 5 ]]; then
                echo -e "    ${YELLOW}!${RESET} Covenant requires .NET 5+ (current: $dotnet_ver)${RESET}"
                ((total_failed++))
            else
                if [[ ! -f "bin/Debug/netcoreapp3.1/Covenant.dll" ]]; then
                    info "Building Covenant..."
                    if DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 dotnet build \
                        >> "$LOG_FILE" 2>&1; then
                        echo -e "    ${GREEN}✔${RESET} Covenant built${RESET}"
                    else
                        echo -e "    ${RED}✗${RESET} Covenant build failed${RESET}"
                    fi
                fi
                
                cat > /usr/local/bin/covenant << 'EOF'
#!/usr/bin/env bash
cd /opt/Covenant/Covenant
DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 dotnet run "$@"
EOF
                chmod +x /usr/local/bin/covenant
                
                if [[ -f "bin/Debug/netcoreapp3.1/Covenant.dll" ]]; then
                    echo -e "    ${GREEN}✔${RESET} Covenant ${DIM}[ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${RED}✗${RESET} Covenant ${DIM}[build incomplete]${RESET}"
                    ((total_failed++))
                fi
            fi
        else
            echo -e "    ${RED}✗${RESET} dotnet not found${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Empire C2 (Post-Exploitation)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/8] EMPIRE C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/Empire" ]]; then
        info "Cloning Empire..."
        if git clone --depth=1 https://github.com/BC-SECURITY/Empire.git /opt/Empire \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Empire cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Empire clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Empire ${DIM}[already cloned]${RESET}"
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
            echo -e "    ${GREEN}✔${RESET} Empire ${DIM}[ready]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Empire ${DIM}[ps-empire not found]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: Starkiller (Empire GUI)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/8] STARKILLER (EMPIRE GUI)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/Starkiller" ]]; then
        info "Cloning Starkiller..."
        if git clone --depth=1 https://github.com/BC-SECURITY/Starkiller.git /opt/Starkiller \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Starkiller cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Starkiller clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Starkiller ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/Starkiller" ]]; then
        cd /opt/Starkiller
        if [[ ! -d "node_modules" ]]; then
            info "Installing dependencies..."
            if npm install >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} Dependencies installed${RESET}"
            else
                echo -e "    ${YELLOW}!${RESET} npm install had issues${RESET}"
            fi
        fi
        
        cat > /usr/local/bin/starkiller << 'EOF'
#!/usr/bin/env bash
cd /opt/Starkiller
npm run serve
EOF
        chmod +x /usr/local/bin/starkiller
        echo -e "    ${GREEN}✔${RESET} Starkiller ${DIM}[ready]${RESET}"
        ((total_installed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Merlin C2 (HTTP/2)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/8] MERLIN C2${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/merlin" ]]; then
        info "Cloning Merlin C2..."
        if git clone --depth=1 https://github.com/Ne0nd0g/merlin.git /opt/merlin \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Merlin cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} Merlin clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Merlin ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/merlin" ]]; then
        cd /opt/merlin
        
        # Create symlinks
        if [[ -x "merlin-server" ]]; then
            ln -sf /opt/merlin/merlin-server /usr/local/bin/merlin-server 2>/dev/null || true
            ln -sf /opt/merlin/merlinCLI-Linux-x64 /usr/local/bin/merlin-cli 2>/dev/null || true
            
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
            echo -e "    ${GREEN}✔${RESET} Merlin ${DIM}[ready]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Merlin ${DIM}[binaries not found]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: NimPlant (Nim-based)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/8] NIMPLANT${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "/opt/NimPlant" ]]; then
        info "Cloning NimPlant..."
        if git clone --depth=1 https://github.com/chvancooten/NimPlant.git /opt/NimPlant \
            >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} NimPlant cloned${RESET}"
        else
            echo -e "    ${RED}✗${RESET} NimPlant clone failed${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} NimPlant ${DIM}[already cloned]${RESET}"
    fi
    
    if [[ -d "/opt/NimPlant" ]]; then
        # Install dependencies
        apt-get install -y -qq python3-dev libev-dev cython3 nim gcc \
            >> "$LOG_FILE" 2>&1
        
        # Install Python packages
        "${VENV_DIR}/bin/pip" install cryptography==43.0.0 flask_cors==4.0.1 Flask==3.0.3 \
            gevent PyCryptodome==3.20.0 pyyaml==6.0.1 requests==2.32.3 \
            toml==0.10.2 werkzeug==3.0.3 --quiet >> "$LOG_FILE" 2>&1 || true
        
        # Setup config
        [[ ! -f "/opt/NimPlant/config.toml" ]] && \
            cp /opt/NimPlant/config.toml.example /opt/NimPlant/config.toml
        
        # Create wrapper
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
        echo -e "    ${GREEN}✔${RESET} NimPlant ${DIM}[ready]${RESET}"
        ((total_installed++))
    fi
    
    echo ""
    
    # ========================================================
    # Verification
    # ========================================================
    echo -e "${BOLD}${CYAN}[VERIFICATION]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local c2_tools=("sliver-server" "havoc" "mythic-cli" "covenant" "empire" "starkiller" "merlin" "nimplant")
    local verified=0
    
    for tool in "${c2_tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            ((verified++))
        fi
    done
    
    ok "C2 tools verified: $verified/${#c2_tools[@]}"
    
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
    echo -e "${BOLD}${MAGENTA}  RED TEAM C2 FRAMEWORKS COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} frameworks"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} frameworks"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} frameworks"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 frameworks"
    fi
    
    echo ""
    echo -e "  ${BOLD}Installed C2 Frameworks:${RESET}"
    echo -e "    ${GREEN}●${RESET} Sliver — Modern multi-protocol C2"
    echo -e "    ${GREEN}●${RESET} Havoc — Modern C2 with great UI"
    echo -e "    ${GREEN}●${RESET} Mythic — Cross-platform C2 (Docker)"
    echo -e "    ${GREEN}●${RESET} Covenant — .NET-based C2"
    echo -e "    ${GREEN}●${RESET} Empire — Post-exploitation framework"
    echo -e "    ${GREEN}●${RESET} Starkiller — Empire GUI"
    echo -e "    ${GREEN}●${RESET} Merlin — HTTP/2 C2"
    echo -e "    ${GREEN}●${RESET} NimPlant — Nim-based beacon"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some frameworks failed to install"
        info "Check log: ${LOG_FILE}"
    else
        ok "All C2 frameworks installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}c2-menu${RESET}              ${DIM}→ Interactive C2 launcher${RESET}"
    echo -e "    ${CYAN}sliver-server${RESET}        ${DIM}→ Start Sliver${RESET}"
    echo -e "    ${CYAN}havoc server${RESET}         ${DIM}→ Start Havoc${RESET}"
    echo -e "    ${CYAN}mythic-cli start${RESET}     ${DIM}→ Start Mythic${RESET}"
    echo -e "    ${CYAN}covenant${RESET}             ${DIM}→ Start Covenant${RESET}"
    echo -e "    ${CYAN}empire server${RESET}        ${DIM}→ Start Empire${RESET}"
    echo -e "    ${CYAN}merlin server${RESET}        ${DIM}→ Start Merlin${RESET}"
    echo -e "    ${CYAN}nimplant server${RESET}      ${DIM}→ Start NimPlant${RESET}"
    echo ""
}

# ============================================================
# STEP 18 — C2 Redirectors + SSL Automation (OPSEC)
# ============================================================
