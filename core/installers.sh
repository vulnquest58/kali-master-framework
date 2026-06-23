#!/usr/bin/env bash
# ============================================================
#  core/installers.sh — Kali Master Framework v7.0.0
#  Multi-tier install helpers: apt, go, cargo, pip, nim,
#  dotnet, npm, github release, direct URL
# ============================================================

# ============================================================
# APT installer with idempotency check
# ============================================================
install_apt_tool() {
    local binary_name="$1"
    local apt_package="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }
    dpkg -l "$apt_package" 2>/dev/null | grep -q "^ii" && { ok "${binary_name} — already installed via apt"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "apt install $apt_package"; return 0; }

    info "Installing ${apt_package} via apt..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing "$apt_package" >> "$LOG_FILE" 2>&1; then
        ok "${binary_name} — installed via apt"
    else
        fail "${binary_name} — apt install failed"
        return 1
    fi
}

# ============================================================
# Go tool installer with multi-proxy fallback
# ============================================================
install_go_tool() {
    local tool_name="$1"
    local go_package="$2"
    local binary_name="${3:-$tool_name}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "go install ${go_package}@latest"; return 0; }

    # Ensure go is available
    local go_bin="/usr/local/go/bin/go"
    [[ -x "$go_bin" ]] || go_bin=$(command -v go 2>/dev/null || echo "")
    if [[ -z "$go_bin" ]]; then
        fail "Go not installed — cannot install ${tool_name}"
        return 1
    fi

    info "Installing ${tool_name} via go install..."
    local proxies=(
        "https://proxy.golang.org,direct"
        "https://goproxy.io,direct"
        "direct"
    )

    for proxy in "${proxies[@]}"; do
        if GOPATH="$HOME/go" GOPROXY="$proxy" GONOSUMDB="*" GO111MODULE="on" \
           "$go_bin" install "${go_package}@latest" >> "$LOG_FILE" 2>&1; then
            if [[ -x "$GOPATH_BIN/${binary_name}" ]]; then
                ln -sf "$GOPATH_BIN/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null || true
            fi
            ok "${binary_name} — installed (proxy=${proxy})"
            return 0
        fi
    done

    fail "${binary_name} — go install failed (all proxies exhausted)"
    return 1
}

# ============================================================
# Cargo/Rust tool installer
# ============================================================
install_cargo_tool() {
    local binary_name="$1"
    local crate_name="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "cargo install $crate_name"; return 0; }

    if ! command -v cargo &>/dev/null; then
        fail "Cargo not installed — cannot install ${binary_name}"
        return 1
    fi

    info "Installing ${crate_name} via cargo..."
    if cargo install "$crate_name" --quiet >> "$LOG_FILE" 2>&1; then
        [[ -x "$CARGO_BIN/${binary_name}" ]] && \
            ln -sf "$CARGO_BIN/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null || true
        ok "${binary_name} — installed via cargo"
    else
        fail "${binary_name} — cargo install failed"
        return 1
    fi
}

# ============================================================
# Python venv tool installer
# ============================================================
install_venv_tool() {
    local tool_name="$1"
    local pip_package="${2:-$1}"
    local binary="${3:-$tool_name}"
    local venv="${4:-$VENV_DIR}"

    if [[ -x "${venv}/bin/${binary}" ]] || smart_find_tool "$binary" &>/dev/null; then
        ok "${binary} — found"
        return 0
    fi

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "pip install $pip_package in $venv"; return 0; }

    if [[ ! -f "${venv}/bin/pip" ]]; then
        fail "Venv not initialized: $venv — run python_venv step first"
        return 1
    fi

    info "Installing ${pip_package} in venv ($(basename "$venv"))..."
    if "${venv}/bin/pip" install "$pip_package" --quiet >> "$LOG_FILE" 2>&1; then
        [[ -x "${venv}/bin/${binary}" ]] && make_wrapper "$binary" "${venv}/bin/${binary}"
        ok "${binary} — installed in venv"
    else
        fail "${binary} — venv pip install failed"
        return 1
    fi
}

