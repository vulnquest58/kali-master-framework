#!/usr/bin/env bash
# modules/07_reversing.sh

do_reversing() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 7/${STEP_TOTAL} — REVERSE ENGINEERING TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Reverse Engineering tools — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Core RE Tools (APT)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/9] CORE RE TOOLS (APT)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local apt_categories=(
        "Debuggers|gdb gdb-multiarch gdbserver"
        "Binary Analysis|radare2 rizin cutter iaito"
        "Tracing|ltrace strace"
        "File Analysis|binwalk foremost file"
        "ELF Utilities|checksec patchelf elfutils objdump readelf strings"
        "Assembly|nasm yasm"
        "Pattern Matching|yara"
        "Hex Editors|hexedit xxd bsdmainutils"
        "Packing|upx-ucl"
        "Emulation|qemu-user qemu-user-static libc6-dev-i386 valgrind"
        "Java/Android|ghidra apktool dex2jar jadx"
    )
    
    local apt_total=0
    local apt_installed=0
    local apt_failed=0
    
    for category_info in "${apt_categories[@]}"; do
        IFS='|' read -r category packages <<< "$category_info"
        local pkg_array=($packages)
        local pkg_count=${#pkg_array[@]}
        apt_total=$((apt_total + pkg_count))
        
        echo ""
        echo -e "  ${BOLD}${category}${RESET} ${DIM}($pkg_count packages)${RESET}"
        
        for pkg in "${pkg_array[@]}"; do
            if smart_find_tool "$pkg" &>/dev/null || dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[already installed]${RESET}"
                ((total_skipped++))
                ((apt_installed++))
                continue
            fi
            
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$pkg" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $pkg ${DIM}[installed]${RESET}"
                ((total_installed++))
                ((apt_installed++))
            else
                echo -e "    ${RED}✗${RESET} $pkg ${DIM}[failed]${RESET}"
                ((total_failed++))
                ((apt_failed++))
            fi
        done
    done
    
    echo ""
    if [[ $apt_failed -eq 0 ]]; then
        ok "Core RE tools: ${apt_installed}/${apt_total} packages ready"
    else
        warn "Core RE tools: ${apt_installed}/${apt_total} installed, ${apt_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Advanced Hex Editor (ImHex)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/9] ADVANCED HEX EDITOR${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if smart_find_tool "imhex" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ImHex ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        ok "ImHex ready"
    else
        info "Installing ImHex (Advanced Hex Editor)..."
        if install_github_release "imhex" \
            "https://api.github.com/repos/WerWolv/ImHex/releases/latest" \
            "Linux-x86_64.tar.gz" "imhex" "imhex" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} ImHex ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "ImHex installed successfully"
        else
            echo -e "    ${RED}✗${RESET} ImHex ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "ImHex installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: GDB Enhancements (pwndbg, GEF, PEDA)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/9] GDB ENHANCEMENTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # pwndbg
    if [[ -d "$HOME/.pwndbg" ]]; then
        echo -e "    ${GREEN}✔${RESET} pwndbg ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing pwndbg..."
        if git clone -q https://github.com/pwndbg/pwndbg "$HOME/.pwndbg" >> "$LOG_FILE" 2>&1; then
            if (cd "$HOME/.pwndbg" && VENV_HOME="${TOOLS_DIR}/pwndbg-venv" ./setup.sh >> "$LOG_FILE" 2>&1); then
                echo -e "    ${GREEN}✔${RESET} pwndbg ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "pwndbg installed"
            else
                echo -e "    ${RED}✗${RESET} pwndbg ${DIM}[setup failed]${RESET}"
                ((total_failed++))
                warn "pwndbg setup failed"
            fi
        else
            echo -e "    ${RED}✗${RESET} pwndbg ${DIM}[clone failed]${RESET}"
            ((total_failed++))
            warn "pwndbg clone failed"
        fi
    fi
    
    # GEF
    if grep -q "gef" "$HOME/.gdbinit" 2>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} GEF ${DIM}[already configured]${RESET}"
        ((total_skipped++))
    else
        info "Installing GEF..."
        if safe_wget "https://gef.blah.cat/py" /tmp/gef.py; then
            install -m 644 /tmp/gef.py /usr/local/share/gef.py
            echo "source /usr/local/share/gef.py" >> "$HOME/.gdbinit"
            rm -f /tmp/gef.py
            echo -e "    ${GREEN}✔${RESET} GEF ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "GEF installed"
        else
            echo -e "    ${RED}✗${RESET} GEF ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "GEF installation failed"
        fi
    fi
    
    # PEDA
    if [[ -d "${TOOLS_DIR}/peda" ]]; then
        echo -e "    ${GREEN}✔${RESET} PEDA ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing PEDA..."
        if git clone -q https://github.com/longld/peda.git "${TOOLS_DIR}/peda" >> "$LOG_FILE" 2>&1; then
            cat > "${LOCAL_BIN}/gdb-peda" << GDBPEDA
