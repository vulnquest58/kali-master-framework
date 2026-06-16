#!/usr/bin/env bash
# modules/01_preflight.sh

do_network_fix() {
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  NETWORK & DNS HARDENING${RESET}"
    echo -e "${BOLD}${MAGENTA}  Optimizing connectivity for reliable downloads${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""

    local changes_made=0

    # ========================================================
    # 1. IPv6 Connectivity Check & Disable (if unreachable)
    # ========================================================
    echo -e "${BOLD}${CYAN}[1/4] IPv6 CONNECTIVITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if curl -6 -sf --max-time 3 https://ipv6.google.com &>/dev/null; then
        ok "IPv6 is reachable — keeping enabled"
    else
        warn "IPv6 is unreachable — disabling to prevent download hangs"
        
        # Disable for current session
        sysctl -w net.ipv6.conf.all.disable_ipv6=1 >> "$LOG_FILE" 2>&1 || true
        sysctl -w net.ipv6.conf.default.disable_ipv6=1 >> "$LOG_FILE" 2>&1 || true
        
        # Persist across reboots
        if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.d/99-kali-master.conf 2>/dev/null; then
            cat >> /etc/sysctl.d/99-kali-master.conf << 'EOF' 2>/dev/null || true
# Added by Kali Master Framework
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
            sysctl -p /etc/sysctl.d/99-kali-master.conf >> "$LOG_FILE" 2>&1 || true
        fi
        ok "IPv6 disabled successfully"
        ((changes_made++))
    fi
    echo ""

    # ========================================================
    # 2. DNS Health Check & Fallback Configuration
    # ========================================================
    echo -e "${BOLD}${CYAN}[2/4] DNS RESOLUTION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local current_ns
    current_ns=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    current_ns="${current_ns:-8.8.8.8}"
    
    info "Testing current DNS resolver: ${current_ns}"
    
    if host -W 3 google.com "${current_ns}" &>/dev/null 2>&1; then
        ok "Current DNS (${current_ns}) is working properly"
    else
        warn "Current DNS (${current_ns}) is misbehaving or blocked"
        info "Adding reliable fallback resolvers (1.1.1.1, 8.8.8.8, 9.9.9.9)..."
        
        # Backup original resolv.conf
        cp /etc/resolv.conf /etc/resolv.conf.backup."$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        
        # Prepend reliable nameservers
        local tmp_resolv
        tmp_resolv=$(mktemp)
        {
            echo "# Added by Kali Master Framework — Reliable DNS Fallbacks"
            echo "nameserver 1.1.1.1"
            echo "nameserver 8.8.8.8"
            echo "nameserver 9.9.9.9"
            cat /etc/resolv.conf.backup.* 2>/dev/null | grep -v "^#" | grep "^nameserver" || cat /etc/resolv.conf
        } > "$tmp_resolv"
        
        # Remove duplicates while preserving order
        awk '!seen[$0]++' "$tmp_resolv" > /etc/resolv.conf
        rm -f "$tmp_resolv"
        
        ok "DNS fallbacks configured successfully"
        ((changes_made++))
    fi
    echo ""

    # ========================================================
    # 3. Force APT to use IPv4
    # ========================================================
    echo -e "${BOLD}${CYAN}[3/4] APT CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local apt_conf="/etc/apt/apt.conf.d/99-force-ipv4"
    if [[ ! -f "$apt_conf" ]] || ! grep -q 'Acquire::ForceIPv4 "true"' "$apt_conf" 2>/dev/null; then
        info "Forcing APT to use IPv4 to avoid mirror routing issues..."
        cat > "$apt_conf" << 'EOF'
# Added by Kali Master Framework
Acquire::ForceIPv4 "true";
EOF
        ok "APT forced to IPv4"
        ((changes_made++))
    else
        ok "APT is already configured to force IPv4"
    fi
    echo ""

    # ========================================================
    # 4. Go Proxy Configuration (Rate Limit & Reliability)
    # ========================================================
    echo -e "${BOLD}${CYAN}[4/4] GO PROXY CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local go_conf="/etc/profile.d/goproxy.sh"
    if [[ ! -f "$go_conf" ]] || ! grep -q "proxy.golang.org" "$go_conf" 2>/dev/null; then
        info "Configuring Go proxy chain for faster and reliable module downloads..."
        cat > "$go_conf" << 'EOF'
# Added by Kali Master Framework
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
export GOPRIVATE=""
EOF
        chmod +x "$go_conf"
        
        # Apply to current session
        export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
        export GONOSUMDB="*"
        
        ok "Go proxy chain configured (GOPROXY + GONOSUMDB)"
        ((changes_made++))
    else
        ok "Go proxy is already configured"
    fi
    echo ""

    # ========================================================
    # Final Summary
    # ========================================================
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    
    if [[ $changes_made -gt 0 ]]; then
        ok "Network hardening complete (${changes_made} changes applied)"
        info "Changes will persist across reboots"
    else
        ok "Network is already optimally configured — no changes needed"
    fi
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ============================================================
# Pre-flight Checks (Professional Edition)
# ============================================================

do_preflight() {
    # ========================================================
    # Banner
    # ========================================================
    clear
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
  ╔═══════════════════════════════════════════════════════╗
  ║   KALI MASTER FRAMEWORK — PRE-FLIGHT CHECKS           ║
  ║   Verifying system requirements before installation   ║
  ╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
    echo ""
    
    # ========================================================
    # Section 1: System Identity
    # ========================================================
    echo -e "${BOLD}${CYAN}[1/8] SYSTEM IDENTITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # OS Detection
    if grep -qi "kali" /etc/os-release 2>/dev/null; then
        local os_name
        os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
        ok "OS: $os_name"
    else
        warn "Kali Linux not detected — some packages may not be available"
        local os_name
        os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Unknown")
        info "Detected: $os_name"
    fi
    
    # Kernel
    echo -e "  ${DIM}Kernel: $(uname -r)${RESET}"
    
    # Architecture
    local arch
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        ok "Architecture: $arch (amd64)"
    else
        warn "Architecture: $arch — some tools may not be compatible"
    fi
    
    # Hostname
    local hostname
    hostname=$(hostname)
    echo -e "  ${DIM}Hostname: $hostname${RESET}"
    if ! grep -q "^127.0.0.1.*${hostname}" /etc/hosts 2>/dev/null; then
        echo "127.0.0.1   ${hostname}" >> /etc/hosts 2>/dev/null
        ok "Hostname added to /etc/hosts"
    fi
    
    echo ""
    
    # ========================================================
    # Section 2: Privileges
    # ========================================================
    echo -e "${BOLD}${CYAN}[2/8] PRIVILEGES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ $EUID -eq 0 ]]; then
        ok "Running as root"
    else
        fail "Must run as root — use: sudo $0"
        exit 1
    fi
    
    # Check sudo availability
    if command -v sudo &>/dev/null; then
        ok "sudo available"
    else
        warn "sudo not found — some operations may fail"
    fi
    
    echo ""
    
    # ========================================================
    # Section 3: Hardware Resources
    # ========================================================
    echo -e "${BOLD}${CYAN}[3/8] HARDWARE RESOURCES${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # CPU
    local cpu_cores
    cpu_cores=$(nproc 2>/dev/null || echo "1")
    local cpu_model
    cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "Unknown")
    
    if [[ "$cpu_cores" -ge 2 ]]; then
        ok "CPU: $cpu_model ($cpu_cores cores)"
    else
        warn "CPU: $cpu_cores core — compilation will be slow"
    fi
    
    # RAM
    local ram_total ram_free ram_used
    ram_total=$(free -g | awk '/^Mem:/{print $2}')
    ram_used=$(free -g | awk '/^Mem:/{print $3}')
    ram_free=$(free -g | awk '/^Mem:/{print $4}')
    
    if [[ "$ram_total" -ge 4 ]]; then
        ok "RAM: ${ram_used}GB / ${ram_total}GB total (${ram_free}GB free)"
    elif [[ "$ram_total" -ge 2 ]]; then
        warn "RAM: ${ram_total}GB — 4GB+ recommended for full installation"
    else
        fail "RAM: ${ram_total}GB — minimum 2GB required"
        exit 1
    fi
    
    # Swap
    local swap_total
    swap_total=$(free -g | awk '/^Swap:/{print $2}')
    if [[ "$swap_total" -gt 0 ]]; then
        info "Swap: ${swap_total}GB"
    else
        warn "No swap space — consider adding swap for stability"
    fi
    
    # Disk Space
    local free_gb total_gb used_percent
    free_gb=$(df -BG / | awk 'NR==2{gsub("G",""); print $4}')
    total_gb=$(df -BG / | awk 'NR==2{gsub("G",""); print $2}')
    used_percent=$(df -h / | awk 'NR==2{print $5}')
    
    if [[ "$free_gb" -ge 30 ]]; then
        ok "Disk: ${free_gb}GB free of ${total_gb}GB (${used_percent} used)"
    elif [[ "$free_gb" -ge 15 ]]; then
        warn "Disk: ${free_gb}GB free — 30GB+ recommended for full install"
    elif [[ "$free_gb" -ge 10 ]]; then
        warn "Disk: ${free_gb}GB free — consider using --minimal mode"
    else
        fail "Disk: ${free_gb}GB free — minimum 10GB required"
        exit 1
    fi
    
    # Inode check
    local free_inodes
    free_inodes=$(df -i / | awk 'NR==2{print $4}')
    if [[ "$free_inodes" -lt 100000 ]]; then
        warn "Low inodes: $free_inodes free — may cause installation issues"
    fi
    
    echo ""
    
    # ========================================================
    # Section 4: Network Connectivity
    # ========================================================
    echo -e "${BOLD}${CYAN}[4/8] NETWORK CONNECTIVITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Basic internet check
    if curl -sf --max-time 5 https://1.1.1.1 &>/dev/null; then
        ok "Internet: Active (HTTPS)"
    elif ping -c1 -W3 8.8.8.8 &>/dev/null; then
        ok "Internet: Active (ICMP only)"
        warn "HTTPS blocked — some downloads may fail"
    else
        fail "No internet connection"
        exit 1
    fi
    
    # DNS check
    if host -W 3 google.com 8.8.8.8 &>/dev/null 2>&1; then
        ok "DNS: Working"
    else
        warn "DNS: Issues detected — adding fallback resolvers"
        if ! grep -q "1.1.1.1" /etc/resolv.conf 2>/dev/null; then
            cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null
            {
                echo "# Added by kali-master"
                echo "nameserver 1.1.1.1"
                echo "nameserver 8.8.8.8"
                cat /etc/resolv.conf.backup 2>/dev/null
            } > /etc/resolv.conf
            ok "DNS fallbacks added (1.1.1.1, 8.8.8.8)"
        fi
    fi
    
    # GitHub API check
    if curl -sf --max-time 5 https://api.github.com &>/dev/null; then
        ok "GitHub API: Accessible"
    else
        warn "GitHub API: Unreachable — tool downloads may fail"
    fi
    
    # Go proxy check
    if curl -sf --max-time 5 https://proxy.golang.org &>/dev/null; then
        ok "Go Proxy: Accessible"
    else
        warn "Go Proxy: Unreachable — Go tools may fail to install"
    fi
    
    # IPv6 check
    if curl -6 -sf --max-time 3 https://ipv6.google.com &>/dev/null; then
        ok "IPv6: Enabled"
    else
        info "IPv6: Disabled/Unreachable (not critical)"
    fi
    
    # IP Address
    local public_ip local_ip
    local_ip=$(ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "N/A")
    echo -e "  ${DIM}Local IP: $local_ip${RESET}"
    
    echo ""
    
    # ========================================================
    # Section 5: Essential Tools Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[5/8] ESSENTIAL TOOLS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local essential_tools=("curl" "wget" "git" "python3" "tar" "unzip" "gpg")
    local missing_essential=()
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}[✔]${RESET} $tool"
        else
            echo -e "  ${RED}[✗]${RESET} $tool ${DIM}[MISSING]${RESET}"
            missing_essential+=("$tool")
        fi
    done
    
    if [[ ${#missing_essential[@]} -gt 0 ]]; then
        warn "Installing missing essential tools..."
        DEBIAN_FRONTEND=noninteractive apt-get update -qq >> "$LOG_FILE" 2>&1
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${missing_essential[@]}" >> "$LOG_FILE" 2>&1
        
        # Verify again
        for tool in "${missing_essential[@]}"; do
            if command -v "$tool" &>/dev/null; then
                ok "$tool installed successfully"
            else
                fail "$tool installation failed — aborting"
                exit 1
            fi
        done
    fi
    
    echo ""
    
    # ========================================================
    # Section 6: Environment & Configuration
    # ========================================================
    echo -e "${BOLD}${CYAN}[6/8] ENVIRONMENT & CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # GITHUB_TOKEN
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        ok "GITHUB_TOKEN: Configured (rate limit: 5000/hour)"
    else
        info "GITHUB_TOKEN: Not set (rate limit: 60/hour)"
        warn "Set GITHUB_TOKEN for faster downloads"
    fi
    
    # Locale
    local current_locale
    current_locale=$(locale 2>/dev/null | grep "^LANG=" | cut -d= -f2 || echo "Unknown")
    if [[ "$current_locale" == *"UTF-8"* ]] || [[ "$current_locale" == *"utf8"* ]]; then
        ok "Locale: $current_locale"
    else
        warn "Locale: $current_locale — UTF-8 recommended"
    fi
    
    # Timezone
    local current_tz
    current_tz=$(cat /etc/timezone 2>/dev/null || echo "Unknown")
    echo -e "  ${DIM}Timezone: $current_tz${RESET}"
    
    # umask
    local current_umask
    current_umask=$(umask)
    if [[ "$current_umask" == "0022" ]] || [[ "$current_umask" == "022" ]]; then
        ok "umask: $current_umask"
    else
        warn "umask: $current_umask — 022 recommended"
    fi
    
    echo ""
    
    # ========================================================
    # Section 7: Previous Installation Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[7/8] PREVIOUS INSTALLATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ -d "$STATE_DIR" ]] && [[ -n "$(ls -A "$STATE_DIR" 2>/dev/null)" ]]; then
        local completed_steps
        completed_steps=$(ls "$STATE_DIR"/*.done 2>/dev/null | wc -l)
        ok "Previous installation detected: $completed_steps step(s) completed"
        
        # Show completed steps
        if [[ "$completed_steps" -gt 0 ]]; then
            echo -e "  ${DIM}Completed steps:${RESET}"
            for step_file in "$STATE_DIR"/*.done; do
                local step_name
                step_name=$(basename "$step_file" .done)
                echo -e "    ${GREEN}•${RESET} $step_name"
            done
        fi
        
        info "Use --reset to start fresh, or --force to re-run steps"
    else
        info "Fresh installation — no previous state found"
    fi
    
    # Check for existing tools
    local existing_tools=0
    for dir in "$LOCAL_BIN" "$GOPATH_BIN" "$CARGO_BIN" "${VENV_DIR}/bin"; do
        if [[ -d "$dir" ]]; then
            local count
            count=$(find "$dir" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
            existing_tools=$((existing_tools + count))
        fi
    done
    
    if [[ $existing_tools -gt 0 ]]; then
        info "Existing tools found: $existing_tools executables"
    fi
    
    echo ""
    
    # ========================================================
    # Section 8: Directory Setup
    # ========================================================
    echo -e "${BOLD}${CYAN}[8/8] DIRECTORY SETUP${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Create all required directories
    local dirs_to_create=(
        "$(dirname "$LOG_FILE")"
        "$STATE_DIR"
        "$CONFIG_DIR"
        "${TOOLS_DIR}/bin"
        "${TOOLS_DIR}/wordlists"
        "${TOOLS_DIR}/exploits"
        "${TOOLS_DIR}/scripts"
        "${TOOLS_DIR}/payloads"
        "${TOOLS_DIR}/github"
        "$C2_DIR"
        "$REDIRECTOR_DIR"
        "$EVASION_DIR"
        "$POSTEXPLOIT_DIR"
        "$HOME/bugbounty"
        "$HOME/ctf"
        "$HOME/redteam"
        "$HOME/payloads"
    )
    
    for dir in "${dirs_to_create[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" 2>/dev/null
            echo -e "  ${GREEN}[+]${RESET} Created: ${DIM}$dir${RESET}"
        fi
    done
    
    ok "All directories ready"
    echo ""
    
    # ========================================================
    # Final Summary
    # ========================================================
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  PRE-FLIGHT CHECKS COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    # Display mode
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        echo -e "  ${BOLD}Mode:${RESET}       ${YELLOW}MINIMAL${RESET} ${DIM}(lightweight — core tools only)${RESET}"
        echo -e "  ${BOLD}ETA:${RESET}        ${DIM}~15-20 minutes${RESET}"
    else
        echo -e "  ${BOLD}Mode:${RESET}       ${GREEN}FULL${RESET} ${DIM}(complete installation)${RESET}"
        echo -e "  ${BOLD}ETA:${RESET}        ${DIM}~45-90 minutes${RESET}"
    fi
    
    echo -e "  ${BOLD}Log:${RESET}        ${DIM}${LOG_FILE}${RESET}"
    echo -e "  ${BOLD}State:${RESET}      ${DIM}${STATE_DIR}${RESET}"
    echo ""
    
    # Security warning
    echo -e "  ${YELLOW}${BOLD}⚠  SECURITY NOTICE${RESET}"
    echo -e "  ${DIM}This script installs offensive security tools.${RESET}"
    echo -e "  ${DIM}Use only on systems you own or have explicit authorization to test.${RESET}"
    echo ""
    
    # Countdown
    info "Installation starts in 3 seconds... (Ctrl+C to cancel)"
    for i in 3 2 1; do
        echo -ne "  ${BOLD}$i${RESET}..."
        sleep 1
    done
    echo -e " ${GREEN}GO!${RESET}"
    echo ""
}

# ============================================================
# STEP 1 — Snapshot (Professional Edition)
# ============================================================

do_snapshot() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 1/${STEP_TOTAL} — SYSTEM SNAPSHOT${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local snapshot_taken=0
    local snapshot_method=""
    
    # ========================================================
    # Check for skip flag
    # ========================================================
    if [[ "${SKIP_SNAPSHOT:-0}" == "1" ]]; then
        skip "Snapshot skipped by user (--no-snapshot)"
        return 0
    fi
    
    # ========================================================
    # 1. VMware Snapshot (via vmrun)
    # ========================================================
    if pgrep -x vmtoolsd &>/dev/null || pgrep -x vmware-toolbox-cmd &>/dev/null; then
        info "VMware environment detected"
        
        if command -v vmrun &>/dev/null; then
            info "Creating VMware snapshot..."
            local vmx_file
            vmx_file=$(find / -name "*.vmx" -type f 2>/dev/null | head -1)
            
            if [[ -n "$vmx_file" ]]; then
                if vmrun -T ws snapshot "$vmx_file" "kali-master-v6.7.0-pre-install" >> "$LOG_FILE" 2>&1; then
                    ok "VMware snapshot created: kali-master-v6.7.0-pre-install"
                    snapshot_taken=1
                    snapshot_method="VMware (vmrun)"
                else
                    warn "VMware snapshot failed — take manually if needed"
                fi
            else
                info "VMware Tools detected but no VMX file found"
                info "Take snapshot manually via VMware interface"
            fi
        elif command -v vmware-toolbox-cmd &>/dev/null; then
            info "VMware Tools available (vmware-toolbox-cmd)"
            info "Take snapshot manually via VMware interface"
            info "Or install vmrun: apt install open-vm-tools-desktop"
        else
            warn "VMware detected but vmrun not available"
            info "Take snapshot manually via VMware interface"
        fi
    fi
    
    # ========================================================
    # 2. VirtualBox Snapshot
    # ========================================================
    if [[ -f /sys/class/dmi/id/sys_vendor ]] && grep -qi "innotek\|virtualbox" /sys/class/dmi/id/sys_vendor 2>/dev/null; then
        info "VirtualBox environment detected"
        
        if command -v VBoxManage &>/dev/null; then
            local vm_name
            vm_name=$(VBoxManage list runningvms 2>/dev/null | head -1 | cut -d'"' -f2)
            
            if [[ -n "$vm_name" ]]; then
                info "Creating VirtualBox snapshot for: $vm_name"
                if VBoxManage snapshot "$vm_name" take "kali-master-v6.7.0-pre-install" --description "Pre-installation snapshot" >> "$LOG_FILE" 2>&1; then
                    ok "VirtualBox snapshot created"
                    snapshot_taken=1
                    snapshot_method="VirtualBox (VBoxManage)"
                else
                    warn "VirtualBox snapshot failed"
                fi
            else
                info "VirtualBox detected but no running VM found"
                info "Take snapshot manually via VirtualBox Manager"
            fi
        else
            warn "VirtualBox detected but VBoxManage not available"
            info "Take snapshot manually via VirtualBox Manager"
        fi
    fi
    
    # ========================================================
    # 3. Timeshift Snapshot (BTRFS/RSYNC)
    # ========================================================
    if command -v timeshift &>/dev/null; then
        info "Timeshift detected"
        
        # Check if Timeshift is configured
        if [[ -f /etc/timeshift.json ]] || [[ -d /run/timeshift ]]; then
            info "Creating Timeshift snapshot..."
            if timeshift --create --comments "kali-master-v6.7.0-pre-install" --tags "D" --yes >> "$LOG_FILE" 2>&1; then
                ok "Timeshift snapshot created"
                snapshot_taken=1
                snapshot_method="Timeshift"
            else
                warn "Timeshift snapshot failed"
            fi
        else
            info "Timeshift installed but not configured"
            info "Configure Timeshift first: sudo timeshift --setup"
        fi
    fi
    
    # ========================================================
    # 4. BTRFS Snapshot (Native)
    # ========================================================
    if command -v btrfs &>/dev/null && mount | grep -q "type btrfs"; then
        info "BTRFS filesystem detected"
        
        local btrfs_mount
        btrfs_mount=$(mount | grep "type btrfs" | head -1 | awk '{print $3}')
        
        if [[ -n "$btrfs_mount" ]]; then
            info "Creating BTRFS snapshot at: $btrfs_mount"
            local snapshot_dir="${btrfs_mount}/.snapshots/kali-master-v6.7.0-pre-install-$(date +%Y%m%d_%H%M%S)"
            
            if mkdir -p "$(dirname "$snapshot_dir")" 2>/dev/null; then
                if btrfs subvolume snapshot "$btrfs_mount" "$snapshot_dir" >> "$LOG_FILE" 2>&1; then
                    ok "BTRFS snapshot created: $snapshot_dir"
                    snapshot_taken=1
                    snapshot_method="BTRFS (native)"
                else
                    warn "BTRFS snapshot failed"
                fi
            fi
        fi
    fi
    
    # ========================================================
    # 5. LVM Snapshot
    # ========================================================
    if command -v lvcreate &>/dev/null; then
        local root_lv
        root_lv=$(lvs --noheadings -o lv_path 2>/dev/null | grep -E "root|kali" | head -1)
        
        if [[ -n "$root_lv" ]]; then
            info "LVM detected: $root_lv"
            local snapshot_name="kali-master-v67-pre-$(date +%Y%m%d)"
            
            info "Creating LVM snapshot (1GB)..."
            if lvcreate -L 1G -s -n "$snapshot_name" "$root_lv" >> "$LOG_FILE" 2>&1; then
                ok "LVM snapshot created: $snapshot_name"
                snapshot_taken=1
                snapshot_method="LVM"
            else
                warn "LVM snapshot failed — may need more free space"
            fi
        fi
    fi
    
    # ========================================================
    # Summary
    # ========================================================
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    
    if [[ $snapshot_taken -eq 1 ]]; then
        ok "Snapshot created successfully"
        info "Method: ${BOLD}$snapshot_method${RESET}"
        info "You can rollback if installation fails"
    else
        warn "No snapshot created"
        info "Recommendations:"
        echo -e "    ${DIM}• Install Timeshift: apt install timeshift${RESET}"
        echo -e "    ${DIM}• Or take manual VM snapshot${RESET}"
        echo -e "    ${DIM}• Or use: --no-snapshot to skip this step${RESET}"
    fi
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ============================================================
# STEP 2 — System Update + Build Dependencies (Professional)
# ============================================================

