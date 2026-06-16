#!/usr/bin/env bash
# modules/19_evasion_tools.sh

do_evasion_tools() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 19/${STEP_TOTAL} — EDR/AV EVASION TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Evasion tools — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    info "Installing EDR/AV Evasion toolkit into ${EVASION_DIR}..."
    mkdir -p "$EVASION_DIR"
    echo ""
    
    # ========================================================
    # Phase 1: Shellcode Generators
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/6] SHELLCODE GENERATORS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Donut — .NET/PE/VBS -> PIC shellcode
    if [[ -x "${LOCAL_BIN}/donut" ]] || [[ -x "${EVASION_DIR}/donut/donut" ]]; then
        echo -e "    ${GREEN}✔${RESET} Donut ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Building Donut..."
        if git clone --depth=1 https://github.com/TheWover/donut.git \
            "${EVASION_DIR}/donut" >> "$LOG_FILE" 2>&1; then
            if (cd "${EVASION_DIR}/donut" && make -j"$(nproc)" >> "$LOG_FILE" 2>&1); then
                if [[ -x "${EVASION_DIR}/donut/donut" ]]; then
                    ln -sf "${EVASION_DIR}/donut/donut" "${LOCAL_BIN}/donut" 2>/dev/null || true
                    echo -e "    ${GREEN}✔${RESET} Donut ${DIM}[built and ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${RED}✗${RESET} Donut ${DIM}[build incomplete]${RESET}"
                    ((total_failed++))
                fi
            else
                echo -e "    ${RED}✗${RESET} Donut ${DIM}[build failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} Donut ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # SGN — Shikata Ga Nai encoder
    if smart_find_tool "sgn" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} SGN ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing SGN (shikata-ga-nai)..."
        
        # Setup keystone library
        local keystone_lib
        keystone_lib=$(find "${VENV_DIR}/lib" -name "libkeystone.so" 2>/dev/null | head -1)
        if [[ -n "$keystone_lib" ]]; then
            cp "$keystone_lib" /usr/local/lib/libkeystone.so 2>/dev/null || true
            ln -sf /usr/local/lib/libkeystone.so /usr/local/lib/libkeystone.so.0 2>/dev/null || true
            ldconfig 2>/dev/null || true
        fi
        
        if [[ ! -d "${EVASION_DIR}/sgn" ]]; then
            if git clone --depth=1 https://github.com/EgeBalci/sgn.git \
                "${EVASION_DIR}/sgn" >> "$LOG_FILE" 2>&1; then
                cd "${EVASION_DIR}/sgn"
                export GOPATH="$HOME/go"
                export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
                
                if go build . >> "$LOG_FILE" 2>&1; then
                    if [[ -x "${EVASION_DIR}/sgn/sgn" ]]; then
                        cp "${EVASION_DIR}/sgn/sgn" /usr/local/bin/sgn 2>/dev/null || true
                        echo -e "    ${GREEN}✔${RESET} SGN ${DIM}[built and ready]${RESET}"
                        ((total_installed++))
                    else
                        echo -e "    ${RED}✗${RESET} SGN ${DIM}[build incomplete]${RESET}"
                        ((total_failed++))
                    fi
                else
                    echo -e "    ${RED}✗${RESET} SGN ${DIM}[build failed]${RESET}"
                    ((total_failed++))
                fi
            else
                echo -e "    ${RED}✗${RESET} SGN ${DIM}[clone failed]${RESET}"
                ((total_failed++))
            fi
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: EDR Bypass Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/6] EDR BYPASS TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # ScareCrow — EDR bypass
    if [[ -x "${LOCAL_BIN}/scarecrow" ]] || [[ -x "${LOCAL_BIN}/ScareCrow" ]]; then
        echo -e "    ${GREEN}✔${RESET} ScareCrow ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Building ScareCrow..."
        if git clone --depth=1 https://github.com/optiv/ScareCrow.git \
            "${EVASION_DIR}/ScareCrow" >> "$LOG_FILE" 2>&1; then
            
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
                openssl libssl-dev gcc-mingw-w64 x86_64-w64-mingw32-gcc \
                >> "$LOG_FILE" 2>&1 || true
            
            # Install Garble for obfuscation
            info "Installing Garble..."
            export GOPATH="$HOME/go"
            export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
            go install mvdan.cc/garble@latest >> "$LOG_FILE" 2>&1 || true
            
            cd "${EVASION_DIR}/ScareCrow"
            if go build ScareCrow.go >> "$LOG_FILE" 2>&1; then
                if [[ -x "${EVASION_DIR}/ScareCrow/ScareCrow" ]]; then
                    cp "${EVASION_DIR}/ScareCrow/ScareCrow" /usr/local/bin/ScareCrow 2>/dev/null || true
                    ln -sf /usr/local/bin/ScareCrow /usr/local/bin/scarecrow 2>/dev/null || true
                    echo -e "    ${GREEN}✔${RESET} ScareCrow ${DIM}[built and ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${RED}✗${RESET} ScareCrow ${DIM}[build incomplete]${RESET}"
                    ((total_failed++))
                fi
            else
                echo -e "    ${RED}✗${RESET} ScareCrow ${DIM}[build failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} ScareCrow ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Freeze — payload obfuscation
    if smart_find_tool "freeze" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} Freeze ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Freeze..."
        if install_go_tool "freeze" "github.com/optiv/Freeze" "freeze" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} Freeze ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Freeze ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Inceptor — AV/EDR bypass
    if smart_find_tool "inceptor" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} Inceptor ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Inceptor..."
        if install_py_github_tool "inceptor" "" "https://github.com/klezVirus/inceptor.git" "inceptor.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} Inceptor ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Inceptor ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: PE Packers & Crypters
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/6] PE PACKERS & CRYPTERS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Pezor — PE packer
    if smart_find_tool "pezor" &>/dev/null || smart_find_tool "PEzor.sh" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} Pezor ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Pezor..."
        if install_py_github_tool "pezor" "" "https://github.com/phra/PEzor.git" "PEzor.sh" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} Pezor ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Pezor ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Nimcrypt2 — Nim-based PE crypter
    if [[ -x "${LOCAL_BIN}/nimcrypt2" ]] || [[ -x "${EVASION_DIR}/nimcrypt2/nimcrypt2" ]]; then
        echo -e "    ${GREEN}✔${RESET} Nimcrypt2 ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Building Nimcrypt2..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
            nim gcc-mingw-w64-x86-64-win32 \
            >> "$LOG_FILE" 2>&1 || true
        
        if git clone --depth=1 https://github.com/icyguider/Nimcrypt2.git \
            "${EVASION_DIR}/nimcrypt2" >> "$LOG_FILE" 2>&1; then
            if (cd "${EVASION_DIR}/nimcrypt2" && nim c nimcrypt2.nim >> "$LOG_FILE" 2>&1); then
                if [[ -x "${EVASION_DIR}/nimcrypt2/nimcrypt2" ]]; then
                    ln -sf "${EVASION_DIR}/nimcrypt2/nimcrypt2" "${LOCAL_BIN}/nimcrypt2" 2>/dev/null || true
                    echo -e "    ${GREEN}✔${RESET} Nimcrypt2 ${DIM}[built and ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${RED}✗${RESET} Nimcrypt2 ${DIM}[build incomplete]${RESET}"
                    ((total_failed++))
                fi
            else
                echo -e "    ${RED}✗${RESET} Nimcrypt2 ${DIM}[build failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} Nimcrypt2 ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Detection & Analysis Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/6] DETECTION & ANALYSIS TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # PE-Sieve — detect in-memory patches/hooks
    if [[ -x "${LOCAL_BIN}/pe-sieve" ]]; then
        echo -e "    ${GREEN}✔${RESET} PE-Sieve ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Building PE-Sieve..."
        if git clone --depth=1 https://github.com/hasherezade/pe-sieve.git \
            "${EVASION_DIR}/pe-sieve" >> "$LOG_FILE" 2>&1; then
            if (cd "${EVASION_DIR}/pe-sieve" && \
                cmake -B build -DCMAKE_BUILD_TYPE=Release >> "$LOG_FILE" 2>&1 && \
                cmake --build build -j"$(nproc)" >> "$LOG_FILE" 2>&1); then
                
                local pesieve_bin
                pesieve_bin=$(find "${EVASION_DIR}/pe-sieve/build" -name "pe-sieve*" \
                    -type f -executable 2>/dev/null | head -1)
                
                if [[ -n "$pesieve_bin" ]]; then
                    ln -sf "$pesieve_bin" "${LOCAL_BIN}/pe-sieve" 2>/dev/null || true
                    echo -e "    ${GREEN}✔${RESET} PE-Sieve ${DIM}[built and ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${YELLOW}!${RESET} PE-Sieve ${DIM}[Windows binary — expected on Linux]${RESET}"
                    ((total_skipped++))
                fi
            else
                echo -e "    ${YELLOW}!${RESET} PE-Sieve ${DIM}[build failed — Windows target]${RESET}"
                ((total_skipped++))
            fi
        else
            echo -e "    ${RED}✗${RESET} PE-Sieve ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Hollows_Hunter — find hooked processes
    if [[ -x "${LOCAL_BIN}/hollows-hunter" ]]; then
        echo -e "    ${GREEN}✔${RESET} Hollows_Hunter ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Building Hollows_Hunter..."
        if git clone --depth=1 https://github.com/hasherezade/hollows_hunter.git \
            "${EVASION_DIR}/hollows_hunter" >> "$LOG_FILE" 2>&1; then
            if (cd "${EVASION_DIR}/hollows_hunter" && \
                cmake -B build -DCMAKE_BUILD_TYPE=Release >> "$LOG_FILE" 2>&1 && \
                cmake --build build -j"$(nproc)" >> "$LOG_FILE" 2>&1); then
                
                local hh_bin
                hh_bin=$(find "${EVASION_DIR}/hollows_hunter/build" -name "hollows_hunter*" \
                    -type f -executable 2>/dev/null | head -1)
                
                if [[ -n "$hh_bin" ]]; then
                    ln -sf "$hh_bin" "${LOCAL_BIN}/hollows-hunter" 2>/dev/null || true
                    echo -e "    ${GREEN}✔${RESET} Hollows_Hunter ${DIM}[built and ready]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${YELLOW}!${RESET} Hollows_Hunter ${DIM}[Windows binary — expected on Linux]${RESET}"
                    ((total_skipped++))
                fi
            else
                echo -e "    ${YELLOW}!${RESET} Hollows_Hunter ${DIM}[build failed — Windows target]${RESET}"
                ((total_skipped++))
            fi
        else
            echo -e "    ${RED}✗${RESET} Hollows_Hunter ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Evasion Menu Setup
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/6] EVASION MENU SETUP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    cat > "${LOCAL_BIN}/evasion-menu" << 'EVMENU'
#!/usr/bin/env bash
# ============================================================
# EVASION-MENU — EDR/AV Evasion Toolkit Menu
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'
DIM='\033[2m'; RESET='\033[0m'

