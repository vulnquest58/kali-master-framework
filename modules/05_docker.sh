#!/usr/bin/env bash
# modules/05_docker.sh

do_docker() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 5/${STEP_TOTAL} — DOCKER CONTAINER RUNTIME${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    
    # ========================================================
    # Check Minimal Mode
    # ========================================================
    if [[ "$MINIMAL_MODE" == "1" ]]; then
        skip "Docker — skipped in minimal mode"
        return 0
    fi
    
    # ========================================================
    # Phase 1: Detection & Current Version Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/8] DETECTING EXISTING DOCKER${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local existing_docker=""
    local existing_version=""
    local needs_install=1
    
    if smart_find_tool "docker" &>/dev/null; then
        existing_docker=$(smart_find_tool "docker")
        existing_version=$(docker --version 2>/dev/null | grep -oP 'Docker version \K[\d.]+' || echo "unknown")
        ok "Existing Docker installation found"
        info "Path:    ${DIM}${existing_docker}${RESET}"
        info "Version: ${BOLD}${existing_version}${RESET}"
        
        # Check if service is running
        if systemctl is-active --quiet docker 2>/dev/null; then
            ok "Docker service is running"
        else
            warn "Docker service is not running — starting..."
            systemctl enable docker --quiet >> "$LOG_FILE" 2>&1 || true
            systemctl start docker >> "$LOG_FILE" 2>&1 || true
            
            if systemctl is-active --quiet docker 2>/dev/null; then
                ok "Docker service started successfully"
            else
                warn "Failed to start Docker service"
            fi
        fi
        
        needs_install=0
    else
        info "No existing Docker installation detected"
    fi
    
    # Check for conflicting packages
    local conflicting_pkgs=("docker.io" "docker-doc" "docker-compose" "podman-docker" "containerd" "runc")
    local found_conflicts=()
    
    for pkg in "${conflicting_pkgs[@]}"; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            found_conflicts+=("$pkg")
        fi
    done
    
    if [[ ${#found_conflicts[@]} -gt 0 ]]; then
        warn "Conflicting packages detected: ${found_conflicts[*]}"
        info "These will be removed during installation"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: System Requirements Check
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/8] VERIFYING SYSTEM REQUIREMENTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Check kernel version (Docker requires 3.10+)
    local kernel_version
    kernel_version=$(uname -r | cut -d. -f1,2)
    local kernel_major
    kernel_major=$(echo "$kernel_version" | cut -d. -f1)
    local kernel_minor
    kernel_minor=$(echo "$kernel_version" | cut -d. -f2)
    
    if [[ "$kernel_major" -ge 4 ]] || ([[ "$kernel_major" -eq 3 ]] && [[ "$kernel_minor" -ge 10 ]]); then
        ok "Kernel version: ${BOLD}${kernel_version}${RESET} (3.10+ required)"
    else
        fail "Kernel version ${kernel_version} is too old (3.10+ required)"
        return 1
    fi
    
    # Check for cgroup support
    if [[ -d /sys/fs/cgroup ]]; then
        ok "cgroup filesystem detected"
    else
        warn "cgroup filesystem not found — Docker may not work"
    fi
    
    # Check architecture
    local arch
    arch=$(dpkg --print-architecture 2>/dev/null || uname -m)
    case "$arch" in
        amd64|x86_64|arm64|aarch64|armhf|s390x|ppc64le)
            ok "Architecture supported: ${BOLD}${arch}${RESET}"
            ;;
        *)
            warn "Architecture ${arch} may not be fully supported"
            ;;
    esac
    
    # Check disk space (Docker needs at least 2GB)
    local free_gb
    free_gb=$(df -BG / | awk 'NR==2{gsub("G",""); print $4}')
    if [[ "$free_gb" -ge 5 ]]; then
        ok "Disk space: ${free_gb}GB free (5GB+ recommended)"
    elif [[ "$free_gb" -ge 2 ]]; then
        warn "Disk space: ${free_gb}GB free — 5GB+ recommended"
    else
        fail "Insufficient disk space: ${free_gb}GB (2GB minimum required)"
        return 1
    fi
    
    echo ""
    
    # Skip installation if already installed
    if [[ $needs_install -eq 0 ]]; then
        info "Skipping installation — Docker is already installed"
        echo ""
    else
        # ========================================================
        # Phase 3: Remove Conflicting Packages
        # ========================================================
        echo -e "${BOLD}${CYAN}[PHASE 3/8] REMOVING CONFLICTING PACKAGES${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        export DEBIAN_FRONTEND=noninteractive
        
        local pkgs_to_remove=(
            "docker" "docker-engine" "docker.io" "docker-doc"
            "docker-compose" "podman-docker" "containerd" "runc"
        )
        
        info "Removing old/conflicting Docker packages..."
        if apt-get remove -y -qq "${pkgs_to_remove[@]}" >> "$LOG_FILE" 2>&1; then
            ok "Conflicting packages removed"
        else
            warn "Some packages could not be removed — continuing"
        fi
        
        # Clean up old data
        if [[ -d /var/lib/docker ]]; then
            info "Old Docker data found at /var/lib/docker"
            info "Preserving existing containers and images"
        fi
        
        echo ""
        
        # ========================================================
        # Phase 4: Add Docker Repository
        # ========================================================
        echo -e "${BOLD}${CYAN}[PHASE 4/8] ADDING DOCKER REPOSITORY${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        # Install prerequisites
        info "Installing prerequisites..."
        apt-get install -y -qq ca-certificates curl gnupg lsb-release >> "$LOG_FILE" 2>&1 || true
        
        # Create keyrings directory
        install -m 0755 -d /etc/apt/keyrings
        
        # Download Docker GPG key
        info "Downloading Docker GPG key..."
        if safe_curl "https://download.docker.com/linux/debian/gpg" "/etc/apt/keyrings/docker.asc"; then
            chmod a+r /etc/apt/keyrings/docker.asc
            ok "Docker GPG key installed"
        else
            fail "Failed to download Docker GPG key"
            return 1
        fi
        
        # Detect distribution
        local distro_id
        distro_id=$(. /etc/os-release && echo "$ID" 2>/dev/null)
        local distro_codename
        distro_codename=$(. /etc/os-release && echo "${VERSION_CODENAME:-bookworm}")
        
        # Kali uses Debian bookworm repos
        if [[ "$distro_id" == "kali" ]]; then
            distro_codename="bookworm"
            info "Kali Linux detected — using Debian ${distro_codename} repository"
        fi
        
        # Add Docker repository
        local docker_repo="/etc/apt/sources.list.d/docker.list"
        info "Adding Docker repository for ${distro_id} ${distro_codename}..."
        
        cat > "$docker_repo" << DOCKER_REPO
# Added by Kali Master Framework
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${distro_codename} stable
DOCKER_REPO
        
        ok "Docker repository added: ${DIM}${docker_repo}${RESET}"
        
        # Update package lists
        info "Updating package lists..."
        if apt-get update -qq >> "$LOG_FILE" 2>&1; then
            ok "Package lists updated"
        else
            warn "apt-get update had issues — continuing"
        fi
        
        echo ""
        
        # ========================================================
        # Phase 5: Install Docker CE
        # ========================================================
        echo -e "${BOLD}${CYAN}[PHASE 5/8] INSTALLING DOCKER CE${RESET}"
        echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
        
        local docker_packages=(
            "docker-ce"
            "docker-ce-cli"
            "containerd.io"
            "docker-buildx-plugin"
            "docker-compose-plugin"
        )
        
        info "Installing Docker CE and plugins..."
        info "Packages: ${DIM}${docker_packages[*]}${RESET}"
        
        if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --fix-missing \
            "${docker_packages[@]}" >> "$LOG_FILE" 2>&1; then
            ok "Docker CE installed successfully"
        else
            fail "Docker installation failed"
            warn "Check log for details: ${LOG_FILE}"
            return 1
        fi
        
        # Get installed version
        local installed_version
        installed_version=$(docker --version 2>/dev/null | grep -oP 'Docker version \K[\d.]+' || echo "unknown")
        ok "Installed version: ${BOLD}${installed_version}${RESET}"
        
        echo ""
    fi
    
    # ========================================================
    # Phase 6: Service Configuration
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/8] CONFIGURING DOCKER SERVICE${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Enable and start Docker service
    info "Enabling Docker service..."
    if systemctl enable docker --quiet >> "$LOG_FILE" 2>&1; then
        ok "Docker service enabled (starts on boot)"
    else
        warn "Failed to enable Docker service"
    fi
    
    info "Starting Docker service..."
    if systemctl start docker >> "$LOG_FILE" 2>&1; then
        ok "Docker service started"
    else
        fail "Failed to start Docker service"
        warn "Try: sudo systemctl status docker"
    fi
    
    # Wait for Docker to be ready
    sleep 2
    
    # Verify Docker is running
    if docker info &>/dev/null; then
        ok "Docker daemon is responding"
    else
        warn "Docker daemon not responding yet — retrying..."
        sleep 3
        if docker info &>/dev/null; then
            ok "Docker daemon is now responding"
        else
            fail "Docker daemon still not responding"
        fi
    fi
    
    # Configure Docker daemon for performance
    local daemon_json="/etc/docker/daemon.json"
    if [[ ! -f "$daemon_json" ]]; then
        info "Creating Docker daemon configuration..."
        mkdir -p /etc/docker
        cat > "$daemon_json" << 'DAEMON_JSON'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "live-restore": true,
    "default-address-pools": [
        {
            "base": "172.80.0.0/16",
            "size": 24
        }
    ]
}
DAEMON_JSON
        ok "Docker daemon configuration created"
        
        # Reload Docker to apply changes
        systemctl reload docker >> "$LOG_FILE" 2>&1 || systemctl restart docker >> "$LOG_FILE" 2>&1 || true
    else
        ok "Docker daemon configuration already exists"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 7: User Permissions
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/8] CONFIGURING USER PERMISSIONS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Create docker group if it doesn't exist
    if ! getent group docker &>/dev/null; then
        info "Creating docker group..."
        groupadd docker >> "$LOG_FILE" 2>&1 || true
        ok "Docker group created"
    else
        ok "Docker group already exists"
    fi
    
    # Add current user to docker group
    local current_user="${SUDO_USER:-$USER}"
    if [[ "$current_user" != "root" ]]; then
        if ! id -nG "$current_user" | grep -qw "docker"; then
            info "Adding user '${current_user}' to docker group..."
            usermod -aG docker "$current_user" >> "$LOG_FILE" 2>&1
            ok "User '${current_user}' added to docker group"
            info "Note: Log out and back in for changes to take effect"
        else
            ok "User '${current_user}' is already in docker group"
        fi
    else
        info "Running as root — skipping user group configuration"
    fi
    
    # Add root to docker group too (for consistency)
    if ! id -nG root | grep -qw "docker"; then
        usermod -aG docker root >> "$LOG_FILE" 2>&1 || true
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8: Verification & Testing
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/8] VERIFICATION & TESTING${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Test Docker with hello-world
    info "Testing Docker with hello-world container..."
    if docker run --rm hello-world >> "$LOG_FILE" 2>&1; then
        ok "Docker test: hello-world container PASSED"
    else
        warn "Docker test: hello-world container FAILED"
        warn "Docker may still work for other containers"
    fi
    
    # Verify Docker Compose
    if docker compose version &>/dev/null; then
        local compose_version
        compose_version=$(docker compose version 2>/dev/null | grep -oP 'v[\d.]+' || echo "unknown")
        ok "Docker Compose: ${BOLD}${compose_version}${RESET}"
    else
        warn "Docker Compose not available"
    fi
    
    # Verify Docker Buildx
    if docker buildx version &>/dev/null; then
        local buildx_version
        buildx_version=$(docker buildx version 2>/dev/null | grep -oP 'v[\d.]+' || echo "unknown")
        ok "Docker Buildx: ${BOLD}${buildx_version}${RESET}"
    else
        warn "Docker Buildx not available"
    fi
    
    # Get Docker info
    local storage_driver
    storage_driver=$(docker info 2>/dev/null | grep "Storage Driver" | awk '{print $3}' || echo "unknown")
    local cgroup_driver
    cgroup_driver=$(docker info 2>/dev/null | grep "Cgroup Driver" | awk '{print $3}' || echo "unknown")
    local os_arch
    os_arch=$(docker info 2>/dev/null | grep "Architecture" | awk '{print $2}' || echo "unknown")
    
    ok "Storage Driver: ${BOLD}${storage_driver}${RESET}"
    ok "Cgroup Driver: ${BOLD}${cgroup_driver}${RESET}"
    ok "Architecture: ${BOLD}${os_arch}${RESET}"
    
    echo ""
    
    # ========================================================
    # Final Summary
    # ========================================================
    local step_end_time
    step_end_time=$(date +%s)
    local step_duration=$((step_end_time - step_start_time))
    local step_minutes=$((step_duration / 60))
    local step_seconds=$((step_duration % 60))
    
    # Count containers and images
    local containers_count
    containers_count=$(docker ps -a -q 2>/dev/null | wc -l)
    local images_count
    images_count=$(docker images -q 2>/dev/null | wc -l)
    
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  DOCKER SETUP COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${BOLD}Version:${RESET}        ${GREEN}${installed_version:-$existing_version}${RESET}"
    echo -e "  ${BOLD}Service:${RESET}        $(systemctl is-active docker 2>/dev/null)"
    echo -e "  ${BOLD}Storage:${RESET}        ${storage_driver}"
    echo -e "  ${BOLD}Containers:${RESET}     ${containers_count}"
    echo -e "  ${BOLD}Images:${RESET}         ${images_count}"
    echo ""
    echo -e "  ${BOLD}Components:${RESET}"
    echo -e "    ${GREEN}●${RESET} Docker CE"
    echo -e "    ${GREEN}●${RESET} Docker Compose Plugin"
    echo -e "    ${GREEN}●${RESET} Docker Buildx Plugin"
    echo -e "    ${GREEN}●${RESET} containerd.io"
    echo ""
    
    if [[ $needs_install -eq 0 ]]; then
        ok "Docker was already installed — service verified"
    else
        ok "Docker environment ready for lab deployment"
    fi
    
    echo ""
}

# ============================================================
# STEP 6 — Bug Bounty Tools (Professional Edition)
# ============================================================
