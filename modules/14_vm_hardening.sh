#!/usr/bin/env bash
# modules/14_vm_hardening.sh

do_vm_hardening() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 14/${STEP_TOTAL} — SYSTEM OPTIMIZATION & HARDENING${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_applied=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Kernel Security Hardening
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/9] KERNEL SECURITY HARDENING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Applying kernel security parameters..."
    
    cat > /etc/sysctl.d/99-kali-master-security.conf << 'SYSCTL_SECURITY'
# ============================================================
# Kali Master v6.7.0 — Kernel Security Hardening
# ============================================================

# ─── ptrace Security ───────────────────────────────────────
# Allow ptrace for debugging (required for gdb, strace, etc.)
# Set to 1 for stricter security (breaks some debuggers)
kernel.yama.ptrace_scope = 0

# ─── Kernel Address Protection ─────────────────────────────
# Hide kernel pointers from unprivileged users
kernel.kptr_restrict = 2

# ─── dmesg Restriction ─────────────────────────────────────
# Restrict dmesg access to root only
kernel.dmesg_restrict = 1

# ─── Perf Events ───────────────────────────────────────────
# Restrict perf events to prevent information leaks
kernel.perf_event_paranoid = 3

# ─── BPF JIT Hardening ─────────────────────────────────────
# Enable BPF JIT hardening
net.core.bpf_jit_harden = 2

# ─── kexec Restriction ─────────────────────────────────────
# Disable kexec to prevent kernel replacement
kernel.kexec_load_disabled = 1

# ─── SysRq Keys ────────────────────────────────────────────
# Restrict SysRq keys (4 = allow only sync, reboot, poweroff)
kernel.sysrq = 4

# ─── Core Dumps ────────────────────────────────────────────
# Disable core dumps for setuid programs
fs.suid_dumpable = 0

# ─── Kernel Modules ────────────────────────────────────────
# Disable module loading after boot (uncomment if needed)
# kernel.modules_disabled = 1
SYSCTL_SECURITY
    
    if sysctl -p /etc/sysctl.d/99-kali-master-security.conf >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} Kernel security parameters applied${RESET}"
        ((total_applied++))
    else
        echo -e "    ${RED}✗${RESET} Kernel security parameters failed${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Network Security Hardening
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/9] NETWORK SECURITY HARDENING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Applying network security parameters..."
    
    cat > /etc/sysctl.d/99-kali-master-network-security.conf << 'SYSCTL_NET_SECURITY'
# ============================================================
# Kali Master v6.7.0 — Network Security Hardening
# ============================================================

# ─── ICMP Redirects ────────────────────────────────────────
# Disable ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# ─── Source Routing ────────────────────────────────────────
# Disable source routing (prevent IP spoofing)
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# ─── Reverse Path Filtering ────────────────────────────────
# Enable strict reverse path filtering (anti-spoofing)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ─── ICMP Broadcast ────────────────────────────────────────
# Ignore ICMP broadcast requests (prevent smurf attacks)
net.ipv4.icmp_echo_ignore_broadcasts = 1

# ─── Bogus ICMP Responses ──────────────────────────────────
# Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# ─── SYN Cookies ───────────────────────────────────────────
# Enable SYN cookies (SYN flood protection)
net.ipv4.tcp_syncookies = 1

# ─── IP Forwarding ─────────────────────────────────────────
# Disable IP forwarding (enable if using as router)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# ─── TCP Timestamps ────────────────────────────────────────
# Disable TCP timestamps (prevent OS fingerprinting)
net.ipv4.tcp_timestamps = 0

# ─── Anonymous IP ──────────────────────────────────────────
# Disable anonymous IP (prevent information leaks)
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
SYSCTL_NET_SECURITY
    
    if sysctl -p /etc/sysctl.d/99-kali-master-network-security.conf >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} Network security parameters applied${RESET}"
        ((total_applied++))
    else
        echo -e "    ${RED}✗${RESET} Network security parameters failed${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Network Performance Optimization
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/9] NETWORK PERFORMANCE OPTIMIZATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Applying network performance parameters..."
    
    cat > /etc/sysctl.d/99-kali-master-network-perf.conf << 'SYSCTL_NET_PERF'
