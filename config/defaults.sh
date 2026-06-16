#!/usr/bin/env bash
# config/defaults.sh

# Mode Flags (User-configurable, can be overridden by env or CLI args)
MINIMAL_MODE="${MINIMAL_MODE:-0}"
FORCE="${FORCE:-0}"
ONLY_STEP="${ONLY_STEP:-}"
AUTO_FIX_MODE="${AUTO_FIX_MODE:-0}"

# Export Critical Paths & Go/Network settings
export PATH="$PATH:$LOCAL_BIN:$GOPATH_BIN:$CARGO_BIN:$PIP_BIN:$VENV_DIR/bin"
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
