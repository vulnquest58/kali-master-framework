#!/usr/bin/env bash
# modules/12_shell_config.sh

do_shell_config() {
    clear
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  ▶ STEP 12/${STEP_TOTAL} — SHELL CONFIGURATION${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    
    local step_start_time
    step_start_time=$(date +%s)
    local total_installed=0
    local total_failed=0
    local total_skipped=0
    
    # ========================================================
    # Phase 1: Install Nerd Fonts (Required for Powerlevel10k)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 1/10] INSTALLING NERD FONTS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Install fonts package
    info "Installing fonts-powerline and fonts-font-awesome..."
    if DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        fonts-powerline fonts-font-awesome fonts-hack-ttf \
        fonts-firacode fonts-noto-color-emoji >> "$LOG_FILE" 2>&1; then
        echo -e "    ${GREEN}✔${RESET} System fonts ${DIM}[installed]${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} System fonts ${DIM}[failed]${RESET}"
        ((total_failed++))
    fi
    
    # Install MesloLGS NF (recommended for Powerlevel10k)
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    if [[ ! -f "$font_dir/MesloLGS NF Regular.ttf" ]]; then
        info "Installing MesloLGS Nerd Font (recommended for p10k)..."
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
        if safe_curl "$font_url" "/tmp/meslo.zip"; then
            unzip -q /tmp/meslo.zip -d "$font_dir" >> "$LOG_FILE" 2>&1
            rm -f /tmp/meslo.zip
            fc-cache -fv >> "$LOG_FILE" 2>&1
            echo -e "    ${GREEN}✔${RESET} MesloLGS NF ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} MesloLGS NF ${DIM}[download failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} MesloLGS NF ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 2: Install Oh-My-Zsh
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 2/10] INSTALLING OH-MY-ZSH${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing Oh-My-Zsh..."
        if RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
            sh -c "$(curl -fsSL \
                https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
            "" --unattended >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Oh-My-Zsh ${DIM}[installed]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Oh-My-Zsh ${DIM}[installation failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Oh-My-Zsh ${DIM}[already installed]${RESET}"
        ((total_skipped++))
    fi
    
    # Set zsh as default shell
    local zsh_bin
    zsh_bin=$(command -v zsh)
    if [[ -n "$zsh_bin" ]]; then
        if [[ "$(getent passwd root | cut -d: -f7)" != "$zsh_bin" ]]; then
            info "Setting zsh as default shell..."
            if chsh -s "$zsh_bin" root >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} Default shell changed to zsh${RESET}"
                ((total_installed++))
            else
                echo -e "    ${YELLOW}!${RESET} Could not change default shell (manual change required)${RESET}"
            fi
        else
            echo -e "    ${GREEN}✔${RESET} zsh is already the default shell${RESET}"
            ((total_skipped++))
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 3: Install Zsh Plugins
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 3/10] INSTALLING ZSH PLUGINS${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions|Auto-suggestions from history"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting|Syntax highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions|Additional completions"
        ["fast-syntax-highlighting"]="https://github.com/zdharma-continuum/fast-syntax-highlighting|Fast syntax highlighting"
        ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search|History substring search"
        ["zsh-you-should-use"]="https://github.com/MichaelAqworka/zsh-you-should-use|Alias reminder"
        ["zsh-better-npm-completion"]="https://github.com/lukechilds/zsh-better-npm-completion|Better npm completion"
    )
    
    local plugin_count=0
    for plugin in "${!plugins[@]}"; do
        IFS='|' read -r url desc <<< "${plugins[$plugin]}"
        local plugin_path="${ZSH_CUSTOM}/plugins/$plugin"
        
        if [[ -d "$plugin_path" ]]; then
            echo -e "    ${GREEN}✔${RESET} $plugin ${DIM}[already installed]${RESET}"
            ((total_skipped++))
        else
            if git clone -q "$url" "$plugin_path" >> "$LOG_FILE" 2>&1; then
                echo -e "    ${GREEN}✔${RESET} $plugin ${DIM}[installed - $desc]${RESET}"
                ((total_installed++))
                ((plugin_count++))
            else
                echo -e "    ${RED}✗${RESET} $plugin ${DIM}[clone failed]${RESET}"
                ((total_failed++))
            fi
        fi
    done
    
    echo ""
    ok "Installed $plugin_count new plugins"
    echo ""
    
    # ========================================================
    # Phase 4: Install Powerlevel10k
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 4/10] INSTALLING POWERLEVEL10K${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        info "Cloning Powerlevel10k..."
        if git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$ZSH_CUSTOM/themes/powerlevel10k" >> "$LOG_FILE" 2>&1; then
            echo -e "    ${GREEN}✔${RESET} Powerlevel10k ${DIM}[cloned]${RESET}"
            ((total_installed++))
        else
            echo -e "    ${RED}✗${RESET} Powerlevel10k ${DIM}[clone failed]${RESET}"
            ((total_failed++))
        fi
    else
        echo -e "    ${GREEN}✔${RESET} Powerlevel10k ${DIM}[already installed]${RESET}"
        ((total_skipped++))
        
        # Update if exists
        info "Updating Powerlevel10k..."
        if (cd "$ZSH_CUSTOM/themes/powerlevel10k" && git pull -q >> "$LOG_FILE" 2>&1); then
            echo -e "    ${GREEN}✔${RESET} Powerlevel10k ${DIM}[updated]${RESET}"
        fi
    fi
    
    echo ""
    
    # ========================================================
    # Phase 5: Configure Powerlevel10k (Professional Theme)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 5/10] CONFIGURING POWERLEVEL10K${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Creating professional Powerlevel10k configuration..."
    
    cp "$SCRIPT_DIR/assets/p10k-config.zsh" "$HOME/.p10k.zsh"
    
    echo -e "    ${GREEN}✔${RESET} Powerlevel10k configuration created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 6: Configure tmux
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 6/10] CONFIGURING TMUX${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Creating tmux configuration..."
    
    cp "$SCRIPT_DIR/assets/tmux.conf" "$HOME/.tmux.conf"
    
    echo -e "    ${GREEN}✔${RESET} tmux configuration created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 7: Configure vim/neovim
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 7/10] CONFIGURING VIM/NEOVIM${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Creating vim configuration..."
    
    cat > "$HOME/.vimrc" << 'VIM'
" ============================================================
" Vim Configuration — Kali Master Framework
" ============================================================

" Enable syntax highlighting
syntax on

" Enable file type detection
filetype plugin indent on

" Show line numbers
set number
set relativenumber

" Enable mouse support
set mouse=a

" Set encoding
set encoding=utf-8

" Enable 256 colors
set t_Co=256

" Set color scheme
set background=dark
colorscheme desert

" Show matching brackets
set showmatch

" Enable auto-indent
set autoindent
set smartindent

" Set tab width
set tabstop=4
set shiftwidth=4
set expandtab

" Highlight current line
set cursorline

" Show trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Enable search highlighting
set hlsearch
set incsearch
set ignorecase
set smartcase

" Enable wildmenu
set wildmenu
set wildmode=longest:full,full

" Set backup directory
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Create directories if they don't exist
if !isdirectory($HOME . "/.vim/backup")
    call mkdir($HOME . "/.vim/backup", "p")
endif
if !isdirectory($HOME . "/.vim/swap")
    call mkdir($HOME . "/.vim/swap", "p")
endif
if !isdirectory($HOME . "/.vim/undo")
    call mkdir($HOME . "/.vim/undo", "p")
endif

" Enable persistent undo
set undofile

" Key mappings
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprevious<CR>

" Status line
set laststatus=2
set statusline=%f\ %m%r%h%w\ [%{&ff}]\ [%Y]\ [%l/%L,\ %c]\ [%p%%]
VIM
    
    echo -e "    ${GREEN}✔${RESET} vim configuration created${RESET}"
    ((total_installed++))
    
    echo ""
    
    # ========================================================
    # Phase 8: Deploy Environment Configuration (from assets)
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8/11] CREATING ENVIRONMENT CONFIGURATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    info "Deploying kali_env.zsh from assets (SQLite-powered)..."
    
    if cp "$SCRIPT_DIR/assets/kali_env.zsh" "$HOME/.kali_env.zsh"; then
        chmod 644 "$HOME/.kali_env.zsh"
        echo -e "    ${GREEN}✔${RESET} Environment configuration deployed${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} Failed to copy kali_env.zsh from assets${RESET}"
        ((total_failed++))
    fi
    
    echo ""
    
    # ========================================================
    # Phase 8.5: Deploy & Build the Kali Tool Intelligence DB
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 8.5/11] KALI TOOL INTELLIGENCE SYSTEM (KTIS)${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    local ktis_dir="$HOME/.kali-autoinstall"
    local ktis_builder="$ktis_dir/build_tool_db.py"
    local ktis_db="$ktis_dir/db/tools.sqlite"
    
    # Ensure KTIS directory structure exists
    mkdir -p "$ktis_dir/db" "$ktis_dir/cache" "$ktis_dir/logs" "$ktis_dir/custom"
    
    # Deploy the builder script
    if cp "$SCRIPT_DIR/assets/build_tool_db.py" "$ktis_builder"; then
        chmod 755 "$ktis_builder"
        echo -e "    ${GREEN}✔${RESET} KTIS builder deployed to: $ktis_builder${RESET}"
        ((total_installed++))
    else
        echo -e "    ${RED}✗${RESET} Failed to deploy KTIS builder${RESET}"
        ((total_failed++))
    fi
    
    # Export the builder path so kali_env.zsh can find it
    export KALI_DB_BUILDER="$ktis_builder"
    
    # Run builder to prime the database
    if command -v python3 &>/dev/null; then
        info "Building Kali Tool Intelligence database (first-time, may take ~30s)..."
        if python3 "$ktis_builder" >> "$LOG_FILE" 2>&1; then
            local tool_count
            tool_count=$(sqlite3 "$ktis_db" 'SELECT COUNT(*) FROM tools;' 2>/dev/null || echo "0")
            echo -e "    ${GREEN}✔${RESET} KTIS database built: ${CYAN}${tool_count}${RESET} tools indexed${RESET}"
            echo -e "    ${DIM}Location: $ktis_db${RESET}"
            ((total_installed++))
        else
            echo -e "    ${YELLOW}!${RESET} KTIS database build failed (APT cache may be empty in this environment)${RESET}"
            echo -e "    ${DIM}Run 'ktis-rebuild' after first boot to populate the database${RESET}"
            ((total_skipped++))
        fi
    else
        echo -e "    ${YELLOW}!${RESET} python3 not found — skipping KTIS build${RESET}"
        echo -e "    ${DIM}Install python3 then run: ktis-rebuild${RESET}"
        ((total_skipped++))
    fi
    
    # Inject KALI_DB_BUILDER export into .zshrc if not already present
    if ! grep -q "KALI_DB_BUILDER" "$HOME/.zshrc" 2>/dev/null; then
        printf '\nexport KALI_DB_BUILDER="%s"\n' "$ktis_builder" >> "$HOME/.zshrc"
        echo -e "    ${GREEN}✔${RESET} KALI_DB_BUILDER exported in .zshrc${RESET}"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 9: Update .zshrc
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 9/11] UPDATING .ZSHRC${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Add kali_env.zsh to .zshrc
    if ! grep -q "kali_env.zsh" "$HOME/.zshrc" 2>/dev/null; then
        printf '\n# Kali Master v6.7.0\n[[ -f "$HOME/.kali_env.zsh" ]] && source "$HOME/.kali_env.zsh"\n' \
            >> "$HOME/.zshrc"
        echo -e "    ${GREEN}✔${RESET} Added kali_env.zsh to .zshrc${RESET}"
        ((total_installed++))
    else
        echo -e "    ${GREEN}✔${RESET} kali_env.zsh already in .zshrc${RESET}"
        ((total_skipped++))
    fi
    
    # Set Powerlevel10k theme
    if ! grep -q "powerlevel10k" "$HOME/.zshrc" 2>/dev/null; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        echo -e "    ${GREEN}✔${RESET} Set Powerlevel10k as theme${RESET}"
        ((total_installed++))
    else
        echo -e "    ${GREEN}✔${RESET} Powerlevel10k already set as theme${RESET}"
        ((total_skipped++))
    fi
    
    # Update plugins
    if grep -q "^plugins=" "$HOME/.zshrc" 2>/dev/null; then
        sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions fast-syntax-highlighting zsh-history-substring-search colored-man-pages extract z sudo docker)/' \
            "$HOME/.zshrc"
        echo -e "    ${GREEN}✔${RESET} Updated plugins list${RESET}"
        ((total_installed++))
    else
        echo -e "    ${YELLOW}!${RESET} Could not update plugins (manual update required)${RESET}"
    fi
    
    echo ""
    
    # ========================================================
    # Phase 10: Verification & Summary
    # ========================================================
    echo -e "${BOLD}${CYAN}[PHASE 10/11] VERIFICATION${RESET}"
    echo -e "  ${DIM}────────────────────────────────────────────────────────${RESET}"
    
    # Verify installations
    local verified=0
    local total_checks=0
    
    # Verify KTIS database
    ((total_checks++))
    
    # Check Oh-My-Zsh
    ((total_checks++))
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "    ${GREEN}✔${RESET} Oh-My-Zsh installed"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} Oh-My-Zsh not found"
    fi
    
    # Check Powerlevel10k
    ((total_checks++))
    if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        echo -e "    ${GREEN}✔${RESET} Powerlevel10k installed"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} Powerlevel10k not found"
    fi
    
    # Check plugins
    ((total_checks++))
    local plugin_count=0
    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
        if [[ -d "${ZSH_CUSTOM}/plugins/$plugin" ]]; then
            ((plugin_count++))
        fi
    done
    if [[ $plugin_count -ge 3 ]]; then
        echo -e "    ${GREEN}✔${RESET} Zsh plugins installed ($plugin_count/3)"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} Zsh plugins incomplete ($plugin_count/3)"
    fi
    
    # Check configuration files
    ((total_checks++))
    if [[ -f "$HOME/.p10k.zsh" ]] && [[ -f "$HOME/.kali_env.zsh" ]]; then
        echo -e "    ${GREEN}✔${RESET} Configuration files created"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} Configuration files missing"
    fi
    
    # Check tmux config
    ((total_checks++))
    if [[ -f "$HOME/.tmux.conf" ]]; then
        echo -e "    ${GREEN}✔${RESET} tmux configuration created"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} tmux configuration missing"
    fi
    
    # Check vim config
    ((total_checks++))
    if [[ -f "$HOME/.vimrc" ]]; then
        echo -e "    ${GREEN}✔${RESET} vim configuration created"
        ((verified++))
    else
        echo -e "    ${RED}✗${RESET} vim configuration missing"
    fi
    
    # Count aliases and functions
    local alias_count
    alias_count=$(grep -c "^alias " "$HOME/.kali_env.zsh" 2>/dev/null || echo "0")
    local function_count
    function_count=$(grep -c "^[a-z_]*() {" "$HOME/.kali_env.zsh" 2>/dev/null || echo "0")
    
    echo ""
    info "Shell configuration statistics:"
    echo -e "    ${DIM}Aliases: $alias_count${RESET}"
    echo -e "    ${DIM}Functions: $function_count${RESET}"
    echo -e "    ${DIM}Plugins: $plugin_count${RESET}"
    
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
    echo -e "${BOLD}${MAGENTA}  SHELL CONFIGURATION COMPLETE${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${BOLD}Duration:${RESET}       ${CYAN}${step_minutes}m ${step_seconds}s${RESET}"
    echo -e "  ${GREEN}Installed:${RESET}      ${total_installed} components"
    echo -e "  ${DIM}Skipped:${RESET}        ${total_skipped} components (already installed)"
    
    if [[ $total_failed -gt 0 ]]; then
        echo -e "  ${RED}Failed:${RESET}        ${total_failed} components"
    else
        echo -e "  ${GREEN}Failed:${RESET}        0 components"
    fi
    
    echo ""
    echo -e "  ${BOLD}Components:${RESET}"
    echo -e "    ${GREEN}●${RESET} Nerd Fonts (MesloLGS NF)"
    echo -e "    ${GREEN}●${RESET} Oh-My-Zsh"
    echo -e "    ${GREEN}●${RESET} Powerlevel10k Theme"
    echo -e "    ${GREEN}●${RESET} Zsh Plugins ($plugin_count installed)"
    echo -e "    ${GREEN}●${RESET} tmux Configuration"
    echo -e "    ${GREEN}●${RESET} vim Configuration"
    echo -e "    ${GREEN}●${RESET} Environment Variables"
    echo -e "    ${GREEN}●${RESET} Aliases ($alias_count)"
    echo -e "    ${GREEN}●${RESET} Functions ($function_count)"
    echo -e "    ${GREEN}●${RESET} Kali Tool Intelligence System (SQLite DB)"
    echo ""
    echo -e "  ${BOLD}KTIS Commands:${RESET}"
    echo -e "    ${CYAN}ktis-stats${RESET}                   ${DIM}→ Show KTIS database statistics${RESET}"
    echo -e "    ${CYAN}ktis-search <tool>${RESET}           ${DIM}→ Search tool database${RESET}"
    echo -e "    ${CYAN}ktis-rebuild${RESET}                 ${DIM}→ Rebuild the tool database${RESET}"
    
    if [[ $total_failed -gt 0 ]]; then
        warn "Some components failed to install"
        info "Check log for details: ${LOG_FILE}"
    else
        ok "Shell configuration completed successfully"
    fi
    
    echo ""
    echo -e "  ${BOLD}Quick Commands:${RESET}"
    echo -e "    ${CYAN}source ~/.zshrc${RESET}              ${DIM}→ Reload shell configuration${RESET}"
    echo -e "    ${CYAN}p10k configure${RESET}               ${DIM}→ Reconfigure Powerlevel10k${RESET}"
    echo -e "    ${CYAN}tmux${RESET}                         ${DIM}→ Start tmux session${RESET}"
    echo -e "    ${CYAN}myip${RESET}                         ${DIM}→ Show public IP${RESET}"
    echo -e "    ${CYAN}ports${RESET}                        ${DIM}→ Show open ports${RESET}"
    echo -e "    ${CYAN}extract archive.tar.gz${RESET}       ${DIM}→ Extract archive${RESET}"
    echo -e "    ${CYAN}mkcd newdir${RESET}                  ${DIM}→ Create and cd to directory${RESET}"
    echo -e "    ${CYAN}serve 8080${RESET}                   ${DIM}→ Start HTTP server${RESET}"
    echo -e "    ${CYAN}listen 4444${RESET}                  ${DIM}→ Start netcat listener${RESET}"
    echo -e "    ${CYAN}quickscan target${RESET}             ${DIM}→ Quick port scan${RESET}"
    echo -e "    ${CYAN}fullscan target${RESET}              ${DIM}→ Full port scan${RESET}"
    echo -e "    ${CYAN}killport 8080${RESET}                ${DIM}→ Kill process on port${RESET}"
    echo ""
    echo -e "  ${YELLOW}${BOLD}⚠  IMPORTANT${RESET}"
    echo -e "  ${DIM}Open a new terminal or run: ${CYAN}source ~/.zshrc${RESET}"
    echo -e "  ${DIM}Then run: ${CYAN}p10k configure${RESET} to customize your theme${RESET}"
    echo ""
}

# ============================================================
# STEP 13 — Secrets Manager (Professional Edition)
# ============================================================