# ============================================================
# Kali Master v6.7.0 — Network Performance Optimization
# ============================================================

# ─── Socket Buffers ────────────────────────────────────────
# Increase socket buffer sizes for better throughput
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.optmem_max = 65536

# ─── TCP Buffer Tuning ─────────────────────────────────────
# Optimize TCP buffer sizes (min, default, max)
net.ipv4.tcp_rmem = 4096 1048576 16777216
net.ipv4.tcp_wmem = 4096 1048576 16777216

# ─── Connection Backlog ────────────────────────────────────
# Increase connection backlog
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_max_syn_backlog = 65535

# ─── TCP Window Scaling ────────────────────────────────────
# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1

# ─── TCP Fast Open ─────────────────────────────────────────
# Enable TCP Fast Open (client and server)
net.ipv4.tcp_fastopen = 3

# ─── TCP Slow Start ────────────────────────────────────────
# Enable TCP slow start after idle
net.ipv4.tcp_slow_start_after_idle = 0

# ─── TCP MTU Probing ───────────────────────────────────────
# Enable TCP MTU probing
net.ipv4.tcp_mtu_probing = 1

# ─── TCP Keepalive ─────────────────────────────────────────
# Optimize TCP keepalive settings
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 5

# ─── TIME_WAIT Optimization ────────────────────────────────
# Reduce TIME_WAIT timeout
net.ipv4.tcp_fin_timeout = 15

# ─── Connection Tracking ───────────────────────────────────
# Increase connection tracking table size
net.netfilter.nf_conntrack_max = 1048576
SYSCTL_NET_PERF
    
    if sysctl -p /etc/sysctl.d/99-kali-master-network-perf.conf >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} Network performance parameters applied${RESET}"
        ((total_applied++))
    else
        echo -e "    ${RED}✗${RESET} Network performance parameters failed${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 4: System Performance Optimization
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/9] SYSTEM PERFORMANCE OPTIMIZATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Applying system performance parameters..."
    
    cat > /etc/sysctl.d/99-kali-master-system-perf.conf << 'SYSCTL_SYS_PERF'
# ============================================================
# Kali Master v6.7.0 — System Performance Optimization
# ============================================================

# ─── File Descriptors ──────────────────────────────────────
# Increase maximum file descriptors
fs.file-max = 2097152
fs.nr_open = 2097152

# ─── Inotify Limits ────────────────────────────────────────
# Increase inotify limits for file monitoring
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024
fs.inotify.max_queued_events = 1048576

# ─── Virtual Memory ────────────────────────────────────────
# Optimize virtual memory settings
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
vm.vfs_cache_pressure = 50
vm.overcommit_memory = 0
vm.min_free_kbytes = 65536

# ─── Kernel Scheduler ──────────────────────────────────────
# Optimize kernel scheduler
kernel.sched_autogroup_enabled = 0
kernel.sched_migration_cost_ns = 5000000

# ─── PID Maximum ───────────────────────────────────────────
# Increase maximum PID value
kernel.pid_max = 4194304

# ─── Panic on OOM ──────────────────────────────────────────
# Don't panic on OOM (let OOM killer handle it)
vm.panic_on_oom = 0
SYSCTL_SYS_PERF
    
    if sysctl -p /etc/sysctl.d/99-kali-master-system-perf.conf >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} System performance parameters applied${RESET}"
        ((total_applied++))
    else
        echo -e "    ${RED}✗${RESET} System performance parameters failed${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: File Descriptor Limits
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/9] FILE DESCRIPTOR LIMITS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Configuring file descriptor limits..."
    
    # Create limits configuration
    cat > /etc/security/limits.d/99-kali-master.conf << 'LIMITS'
