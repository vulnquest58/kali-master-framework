#!/usr/bin/env zsh
# ============================================================
# Kali Master v6.7.0 — Environment Configuration
# Kali Tool Intelligence System — SQLite-powered shell env
# ============================================================

# ─── PATH Configuration ────────────────────────────────────
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin"
export PATH="$PATH:$HOME/.cargo/bin:/opt/tools/bin:/usr/local/bin"
export PATH="$PATH:/opt/evasion-tools:/opt/postexploit"
export PATH="$PATH:$HOME/.krew/bin"

# ─── Go Configuration ──────────────────────────────────────
export GOPATH="$HOME/go"
export GOPROXY="https://proxy.golang.org,https://goproxy.io,direct"
export GONOSUMDB="*"
export GO111MODULE="on"

# ─── Python Virtual Environment ────────────────────────────
if [[ -f "/opt/kali-venv/bin/activate" ]]; then
    source "/opt/kali-venv/bin/activate"
fi

# ─── Wordlists ─────────────────────────────────────────────
export WORDLISTS="/opt/wordlists"
export SECLISTS="${WORDLISTS}/SecLists"
export ROCKYOU="/usr/share/wordlists/rockyou.txt"

# ─── Kali Tool Intelligence System ─────────────────────────
# Database path
export KALI_TOOL_DB="$HOME/.kali-autoinstall/db/tools.sqlite"
export KALI_ALIAS_DB="$HOME/.kali-autoinstall/db/tools.sqlite"

