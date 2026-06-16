#!/usr/bin/env bash
# core/utils.sh

# ============================================================
# Smart Tool Finder — Enhanced with Case-Insensitive Search
# ============================================================
smart_find_tool() {
    local tool="$1"
    
    # 1. Exact match in PATH
    command -v "$tool" &>/dev/null && { command -v "$tool"; return 0; }
    
    # 2. Search in all known paths (case-insensitive)
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        
        # Exact match
        [[ -x "${search_path}/${tool}" ]] && { echo "${search_path}/${tool}"; return 0; }
        
        # Case-insensitive match
        local found
        found=$(find "$search_path" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
        [[ -n "$found" ]] && { echo "$found"; return 0; }
    done
    
    # 3. Deep search in tools directory
    if [[ -d "$TOOLS_DIR" ]]; then
        local found
        found=$(find "$TOOLS_DIR" -maxdepth 5 -type f -executable -iname "$tool" 2>/dev/null | head -1)
        [[ -n "$found" ]] && { echo "$found"; return 0; }
    fi
    
    # 4. Search in Python venvs
    for venv_base in "$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV" "/opt/scoutsuite-venv"; do
        [[ -d "${venv_base}/bin" ]] || continue
        local found
        found=$(find "${venv_base}/bin" -maxdepth 1 -type f -executable -iname "$tool" 2>/dev/null | head -1)
        [[ -n "$found" ]] && { echo "$found"; return 0; }
    done
    
    # 5. Search in pipx venvs
    if [[ -d "$HOME/.local/share/pipx/venvs" ]]; then
        local found
        found=$(find "$HOME/.local/share/pipx/venvs" -maxdepth 3 -type f -executable -iname "$tool" 2>/dev/null | head -1)
        [[ -n "$found" ]] && { echo "$found"; return 0; }
    fi
    
    return 1
}

require_ok() {
    local tool="$1"
    if ! smart_find_tool "$tool" &>/dev/null; then
        fail "Critical tool missing: ${BOLD}$tool${RESET} — aborting."
        exit 1
    fi
}

# ============================================================
# Network Helpers
# ============================================================
safe_curl() {
    local url="$1" out="$2"
    local attempts=3 delay=5
    for i in $(seq 1 $attempts); do
        if curl -fsSL --max-time 90 --retry 3 --retry-delay 3 \
               --retry-all-errors -o "$out" "$url" >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        warn "curl attempt $i/$attempts failed for $url — retrying in ${delay}s"
        sleep "$delay"
    done
    return 1
}

safe_wget() {
    local url="$1" out="$2"
    wget -q --timeout=90 --tries=3 --waitretry=5 -O "$out" "$url" >> "$LOG_FILE" 2>&1
}

# ============================================================
# Wrapper + PATH Helpers
# ============================================================
make_wrapper() {
    local tool_name="$1"
    local tool_real_path="$2"
    local wrapper="${WRAPPERS_DIR}/${tool_name}"

    [[ "$(dirname "$tool_real_path")" == "$WRAPPERS_DIR" ]] && return 0
    [[ -L "$wrapper" ]] && [[ "$(readlink -f "$wrapper")" == "$(readlink -f "$tool_real_path")" ]] && return 0

    cat > "$wrapper" << WRAPPER
#!/usr/bin/env bash
exec "${tool_real_path}" "\$@"
WRAPPER
    chmod +x "$wrapper"
    log "Wrapper: $wrapper -> $tool_real_path"
}

make_venv_wrapper() {
    local cmd_name="$1"
    local venv_dir="$2"
    local script_path="$3"

    cat > "${WRAPPERS_DIR}/${cmd_name}" << WRAPPER
#!/usr/bin/env bash
source "${venv_dir}/bin/activate"
exec python3 "${script_path}" "\$@"
WRAPPER
    chmod +x "${WRAPPERS_DIR}/${cmd_name}"
    ok "${cmd_name} wrapper -> ${script_path}"
}

# ============================================================
#  PROFESSIONAL VERIFICATION ENGINE
# ============================================================
verify_tool() {
    local tool_name="$1"
    local min_version="${2:-}"
    
    if ! command -v "$tool_name" &>/dev/null; then
        fail "Tool not found: $tool_name"
        return 1
    fi
    
    if ! "$tool_name" --version &>/dev/null && ! "$tool_name" -v &>/dev/null && ! "$tool_name" -h &>/dev/null; then
        warn "Tool $tool_name exists but does not respond to basic version/help commands (may be broken)"
        return 1
    fi
    
    if [[ -n "$min_version" ]]; then
        local current_ver
        current_ver=$("$tool_name" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
        if [[ -z "$current_ver" ]]; then
            warn "Could not verify min version ($min_version) for $tool_name"
        fi
    fi
    
    ok "Verified tool: $tool_name ✓"
    return 0
}

verify_config() {
    local config_file="$1"
    local expected_pattern="$2"
    local description="$3"
    
    if [[ ! -f "$config_file" ]]; then
        fail "Config file missing: $config_file"
        return 1
    fi
    
    if grep -qE "$expected_pattern" "$config_file" 2>/dev/null; then
        ok "Verified config: $description"
        return 0
    else
        warn "Verification failed: required pattern not found in $config_file"
        echo -e "    ${DIM}Expected pattern: $expected_pattern${RESET}"
        return 1
    fi
}

pre_flight_check() {
    local step_name="$1"
    shift
    local checks=("$@")
    
    echo -e "${BOLD}${CYAN}[*]${RESET} Pre-flight verification for: ${BOLD}$step_name${RESET}"
    local all_passed=true
    
    for check_cmd in "${checks[@]}"; do
        if ! eval "$check_cmd"; then
            all_passed=false
            break
        fi
    done
    
    if [[ "$all_passed" == "true" ]]; then
        ok "All requirements for step '$step_name' are satisfied. Skipping (Idempotent)."
        state_done "$step_name"
        return 0
    else
        warn "Some requirements are missing. Running setup/installation logic..."
        return 1
    fi
}
