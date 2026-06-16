#!/usr/bin/env bash
# modules/10_cloud_security.sh

do_cloud_security() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 10/${STEP_TOTAL} — CLOUD & CONTAINER SECURITY TOOLKIT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Check Minimal Mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Cloud & Container tools — skipped in minimal mode"
        return 0
    fi
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Container Scanning Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/9] CONTAINER SCANNING TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Trivy
    if smart_find_tool "trivy" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} trivy ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing trivy (Container vulnerability scanner)..."
        if install_github_release "trivy" \
            "https://api.github.com/repos/aquasecurity/trivy/releases/latest" \
            "Linux-64bit.tar.gz" "trivy" "trivy" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} trivy ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} trivy ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Grype
    if smart_find_tool "grype" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} grype ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing grype (Container image scanner)..."
        if install_github_release "grype" \
            "https://api.github.com/repos/anchore/grype/releases/latest" \
            "linux_amd64.tar.gz" "grype" "grype" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} grype ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} grype ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Syft
    if smart_find_tool "syft" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} syft ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing syft (SBOM generator)..."
        if install_github_release "syft" \
            "https://api.github.com/repos/anchore/syft/releases/latest" \
            "linux_amd64.tar.gz" "syft" "syft" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} syft ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} syft ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Dive (NEW - Docker image layer explorer)
    if smart_find_tool "dive" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} dive ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing dive (Docker image layer explorer)..."
        if install_github_release "dive" \
            "https://api.github.com/repos/wagoodman/dive/releases/latest" \
            "linux_amd64.tar.gz" "dive" "dive" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} dive ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} dive ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Dockle (Container image linter)
    if smart_find_tool "dockle" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} dockle ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing dockle (Container image linter)..."
        if install_github_release "dockle" \
            "https://api.github.com/repos/goodwithtech/dockle/releases/latest" \
            "Linux-64bit.tar.gz" "dockle" "dockle" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} dockle ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} dockle ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "Container scanning tools ready"
    echo ""
    
    # ========================================================
    # Phase 2: Kubernetes Security
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/9] KUBERNETES SECURITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # kubectl
    if smart_find_tool "kubectl" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kubectl ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kubectl..."
        local k8s_ver kubectl_ok=0
        
        k8s_ver=$(curl -sf --max-time 10 "https://dl.k8s.io/release/stable.txt" 2>/dev/null) || \
            k8s_ver="v1.30.0"
        
        if safe_curl "https://dl.k8s.io/release/${k8s_ver}/bin/linux/amd64/kubectl" \
            "${LOCAL_BIN}/kubectl"; then
            chmod +x "${LOCAL_BIN}/kubectl"
            kubectl_ok=1
        fi
        
        if [[ $kubectl_ok -eq 0 ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing kubectl \
                >> "$LOG_FILE" 2>&1 && kubectl_ok=1 || true
        fi
        
        if [[ $kubectl_ok -eq 1 ]]; then
            echo -e "    ${GREEN}✔${RESET} kubectl ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} kubectl ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # kube-hunter (Kubernetes pentesting)
    if smart_find_tool "kube-hunter" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kube-hunter ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kube-hunter..."
        if "${VENV_DIR}/bin/pip" install kube-hunter --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/kube-hunter" ]]; then
                make_wrapper "kube-hunter" "${VENV_DIR}/bin/kube-hunter"
                echo -e "    ${GREEN}✔${RESET} kube-hunter ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} kube-hunter ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} kube-hunter ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # kubesec (Kubernetes manifest security scanner)
    if smart_find_tool "kubesec" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kubesec ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kubesec..."
        if install_github_release "kubesec" \
            "https://api.github.com/repos/controlplaneio/kubesec/releases/latest" \
            "linux_amd64.tar.gz" "kubesec" "kubesec" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} kubesec ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} kubesec ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # krew (kubectl plugin manager)
    if smart_find_tool "krew" &>/dev/null || [[ -f "$HOME/.krew/bin/kubectl-krew" ]]; then
        echo -e "    ${GREEN}✔${RESET} krew ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing krew (kubectl plugin manager)..."
        if (cd /tmp && curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz" && \
            tar zxvf krew-linux_amd64.tar.gz >> "$LOG_FILE" 2>&1 && \
            ./krew-linux_amd64 install krew >> "$LOG_FILE" 2>&1); then
            # Add to PATH
            export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
            echo -e "    ${GREEN}✔${RESET} krew ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} krew ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # kubeaudit
    if smart_find_tool "kubeaudit" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kubeaudit ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kubeaudit..."
        if install_go_tool "kubeaudit" "github.com/Shopify/kubeaudit/cmd/kubeaudit" "kubeaudit" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} kubeaudit ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} kubeaudit ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "Kubernetes security tools ready"
    echo ""
    
    # ========================================================
    # Phase 3: AWS Security Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/9] AWS SECURITY TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # AWS CLI
    if smart_find_tool "aws" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} aws cli ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing AWS CLI v2..."
        local aws_ok=0
        
        if safe_curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" /tmp/awscliv2.zip; then
            unzip -q /tmp/awscliv2.zip -d /tmp/awsinstall >> "$LOG_FILE" 2>&1 && \
            /tmp/awsinstall/aws/install >> "$LOG_FILE" 2>&1 && aws_ok=1
            rm -rf /tmp/awscliv2.zip /tmp/awsinstall
        fi
        
        if [[ $aws_ok -eq 0 ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq awscli \
                >> "$LOG_FILE" 2>&1 && aws_ok=1 || true
        fi
        
        if [[ $aws_ok -eq 0 ]]; then
            "${VENV_DIR}/bin/pip" install awscli --quiet >> "$LOG_FILE" 2>&1 && \
            [[ -x "${VENV_DIR}/bin/aws" ]] && \
            make_wrapper "aws" "${VENV_DIR}/bin/aws" && aws_ok=1 || true
        fi
        
        if [[ $aws_ok -eq 1 ]]; then
            echo -e "    ${GREEN}✔${RESET} aws cli ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} aws cli ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # cloudfox (AWS enumeration)
    if smart_find_tool "cloudfox" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} cloudfox ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing cloudfox (AWS enumeration)..."
        if install_go_tool "cloudfox" "github.com/BishopFox/cloudfox" "cloudfox" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} cloudfox ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} cloudfox ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Prowler (AWS Security Assessment - NEW & CRITICAL)
    if smart_find_tool "prowler" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} prowler ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing prowler (AWS Security Assessment)..."
        if "${VENV_DIR}/bin/pip" install prowler --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/prowler" ]]; then
                make_wrapper "prowler" "${VENV_DIR}/bin/prowler"
                echo -e "    ${GREEN}✔${RESET} prowler ${DIM}[installed]${RESET}"
                ((total_installed++))
                ok "prowler installed (300+ AWS security checks)"
            else
                echo -e "    ${RED}✗${RESET} prowler ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} prowler ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # CloudMapper (AWS environment visualization)
    if [[ -d "${TOOLS_DIR}/cloudmapper" ]]; then
        echo -e "    ${GREEN}✔${RESET} cloudmapper ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing cloudmapper..."
        if git clone -q --depth 1 https://github.com/duo-labs/cloudmapper "${TOOLS_DIR}/cloudmapper" >> "$LOG_FILE" 2>&1; then
            if (cd "${TOOLS_DIR}/cloudmapper" && "${VENV_DIR}/bin/pip" install -r requirements.txt --quiet >> "$LOG_FILE" 2>&1); then
                cat > "${LOCAL_BIN}/cloudmapper" << 'CLOUDMAPPER'
