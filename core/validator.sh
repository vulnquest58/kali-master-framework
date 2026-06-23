#!/usr/bin/env bash
# ============================================================
#  core/validator.sh — Kali Master Framework v7.0.0
#  Pre-install validation: conflicts, versions, disk space
# ============================================================

# ============================================================
# Check minimum disk space for a step (in GB)
# ============================================================
check_disk_space() {
    local required_gb="${1:-5}"
    local label="${2:-step}"
    local free_gb
    free_gb=$(df -BG / 2>/dev/null | awk 'NR==2{gsub("G",""); print $4}')

    if [[ "${free_gb:-0}" -lt "$required_gb" ]]; then
        warn "Disk space check for [$label]: ${free_gb}GB free, ${required_gb}GB required"
        if [[ "${free_gb:-0}" -lt 2 ]]; then
            fail "Critically low disk space — cannot proceed with $label"
            return 1
        fi
    else
        debug "Disk OK for [$label]: ${free_gb}GB free (need ${required_gb}GB)"
    fi
    return 0
}

# ============================================================
# Check for conflicting packages before install
# ============================================================
check_conflicts() {
    local package="$1"
    shift
    local conflicts=("$@")

    for conflict in "${conflicts[@]}"; do
        if dpkg -l "$conflict" 2>/dev/null | grep -q "^ii"; then
            warn "Conflict detected: $package conflicts with installed $conflict"
            return 1
        fi
    done
    return 0
}

# ============================================================
# Validate Go is installed and meets minimum version
# ============================================================
validate_go() {
    local min_version="${1:-1.21}"
    if ! command -v go &>/dev/null && ! [[ -x "/usr/local/go/bin/go" ]]; then
        fail "Go is not installed — required for this step"
        return 1
    fi

    local go_bin
    go_bin=$(command -v go 2>/dev/null || echo "/usr/local/go/bin/go")
    local go_ver
    go_ver=$("$go_bin" version 2>/dev/null | awk '{print $3}' | sed 's/go//')

    if [[ -z "$go_ver" ]]; then
        warn "Cannot determine Go version"
        return 0
    fi

    # Compare major.minor
    local min_major min_minor cur_major cur_minor
    IFS='.' read -r min_major min_minor _ <<< "$min_version"
    IFS='.' read -r cur_major cur_minor _ <<< "$go_ver"

    if [[ "$cur_major" -lt "$min_major" ]] || \
       [[ "$cur_major" -eq "$min_major" && "$cur_minor" -lt "$min_minor" ]]; then
        warn "Go version $go_ver is below minimum $min_version"
        return 1
    fi

    debug "Go version OK: $go_ver >= $min_version"
    return 0
}

# ============================================================
# Validate Python venv exists and has key packages
# ============================================================
validate_venv() {
    local venv="${1:-$VENV_DIR}"
    local required_pkg="${2:-pip}"

    if [[ ! -f "${venv}/bin/python3" ]]; then
        fail "Python venv not found at: $venv"
        return 1
    fi

    if ! "${venv}/bin/pip" show "$required_pkg" &>/dev/null; then
        warn "Package '$required_pkg' not found in venv $venv"
        return 1
    fi

    debug "Venv OK: $venv (has $required_pkg)"
    return 0
}

# ============================================================
# Pre-install checker for a module
# Usage: pre_install_check "module_name" required_gb tool1 tool2 ...
# ============================================================
pre_install_check() {
    local module_name="$1"
    local required_gb="${2:-5}"
    shift 2
    local required_tools=("$@")

    debug "Pre-install check for: $module_name"

    # Check disk space
    check_disk_space "$required_gb" "$module_name" || return 1

    # Check required tools
    local missing=()
    for tool in "${required_tools[@]}"; do
        smart_find_tool "$tool" &>/dev/null || missing+=("$tool")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "Missing prerequisites for $module_name: ${missing[*]}"
        return 1
    fi

    return 0
}

# ============================================================
# Post-install verifier — check a list of tools installed correctly
# Usage: post_install_verify tool1 tool2 ...
# Returns: number of failed tools
# ============================================================
post_install_verify() {
    local tools=("$@")
    local ok_count=0
    local fail_count=0

    echo ""
    echo -e "  ${BOLD}${CYAN}[POST-INSTALL VERIFICATION]${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"

    for tool in "${tools[@]}"; do
        if smart_find_tool "$tool" &>/dev/null; then
            local ver
            ver=$(get_tool_version "$tool" 2>/dev/null || echo "")
            echo -e "    ${GREEN}✔${RESET} $tool${ver:+ ${DIM}(v$ver)${RESET}}"
            ((ok_count++))
        else
            echo -e "    ${RED}✗${RESET} $tool ${DIM}[NOT FOUND]${RESET}"
            ((fail_count++))
        fi
    done

    echo ""
    if [[ $fail_count -eq 0 ]]; then
        ok "All ${ok_count} tools verified successfully"
    else
        warn "Verification: ${ok_count} OK, ${fail_count} failed"
    fi

    return "$fail_count"
}

# ============================================================
# System kernel compatibility check
# ============================================================
check_kernel_features() {
    local kernel_ver
    kernel_ver=$(uname -r | cut -d. -f1,2)
    local major minor
    IFS='.' read -r major minor <<< "$kernel_ver"

    debug "Kernel version: $kernel_ver"

    # Check eBPF support (kernel >= 4.4)
    if [[ "$major" -gt 4 ]] || [[ "$major" -eq 4 && "${minor:-0}" -ge 4 ]]; then
        debug "eBPF supported (kernel $kernel_ver)"
    else
        warn "Kernel $kernel_ver may not support eBPF features"
    fi

    # Check if running in container
    if [[ -f /.dockerenv ]] || grep -q "docker\|lxc\|containerd" /proc/1/cgroup 2>/dev/null; then
        warn "Running in container — some features (iptables, sysctl) may be restricted"
    fi
}

# ============================================================
# Validate APT sources are healthy
# ============================================================
validate_apt_sources() {
    info "Validating APT sources..."

    # Check if Kali sources exist
    if grep -r "kali" /etc/apt/sources.list /etc/apt/sources.list.d/ &>/dev/null 2>&1; then
        ok "Kali APT sources found"
    else
        warn "Kali APT sources not found — some tools may not be available"
    fi

    # Check for broken sources (files with errors)
    local broken=0
    for src_file in /etc/apt/sources.list.d/*.list; do
        [[ -f "$src_file" ]] || continue
        if grep -qP "^\s*deb\s" "$src_file" 2>/dev/null; then
            debug "APT source OK: $src_file"
        else
            warn "Possibly invalid APT source: $src_file"
            ((broken++))
        fi
    done

    [[ $broken -eq 0 ]] && ok "All APT sources appear valid" || warn "$broken potentially broken APT source(s)"
}