#!/usr/bin/env bash
exec gdb -q -ix "${TOOLS_DIR}/peda/peda.py" "\$@"
GDBPEDA
            chmod +x "${LOCAL_BIN}/gdb-peda"
            echo -e "    ${GREEN}✔${RESET} PEDA ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "PEDA installed"
        else
            echo -e "    ${RED}✗${RESET} PEDA ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "PEDA installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Python RE Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/9] PYTHON RE TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local py_tools=(
        "ROPgadget:ROPgadget:ROPgadget"
        "ropper:ropper:ropper"
        "pefile:pefile:pefile"
        "r2pipe:r2pipe:r2pipe"
        "pwntools:pwntools:pwn"
    )
    
    local py_count=${#py_tools[@]}
    local py_installed=0
    local py_failed=0
    
    info "Installing ${py_count} Python RE tools..."
    
    for entry in "${py_tools[@]}"; do
        IFS=':' read -r name package binary <<< "$entry"
        
        if smart_find_tool "$binary" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((py_installed++))
            continue
        fi
        
        if install_venv_tool "$name" "$package" "$binary" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} $name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((py_installed++))
        else
            echo -e "    ${RED}✗${RESET} $name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((py_failed++))
        fi
    done
    
    echo ""
    if [[ $py_failed -eq 0 ]]; then
        ok "Python RE tools: ${py_installed}/${py_count} tools ready"
    else
        warn "Python RE tools: ${py_installed}/${py_count} installed, ${py_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Office Document Analysis (oletools)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/9] OFFICE DOCUMENT ANALYSIS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if smart_find_tool "olevba" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} oletools ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        ok "oletools ready"
    else
        info "Installing oletools..."
        if install_venv_tool "oletools" "oletools" "olevba" 2>&1 | grep -q "installed"; then
            # Create wrappers for all oletools binaries
            for oletool in olevba oledump mraptor oleobj rtfobj; do
                if [[ -f "${VENV_DIR}/bin/${oletool}" ]]; then
                    make_wrapper "$oletool" "${VENV_DIR}/bin/${oletool}"
                fi
            done
            echo -e "    ${GREEN}✔${RESET} oletools ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "oletools installed with all binaries"
        else
            echo -e "    ${RED}✗${RESET} oletools ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "oletools installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: FLARE Tools (capa, floss)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/9] FLARE TOOLS (MALWARE ANALYSIS)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local flare_tools=("capa" "floss")
    local flare_installed=0
    local flare_missing=0
    
    for flare_bin in "${flare_tools[@]}"; do
        if smart_find_tool "$flare_bin" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $flare_bin ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((flare_installed++))
        else
            echo -e "    ${RED}✗${RESET} $flare_bin ${DIM}[not found]${RESET}"
            ((flare_missing++))
        fi
    done
    
    if [[ $flare_missing -eq 0 ]]; then
        ok "FLARE tools: ${flare_installed}/${#flare_tools[@]} tools ready"
    else
        warn "FLARE tools: ${flare_installed}/${#flare_tools[@]} ready, ${flare_missing} missing"
        info "Check FLARE venv: ${FLARE_VENV}"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Ruby Exploitation Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/9] RUBY EXPLOITATION TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local ruby_tools=("one_gadget" "seccomp-tools")
    local ruby_installed=0
    local ruby_failed=0
    
    for gem_name in "${ruby_tools[@]}"; do
        if smart_find_tool "$gem_name" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} $gem_name ${DIM}[already installed]${RESET}"
            ((total_skipped++))
            ((ruby_installed++))
            continue
        fi
        
        info "Installing $gem_name..."
        if gem install "$gem_name" --quiet >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} $gem_name ${DIM}[installed]${RESET}"
            ((total_installed++))
            ((ruby_installed++))
            ok "$gem_name installed"
        else
            echo -e "    ${RED}✗${RESET} $gem_name ${DIM}[failed]${RESET}"
            ((total_failed++))
            ((ruby_failed++))
            warn "$gem_name installation failed"
        fi
    done
    
    echo ""
    if [[ $ruby_failed -eq 0 ]]; then
        ok "Ruby tools: ${ruby_installed}/${#ruby_tools[@]} tools ready"
    else
        warn "Ruby tools: ${ruby_installed}/${#ruby_tools[@]} installed, ${ruby_failed} failed"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: CTF Binary Patching (pwninit)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/9] CTF BINARY PATCHING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if smart_find_tool "pwninit" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} pwninit ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        ok "pwninit ready"
    else
        info "Installing pwninit (CTF binary patching tool)..."
        if install_cargo_tool "pwninit" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} pwninit ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "pwninit installed successfully"
        else
            echo -e "    ${RED}✗${RESET} pwninit ${DIM}[failed]${RESET}"
            ((total_failed++))
            warn "pwninit installation failed"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 9: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 9/9] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical RE tools
    local critical_tools=("gdb" "radare2" "ghidra" "binwalk" "yara" "jadx")
    local verified=0
    local missing_critical=()
    
    for tool in "${critical_tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            ((verified++))
        else
            missing_critical+=("$tool")
        fi
    done
    
    if [[ ${#missing_critical[@]} -eq 0 ]]; then
        ok "Critical RE tools verified (${verified}/${#critical_tools[@]})"
    else
        warn "Missing critical tools: ${missing_critical[*]}"
    fi
    
    # Get version info for key tools
    info "Tool versions:"
    for tool in gdb radare2 ghidra; do
        if smart_find_tool "$tool" &>/dev/null; then
            local version
            case "$tool" in
                gdb)
                    version=$(gdb --version 2>&1 | head -1 | grep -oP '[\d.]+' | head -1 || echo "unknown")
                    ;;
                radare2)
                    version=$(r2 -v 2>&1 | head -1 | grep -oP '[\d.]+' | head -1 || echo "unknown")
                    ;;
                ghidra)
                    version=$(ghidra --help 2>&1 | head -1 | grep -oP '[\d.]+' | head -1 || echo "unknown")
                    ;;
            esac
            echo -e "    ${DIM}• $tool: $version${RESET}"
        fi
    done
    
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
    echo -e "${BOLD}${MAGENTA}  REVERSE ENGINEERING TOOLKIT COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} tools"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} tools (already installed)"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} tools"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 tools"
    fi
    
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Core RE Tools (APT): ${apt_installed} packages"
    echo -e "    ${GREEN}●${RESET} Advanced Hex Editor: ImHex"
    echo -e "    ${GREEN}●${RESET} GDB Enhancements: pwndbg, GEF, PEDA"
    echo -e "    ${GREEN}●${RESET} Python RE Tools: ${py_installed} tools"
    echo -e "    ${GREEN}●${RESET} Office Analysis: oletools"
    echo -e "    ${GREEN}●${RESET} FLARE Tools: ${flare_installed} tools (capa, floss)"
    echo -e "    ${GREEN}●${RESET} Ruby Tools: ${ruby_installed} tools"
    echo -e "    ${GREEN}●${RESET} CTF Tools: pwninit"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All Reverse Engineering tools installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}gdb ./binary${RESET}              ${DIM}→ Debug with GDB${RESET}"
    echo -e "    ${CYAN}gdb-peda ./binary${RESET}         ${DIM}→ Debug with PEDA${RESET}"
    echo -e "    ${CYAN}r2 ./binary${RESET}               ${DIM}→ Open in radare2${RESET}"
    echo -e "    ${CYAN}ghidra${RESET}                    ${DIM}→ Launch Ghidra${RESET}"
    echo -e "    ${CYAN}jadx -d out app.apk${RESET}       ${DIM}→ Decompile APK${RESET}"
    echo -e "    ${CYAN}capa malware.exe${RESET}          ${DIM}→ Malware capability analysis${RESET}"
    echo -e "    ${CYAN}floss malware.exe${RESET}         ${DIM}→ Extract strings${RESET}"
    echo -e "    ${CYAN}binwalk firmware.bin${RESET}      ${DIM}→ Firmware analysis${RESET}"
    echo -e "    ${CYAN}pwninit ./binary${RESET}          ${DIM}→ Patch binary for CTF${RESET}"
    echo ""
}

# ============================================================
# STEP 8 — CTF Toolkit (Professional Edition)
# ============================================================
