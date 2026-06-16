#!/usr/bin/env bash
# modules/23_auto_fix.sh

# ============================================================
# UNIVERSAL AUTO-FIX ENGINE v3.0 (Single Source of Truth)
# Features: Log parsing, 4-tier fallback, auto-verification
# ============================================================
do_auto_fix() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  UNIVERSAL AUTO-FIX ENGINE v3.0${RESET}"
    echo -e "${BOLD}${MAGENTA}  Intelligent Multi-Tier Tool Recovery${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time=$(date +%s)
    local total_scanned=0
    local already_ok=0
    local successfully_fixed=0
    local hard_failures=0
    
    # ========================================================
    # Phase 1: Log Analysis & Target Identification
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/4] ANALYZING INSTALLATION LOG${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local failed_tools=()
    if [[ -f "$LOG_FILE" ]]; then
        info "Scanning $LOG_FILE for installation failures..."
        # استخراج أسماء الأدوات التي فشلت من السجل (بحث ذكي عن كلمات الفشل)
        while IFS= read -r line; do
            local tool_name
            tool_name=$(echo "$line" | grep -oE '\b(subfinder|httpx|nuclei|dnsx|naabu|katana|gobuster|ffuf|dalfox|gau|trufflehog|feroxbuster|amass|chisel|kerbrute|ghauri|cloudfox|gitleaks|freeze|sliver-server|linpeas|pspy64|kubectl|aws|trivy|grype|syft|certipy|donut|scarecrow|sgn|pezor|nimcrypt2)\b' | head -1)
            if [[ -n "$tool_name" ]] && [[ ! " ${failed_tools[@]} " =~ " ${tool_name} " ]]; then
                failed_tools+=("$tool_name")
            fi
        done < <(grep -iE "failed|missing|error|could not" "$LOG_FILE" 2>/dev/null)
    fi
    
    # ========================================================
    # Phase 2: The Ultimate Fix Map (Tool -> 4 Fallback Methods)
    # Format: "tool_name|method1|method2|method3|method4"
    # Methods: apt:pkg_name | go:package_path | pip:pkg_name | cargo:crate | github:repo:asset_pattern:binary_name | git:repo_url
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/4] LOADING INTELLIGENT FIX MAP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    declare -A FIX_MAP=(
        # --- Bug Bounty & Recon ---
        ["nuclei"]="go:github.com/projectdiscovery/nuclei/v3/cmd/nuclei|github:aquasecurity/nuclei:Linux-64bit.tar.gz:nuclei|git:https://github.com/projectdiscovery/nuclei.git"
        ["subfinder"]="go:github.com/projectdiscovery/subfinder/v2/cmd/subfinder|apt:subfinder"
        ["httpx"]="go:github.com/projectdiscovery/httpx/cmd/httpx|apt:httpx"
        ["ffuf"]="go:github.com/ffuf/ffuf/v2|apt:ffuf"
        ["gobuster"]="go:github.com/OJ/gobuster/v3|apt:gobuster"
        ["gau"]="go:github.com/lc/gau/v2/cmd/gau|git:https://github.com/lc/gau.git"
        ["amass"]="go:github.com/owasp-amass/amass/v4/...@latest|apt:amass"
        ["feroxbuster"]="cargo:feroxbuster|apt:feroxbuster"
        
        # --- Network & AD ---
        ["chisel"]="go:github.com/jpillora/chisel|apt:chisel"
        ["kerbrute"]="go:github.com/ropnop/kerbrute|github:ropnop/kerbrute:linux_amd64:kerbrute"
        ["nxc"]="apt:netexec|pip:netexec"
        ["certipy"]="pip:certipy-ad|git:https://github.com/ly4k/Certipy.git"
        
        # --- Cloud & Container ---
        ["kubectl"]="binary:https://dl.k8s.io/release/stable.txt:linux/amd64/kubectl:kubectl|apt:kubectl"
        ["aws"]="binary:https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip:aws/install:aws|apt:awscli"
        ["trivy"]="github:aquasecurity/trivy:Linux-64bit.tar.gz:trivy|apt:trivy"
        ["grype"]="github:anchore/grype:linux_amd64.tar.gz:grype"
        
        # --- Evasion & Post-Exploit ---
        ["donut"]="git:https://github.com/TheWover/donut.git|apt:donut"
        ["scarecrow"]="git:https://github.com/optiv/ScareCrow.git"
        ["sgn"]="go:github.com/EgeBalci/sgn|git:https://github.com/EgeBalci/sgn.git"
        ["pezor"]="git:https://github.com/phra/PEzor.git"
        ["nimcrypt2"]="git:https://github.com/icyguider/Nimcrypt2.git"
        ["linpeas"]="curl:https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh:linpeas.sh"
        ["pspy64"]="curl:https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64:pspy64"
    )
    
    info "Fix map loaded with ${#FIX_MAP[@]} intelligent recovery profiles."
    echo ""
    
    # ========================================================
    # Phase 3: Multi-Tier Fallback Installation Engine
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/4] EXECUTING MULTI-TIER RECOVERY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # دالة داخلية لمحاولة التثبيت بطرق متعددة
    attempt_fix_tool() {
        local tool="$1"
        local profile="${FIX_MAP[$tool]:-}"
        
        if [[ -z "$profile" ]]; then
            warn "No recovery profile defined for: $tool"
            return 1
        fi
        
        # تقسيم البروفيل إلى مصفوفة طرق
        IFS='|' read -r -a methods <<< "$profile"
        
        for method in "${methods[@]}"; do
            local type="${method%%:*}"
            local args="${method#*:}"
            
            case "$type" in
                "apt")
                    info "  [Tier 1] Attempting APT: $args"
                    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$args" >> "$LOG_FILE" 2>&1; then
                        return 0
                    fi
                    ;;
                "go")
                    info "  [Tier 2] Attempting Go Install: $args"
                    export GOPATH="$HOME/go"
                    export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
                    export GOPROXY="https://proxy.golang.org,direct"
                    if GOPATH="$HOME/go" go install "$args@latest" >> "$LOG_FILE" 2>&1; then
                        # ربط الملف إذا كان في go/bin
                        [[ -x "$GOPATH/bin/$(basename "$args")" ]] && ln -sf "$GOPATH/bin/$(basename "$args")" "$LOCAL_BIN/$(basename "$args")" 2>/dev/null
                        return 0
                    fi
                    ;;
                "pip")
                    info "  [Tier 2] Attempting Pip Install: $args"
                    if "${VENV_DIR}/bin/pip" install "$args" --quiet >> "$LOG_FILE" 2>&1; then
                        [[ -x "${VENV_DIR}/bin/$tool" ]] && make_wrapper "$tool" "${VENV_DIR}/bin/$tool"
                        return 0
                    fi
                    ;;
                "cargo")
                    info "  [Tier 2] Attempting Cargo Install: $args"
                    if cargo install "$args" --quiet >> "$LOG_FILE" 2>&1; then
                        [[ -x "$CARGO_BIN/$tool" ]] && ln -sf "$CARGO_BIN/$tool" "$LOCAL_BIN/$tool" 2>/dev/null
                        return 0
                    fi
                    ;;
                "github")
                    info "  [Tier 3] Attempting GitHub Release: $args"
                    IFS=':' read -r repo asset_pattern bin_name <<< "$args"
                    install_github_release "$tool" "https://api.github.com/repos/${repo}/releases/latest" "$asset_pattern" "${bin_name:-$tool}" >> "$LOG_FILE" 2>&1 && return 0
                    ;;
                "git")
                    info "  [Tier 4] Attempting Git Clone & Build: $args"
                    local target_dir="$TOOLS_DIR/$tool"
                    if git clone --depth 1 "$args" "$target_dir" >> "$LOG_FILE" 2>&1; then
                        # محاولة إيجاد ملف تنفيذي أو بناءه
                        local exec_file
                        exec_file=$(find "$target_dir" -maxdepth 2 -type f -executable -name "*$tool*" 2>/dev/null | head -1)
                        if [[ -n "$exec_file" ]]; then
                            ln -sf "$exec_file" "$LOCAL_BIN/$tool" 2>/dev/null
                            return 0
                        fi
                        # محاولة بناء Go إذا كان هناك go.mod
                        if [[ -f "$target_dir/go.mod" ]]; then
                            (cd "$target_dir" && go build -o "$LOCAL_BIN/$tool" . >> "$LOG_FILE" 2>&1) && return 0
                        fi
                    fi
                    ;;
                "curl")
                    info "  [Tier 3] Attempting Direct Curl Download: $args"
                    IFS=':' read -r url filename <<< "$args"
                    if safe_curl "$url" "/tmp/$filename" 2>/dev/null; then
                        install -m 755 "/tmp/$filename" "$LOCAL_BIN/$tool"
                        rm -f "/tmp/$filename"
                        return 0
                    fi
                    ;;
                "binary")
                    info "  [Tier 3] Attempting Custom Binary Install: $args"
                    IFS=':' read -r url path_in_archive bin_name <<< "$args"
                    # منطق مبسط للتحميل المباشر (يمكن توسيعه حسب الحاجة)
                    if [[ "$url" == *"kubectl"* ]]; then
                        local k8s_ver=$(curl -sf --max-time 5 "https://dl.k8s.io/release/stable.txt" 2>/dev/null || echo "v1.30.0")
                        safe_curl "https://dl.k8s.io/release/${k8s_ver}/bin/linux/amd64/kubectl" "$LOCAL_BIN/kubectl" && chmod +x "$LOCAL_BIN/kubectl" && return 0
                    elif [[ "$url" == *"aws"* ]]; then
                        safe_curl "$url" "/tmp/awscliv2.zip" && unzip -q /tmp/awscliv2.zip -d /tmp/awsinstall && /tmp/awsinstall/aws/install --update >> "$LOG_FILE" 2>&1 && rm -rf /tmp/awscliv2.zip /tmp/awsinstall && return 0
                    fi
                    ;;
            esac
        done
        
        return 1 # كل الطرق فشلت
    }

    # تجميع القائمة النهائية للفحص (الأدوات الفاشلة من السجل + أدوات حرجة محددة)
    local tools_to_fix=("${failed_tools[@]}")
    # إضافة أدوات حرجة للتأكد منها دائماً
    local critical_checks=("nuclei" "subfinder" "httpx" "kubectl" "chisel" "linpeas")
    for c in "${critical_checks[@]}"; do
        if ! smart_find_tool "$c" &>/dev/null; then
            if [[ ! " ${tools_to_fix[@]} " =~ " ${c} " ]]; then
                tools_to_fix+=("$c")
            fi
        fi
    done

    # إزالة التكرارات
    local unique_tools=()
    for t in "${tools_to_fix[@]}"; do
        if [[ ! " ${unique_tools[@]} " =~ " ${t} " ]]; then
            unique_tools+=("$t")
        fi
    done

    info "Targeting ${#unique_tools[@]} tools for recovery..."
    echo ""

    for tool in "${unique_tools[@]}"; do
        ((total_scanned++))
        echo -e "${BOLD}▶ Fixing:${RESET} ${CYAN}$tool${RESET}"
        
        # 1. التحقق مما إذا كان مثبتاً بالفعل
        if smart_find_tool "$tool" &>/dev/null; then
            ok "  Already installed and functional. Skipping."
            ((already_ok++))
            echo ""
            continue
        fi
        
        # 2. محاولة الإصلاح عبر المحرك متعدد المراحل
        if attempt_fix_tool "$tool"; then
            # 3. التحقق النهائي والتفعيل
            local final_path
            final_path=$(smart_find_tool "$tool")
            if [[ -n "$final_path" ]]; then
                # إنشاء Wrapper لضمان الوصول العالمي
                make_wrapper "$tool" "$final_path"
                ok "  Successfully fixed and activated! ➔ $final_path"
                ((successfully_fixed++))
            else
                warn "  Installation reported success, but binary not found in PATH."
                ((hard_failures++))
            fi
        else
            fail "  All recovery tiers failed for $tool."
            ((hard_failures++))
        fi
        echo ""
    done

    # ========================================================
    # Phase 4: Final Summary & Reporting
    # ========================================================
    local step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  AUTO-FIX ENGINE COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}$((step_duration / 60))m $((step_duration % 60))s${RESET}"
    echo -e "  ${BOLD}Total Scanned:${RESET}  ${total_scanned} tools"
    echo -e "  ${DIM}Already OK:${RESET}     ${already_ok} tools"
    echo -e "  ${GREEN}Successfully Fixed:${RESET} ${successfully_fixed} tools"
    
    if [[ $hard_failures -gt 0 ]]; then
        echo -e "  ${RED}Hard Failures:${RESET}    ${hard_failures} tools (Require manual intervention)"
        echo ""
        echo -e "  ${YELLOW}⚠ Recommendation:${RESET}"
        echo -e "    Check the log file for specific build errors: ${DIM}$LOG_FILE${RESET}"
        echo -e "    Some tools may require specific system dependencies (e.g., specific Go versions, Rust toolchains)."
    else
        echo -e "  ${GREEN}Hard Failures:${RESET}    0 tools"
        echo ""
        echo -e "  ${GREEN}${BOLD}🎉 All targeted tools have been successfully recovered and activated!${RESET}"
    fi
    echo ""
}
