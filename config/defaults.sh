#!/usr/bin/env bash
# ============================================================
#  config/defaults.sh — Kali Master Framework v7.0.0
#  Default values — override via environment or .env file
# ============================================================

# ─── Load .env if exists ─────────────────────────────────────
_load_dotenv() {
    local env_file="${SCRIPT_DIR}/.env"
    if [[ -f "$env_file" ]]; then
        # Safely source .env (only KEY=VALUE lines, no subshells)
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            # Only export simple string values (no eval)
            key="${key// /}"
            value="${value%\"}"
            value="${value#\"}"
            value="${value%\'}"
            value="${value#\'}"
            # Only set if not already defined
            [[ -z "${!key:-}" ]] && export "$key"="$value"
        done < "$env_file"
    fi
}

_load_dotenv

# ─── Network Defaults ────────────────────────────────────────
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
HTTP_TIMEOUT="${HTTP_TIMEOUT:-90}"
MAX_RETRIES="${MAX_RETRIES:-3}"
RETRY_DELAY="${RETRY_DELAY:-5}"

# ─── Go Defaults ─────────────────────────────────────────────
GO_FALLBACK_VERSION="${GO_FALLBACK_VERSION:-1.24.2}"
GOPROXY="${GOPROXY:-https://proxy.golang.org,https://goproxy.io,direct}"

# ─── Python Defaults ─────────────────────────────────────────
PIP_NO_CACHE_DIR="${PIP_NO_CACHE_DIR:-0}"
PIP_EXTRA_INDEX_URL="${PIP_EXTRA_INDEX_URL:-}"

# ─── Installation Defaults ───────────────────────────────────
BATCH_SIZE="${BATCH_SIZE:-15}"
PARALLEL_JOBS="${PARALLEL_JOBS:-4}"

# ─── Mode Defaults ───────────────────────────────────────────
MINIMAL_MODE="${MINIMAL_MODE:-0}"
FORCE="${FORCE:-0}"
DRY_RUN="${DRY_RUN:-0}"
DEBUG_MODE="${DEBUG_MODE:-0}"
SKIP_SNAPSHOT="${SKIP_SNAPSHOT:-0}"
AUTO_FIX_MODE="${AUTO_FIX_MODE:-0}"