# ─── command_not_found_handler (SQLite Edition) ────────────
# Triggered by Zsh when a command is not found in PATH.
# Priority: 1) exact alias lookup → 2) exact tool match →
#           3) fuzzy/LIKE match → 4) apt-get fallback
command_not_found_handler() {
    local cmd="$1"
    shift
    local args=("$@")

    # ── Guard: DB must exist ──────────────────────────────
    if [[ ! -f "$KALI_TOOL_DB" ]]; then
        # Fall back gracefully
        print -u2 "zsh: command not found: $cmd"
        return 127
    fi

    # ── 1. Alias lookup (typo / short-name) ───────────────
    local resolved
    resolved=$(sqlite3 "$KALI_TOOL_DB" \
        "SELECT tool_cmd FROM aliases WHERE alias = '$(printf '%s' "$cmd" | sed "s/'/''/g")' LIMIT 1;" \
        2>/dev/null)

    if [[ -n "$resolved" ]]; then
        print -u2 "\e[33m[ktis]\e[0m '$cmd' → alias for '\e[36m$resolved\e[0m'"
        if command -v "$resolved" &>/dev/null; then
            "$resolved" "${args[@]}"
            return $?
        else
            print -u2 "\e[33m[ktis]\e[0m '$resolved' is not installed yet."
            _ktis_offer_install "$resolved"
            return 127
        fi
    fi

    # ── 2. Exact tool lookup ───────────────────────────────
    local tool_row
    tool_row=$(sqlite3 -separator '|' "$KALI_TOOL_DB" \
        "SELECT cmd, pkg_name, source, install_cmd, description
         FROM tools
         WHERE cmd = '$(printf '%s' "$cmd" | sed "s/'/''/g")'
         ORDER BY CASE source
             WHEN 'apt'        THEN 1
             WHEN 'kali_tools' THEN 2
             WHEN 'go'         THEN 3
             WHEN 'pip'        THEN 4
             WHEN 'cargo'      THEN 5
             ELSE 6
         END
         LIMIT 1;" 2>/dev/null)

    if [[ -n "$tool_row" ]]; then
        local t_cmd t_pkg t_src t_install t_desc
        IFS='|' read -r t_cmd t_pkg t_src t_install t_desc <<< "$tool_row"
        _ktis_show_suggestion "$cmd" "$t_pkg" "$t_src" "$t_install" "$t_desc"
        _ktis_offer_install "$t_cmd" "$t_install"
        return 127
    fi

    # ── 3. Fuzzy / LIKE lookup ────────────────────────────
    local fuzzy_row
    fuzzy_row=$(sqlite3 -separator '|' "$KALI_TOOL_DB" \
        "SELECT cmd, pkg_name, source, install_cmd, description
         FROM tools
         WHERE cmd LIKE '%$(printf '%s' "$cmd" | sed "s/'/''/g")%'
            OR pkg_name LIKE '%$(printf '%s' "$cmd" | sed "s/'/''/g")%'
         ORDER BY length(cmd) ASC
         LIMIT 1;" 2>/dev/null)

    if [[ -n "$fuzzy_row" ]]; then
        local f_cmd f_pkg f_src f_install f_desc
        IFS='|' read -r f_cmd f_pkg f_src f_install f_desc <<< "$fuzzy_row"
        print -u2 "\e[33m[ktis]\e[0m Did you mean '\e[36m$f_cmd\e[0m'? ($f_desc)"
        _ktis_offer_install "$f_cmd" "$f_install"
        return 127
    fi

    # ── 4. apt-file fallback (last resort) ────────────────
    if command -v apt-file &>/dev/null; then
        local apt_result
        apt_result=$(apt-file search --regexp "bin/${cmd}$" 2>/dev/null | head -3)
        if [[ -n "$apt_result" ]]; then
            print -u2 "\e[33m[ktis]\e[0m Command '$cmd' found in APT packages:"
            print -u2 "$apt_result"
            return 127
        fi
    fi

    # ── 5. Generic fallback ───────────────────────────────
    print -u2 "zsh: command not found: $cmd"
    print -u2 "\e[90m[ktis]\e[0m Run '\e[36mkali-master --fix\e[0m' to rebuild the tool database."
    return 127
}

# ─── Helper: Show suggestion banner ────────────────────────
_ktis_show_suggestion() {
    local cmd="$1" pkg="$2" src="$3" install="$4" desc="$5"
    print -u2 ""
    print -u2 "\e[33m╔══ Kali Tool Intelligence System ══════════════════════╗\e[0m"
    print -u2 "\e[33m║\e[0m  Command  : \e[36m$cmd\e[0m"
    print -u2 "\e[33m║\e[0m  Package  : \e[32m$pkg\e[0m  \e[90m[via $src]\e[0m"
    print -u2 "\e[33m║\e[0m  Info     : $desc"
    print -u2 "\e[33m║\e[0m  Install  : \e[35m$install\e[0m"
    print -u2 "\e[33m╚═══════════════════════════════════════════════════════╝\e[0m"
    print -u2 ""
}

# ─── Helper: Offer interactive installation ────────────────
_ktis_offer_install() {
    local tool_cmd="$1"
    local install_cmd="$2"

    # Non-interactive: skip prompt when stdin is not a tty
    [[ ! -t 0 ]] && return 0

    print -u2 -n "\e[33m[ktis]\e[0m Install '\e[36m$tool_cmd\e[0m' now? [y/N] "
    local answer
    read -r answer </dev/tty

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if [[ -n "$install_cmd" ]]; then
            print -u2 "\e[32m[ktis]\e[0m Running: $install_cmd"
            eval "$install_cmd"
            local exit_code=$?
            if [[ $exit_code -eq 0 ]]; then
                # Run post-install commands if any
                local post_cmd
                post_cmd=$(sqlite3 "$KALI_TOOL_DB" \
                    "SELECT command FROM post_install WHERE tool_cmd = '$(printf '%s' "$tool_cmd" | sed "s/'/''/g")';" \
                    2>/dev/null)
                if [[ -n "$post_cmd" ]]; then
                    print -u2 "\e[32m[ktis]\e[0m Running post-install: $post_cmd"
                    eval "$post_cmd"
                fi
                print -u2 "\e[32m[ktis]\e[0m '$tool_cmd' installed successfully."
            else
                print -u2 "\e[31m[ktis]\e[0m Installation failed (exit code $exit_code)."
            fi
        else
            print -u2 "\e[31m[ktis]\e[0m No install command available for '$tool_cmd'."
        fi
    fi
}

# ─── DB refresh function ───────────────────────────────────
ktis-rebuild() {
    local db_builder="${KALI_DB_BUILDER:-$HOME/.kali-autoinstall/build_tool_db.py}"
    if [[ -f "$db_builder" ]]; then
        print "\e[36m[ktis]\e[0m Rebuilding tool database..."
        python3 "$db_builder"
        print "\e[32m[ktis]\e[0m Database rebuilt at: $KALI_TOOL_DB"
    else
        print -u2 "\e[31m[ktis]\e[0m Builder not found at: $db_builder"
        print -u2 "       Run 'kali-master --rebuild-db' to fix this."
    fi
}

# ─── DB stats function ────────────────────────────────────
ktis-stats() {
    if [[ ! -f "$KALI_TOOL_DB" ]]; then
        print "\e[31m[ktis]\e[0m Database not found. Run: ktis-rebuild"
        return 1
    fi
    local tools aliases deps
    tools=$(sqlite3 "$KALI_TOOL_DB" "SELECT COUNT(*) FROM tools;" 2>/dev/null)
    aliases=$(sqlite3 "$KALI_TOOL_DB" "SELECT COUNT(*) FROM aliases;" 2>/dev/null)
    deps=$(sqlite3 "$KALI_TOOL_DB" "SELECT COUNT(*) FROM dependencies;" 2>/dev/null)
    local db_size
    db_size=$(du -sh "$KALI_TOOL_DB" 2>/dev/null | cut -f1)
    local last_sync
    last_sync=$(cat "$HOME/.kali-autoinstall/last_sync" 2>/dev/null || echo "never")
    [[ "$last_sync" =~ ^[0-9]+$ ]] && last_sync=$(date -d "@$last_sync" "+%Y-%m-%d %H:%M" 2>/dev/null || date -r "$last_sync" "+%Y-%m-%d %H:%M" 2>/dev/null)
    print "\e[36m╔══ KTIS Database Stats ══════════════════╗\e[0m"
    print "  Tools       : \e[32m${tools:-0}\e[0m"
    print "  Aliases     : \e[32m${aliases:-0}\e[0m"
    print "  Dependencies: \e[32m${deps:-0}\e[0m"
    print "  DB Size     : $db_size"
    print "  Last Sync   : $last_sync"
    print "\e[36m╚═════════════════════════════════════════╝\e[0m"
}

# ─── Tool lookup function ──────────────────────────────────
ktis-search() {
    local query="$1"
    if [[ -z "$query" ]]; then
        print "Usage: ktis-search <tool-name>"
        return 1
    fi
    if [[ ! -f "$KALI_TOOL_DB" ]]; then
        print "\e[31m[ktis]\e[0m Database not found. Run: ktis-rebuild"
        return 1
    fi
    sqlite3 -column -header "$KALI_TOOL_DB" \
        "SELECT cmd, source, category, description, install_cmd
         FROM tools
         WHERE cmd LIKE '%${query}%' OR description LIKE '%${query}%'
         ORDER BY length(cmd)
         LIMIT 20;" 2>/dev/null
}

# ─── Aliases - System ──────────────────────────────────────
alias ll='ls -lahF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# ─── Aliases - Kali Master ─────────────────────────────────
alias c2='c2-menu'
alias lab='lab-manager'
alias evade='evasion-menu'
alias postex='postexploit-menu'
alias update='update-tools'
alias fix='kali-master --fix'
alias status='kali-master status'
alias ktis='ktis-stats'

# ─── Aliases - Bug Bounty ──────────────────────────────────
alias bb='bb-recon'
alias newbb='newbb'
alias sub='subfinder -d'
alias http='httpx -l'
alias nuc='nuclei -u'
alias ff='ffuf -u'
alias gob='gobuster dir -u'

# ─── Aliases - Network ─────────────────────────────────────
alias ports='ss -tulanp'
alias myip='curl -s https://api.ipify.org && echo'
alias localip='ip -4 addr show scope global | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | head -1'
alias listen='ss -tlnp'
alias connections='ss -tunap'

# ─── Aliases - C2 Frameworks ───────────────────────────────
alias sliver='sliver-server'
alias havoc='havoc server'
alias mythic='cd /opt/Mythic && sudo ./mythic-cli'
alias covenant='covenant'
alias empire='empire server'
alias merlin='merlin server'
alias nimplant='nimplant server'

# ─── Aliases - Post-Exploitation ───────────────────────────
alias linpeas='linpeas.sh'
alias winpeas='echo "Upload winPEAS.exe to target"'
alias pspy='pspy64'
alias pe-server='pe-server'
alias revshell='revshell'

# ─── Aliases - Docker ──────────────────────────────────────
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
alias dclean='docker system prune -af'
alias dlogs='docker logs --tail 100 -f'

# ─── Aliases - Git ─────────────────────────────────────────
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# ─── Aliases - Security ────────────────────────────────────
alias nmap='nmap -Pn'
alias nmap-quick='nmap -Pn -T4 --top-ports 1000'
alias nmap-full='nmap -Pn -T4 -p- -sC -sV'
alias nmap-vuln='nmap -Pn --script vuln'
alias hydra='hydra -t 4'

# ─── Aliases - Reverse Engineering ─────────────────────────
alias gdb-peda='gdb -q -ix /opt/tools/peda/peda.py'
alias gdb-pwndbg='gdb -q -ex "source /root/.pwndbg/gdbinit.py"'
alias gdb-gef='gdb -q -ex "source /usr/local/share/gef.py"'
alias r2='radare2'

# ─── Aliases - Utilities ───────────────────────────────────
alias weather='curl wttr.in'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
alias please='sudo $(history -p \!\!)'
alias cls='clear'
alias h='history'
alias hg='history | grep'

# ─── Functions ─────────────────────────────────────────────

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find files by name
findfile() {
    find . -type f -name "*$1*"
}

# Find directories by name
finddir() {
    find . -type d -name "*$1*"
}

# Show largest files
largest() {
    find "${1:-.}" -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n "${2:-10}"
}

# Show open ports
openports() {
    sudo netstat -tulanp | grep LISTEN
}

# Kill process by port
killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return 1
    fi
    sudo fuser -k "$1/tcp"
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    echo "Starting HTTP server on port $port..."
    echo "URL: http://$(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1):$port"
    python3 -m http.server "$port"
}

# Start listener on custom port
nc-listen() {
    local port="${1:-4444}"
    echo "Starting listener on port $port..."
    rlwrap nc -lvnp "$port"
}

# Upgrade shell to TTY
upgrade() {
    echo "Upgrading to TTY shell..."
    python3 -c 'import pty; pty.spawn("/bin/bash")'
    echo "Press Ctrl+Z, then run: stty raw -echo; fg"
}

# Check if host is up
isup() {
    if ping -c 1 "$1" &>/dev/null; then
        echo "$1 is UP"
    else
        echo "$1 is DOWN"
    fi
}

# Show all IPs
allips() {
    ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}(?=/)'
}

# Quick port scan
quickscan() {
    if [ -z "$1" ]; then
        echo "Usage: quickscan <target>"
        return 1
    fi
    nmap -Pn -T4 --top-ports 1000 "$1"
}

# Full port scan
fullscan() {
    if [ -z "$1" ]; then
        echo "Usage: fullscan <target>"
        return 1
    fi
    nmap -Pn -T4 -p- -sC -sV "$1"
}

# ─── Load Secrets ──────────────────────────────────────────
[[ -f "$HOME/.config/kali-master/load_secrets.sh" ]] && \
    source "$HOME/.config/kali-master/load_secrets.sh"

# ─── Load Powerlevel10k ────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
