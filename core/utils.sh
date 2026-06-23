#!/usr/bin/env bash
# ============================================================
#  core/utils.sh — Kali Master Framework v7.0.0
#  Utility functions: tool finder, wrappers, network, checksums
# ============================================================

# ============================================================
# Smart Tool Finder — Enhanced with all ecosystems
# ============================================================
smart_find_tool() {
    local tool="$1"

    # 1. Exact match in PATH
    command -v "$tool" &>/dev/null && { command -v "$tool"; return 0; }

    # 2. Search in all known paths (case-insensitive)
    for search_path in "${SEARCH_PATHS[@]}"; do
        [[ -d "$search_path" ]] || continue
        [[ -x "${search_path}/${tool}" ]] && { echo "${search_path}/${tool}"; return 0; }
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

    # 4. Search in all Python venvs
    for venv_base in "$VENV_DIR" "$ANGR_VENV" "$FLARE_VENV" "$SCOUTSUITE_VENV" "$PROWLER_VENV"; do
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

    # 6. Search in Nim packages
    if [[ -d "$NIMBLE_BIN" ]]; then
        [[ -x "${NIMBLE_BIN}/${tool}" ]] && { echo "${NIMBLE_BIN}/${tool}"; return 0; }
    fi

    # 7. Search in dotnet tools
    if [[ -d "$DOTNET_BIN" ]]; then
        [[ -x "${DOTNET_BIN}/${tool}" ]] && { echo "${DOTNET_BIN}/${tool}"; return 0; }
    fi

    return 1
}

# ============================================================
# Check tool version (returns version string)
# ============================================================
get_tool_version() {
    local tool="$1"
    command -v "$tool" &>/dev/null || return 1
    # Try common version flags
    for flag in "--version" "-version" "-v" "version"; do
        local ver
        ver=$("$tool" "$flag" 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
        if [[ -n "$ver" ]]; then
            echo "$ver"
            return 0
        fi
    done
    echo "unknown"
}

# ============================================================
# Require tool or abort
# ============================================================
require_ok() {
    local tool="$1"
    if ! smart_find_tool "$tool" &>/dev/null; then
        fail "Critical tool missing: ${BOLD}$tool${RESET} — aborting."
        exit 1
    fi
}

# ============================================================
# Network Helpers (with progress and authentication)
# ============================================================
safe_curl() {
    local url="$1" out="$2"
    local attempts="${MAX_RETRIES:-3}" delay="${RETRY_DELAY:-5}"
    local auth_header=""
    [[ -n "${GITHUB_TOKEN:-}" && "$url" == *"api.github.com"* ]] && \
        auth_header="-H \"Authorization: token ${GITHUB_TOKEN}\""

    for i in $(seq 1 "$attempts"); do
        if eval curl -fsSL --max-time "${HTTP_TIMEOUT:-90}" --retry 3 --retry-delay 3 \
               --retry-all-errors "$auth_header" -o "\"$out\"" "\"$url\"" >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        warn "curl attempt $i/$attempts failed for $url — retrying in ${delay}s"
        sleep "$delay"
    done
    return 1
}

safe_wget() {
    local url="$1" out="$2"
    wget -q --timeout="${HTTP_TIMEOUT:-90}" --tries="${MAX_RETRIES:-3}" --waitretry="${RETRY_DELAY:-5}" \
        -O "$out" "$url" >> "$LOG_FILE" 2>&1
}

# Download with SHA256 verification
download_verified() {
    local url="$1"
    local out="$2"
    local expected_sha256="${3:-}"

    if ! safe_curl "$url" "$out" && ! safe_wget "$url" "$out"; then
        fail "Download failed: $url"
        return 1
    fi

    if [[ -n "$expected_sha256" ]]; then
        local actual_sha256
        actual_sha256=$(sha256sum "$out" 2>/dev/null | awk '{print $1}')
        if [[ "$actual_sha256" != "$expected_sha256" ]]; then
            fail "SHA256 mismatch for $out"
            fail "  Expected: $expected_sha256"
            fail "  Got:      $actual_sha256"
            rm -f "$out"
            return 1
        fi
        ok "SHA256 verified: $out"
    fi
    return 0
}

# GitHub API helper with token support
github_api() {
    local api_url="$1"
    local auth_header=""
    [[ -n "${GITHUB_TOKEN:-}" ]] && auth_header="-H \"Authorization: token ${GITHUB_TOKEN}\""
    eval curl -fsSL --max-time 30 "$auth_header" "\"$api_url\"" 2>/dev/null
}

# Get latest release tag from GitHub
github_latest_release() {
    local repo="$1"  # e.g. "projectdiscovery/nuclei"
    github_api "https://api.github.com/repos/${repo}/releases/latest" | \
        python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tag_name',''))" 2>/dev/null
}

# ============================================================
# Wrapper + PATH Helpers
# ============================================================
make_wrapper() {
    local tool_name="$1"
    local tool_real_path="$2"
    local wrapper="${WRAPPERS_DIR}/${tool_name}"

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "make_wrapper $tool_name -> $tool_real_path"; return 0; }
    [[ "$(dirname "$tool_real_path")" == "$WRAPPERS_DIR" ]] && return 0
    [[ -L "$wrapper" ]] && [[ "$(readlink -f "$wrapper")" == "$(readlink -f "$tool_real_path")" ]] && return 0

    cat > "$wrapper" << WRAPPER
#!/usr/bin/env bash
exec "${tool_real_path}" "\$@"
WRAPPER
    chmod +x "$wrapper"
    debug "Wrapper: $wrapper -> $tool_real_path"
}

