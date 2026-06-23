#!/usr/bin/env bash
# ============================================================
#  modules/26_ai_tools.sh — Kali Master Framework v7.0.0
#  AI-Assisted Recon & Local LLM Integration
# ============================================================

do_ai_tools() {
    clear
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 26/${STEP_TOTAL} — AI-ASSISTED RECON & LLM TOOLS${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo ""

    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "AI Tools — skipped in minimal mode"
        return 0
    fi

    local step_start_time; step_start_time=$(date +%s)
    local total_installed=0 total_failed=0 total_skipped=0

    mkdir -p "$AI_TOOLS_DIR"

    # ══════════════════════════════════════════════════════════
    # Phase 1: Ollama — Local LLM Runtime
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 1/5] OLLAMA — LOCAL LLM RUNTIME${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    if smart_find_tool "ollama" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ollama ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        local ollama_ver; ollama_ver=$(ollama --version 2>/dev/null | head -1)
        echo -e "    ${DIM}Version: ${ollama_ver}${RESET}"
    else
        info "Installing ollama (local LLM runtime)..."
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            dryrun "curl -fsSL https://ollama.com/install.sh | bash"
            ((total_installed++))
        elif curl -fsSL https://ollama.com/install.sh | bash >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} ollama ${DIM}[installed]${RESET}"
            ((total_installed++))
            ok "ollama installed — local AI runtime ready"
        else
            echo -e "    ${RED}✗${RESET} ollama ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    fi

    # Start ollama service
    if smart_find_tool "ollama" &>/dev/null; then
        info "Starting ollama service..."
        systemctl enable ollama --quiet 2>/dev/null || true
        systemctl start ollama --quiet 2>/dev/null || \
            (ollama serve >> "$LOG_FILE" 2>&1 &)
        sleep 2
        if curl -sf http://localhost:11434/api/tags &>/dev/null; then
            ok "ollama service running on :11434"
        else
            warn "ollama service may not be running — start manually: ollama serve"
        fi
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 2: Security-Focused AI Models
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 2/5] SECURITY AI MODELS${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    if smart_find_tool "ollama" &>/dev/null; then
        local models=(
            "codestral:latest|Code analysis & exploit generation"
            "llama3:8b|General purpose security reasoning"
        )

        for model_info in "${models[@]}"; do
            IFS='|' read -r model desc <<< "$model_info"
            info "Pulling model: ${model} (${desc})..."

            if ollama list 2>/dev/null | grep -q "${model%%:*}"; then
                echo -e "    ${GREEN}✔${RESET} ${model} ${DIM}[already pulled]${RESET}"
                ((total_skipped++))
            else
                if [[ "${DRY_RUN:-0}" == "1" ]]; then
                    dryrun "ollama pull $model"
                    ((total_installed++))
                elif ollama pull "$model" >> "$LOG_FILE" 2>&1; then
                    echo -e "    ${GREEN}✔${RESET} ${model} ${DIM}[pulled — ${desc}]${RESET}"
                    ((total_installed++))
                else
                    echo -e "    ${YELLOW}!${RESET} ${model} ${DIM}[pull failed — large model, try manually]${RESET}"
                    echo -e "      ${DIM}Run: ollama pull ${model}${RESET}"
                    ((total_failed++))
                fi
            fi
        done
    else
        warn "ollama not installed — skipping model pulls"
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 3: AIRecon — Autonomous Recon Agent
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 3/5] AIRECON — AUTONOMOUS RECON AGENT${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local airecon_dir="${AI_TOOLS_DIR}/AIRecon"
    if [[ -d "$airecon_dir" ]]; then
        echo -e "    ${GREEN}✔${RESET} AIRecon ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Cloning AIRecon..."
        if git_clone "https://github.com/ANG13T/airecon.git" "$airecon_dir" 1 0; then
            [[ -f "${airecon_dir}/requirements.txt" ]] && \
                "${VENV_DIR}/bin/pip" install -r "${airecon_dir}/requirements.txt" --quiet >> "$LOG_FILE" 2>&1 || true

            cat > "${LOCAL_BIN}/airecon" << EOF
#!/usr/bin/env bash
cd "${airecon_dir}"
source "${VENV_DIR}/bin/activate"
python3 airecon.py "\$@"
EOF
            chmod +x "${LOCAL_BIN}/airecon"
            echo -e "    ${GREEN}✔${RESET} AIRecon ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} AIRecon ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 4: AI Security Utilities (Python)
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 4/5] AI SECURITY PYTHON TOOLS${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    local ai_py_tools=(
        "burpgpt:burpgpt:burpgpt"
        "openai:openai:openai"
        "anthropic:anthropic:anthropic"
        "langchain:langchain:langchain"
    )

    for entry in "${ai_py_tools[@]}"; do
        IFS=':' read -r name pkg binary <<< "$entry"
        if "${VENV_DIR}/bin/pip" show "$pkg" &>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} ${name} ${DIM}[already installed]${RESET}"
            ((total_skipped++))
        else
            if [[ "${DRY_RUN:-0}" == "1" ]]; then
                dryrun "pip install $pkg"
                ((total_installed++))
            elif "${VENV_DIR}/bin/pip" install "$pkg" --quiet >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} ${name} ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${YELLOW}!${RESET} ${name} ${DIM}[failed — non-critical]${RESET}"
                ((total_failed++))
            fi
        fi
    done
    echo ""

    # ══════════════════════════════════════════════════════════
    # Phase 5: Nuclei AI Integration Config
    # ══════════════════════════════════════════════════════════
    echo -e "${BOLD}${CYAN}[PHASE 5/5] NUCLEI AI INTEGRATION${RESET}"
    echo -e "  ${DIM}──────────────────────────────────────────────────────${RESET}"

    mkdir -p "$HOME/.config/nuclei"
    local nuclei_ai_conf="$HOME/.config/nuclei/config.yaml"

    if [[ ! -f "$nuclei_ai_conf" ]] || ! grep -q "ai:" "$nuclei_ai_conf" 2>/dev/null; then
        cat >> "$nuclei_ai_conf" << 'EOF' 2>/dev/null || true
# Nuclei AI integration — Kali Master Framework v7.0.0
ai:
  # Local ollama endpoint
  provider: ollama
  base-url: http://localhost:11434
  model: codestral:latest
EOF
        ok "Nuclei AI config configured (local ollama)"
        ((total_installed++))
    else
        ok "Nuclei AI config already set"
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
    echo -e "${BOLD}${MAGENTA}  AI TOOLS SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}   ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}  ${total_installed} components"
    echo -e "  ${DIM}Skipped:${RESET}    ${total_skipped} (already installed)"
    [[ $total_failed -gt 0 ]] && echo -e "  ${YELLOW}Failed:${RESET}     ${total_failed} components (non-critical)"
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}ollama serve${RESET}                     ${DIM}→ Start local LLM API${RESET}"
    echo -e "    ${CYAN}ollama run codestral${RESET}             ${DIM}→ Interactive code AI${RESET}"
    echo -e "    ${CYAN}ollama run llama3${RESET}                ${DIM}→ General purpose AI${RESET}"
    echo -e "    ${CYAN}airecon -t target.com${RESET}            ${DIM}→ AI-powered recon${RESET}"
    echo -e "    ${CYAN}nuclei -u target.com -ai${RESET}         ${DIM}→ AI-enhanced scanning${RESET}"
    echo ""
    ok "AI Tools installed — local models run 100% offline"
}