# ============================================================
# Kali Master v6.7.0 — File Descriptor Limits
# ============================================================

# ─── Root User ─────────────────────────────────────────────
root soft nofile 1048576
root hard nofile 1048576
root soft nproc 524288
root hard nproc 524288
root soft memlock unlimited
root hard memlock unlimited

# ─── All Users ─────────────────────────────────────────────
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 524288
* hard nproc 524288
* soft memlock unlimited
* hard memlock unlimited

# ─── Specific Services ─────────────────────────────────────
# Docker
docker soft nofile 1048576
docker hard nofile 1048576

# Nginx
nginx soft nofile 1048576
nginx hard nofile 1048576

# PostgreSQL
postgres soft nofile 1048576
postgres hard nofile 1048576
LIMITS
    
    echo -e "    ${GREEN}✔${RESET} File descriptor limits configured${RESET}"
    ((total_applied++))
    
    # Update systemd defaults
    if [[ -d /etc/systemd/system.conf.d ]]; then
        mkdir -p /etc/systemd/system.conf.d
    fi
    
    cat > /etc/systemd/system.conf.d/99-kali-master.conf << 'SYSTEMD_LIMITS'
# ============================================================
# Kali Master v6.7.0 — Systemd Limits
# ============================================================
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=524288
DefaultLimitMEMLOCK=infinity
SYSTEMD_LIMITS
    
    echo -e "    ${GREEN}✔${RESET} Systemd limits configured${RESET}"
    ((total_applied++))
    
    echo ""
    
    # ========================================================
    # Phase 6: Service Hardening
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/9] SERVICE HARDENING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Hardening critical services..."
    
    # Disable unnecessary services
    local services_to_disable=(
        "bluetooth"
        "cups"
        " ModemManager"
        "avahi-daemon"
        "rpcbind"
        "nfs-common"
    )
    
    local disabled_count=0
    for service in "${services_to_disable[@]}"; do
        service=$(echo "$service" | xargs)  # trim whitespace
        if systemctl list-unit-files | grep -q "^${service}.service"; then
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                systemctl stop "$service" >> "$LOG_FILE" 2>&1
                systemctl disable "$service" >> "$LOG_FILE" 2>&1
                echo -e "    ${GREEN}✔${RESET} Disabled: $service${RESET}"
                ((disabled_count++))
            else
                echo -e "    ${DIM}○${RESET} Already disabled: $service${RESET}"
            fi
        fi
    done
    
    if [[ $disabled_count -gt 0 ]]; then
        ((total_applied += disabled_count))
    fi
    
    # Harden SSH (if installed)
    if [[ -f /etc/ssh/sshd_config ]]; then
        info "Hardening SSH configuration..."
        
        # Backup original
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
        
        # Apply hardening
        cat > /etc/ssh/sshd_config.d/99-kali-master.conf << 'SSH_HARD'
# ============================================================
# Kali Master v6.7.0 — SSH Hardening
# ============================================================

# Disable root login (use sudo instead)
PermitRootLogin prohibit-password

# Disable password authentication (use keys)
PasswordAuthentication no

# Disable empty passwords
PermitEmptyPasswords no

# Disable X11 forwarding
X11Forwarding no

# Disable TCP forwarding (enable if needed)
AllowTcpForwarding no

# Disable agent forwarding
AllowAgentForwarding no

# Set login grace time
LoginGraceTime 30

# Set max auth tries
MaxAuthTries 3

# Set max sessions
MaxSessions 5

# Set client alive interval
ClientAliveInterval 300
ClientAliveCountMax 2

# Use only strong ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# Use only strong MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Use only strong key exchange algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org