#!/usr/bin/env bash
source /opt/kali-venv/bin/activate
cd /opt/tools/cloudmapper
python3 cloudmapper.py "$@"
CLOUDMAPPER
                chmod +x "${LOCAL_BIN}/cloudmapper"
                echo -e "    ${GREEN}✔${RESET} cloudmapper ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} cloudmapper ${DIM}[deps failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} cloudmapper ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    #enumerate-iam (AWS IAM enumeration)
    if [[ -d "${TOOLS_DIR}/enumerate-iam" ]]; then
        echo -e "    ${GREEN}✔${RESET} enumerate-iam ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing enumerate-iam..."
        if git clone -q --depth 1 https://github.com/andresriancho/enumerate-iam "${TOOLS_DIR}/enumerate-iam" >> "$LOG_FILE" 2>&1; then
            if (cd "${TOOLS_DIR}/enumerate-iam" && "${VENV_DIR}/bin/pip" install -r requirements.txt --quiet >> "$LOG_FILE" 2>&1); then
                cat > "${LOCAL_BIN}/enumerate-iam" << 'ENUMIAM'
#!/usr/bin/env bash
source /opt/kali-venv/bin/activate
cd /opt/tools/enumerate-iam
python3 enumerate-iam.py "$@"
ENUMIAM
                chmod +x "${LOCAL_BIN}/enumerate-iam"
                echo -e "    ${GREEN}✔${RESET} enumerate-iam ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} enumerate-iam ${DIM}[deps failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} enumerate-iam ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Principal Mapper (AWS IAM privilege escalation)
    if smart_find_tool "pmapper" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} principal-mapper ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing principal-mapper..."
        if "${VENV_DIR}/bin/pip" install principalmapper --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/pmapper" ]]; then
                make_wrapper "pmapper" "${VENV_DIR}/bin/pmapper"
                echo -e "    ${GREEN}✔${RESET} principal-mapper ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} principal-mapper ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} principal-mapper ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "AWS security tools ready"
    echo ""
    
    # ========================================================
    # Phase 4: Azure Security Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/9] AZURE SECURITY TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Azure CLI
    if smart_find_tool "az" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} azure-cli ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Azure CLI..."
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq azure-cli >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} azure-cli ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            # Try Microsoft's install script
            if curl -sL https://aka.ms/InstallAzureCLIDeb | bash >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} azure-cli ${DIM}[installed via script]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} azure-cli ${DIM}[failed]${RESET}"
                ((total_failed++))
            fi
        fi
    fi
    
    # ROADtools (Azure AD enumeration)
    if smart_find_tool "roadrecon" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} ROADtools ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing ROADtools (Azure AD enumeration)..."
        if "${VENV_DIR}/bin/pip" install roadrecon roadtools --quiet >> "$LOG_FILE" 2>&1; then
            local road_installed=0
            for bin in roadrecon roadtx roadobj; do
                if [[ -x "${VENV_DIR}/bin/${bin}" ]]; then
                    make_wrapper "$bin" "${VENV_DIR}/bin/${bin}"
                    ((road_installed++))
                fi
            done
            if [[ $road_installed -gt 0 ]]; then
                echo -e "    ${GREEN}✔${RESET} ROADtools ${DIM}[installed - $road_installed binaries]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} ROADtools ${DIM}[binaries not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} ROADtools ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Stormspotter (Azure Red Team tool)
    if [[ -d "${TOOLS_DIR}/stormspotter" ]]; then
        echo -e "    ${GREEN}✔${RESET} stormspotter ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing stormspotter..."
        if git clone -q --depth 1 https://github.com/Azure/Stormspotter "${TOOLS_DIR}/stormspotter" >> "$LOG_FILE" 2>&1; then
            if (cd "${TOOLS_DIR}/stormspotter" && "${VENV_DIR}/bin/pip" install -r backend/requirements.txt --quiet >> "$LOG_FILE" 2>&1); then
                cat > "${LOCAL_BIN}/stormspotter" << 'STORMSPOTTER'