# ============================================================
# Python tool from GitHub (pip first, then git clone fallback)
# ============================================================
install_py_github_tool() {
    local cmd_name="$1"
    local pypi_name="$2"
    local github_url="$3"
    local script_name="${4:-auto}"

    smart_find_tool "$cmd_name" &>/dev/null && { ok "${cmd_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "install_py_github_tool $cmd_name"; return 0; }

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
    git_clone "$github_url" "$tool_dir" 1 0 || return 1

    [[ -f "${tool_dir}/requirements.txt" ]] && \
        "${VENV_DIR}/bin/pip" install -r "${tool_dir}/requirements.txt" --quiet >> "$LOG_FILE" 2>&1 || true

    local main_script=""
    if [[ "$script_name" == "auto" ]]; then
        main_script=$(find "$tool_dir" -maxdepth 2 -name "*.py" \
            ! -name "setup.py" ! -name "test*.py" ! -path "*/test*" 2>/dev/null | head -1)
    else
        main_script=$(find "$tool_dir" -maxdepth 3 -name "$script_name" 2>/dev/null | head -1)
    fi

    if [[ -z "$main_script" ]] || [[ ! -f "$main_script" ]]; then
        fail "${cmd_name} — could not locate main script"
        return 1
    fi

    chmod +x "$main_script"
    make_venv_wrapper "$cmd_name" "$VENV_DIR" "$main_script"
    return 0
}

# ============================================================
# GitHub Release installer (tar.gz and zip)
# ============================================================
install_github_release() {
    local tool_name="$1"
    local releases_api="$2"
    local asset_pattern="$3"
    local binary_name="${4:-$tool_name}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "install_github_release $tool_name"; return 0; }

    info "Fetching ${tool_name} release info..."
    local release_json="/tmp/${tool_name}_release.json"

    if ! github_api "$releases_api" > "$release_json" 2>/dev/null || [[ ! -s "$release_json" ]]; then
        warn "${tool_name} — could not fetch release info"
        return 1
    fi

    local asset_url
    asset_url=$(python3 -c "
import json, sys
try:
    data = json.load(open('${release_json}'))
    assets = data.get('assets', [])
    for a in assets:
        url = a.get('browser_download_url', '')
        if '${asset_pattern}' in url:
            print(url)
            break
except Exception as e:
    pass
" 2>/dev/null)

    rm -f "$release_json"
    [[ -z "$asset_url" ]] && { warn "${tool_name} — no matching asset for pattern '${asset_pattern}'"; return 1; }

    local ext="/tmp/${tool_name}_download"
    local extract_dir="/tmp/${tool_name}_extract"

    safe_curl "$asset_url" "$ext" || { warn "${tool_name} — download failed"; return 1; }

    rm -rf "$extract_dir"; mkdir -p "$extract_dir"

    # Support both tar.gz and zip
    if file "$ext" | grep -q "gzip\|tar"; then
        tar -xzf "$ext" -C "$extract_dir" >> "$LOG_FILE" 2>&1
    elif file "$ext" | grep -q "Zip\|zip"; then
        unzip -q "$ext" -d "$extract_dir" >> "$LOG_FILE" 2>&1
    else
        fail "${tool_name} — unknown archive format"
        rm -f "$ext" && rm -rf "$extract_dir"
        return 1
    fi
    rm -f "$ext"

    local found_bin
    found_bin=$(find "$extract_dir" -maxdepth 4 -type f -executable -iname "*${binary_name}*" 2>/dev/null | head -1)
    # Also search for exact binary name
    [[ -z "$found_bin" ]] && found_bin=$(find "$extract_dir" -maxdepth 4 -type f -executable -name "$binary_name" 2>/dev/null | head -1)

    if [[ -n "$found_bin" ]]; then
        install -m 755 "$found_bin" "${LOCAL_BIN}/${binary_name}"
        ok "${binary_name} — installed from GitHub release"
        rm -rf "$extract_dir"
        return 0
    else
        warn "${tool_name} — binary not found in archive"
        rm -rf "$extract_dir"
        return 1
    fi
}

# ============================================================
# Nim tool installer
# ============================================================
install_nim_tool() {
    local tool_name="$1"
    local nimble_pkg="${2:-$tool_name}"
    local binary_name="${3:-$tool_name}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "nimble install $nimble_pkg"; return 0; }

    if ! command -v nimble &>/dev/null; then
        warn "nimble not installed — cannot install ${tool_name}"
        return 1
    fi

    info "Installing ${nimble_pkg} via nimble..."
    if nimble install "$nimble_pkg" -y >> "$LOG_FILE" 2>&1; then
        [[ -x "${NIMBLE_BIN}/${binary_name}" ]] && \
            ln -sf "${NIMBLE_BIN}/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null || true
        ok "${binary_name} — installed via nimble"
    else
        fail "${binary_name} — nimble install failed"
        return 1
    fi
}

# ============================================================
# .NET tool installer
# ============================================================
install_dotnet_tool() {
    local binary_name="$1"
    local package_name="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "dotnet tool install $package_name"; return 0; }

    if ! command -v dotnet &>/dev/null; then
        warn "dotnet not installed — cannot install ${binary_name}"
        return 1
    fi

    info "Installing ${package_name} via dotnet tool..."
    if dotnet tool install -g "$package_name" >> "$LOG_FILE" 2>&1; then
        [[ -x "${DOTNET_BIN}/${binary_name}" ]] && \
            ln -sf "${DOTNET_BIN}/${binary_name}" "${LOCAL_BIN}/${binary_name}" 2>/dev/null || true
        ok "${binary_name} — installed via dotnet tool"
    else
        fail "${binary_name} — dotnet tool install failed"
        return 1
    fi
}

# ============================================================
# NPM global tool installer
# ============================================================
install_npm_tool() {
    local binary_name="$1"
    local npm_package="${2:-$1}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "npm install -g $npm_package"; return 0; }

    if ! command -v npm &>/dev/null; then
        warn "npm not installed — cannot install ${binary_name}"
        return 1
    fi

    info "Installing ${npm_package} via npm..."
    if npm install -g "$npm_package" >> "$LOG_FILE" 2>&1; then
        ok "${binary_name} — installed via npm"
    else
        fail "${binary_name} — npm install failed"
        return 1
    fi
}

# ============================================================
# Direct URL binary installer
# ============================================================
install_from_url() {
    local binary_name="$1"
    local url="$2"
    local expected_sha256="${3:-}"

    smart_find_tool "$binary_name" &>/dev/null && { ok "${binary_name} — found"; return 0; }

    [[ "${DRY_RUN:-0}" == "1" ]] && { dryrun "install_from_url $binary_name $url"; return 0; }

    local tmp_file="/tmp/${binary_name}_download"
    info "Downloading ${binary_name} from URL..."

    download_verified "$url" "$tmp_file" "$expected_sha256" || return 1

    install -m 755 "$tmp_file" "${LOCAL_BIN}/${binary_name}"
    rm -f "$tmp_file"
    ok "${binary_name} — installed from URL"
}

# ============================================================
# Install Missing Bug Bounty Tools (from custom config)
# ============================================================
install_missing_bb_tools() {
    info "Checking for missing Bug Bounty tools..."

    local missing_tools=(
        "findomain|go|github.com/findomain/findomain"
        "aquatone|go|github.com/michenriksen/aquatone"
        "gowitness|go|github.com/sensepost/gowitness/v2"
        "kxss|go|github.com/Emoe/kxss"
        "kiterunner|go|github.com/assetnote/kiterunner/v2/cmd/kr"
        "s3scanner|pip|s3scanner"
    )

    for tool_info in "${missing_tools[@]}"; do
        IFS='|' read -r tool_name install_method install_source <<< "$tool_info"

        if smart_find_tool "$tool_name" &>/dev/null; then
            skip "$tool_name — already installed"
            continue
        fi

        case "$install_method" in
            go)   install_go_tool "$tool_name" "$install_source" ;;
            pip)  install_venv_tool "$tool_name" "$install_source" ;;
            git)  git_clone "$install_source" "${TOOLS_DIR}/${tool_name}" 1 0 ;;
        esac
    done
}