clear
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${MAGENTA}       EDR/AV EVASION TOOLKIT${RESET}"
echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[SHELLCODE GENERATORS]${RESET}"
echo -e "  ${GREEN}1)${RESET} donut          ${DIM}— .NET/PE/VBS → PIC shellcode${RESET}"
echo -e "  ${GREEN}2)${RESET} sgn             ${DIM}— Shikata Ga Nai encoder${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[EDR BYPASS]${RESET}"
echo -e "  ${GREEN}3)${RESET} scarecrow       ${DIM}— EDR bypass (DLL side-load)${RESET}"
echo -e "  ${GREEN}4)${RESET} freeze          ${DIM}— Payload obfuscation${RESET}"
echo -e "  ${GREEN}5)${RESET} inceptor        ${DIM}— AV/EDR bypass${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[PE PACKERS & CRYPTERS]${RESET}"
echo -e "  ${GREEN}6)${RESET} pezor           ${DIM}— PE packer${RESET}"
echo -e "  ${GREEN}7)${RESET} nimcrypt2       ${DIM}— Nim-based PE crypter${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[DETECTION TOOLS]${RESET}"
echo -e "  ${GREEN}8)${RESET} pe-sieve        ${DIM}— detect in-memory hooks${RESET}"
echo -e "  ${GREEN}9)${RESET} hollows-hunter  ${DIM}— find hollowed processes${RESET}"
echo ""
echo -e "${BOLD}${CYAN}[STATUS]${RESET}"
echo -e "  ${YELLOW}10)${RESET} Check installed tools"
echo ""
echo -e "  ${RED}0)${RESET} Exit"
echo ""
read -p "Select [0-10]: " choice

