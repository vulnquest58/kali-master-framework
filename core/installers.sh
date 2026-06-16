#!/usr/bin/env bash
# core/installers.sh

# ============================================================
# Install Missing Bug Bounty Tools
# ============================================================
install_missing_bb_tools() {
    info "Checking for missing Bug Bounty tools..."
    
    local missing_tools=(
        "findomain|go|github.com/findomain/findomain"
        "massdns|go|github.com/blechschmidt/massdns"
        "subbrute|git|https://github.com/TheRook/subbrute.git"
        "aquatone|go|github.com/michenriksen/aquatone"
        "gowitness|go|github.com/sensepost/gowitness"
        "kxss|go|github.com/Emoe/kxss"
        "paramspider|git|https://github.com/devanshbatham/ParamSpider.git"
        "jsfinder|git|https://github.com/Threezh1/JSFinder.git"
        "s3scanner|pip|s3scanner"
        "awsbucketdump|git|https://github.com/jordanpotti/AWSBucketDump.git"
        "gitdorker|git|https://github.com/obheda12/GitDorker.git"
        "kiterunner|go|github.com/assetnote/kiterunner/v2/cmd/kr"
    )
    
    for tool_info in "${missing_tools[@]}"; do
        IFS='|' read -r tool_name install_method install_source <<< "$tool_info"
        
        if ! command -v "$tool_name" &>/dev/null; then
            info "Installing $tool_name..."
            
            case "$install_method" in
                "go")
                    if go install "$install_source"@latest >> "$LOG_FILE" 2>&1; then
                        ok "$tool_name installed"
                    else
                        warn "$tool_name installation failed"
                    fi
                    ;;
                "git")
                    local tool_dir="/opt/tools/$tool_name"
                    if git clone --depth 1 "$install_source" "$tool_dir" >> "$LOG_FILE" 2>&1; then
                        if [[ -f "$tool_dir/requirements.txt" ]]; then
                            "${VENV_DIR}/bin/pip" install -r "$tool_dir/requirements.txt" --quiet >> "$LOG_FILE" 2>&1
                        fi
                        if [[ -f "$tool_dir/$tool_name.py" ]]; then
                            ln -sf "$tool_dir/$tool_name.py" "${LOCAL_BIN}/$tool_name" 2>/dev/null
                        fi
                        ok "$tool_name installed"
                    else
                        warn "$tool_name installation failed"
                    fi
                    ;;
                "pip")
                    if "${VENV_DIR}/bin/pip" install "$install_source" --quiet >> "$LOG_FILE" 2>&1; then
                        ok "$tool_name installed"
                    else
                        warn "$tool_name installation failed"
                    fi
                    ;;
            esac
        else
            ok "$tool_name already installed"
        fi
    done
}

# ============================================================
# Install Helpers (Multi-Tier Fallback)
# ============================================================
install_apt_tool() {
    local binary_name="$1"
    local apt_package="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    info "Installing ${apt_package} via apt..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$apt_package" >> "$LOG_FILE" 2>&1; then
        ok "${binary_name} — installed via apt"
    else
        fail "${binary_name} — apt failed"
        return 1
    fi
}

install_go_tool() {
    local tool_name="$1"
    local go_package="$2"
    local binary_name="${3:-$tool_name}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    info "Installing ${tool_name} via go install..."
    local proxies=("https://proxy.golang.org,direct" "https://goproxy.io,direct" "direct")
    for proxy in "${proxies[@]}"; do
        if GOPATH="$HOME/go" GOPROXY="$proxy" GONOSUMDB="*" go install "${go_package}@latest" >> "$LOG_FILE" 2>&1; then
            if [[ -x "$GOPATH_BIN/${binary_name}" ]]; then
                ln -sf "$GOPATH_BIN/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null
            fi
            ok "${binary_name} — installed (proxy=${proxy})"
            return 0
        fi
    done
    fail "${binary_name} — go install failed"
    return 1
}

install_cargo_tool() {
    local binary_name="$1"
    local crate_name="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    info "Installing ${crate_name} via cargo..."
    if cargo install "$crate_name" --quiet >> "$LOG_FILE" 2>&1; then
        if [[ -x "$CARGO_BIN/${binary_name}" ]]; then
            ln -sf "$CARGO_BIN/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null
        fi
        ok "${binary_name} — installed via cargo"
        return 0
    else
        fail "${binary_name} — cargo failed"
        return 1
    fi
}

install_venv_tool() {
    local tool_name="$1"
    local pip_package="${2:-$1}"
    local binary="${3:-$tool_name}"
    local venv="${4:-$VENV_DIR}"

    if [[ -x "${venv}/bin/${binary}" ]] || smart_find_tool "$binary" &>/dev/null; then
        ok "${binary} — found"
        return 0
    fi

    info "Installing ${pip_package} in venv (${venv})..."
    if "${venv}/bin/pip" install "$pip_package" --quiet >> "$LOG_FILE" 2>&1; then
        [[ -x "${venv}/bin/${binary}" ]] && make_wrapper "$binary" "${venv}/bin/${binary}"
        ok "${binary} — installed in venv"
        return 0
    else
        fail "${binary} — venv install failed"
        return 1
    fi
}