make_venv_wrapper() {
    local cmd_name="$1"
    local venv_dir="$2"
    local script_path="$3"

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "make_venv_wrapper $cmd_name"; return 0; }

    cat > "${WRAPPERS_DIR}/${cmd_name}" << WRAPPER
#!/usr/bin/env bash
source "${venv_dir}/bin/activate"
exec python3 "${script_path}" "\$@"
WRAPPER
    chmod +x "${WRAPPERS_DIR}/${cmd_name}"
    ok "${cmd_name} wrapper -> ${script_path}"
}

make_cd_wrapper() {
    local cmd_name="$1"
    local work_dir="$2"
    local exec_cmd="$3"

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "make_cd_wrapper $cmd_name"; return 0; }

    cat > "${WRAPPERS_DIR}/${cmd_name}" << WRAPPER
#!/usr/bin/env bash
cd "${work_dir}" || exit 1
exec ${exec_cmd} "\$@"
WRAPPER
    chmod +x "${WRAPPERS_DIR}/${cmd_name}"
    ok "${cmd_name} wrapper -> cd ${work_dir} && ${exec_cmd}"
}

# ============================================================
# Verification Helpers
# ============================================================
verify_tool() {
    local tool_name="$1"
    local min_version="${2:-}"

    if ! smart_find_tool "$tool_name" &>/dev/null; then
        fail "Tool not found: $tool_name"
        return 1
    fi

    local ver
    ver=$(get_tool_version "$tool_name")
    ok "Verified: $tool_name${ver:+ (v$ver)}"
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
        return 1
    fi
}

# ============================================================
# Parallel Install Helper (max $PARALLEL_JOBS concurrent)
# ============================================================
parallel_install() {
    local install_func="$1"
    shift
    local items=("$@")
    local pids=()
    local max_jobs="${PARALLEL_JOBS:-4}"
    local failed=0

    for item in "${items[@]}"; do
        # Wait if too many jobs running
        while [[ ${#pids[@]} -ge $max_jobs ]]; do
            local new_pids=()
            for pid in "${pids[@]}"; do
                if kill -0 "$pid" 2>/dev/null; then
                    new_pids+=("$pid")
                else
                    wait "$pid" 2>/dev/null || ((failed++))
                fi
            done
            pids=("${new_pids[@]}")
            sleep 0.5
        done

        # Launch background job
        (
            eval "$install_func" "$item" >> "$LOG_FILE" 2>&1
        ) &
        pids+=("$!")
    done

    # Wait for remaining jobs
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || ((failed++))
    done

    return "$failed"
}

# ============================================================
# Load custom tools from tools.conf
# ============================================================
load_custom_tools() {
    local conf="${SCRIPT_DIR}/config/tools.conf"
    [[ -f "$conf" ]] || return 0

    debug "Loading custom tools from $conf"
    local section=""

    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// /}" ]] && continue

        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            section="${BASH_REMATCH[1]}"
            continue
        fi

        IFS='|' read -r tool_name method source <<< "$line"
        [[ -z "$tool_name" ]] && continue

        debug "Custom tool: $tool_name via $method from $source"
        # Queue for installation (processed by the relevant module)
        CUSTOM_TOOLS+=("${section}|${tool_name}|${method}|${source}")
    done < "$conf"
}

# Global array for custom tools
declare -a CUSTOM_TOOLS=()
