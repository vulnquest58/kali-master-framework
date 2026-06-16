#!/usr/bin/env bash
# core/state.sh

# ============================================================
#  ADVANCED STATE MACHINE & RESUME ENGINE
# ============================================================

init_state() {
    mkdir -p "$STATE_DIR"
    echo "$VERSION" > "$STATE_DIR/framework_version"
}

state_check() {
    local step_name="$1"
    local state_file="$STATE_DIR/${step_name}.done"
    local version_file="$STATE_DIR/framework_version"
    
    if [[ -f "$state_file" ]] && [[ -f "$version_file" ]]; then
        local saved_version
        saved_version=$(cat "$version_file" 2>/dev/null)
        if [[ "$saved_version" == "$VERSION" ]]; then
            return 0 # completed and matching version
        fi
    fi
    return 1 # not completed or version mismatch
}

state_done() {
    mkdir -p "$STATE_DIR"
    touch "$STATE_DIR/${1}.done"
    echo "$VERSION" > "$STATE_DIR/framework_version"
    log "Step '${1}' marked as completed."
}

state_reset() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        rm -rf "$STATE_DIR"
        info "All states reset."
    else
        rm -f "$STATE_DIR/${name}.done"
        info "State reset: $name"
    fi
}

run_step() {
    local name="$1"
    local func="$2"
    shift 2

    if state_check "$name" && [[ "${FORCE:-0}" != "1" ]]; then
        skip "$name — already done. Use --reset $name to re-run."
        return 0
    fi

    if $func "$@"; then
        state_done "$name"
    else
        warn "Step failed: $name (continuing)"
        INSTALL_ERRORS+=("$name")
    fi
}

get_last_completed_step() {
    local last_step="none"
    for file in "$STATE_DIR"/*.done; do
        [[ -e "$file" ]] || continue
        last_step=$(basename "$file" .done)
    done
    echo "$last_step"
}