install_py_github_tool() {
    local cmd_name="$1"
    local pypi_name="$2"
    local github_url="$3"
    local script_name="${4:-auto}"

    smart_find_tool "$cmd_name" &>/dev/null && { ok "${cmd_name} — found"; return 0; }

    local tool_dir="${TOOLS_DIR}/github/${cmd_name}"

    # Method 1: pip install
    if [[ -n "$pypi_name" ]] && "${VENV_DIR}/bin/pip" install "$pypi_name" --quiet >> "$LOG_FILE" 2>&1; then
        if [[ -x "${VENV_DIR}/bin/${cmd_name}" ]]; then
            make_wrapper "$cmd_name" "${VENV_DIR}/bin/${cmd_name}"
            ok "${cmd_name} — installed via pip"
            return 0
        fi
    fi

    # Method 2: git clone
    info "${cmd_name}: cloning from GitHub..."
    if [[ -d "$tool_dir" ]]; then
        ( cd "$tool_dir" && git pull -q >> "$LOG_FILE" 2>&1 ) || true
    else
        mkdir -p "$(dirname "$tool_dir")"
        local clone_cmd="git clone -q --depth 1"
        if [[ -n "${GITHUB_TOKEN:-}" ]]; then
            local auth_url
            auth_url=$(echo "$github_url" | sed "s|https://|https://${GITHUB_TOKEN}@|")
            clone_cmd="$clone_cmd ${auth_url}"
        else
            clone_cmd="$clone_cmd ${github_url}"
        fi
        
        if ! eval "$clone_cmd" "$tool_dir" >> "$LOG_FILE" 2>&1; then
            fail "${cmd_name} — git clone failed"
            return 1
        fi
    fi

    [[ -f "${tool_dir}/requirements.txt" ]] && "${VENV_DIR}/bin/pip" install -r "${tool_dir}/requirements.txt" --quiet >> "$LOG_FILE" 2>&1 || true

    local main_script=""
    if [[ "$script_name" == "auto" ]]; then
        main_script=$(find "$tool_dir" -maxdepth 2 -name "*.py" -not -name "setup.py" -not -name "test*.py" -not -path "*/test*" 2>/dev/null | head -1)
    else
        main_script=$(find "$tool_dir" -maxdepth 3 -name "$script_name" 2>/dev/null | head -1)
    fi

    if [[ -z "$main_script" ]] || [[ ! -f "$main_script" ]]; then
        fail "${cmd_name} — could not find main script"
        return 1
    fi

    chmod +x "$main_script"
    make_venv_wrapper "$cmd_name" "$VENV_DIR" "$main_script"
    return 0
}

install_github_release() {
    local tool_name="$1"
    local releases_api="$2"
    local asset_pattern="$3"
    local binary_name="${4:-$tool_name}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    info "Installing ${tool_name} from GitHub releases..."
    local release_json="/tmp/${tool_name}_release.json"
    
    local curl_auth=""
    [[ -n "${GITHUB_TOKEN:-}" ]] && curl_auth="-H \"Authorization: token ${GITHUB_TOKEN}\""
    
    if ! eval "curl -fsSL ${curl_auth} --max-time 90 -o '${release_json}' '${releases_api}'" >> "$LOG_FILE" 2>&1; then
        warn "${tool_name} — could not fetch release info"
        return 1
    fi

    local asset_url
    asset_url=$(python3 -c "
import json, sys
try:
    data = json.load(open('${release_json}'))
    for a in data.get('assets', []):
        if '${asset_pattern}' in a.get('browser_download_url', ''):
            print(a['browser_download_url'])
            break
except: pass
" 2>/dev/null)

    [[ -z "$asset_url" ]] && { warn "${tool_name} — no matching asset"; return 1; }

    local ext="/tmp/${tool_name}.tar.gz"
    local extract_dir="/tmp/${tool_name}_extract"
    safe_curl "$asset_url" "$ext" || { warn "${tool_name} — download failed"; return 1; }

    rm -rf "$extract_dir"; mkdir -p "$extract_dir"
    tar -xzf "$ext" -C "$extract_dir" >> "$LOG_FILE" 2>&1
    rm -f "$ext"

    local found_bin
    found_bin=$(find "$extract_dir" -maxdepth 3 -type f -executable -iname "*${binary_name}*" 2>/dev/null | head -1)

    if [[ -n "$found_bin" ]]; then
        install -m 755 "$found_bin" "${LOCAL_BIN}/${binary_name}"
        ok "${binary_name} — installed from release"
        rm -rf "$extract_dir"
        return 0
    else
        warn "${tool_name} — binary not found in archive"
        rm -rf "$extract_dir"
        return 1
    fi
}