case $choice in
    1) read -p "Input file: " input; donut -f "$input" ;;
    2) read -p "Input file: " input; sgn "$input" ;;
    3) read -p "Input DLL: " dll; read -p "Loader type [dll/sct]: " loader; scarecrow -loader="$loader" -in="$dll" ;;
    4) read -p "Input file: " input; freeze -loader=windows -console -o output.bin "$input" ;;
    5) inceptor ;;
    6) read -p "Input PE: " pe; pezor "$pe" ;;
    7) read -p "Input PE: " pe; nimcrypt2 -f "$pe" -o output.exe ;;
    8) read -p "PID to scan: " pid; pe-sieve -p "$pid" ;;
    9) hollows-hunter ;;
    10)
        echo ""
        echo -e "${BOLD}Installed Evasion Tools:${RESET}"
        for tool in donut sgn scarecrow freeze inceptor pezor nimcrypt2 pe-sieve hollows-hunter; do
            if command -v "$tool" &>/dev/null; then
                echo -e "  ${GREEN}[✔]${RESET} $tool"
            else
                echo -e "  ${RED}[✗]${RESET} $tool"
            fi
        done
        echo ""
        read -p "Press Enter to continue..."
        exec evasion-menu
        ;;
    0) exit 0 ;;
    *) echo -e "${RED}[✗] Invalid choice${RESET}"; sleep 1; exec evasion-menu ;;
