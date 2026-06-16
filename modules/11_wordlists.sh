#!/usr/bin/env bash
# modules/11_wordlists.sh

do_wordlists() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 11/${STEP_TOTAL} — WORDLISTS & DICTIONARIES${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # Create base directory structure
    mkdir -p /opt/wordlists/{passwords,usernames,subdomains,web,dns,cloud,fuzzing,custom}
    
    # ========================================================
    # Phase 1: Core System Wordlists (APT)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/7] CORE SYSTEM WORDLISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Install wordlists package
    info "Installing wordlists package..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq wordlists --fix-missing >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} wordlists package ${DIM}[installed]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} wordlists package ${DIM}[failed]${RESET}"
        ((total_failed++))
    fi
    
    # Install seclists
    info "Installing seclists package..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq seclists --fix-missing >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} seclists package ${DIM}[installed]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} seclists package ${DIM}[failed]${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: SecLists (Complete Collection)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/7] SECLISTS COLLECTION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ -d "/usr/share/seclists" ]]; then
        # Create symlink
        ln -sf /usr/share/seclists /opt/wordlists/SecLists 2>/dev/null
        echo -e "    ${GREEN}✔${RESET} SecLists ${DIM}[installed via apt]${RESET}"
        ((total_skipped++))
        
        # Count files
        local seclists_count
        seclists_count=$(find /usr/share/seclists -type f 2>/dev/null | wc -l)
        info "SecLists contains: ${seclists_count} files"
    elif [[ -d "/opt/wordlists/SecLists" ]]; then
        echo -e "    ${GREEN}✔${RESET} SecLists ${DIM}[already cloned]${RESET}"
        ((total_skipped++))
    else
        info "Cloning SecLists (latest)..."
        if git clone -q --depth 1 https://github.com/danielmiessler/SecLists \
            /opt/wordlists/SecLists >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} SecLists ${DIM}[cloned]${RESET}"
            ((total_installed++))
            
            local seclists_count
            seclists_count=$(find /opt/wordlists/SecLists -type f 2>/dev/null | wc -l)
            info "SecLists contains: ${seclists_count} files"
        else
            echo -e "    ${RED}✗${RESET} SecLists ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Rockyou & Password Lists
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/7] PASSWORD LISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Rockyou (decompress if needed)
    if [[ -f /usr/share/wordlists/rockyou.txt.gz ]] && [[ ! -f /usr/share/wordlists/rockyou.txt ]]; then
        info "Decompressing rockyou.txt..."
        if gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null; then
            echo -e "    ${GREEN}✔${RESET} rockyou.txt ${DIM}[decompressed]${RESET}"
            ((total_installed++))
            
            local rockyou_lines
            rockyou_lines=$(wc -l < /usr/share/wordlists/rockyou.txt 2>/dev/null || echo "unknown")
            info "rockyou.txt contains: ${rockyou_lines} passwords"
        else
            echo -e "    ${RED}✗${RESET} rockyou.txt ${DIM}[decompression failed]${RESET}"
            ((total_failed++))
        fi
    elif [[ -f /usr/share/wordlists/rockyou.txt ]]; then
        echo -e "    ${GREEN}✔${RESET} rockyou.txt ${DIM}[already ready]${RESET}"
        ((total_skipped++))
        
        local rockyou_lines
        rockyou_lines=$(wc -l < /usr/share/wordlists/rockyou.txt 2>/dev/null || echo "unknown")
        info "rockyou.txt contains: ${rockyou_lines} passwords"
    else
        echo -e "    ${RED}✗${RESET} rockyou.txt ${DIM}[not found]${RESET}"
        ((total_failed++))
    fi
    
    # Create symlink to /opt/wordlists
    ln -sf /usr/share/wordlists /opt/wordlists/kali 2>/dev/null
    
    # Download additional password lists
    info "Downloading additional password lists..."
    
    # Weakpass Top 100M
    if [[ ! -f /opt/wordlists/passwords/weakpass_1.txt ]]; then
        info "Downloading Weakpass Top 100M (1/4)..."
        if safe_curl "https://weakpass.com/wordlist/1949/weakpass_1.7z" "/tmp/weakpass_1.7z"; then
            if command -v 7z &>/dev/null; then
                7z x /tmp/weakpass_1.7z -o/opt/wordlists/passwords/ -y >> "$LOG_FILE" 2>&1
                rm -f /tmp/weakpass_1.7z
                echo -e "    ${GREEN}✔${RESET} weakpass_1.txt ${DIM}[downloaded]${RESET}"
                ((total_installed++))
            else
                warn "7z not installed — skipping weakpass"
            fi
        else
            echo -e "    ${RED}✗${RESET} weakpass_1.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} weakpass_1.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    # Common credentials list
    if [[ ! -f /opt/wordlists/passwords/common_credentials.txt ]]; then
        info "Downloading common credentials list..."
        if safe_curl "https://raw.githubusercontent.com/nixawk/fuzzdb/master/bruteforce/passwd-default.txt" \
            "/opt/wordlists/passwords/common_credentials.txt"; then
            echo -e "    ${GREEN}✔${RESET} common_credentials.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} common_credentials.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} common_credentials.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: Subdomain Wordlists
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/7] SUBDOMAIN WORDLISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Jason Haddix subdomain list
    if [[ ! -f /opt/wordlists/subdomains/subdomains-top1million-5000.txt ]]; then
        info "Downloading Jason Haddix subdomain lists..."
        if safe_curl "https://raw.githubusercontent.com/jhaddix/domain_enum/master/discovery/lists/subdomains-top1million-5000.txt" \
            "/opt/wordlists/subdomains/subdomains-top1million-5000.txt"; then
            echo -e "    ${GREEN}✔${RESET} subdomains-top1million-5000.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} subdomains-top1million-5000.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} subdomains-top1million-5000.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    # Assetnote subdomain wordlists
    info "Downloading Assetnote wordlists..."
    local assetnote_lists=(
        "subdomains:https://wordlists-cdn.assetnote.io/data/automated/httparchive_subdomains_2024_01_28.txt"
        "apiroutes:https://wordlists-cdn.assetnote.io/data/automated/httparchive_apiroutes_2024_01_28.txt"
        "directories:https://wordlists-cdn.assetnote.io/data/automated/httparchive_directories_2024_01_28.txt"
        "txt:https://wordlists-cdn.assetnote.io/data/automated/httparchive_txt_2024_01_28.txt"
        "php:https://wordlists-cdn.assetnote.io/data/automated/httparchive_php_2024_01_28.txt"
    )
    
    for entry in "${assetnote_lists[@]}"; do
        IFS=':' read -r name url <<< "$entry"
        local target_file="/opt/wordlists/subdomains/assetnote_${name}.txt"
        
        if [[ ! -f "$target_file" ]]; then
            if safe_curl "$url" "$target_file"; then
                echo -e "    ${GREEN}✔${RESET} assetnote_${name}.txt ${DIM}[downloaded]${RESET}"
                ((total_installed++))
            else
                echo -e "    ${RED}✗${RESET} assetnote_${name}.txt ${DIM}[download failed]${RESET}"
                ((total_failed++))
            fi
        else
            echo -e "    ${GREEN}✔${RESET} assetnote_${name}.txt ${DIM}[already exists]${RESET}"
            ((total_skipped++))
        fi
    done
    
    echo ""
    
    # ========================================================
    # Phase 5: Web Fuzzing Wordlists
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/7] WEB FUZZING WORDLISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Bo0oM fuzzdb
    if [[ ! -d /opt/wordlists/web/fuzzdb ]]; then
        info "Cloning fuzzdb (comprehensive fuzzing database)..."
        if git clone -q --depth 1 https://github.com/Bo0oM/fuzzdb.git /opt/wordlists/web/fuzzdb >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} fuzzdb ${DIM}[cloned]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} fuzzdb ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} fuzzdb ${DIM}[already cloned]${RESET}"
        ((total_skipped++))
    fi
    
    # swisskyrepo PayloadsAllTheThings
    if [[ ! -d /opt/wordlists/web/PayloadsAllTheThings ]]; then
        info "Cloning PayloadsAllTheThings..."
        if git clone -q --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings.git \
            /opt/wordlists/web/PayloadsAllTheThings >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} PayloadsAllTheThings ${DIM}[cloned]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} PayloadsAllTheThings ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} PayloadsAllTheThings ${DIM}[already cloned]${RESET}"
        ((total_skipped++))
    fi
    
    # XSS wordlists
    if [[ ! -f /opt/wordlists/web/xss_brute.txt ]]; then
        info "Downloading XSS wordlists..."
        if safe_curl "https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/master/XSS%20Injection/Intruder/xss_brute.txt" \
            "/opt/wordlists/web/xss_brute.txt"; then
            echo -e "    ${GREEN}✔${RESET} xss_brute.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} xss_brute.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} xss_brute.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    # SQLi wordlists
    if [[ ! -f /opt/wordlists/web/sqli_brute.txt ]]; then
        if safe_curl "https://raw.githubusercontent.com/swisskyrepo/PayloadsAllTheThings/master/SQL%20Injection/Intruder/sqli_brute.txt" \
            "/opt/wordlists/web/sqli_brute.txt"; then
            echo -e "    ${GREEN}✔${RESET} sqli_brute.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} sqli_brute.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} sqli_brute.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 6: DNS & Cloud Wordlists
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/7] DNS & CLOUD WORDLISTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # DNS subdomains (commonspeak)
    if [[ ! -f /opt/wordlists/dns/commonspeak.txt ]]; then
        info "Downloading commonspeak DNS wordlist..."
        if safe_curl "https://raw.githubusercontent.com/assetnote/commonspeak2-wordlists/master/subdomains/subdomains.txt" \
            "/opt/wordlists/dns/commonspeak.txt"; then
            echo -e "    ${GREEN}✔${RESET} commonspeak.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} commonspeak.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} commonspeak.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    # AWS bucket names
    if [[ ! -f /opt/wordlists/cloud/s3_buckets.txt ]]; then
        info "Downloading S3 bucket wordlist..."
        if safe_curl "https://raw.githubusercontent.com/nixawk/fuzzdb/master/bruteforce/aws-s3-buckets.txt" \
            "/opt/wordlists/cloud/s3_buckets.txt"; then
            echo -e "    ${GREEN}✔${RESET} s3_buckets.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} s3_buckets.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} s3_buckets.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    # Azure blob names
    if [[ ! -f /opt/wordlists/cloud/azure_blobs.txt ]]; then
        info "Downloading Azure blob wordlist..."
        if safe_curl "https://raw.githubusercontent.com/nixawk/fuzzdb/master/bruteforce/azure-blob-names.txt" \
            "/opt/wordlists/cloud/azure_blobs.txt"; then
            echo -e "    ${GREEN}✔${RESET} azure_blobs.txt ${DIM}[downloaded]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} azure_blobs.txt ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} azure_blobs.txt ${DIM}[already exists]${RESET}"
        ((total_skipped++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/7] VERIFICATION & SUMMARY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Calculate total size and file count
    local total_size
    total_size=$(du -sh /opt/wordlists 2>/dev/null | awk '{print $1}')
    local total_files
    total_files=$(find /opt/wordlists -type f 2>/dev/null | wc -l)
    
    info "Wordlists statistics:"
    echo -e "    ${DIM}Total size: $total_size${RESET}"
    echo -e "    ${DIM}Total files: $total_files${RESET}"
    echo ""
    
    # List main directories
    info "Directory structure:"
    for dir in passwords usernames subdomains web dns cloud fuzzing custom; do
        if [[ -d "/opt/wordlists/$dir" ]]; then
            local dir_size
            dir_size=$(du -sh "/opt/wordlists/$dir" 2>/dev/null | awk '{print $1}')
            local dir_files
            dir_files=$(find "/opt/wordlists/$dir" -type f 2>/dev/null | wc -l)
            echo -e "    ${GREEN}●${RESET} /opt/wordlists/$dir ${DIM}($dir_size, $dir_files files)${RESET}"
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
    echo -e "${BOLD}${MAGENTA}  WORDLISTS & DICTIONARIES SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} wordlists"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} wordlists (already exists)"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} wordlists"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 wordlists"
    fi
    
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Core System: wordlists, seclists packages"
    echo -e "    ${GREEN}●${RESET} Passwords: rockyou, weakpass, common_credentials"
    echo -e "    ${GREEN}●${RESET} Subdomains: SecLists, Jason Haddix, Assetnote"
    echo -e "    ${GREEN}●${RESET} Web Fuzzing: fuzzdb, PayloadsAllTheThings, XSS/SQLi"
    echo -e "    ${GREEN}●${RESET} DNS: commonspeak, subdomain lists"
    echo -e "    ${GREEN}●${RESET} Cloud: S3 buckets, Azure blobs"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some wordlists failed to download"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "All wordlists installed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}ls -la /opt/wordlists/${RESET}                    ${DIM}→ Browse wordlists${RESET}"
    echo -e "    ${CYAN}find /opt/wordlists -name '*.txt' | wc -l${RESET} ${DIM}→ Count all wordlists${RESET}"
    echo -e "    ${CYAN}ffuf -u URL/FUZZ -w /opt/wordlists/web/fuzzdb/discovery/predictable-filefolders/...${RESET}"
    echo -e "        ${DIM}→ Web directory fuzzing${RESET}"
    echo -e "    ${CYAN}subfinder -d target.com -w /opt/wordlists/subdomains/assetnote_subdomains.txt${RESET}"
    echo -e "        ${DIM}→ Subdomain enumeration${RESET}"
    echo -e "    ${CYAN}hydra -l admin -P /opt/wordlists/passwords/rockyou.txt ssh://target${RESET}"
    echo -e "        ${DIM}→ Password brute force${RESET}"
    echo -e "    ${CYAN}nuclei -l urls.txt -w /opt/wordlists/web/PayloadsAllTheThings/...${RESET}"
    echo -e "        ${DIM}→ Vulnerability scanning${RESET}"
    echo -e "    ${CYAN}gobuster dir -u URL -w /opt/wordlists/subdomains/assetnote_directories.txt${RESET}"
    echo -e "        ${DIM}→ Directory brute force${RESET}"
    echo ""
}

# ============================================================
# STEP 12 — Shell Configuration (Professional Edition)
# ============================================================