#!/usr/bin/env bash
source /opt/kali-venv/bin/activate
cd /opt/tools/stormspotter/backend
python3 app.py "$@"
STORMSPOTTER
                chmod +x "${LOCAL_BIN}/stormspotter"
                echo -e "    ${GREEN}✔${RESET} stormspotter ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} stormspotter ${DIM}[deps failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} stormspotter ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # MicroBurst (Azure pentesting)
    if [[ -d "${TOOLS_DIR}/MicroBurst" ]]; then
        echo -e "    ${GREEN}✔${RESET} MicroBurst ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing MicroBurst (PowerShell-based)..."
        if git clone -q --depth 1 https://github.com/NetSPI/MicroBurst "${TOOLS_DIR}/MicroBurst" >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} MicroBurst ${DIM}[installed]${RESET}"
            ((total_installed++))
            info "Use: pwsh -c 'Import-Module /opt/tools/MicroBurst/MicroBurst.psd1'"
        else
            echo -e "    ${RED}✗${RESET} MicroBurst ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "Azure security tools ready"
    echo ""
    
    # ========================================================
    # Phase 5: GCP Security Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/9] GCP SECURITY TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # gcloud CLI
    if smart_find_tool "gcloud" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} gcloud cli ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing Google Cloud SDK..."
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates gnupg >> "$LOG_FILE" 2>&1; then
            echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
                tee -a /etc/apt/sources.list.d/google-cloud-sdk.list >> "$LOG_FILE" 2>&1
            curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
                apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - >> "$LOG_FILE" 2>&1
            apt-get update -qq >> "$LOG_FILE" 2>&1
            
            if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq google-cloud-sdk >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} gcloud cli ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} gcloud cli ${DIM}[failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} gcloud cli ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # GCP-Scanner
    if smart_find_tool "gcp_scanner" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} gcp-scanner ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing gcp-scanner..."
        if "${VENV_DIR}/bin/pip" install gcp-scanner --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/gcp_scanner" ]]; then
                make_wrapper "gcp_scanner" "${VENV_DIR}/bin/gcp_scanner"
                echo -e "    ${GREEN}✔${RESET} gcp-scanner ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} gcp-scanner ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} gcp-scanner ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "GCP security tools ready"
    echo ""
    
    # ========================================================
    # Phase 6: Multi-Cloud & Recon Tools
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/9] MULTI-CLOUD & RECON TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # ScoutSuite
    if smart_find_tool "scout" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} scoutsuite ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing scoutsuite (Multi-cloud security audit)..."
        if install_venv_tool "scoutsuite" "scoutsuite" "scout" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} scoutsuite ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} scoutsuite ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Pacu (AWS exploitation framework)
    if smart_find_tool "pacu" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} pacu ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing pacu (AWS exploitation framework)..."
        if install_py_github_tool "pacu" "" "https://github.com/RhinoSecurityLabs/pacu.git" "cli/pacu.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} pacu ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} pacu ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # Cartography (Multi-cloud graph visualization)
    if smart_find_tool "cartography" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} cartography ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing cartography..."
        if "${VENV_DIR}/bin/pip" install cartography --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/cartography" ]]; then
                make_wrapper "cartography" "${VENV_DIR}/bin/cartography"
                echo -e "    ${GREEN}✔${RESET} cartography ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} cartography ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} cartography ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # cloud-nuke (Clean up cloud resources)
    if smart_find_tool "cloud-nuke" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} cloud-nuke ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing cloud-nuke..."
        if install_go_tool "cloud-nuke" "github.com/gruntwork-io/cloud-nuke" "cloud-nuke" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} cloud-nuke ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} cloud-nuke ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # cloud_enum (Multi-cloud OSINT)
    if smart_find_tool "cloud_enum" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} cloud_enum ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing cloud_enum..."
        if install_py_github_tool "cloud_enum" "" "https://github.com/initstring/cloud_enum.git" "cloud_enum.py" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} cloud_enum ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} cloud_enum ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "Multi-cloud tools ready"
    echo ""
    
    # ========================================================
    # Phase 7: Secrets Detection
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/9] SECRETS DETECTION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # gitleaks
    if smart_find_tool "gitleaks" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} gitleaks ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing gitleaks..."
        if install_go_tool "gitleaks" "github.com/gitleaks/gitleaks" "gitleaks" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} gitleaks ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} gitleaks ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # trufflehog (already in bug bounty, verify)
    if smart_find_tool "trufflehog" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} trufflehog ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing trufflehog..."
        if install_go_tool "trufflehog" "github.com/trufflesecurity/trufflehog/v3" "trufflehog" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} trufflehog ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} trufflehog ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # git-hound (GitHub dorking)
    if smart_find_tool "git-hound" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} git-hound ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing git-hound..."
        if install_go_tool "git-hound" "github.com/tillson/git-hound" "git-hound" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} git-hound ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} git-hound ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "Secrets detection tools ready"
    echo ""
    
    # ========================================================
    # Phase 8: Infrastructure as Code (IaC) Security
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/9] INFRASTRUCTURE AS CODE SECURITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # checkov (IaC scanner)
    if smart_find_tool "checkov" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} checkov ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing checkov (IaC security scanner)..."
        if "${VENV_DIR}/bin/pip" install checkov --quiet >> "$LOG_FILE" 2>&1; then
            if [[ -x "${VENV_DIR}/bin/checkov" ]]; then
                make_wrapper "checkov" "${VENV_DIR}/bin/checkov"
                echo -e "    ${GREEN}✔${RESET} checkov ${DIM}[installed]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} checkov ${DIM}[binary not found]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${RED}✗${RESET} checkov ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # tfsec (Terraform security scanner)
    if smart_find_tool "tfsec" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} tfsec ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing tfsec..."
        if install_go_tool "tfsec" "github.com/aquasecurity/tfsec/cmd/tfsec" "tfsec" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} tfsec ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} tfsec ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # kics (KICS IaC scanner)
    if smart_find_tool "kics" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} kics ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing kics..."
        if install_github_release "kics" \
            "https://api.github.com/repos/Checkmarx/kics/releases/latest" \
            "linux_x64.tar.gz" "kics" "kics" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} kics ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} kics ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    # terrascan
    if smart_find_tool "terrascan" &>/dev/null; then
        echo -e "    ${GREEN}✔${RESET} terrascan ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    else
        info "Installing terrascan..."
        if install_go_tool "terrascan" "github.com/tenable/terrascan/cmd/terrascan" "terrascan" 2>&1 | grep -q "installed"; then
            echo -e "    ${GREEN}✔${RESET} terrascan ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} terrascan ${DIM}[failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    ok "IaC security tools ready"
    echo ""
    
    # ========================================================
    # Phase 9: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 9/9] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify critical cloud tools
    local critical_tools=("trivy" "kubectl" "aws" "prowler" "gitleaks" "checkov")
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
        ok "Critical cloud tools verified (${verified}/${#critical_tools[@]})"
    else
        warn "Missing critical tools: ${missing_critical[*]}"
    fi
    
    # Get version info for key tools
    info "Tool versions:"
    for tool in trivy kubectl aws prowler gitleaks; do
        if smart_find_tool "$tool" &>/dev/null; then
            local version
            case "$tool" in
                trivy)
                    version=$(trivy --version 2>&1 | head -1 | grep -oP 'v?[\d.]+' | head -1 || echo "unknown")
                    ;;
                kubectl)
                    version=$(kubectl version --client --short 2>/dev/null | grep -oP 'v[\d.]+' || \
                              kubectl version --client 2>&1 | head -1 | grep -oP 'v[\d.]+' || echo "unknown")
                    ;;
                aws)
                    version=$(aws --version 2>&1 | grep -oP 'aws-cli/[\d.]+' || echo "unknown")
                    ;;
                prowler)
                    version=$(prowler --version 2>&1 | grep -oP '[\d.]+' | head -1 || echo "unknown")
                    ;;
                gitleaks)
                    version=$(gitleaks version 2>&1 | grep -oP 'v?[\d.]+' | head -1 || echo "unknown")
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
    echo -e "${BOLD}${MAGENTA}  CLOUD & CONTAINER SECURITY TOOLKIT COMPLETE${RESET}"
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
    echo -e "    ${GREEN}●${RESET} Container Scanning: trivy, grype, syft, dive, dockle"
    echo -e "    ${GREEN}●${RESET} Kubernetes: kubectl, kube-hunter, kubesec, krew, kubeaudit"
    echo -e "    ${GREEN}●${RESET} AWS Tools: aws cli, cloudfox, prowler, cloudmapper, pmapper"
    echo -e "    ${GREEN}●${RESET} Azure Tools: azure-cli, ROADtools, stormspotter, MicroBurst"
    echo -e "    ${GREEN}●${RESET} GCP Tools: gcloud cli, gcp-scanner"
    echo -e "    ${GREEN}●${RESET} Multi-Cloud: scoutsuite, pacu, cartography, cloud-nuke"
    echo -e "    ${GREEN}●${RESET} Secrets Detection: gitleaks, trufflehog, git-hound"
    echo -e "    ${GREEN}●${RESET} IaC Security: checkov, tfsec, kics, terrascan"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some tools failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All Cloud & Container tools installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}trivy image nginx:latest${RESET}              ${DIM}→ Scan container image${RESET}"
    echo -e "    ${CYAN}trivy fs --security-checks vuln,config .${RESET} ${DIM}→ Scan filesystem${RESET}"
    echo -e "    ${CYAN}grype nginx:latest${RESET}                    ${DIM}→ Alternative image scan${RESET}"
    echo -e "    ${CYAN}dive nginx:latest${RESET}                     ${DIM}→ Explore image layers${RESET}"
    echo -e "    ${CYAN}kube-hunter --remote 10.0.0.1${RESET}         ${DIM}→ Kubernetes pentest${RESET}"
    echo -e "    ${CYAN}kubesec scan deployment.yaml${RESET}          ${DIM}→ K8s manifest scan${RESET}"
    echo -e "    ${CYAN}aws s3 ls${RESET}                             ${DIM}→ List S3 buckets${RESET}"
    echo -e "    ${CYAN}prowler aws -M csv -F output${RESET}          ${DIM}→ AWS security assessment${RESET}"
    echo -e "    ${CYAN}cloudfox aws iam-permissions${RESET}          ${DIM}→ AWS IAM enumeration${RESET}"
    echo -e "    ${CYAN}pacu${RESET}                                  ${DIM}→ Launch AWS exploitation${RESET}"
    echo -e "    ${CYAN}az login${RESET}                              ${DIM}→ Login to Azure${RESET}"
    echo -e "    ${CYAN}roadrecon gather -u user@domain.com${RESET}   ${DIM}→ Azure AD enumeration${RESET}"
    echo -e "    ${CYAN}gcloud auth login${RESET}                     ${DIM}→ Login to GCP${RESET}"
    echo -e "    ${CYAN}scout aws --profile default${RESET}           ${DIM}→ Multi-cloud audit${RESET}"
    echo -e "    ${CYAN}gitleaks detect --source . --verbose${RESET}  ${DIM}→ Scan for secrets${RESET}"
    echo -e "    ${CYAN}checkov -d ./terraform/${RESET}               ${DIM}→ IaC security scan${RESET}"
    echo -e "    ${CYAN}tfsec ./terraform/${RESET}                    ${DIM}→ Terraform scan${RESET}"
    echo -e "    ${CYAN}cloud_enum -k keyword${RESET}                 ${DIM}→ Multi-cloud OSINT${RESET}"
    echo ""
}

# ============================================================
# STEP 11 — Wordlists & Dictionaries (Professional Edition)
# ============================================================