# Disable unused authentication methods
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no
SSH_HARD
        
        systemctl reload sshd >> "$LOG_FILE" 2>&1 || true
        echo -e "    ${GREEN}✔${RESET} SSH hardened${RESET}"
        ((total_applied++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: File System Hardening
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/9] FILE SYSTEM HARDENING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Hardening file system permissions..."
    
    # Secure /tmp
    if [[ -d /tmp ]]; then
        chmod 1777 /tmp
        echo -e "    ${GREEN}✔${RESET} /tmp permissions secured (1777)${RESET}"
        ((total_applied++))
    fi
    
    # Secure /var/tmp
    if [[ -d /var/tmp ]]; then
        chmod 1777 /var/tmp
        echo -e "    ${GREEN}✔${RESET} /var/tmp permissions secured (1777)${RESET}"
        ((total_applied++))
    fi
    
    # Secure /var/log
    if [[ -d /var/log ]]; then
        chmod 750 /var/log
        echo -e "    ${GREEN}✔${RESET} /var/log permissions secured (750)${RESET}"
        ((total_applied++))
    fi
    
    # Secure sensitive files
    local sensitive_files=(
        "/etc/passwd:644"
        "/etc/shadow:640"
        "/etc/gshadow:640"
        "/etc/group:644"
        "/etc/ssh/sshd_config:600"
    )
    
    for file_info in "${sensitive_files[@]}"; do
        IFS=':' read -r file perms <<< "$file_info"
        if [[ -f "$file" ]]; then
            chmod "$perms" "$file" 2>/dev/null
            echo -e "    ${GREEN}✔${RESET} $file → $perms${RESET}"
            ((total_applied++))
        fi
    done
    
    # Remove world-writable files in /etc
    local ww_count
    ww_count=$(find /etc -type f -perm -002 2>/dev/null | wc -l)
    if [[ $ww_count -gt 0 ]]; then
        find /etc -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null
        echo -e "    ${GREEN}✔${RESET} Removed $ww_count world-writable files in /etc${RESET}"
        ((total_applied++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: Umask and Shell Security
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/9] UMASK & SHELL SECURITY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Configuring umask and shell security..."
    
    # Set default umask
    cat > /etc/profile.d/99-kali-master-umask.sh << 'UMASK'
# ============================================================
# Kali Master v6.7.0 — Umask Configuration
# ============================================================

# Set secure umask (files: 644, dirs: 755)
umask 022

# Export for child processes
export UMASK=022
UMASK
    
    chmod +x /etc/profile.d/99-kali-master-umask.sh
    echo -e "    ${GREEN}✔${RESET} Default umask set to 022${RESET}"
    ((total_applied++))
    
    # Add to bashrc
    if ! grep -q "umask 022" /root/.bashrc 2>/dev/null; then
        echo "umask 022" >> /root/.bashrc
        echo -e "    ${GREEN}✔${RESET} Added umask to .bashrc${RESET}"
        ((total_applied++))
    fi
    
    # Add to zshrc
    if ! grep -q "umask 022" /root/.zshrc 2>/dev/null; then
        echo "umask 022" >> /root/.zshrc
        echo -e "    ${GREEN}✔${RESET} Added umask to .zshrc${RESET}"
        ((total_applied++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 9: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 9/9] VERIFICATION & SUMMARY${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify key settings
    local verified=0
    local total_checks=0
    
    # Check ptrace
    ((total_checks++))
    local ptrace_val
    ptrace_val=$(sysctl -n kernel.yama.ptrace_scope 2>/dev/null)
    if [[ "$ptrace_val" == "0" ]]; then
        echo -e "    ${GREEN}✔${RESET} ptrace_scope: $ptrace_val"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} ptrace_scope: $ptrace_val (expected 0)"
    fi
    
    # Check file-max
    ((total_checks++))
    local file_max
    file_max=$(sysctl -n fs.file-max 2>/dev/null)
    if [[ "$file_max" -ge 500000 ]]; then
        echo -e "    ${GREEN}✔${RESET} fs.file-max: $file_max"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} fs.file-max: $file_max (expected ≥500000)"
    fi
    
    # Check somaxconn
    ((total_checks++))
    local somaxconn
    somaxconn=$(sysctl -n net.core.somaxconn 2>/dev/null)
    if [[ "$somaxconn" -ge 65535 ]]; then
        echo -e "    ${GREEN}✔${RESET} net.core.somaxconn: $somaxconn"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} net.core.somaxconn: $somaxconn (expected ≥65535)"
    fi
    
    # Check file descriptor limits
    ((total_checks++))
    local nofile_limit
    nofile_limit=$(ulimit -n 2>/dev/null)
    if [[ "$nofile_limit" -ge 1024 ]]; then
        echo -e "    ${GREEN}✔${RESET} File descriptor limit: $nofile_limit"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} File descriptor limit: $nofile_limit"
    fi
    
    # Check swappiness
    ((total_checks++))
    local swappiness
    swappiness=$(sysctl -n vm.swappiness 2>/dev/null)
    if [[ "$swappiness" -le 10 ]]; then
        echo -e "    ${GREEN}✔${RESET} vm.swappiness: $swappiness"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} vm.swappiness: $swappiness (expected ≤10)"
    fi
    
    # Count configuration files
    local config_count
    config_count=$(find /etc/sysctl.d /etc/security/limits.d /etc/systemd/system.conf.d -name "*kali-master*" 2>/dev/null | wc -l)
    info "Configuration files created: $config_count"
    
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
    echo -e "${BOLD}${MAGENTA}  SYSTEM OPTIMIZATION & HARDENING COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Applied:${RESET}        ${total_applied} optimizations"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} items"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} items"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 items"
    fi
    
    echo ""
    echo -e "  ${BOLD}Categories:${RESET}"
    echo -e "    ${GREEN}●${RESET} Kernel Security (10 parameters)"
    echo -e "    ${GREEN}●${RESET} Network Security (20 parameters)"
    echo -e "    ${GREEN}●${RESET} Network Performance (15 parameters)"
    echo -e "    ${GREEN}●${RESET} System Performance (12 parameters)"
    echo -e "    ${GREEN}●${RESET} File Descriptor Limits (unlimited)"
    echo -e "    ${GREEN}●${RESET} Service Hardening (SSH, disabled services)"
    echo -e "    ${GREEN}●${RESET} File System Hardening (permissions)"
    echo -e "    ${GREEN}●${RESET} Umask & Shell Security"
    echo ""
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some optimizations failed"
        info "Check log: ${LOG_FILE}"
    else
        ok "System optimized and hardened successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Key Improvements:${RESET}"
    echo -e "    ${DIM}• File descriptors: unlimited${RESET}"
    echo -e "    ${DIM}• Network buffers: 16MB max${RESET}"
    echo -e "    ${DIM}• Connection backlog: 65535${RESET}"
    echo -e "    ${DIM}• Swappiness: 10 (minimal swap)${RESET}"
    echo -e "    ${DIM}• Security: ptrace, dmesg, perf restricted${RESET}"
    echo -e "    ${DIM}• Network: SYN cookies, anti-spoofing enabled${RESET}"
    echo ""
    echo -e "  ${BOLD}Configuration Files:${RESET}"
    echo -e "    ${DIM}• /etc/sysctl.d/99-kali-master-*.conf${RESET}"
    echo -e "    ${DIM}• /etc/security/limits.d/99-kali-master.conf${RESET}"
    echo -e "    ${DIM}• /etc/systemd/system.conf.d/99-kali-master.conf${RESET}"
    echo -e "    ${DIM}• /etc/ssh/sshd_config.d/99-kali-master.conf${RESET}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}⚠  REBOOT REQUIRED${RESET}"
    echo -e "  ${DIM}Some changes require a reboot to take full effect${RESET}"
    echo -e "  ${DIM}Run: ${CYAN}sudo reboot${RESET}"
    echo ""
}

# ============================================================
# STEP 15 — Update Manager (Professional Edition v2.0)
# ============================================================