esac
EVMENU
    chmod +x "${LOCAL_BIN}/evasion-menu"
    
    echo -e "    ${GREEN}✔${RESET} evasion-menu created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 6: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/6] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local evasion_tools=("donut" "sgn" "scarecrow" "freeze" "inceptor" "pezor" "nimcrypt2")
    local verified=0
    
    for tool in "${evasion_tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            ((verified++))
        fi
    done
    
    ok "Evasion tools verified: $verified/${#evasion_tools[@]}"
    
    # Note about Windows-targeted tools
    info "Note: PE-Sieve and Hollows_Hunter are Windows-targeted binaries"
    info "      They may not run on Linux but are available for cross-compilation"
    
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
    echo -e "${BOLD}${MAGENTA}  EDR/AV EVASION TOOLKIT COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} tools"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} tools"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} tools"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 tools"
    fi
    
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Shellcode Generators: Donut, SGN"
    echo -e "    ${GREEN}●${RESET} EDR Bypass: ScareCrow, Freeze, Inceptor"
    echo -e "    ${GREEN}●${RESET} PE Packers: Pezor, Nimcrypt2"
    echo -e "    ${GREEN}●${RESET} Detection: PE-Sieve, Hollows_Hunter"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log: ${LOG_FILE}"
    else
        ok "Evasion toolkit ready"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}evasion-menu${RESET}           ${DIM}→ Interactive evasion menu${RESET}"
    echo -e "    ${CYAN}donut -f payload.exe${RESET}   ${DIM}→ Generate shellcode${RESET}"
    echo -e "    ${CYAN}sgn payload.bin${RESET}        ${DIM}→ Encode shellcode${RESET}"
    echo -e "    ${CYAN}scarecrow -in payload.dll${RESET} ${DIM}→ EDR bypass${RESET}"
    echo -e "    ${CYAN}freeze -o out.bin payload.exe${RESET} ${DIM}→ Obfuscate payload${RESET}"
    echo -e "    ${CYAN}pezor payload.exe${RESET}      ${DIM}→ Pack PE file${RESET}"
    echo -e "    ${CYAN}nimcrypt2 -f payload.exe${RESET} ${DIM}→ Nim-based encryption${RESET}"
    echo ""
    echo -e "  ${BOLD}All binaries:${RESET} ${DIM}/opt/evasion-tools/${RESET}"
    echo ""
}

# ============================================================
# STEP 20 — Post-Exploitation Kit (Professional Edition v2.0)
# ============================================================
