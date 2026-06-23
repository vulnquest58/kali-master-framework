#!/usr/bin/env bash
# ============================================================
#  tools/check-tools.sh — Kali Master Framework v7.0.0
#  Standalone tool status checker — no install, read-only
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/config/globals.sh"
source "$SCRIPT_DIR/core/logger.sh"
source "$SCRIPT_DIR/core/utils.sh"

OUTPUT_FORMAT="${1:---text}"   # --text | --json | --summary

# ─── All tracked tools per category ──────────────────────────
declare -A TOOL_CATEGORIES=(
    ["Bug Bounty"]="nuclei subfinder httpx naabu katana ffuf gobuster dalfox ghauri feroxbuster arjun dirsearch sqlmap amass gau trufflehog waybackurls anew qsreplace interactsh-client dnsx cvemap"
    ["Recon"]="nmap masscan shodan theHarvester maltego recon-ng amass"
    ["C2 Frameworks"]="sliver-server havoc mythic-cli empire nimplant merlin-server"
    ["Active Directory"]="crackmapexec netexec evil-winrm bloodhound kerbrute rusthound certipy bloodyAD secretsdump psexec smbclient ldapdomaindump"
    ["Reverse Engineering"]="gdb radare2 r2 rizin ghidra jadx binwalk yara pwntools capa floss strings"
    ["CTF"]="john hashcat hydra medusa steghide stegseek binwalk foremost"
    ["Cloud Security"]="aws awscli az gcloud scout_suite prowler terraform trivy"
    ["Evasion"]="upx msfvenom"
    ["Post Exploitation"]="chisel socat proxychains4 ligolo-ng pspy"
    ["Docker"]="docker docker-compose"
    ["Languages"]="go python3 cargo rustup nim node npm dotnet java"
    ["OPSEC"]="tor proxychains4 macchanger openvpn wg"
    ["AI Tools"]="ollama airecon"
    ["Shell/Config"]="zsh tmux fzf bat rg fd"
)

# ─── JSON output ─────────────────────────────────────────────
output_json() {
    echo "{"
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"version\": \"${VERSION}\","
    echo "  \"categories\": {"

    local first_cat=true
    for category in "${!TOOL_CATEGORIES[@]}"; do
        [[ "$first_cat" == "true" ]] && first_cat=false || echo ","
        echo -n "    \"${category}\": {"

        local tools="${TOOL_CATEGORIES[$category]}"
        local first_tool=true
        for tool in $tools; do
            [[ "$first_tool" == "true" ]] && first_tool=false || echo -n ","
            local status="not_found"
            local path=""
            if path=$(smart_find_tool "$tool" 2>/dev/null); then
                status="installed"
            fi
            local ver; ver=$(get_tool_version "$tool" 2>/dev/null || echo "")
            echo ""
            echo -n "      \"${tool}\": {\"status\": \"${status}\", \"path\": \"${path}\", \"version\": \"${ver}\"}"
        done
        echo ""
        echo -n "    }"
    done

    echo ""
    echo "  }"
    echo "}"
}

# ─── Text output ─────────────────────────────────────────────
output_text() {
    echo ""
    echo -e "${BOLD}${MAGENTA}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${MAGENTA}║   KALI MASTER FRAMEWORK v${VERSION} — TOOL STATUS       ║${RESET}"
    echo -e "${BOLD}${MAGENTA}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""

    local total_ok=0 total_miss=0

    for category in "${!TOOL_CATEGORIES[@]}"; do
        echo -e "  ${BOLD}${CYAN}[ ${category} ]${RESET}"
        local tools="${TOOL_CATEGORIES[$category]}"
        local cat_ok=0 cat_miss=0

        for tool in $tools; do
            if smart_find_tool "$tool" &>/dev/null; then
                local ver; ver=$(get_tool_version "$tool" 2>/dev/null || echo "")
                echo -e "    ${GREEN}✔${RESET} ${tool}${ver:+  ${DIM}v${ver}${RESET}}"
                ((cat_ok++)); ((total_ok++))
            else
                echo -e "    ${RED}✗${RESET} ${tool}  ${DIM}[not installed]${RESET}"
                ((cat_miss++)); ((total_miss++))
            fi
        done

        echo -e "    ${DIM}────────────────── ${cat_ok} OK / ${cat_miss} missing${RESET}"
        echo ""
    done

    echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}"
    echo -e "  ${GREEN}✔ Installed:${RESET}  ${total_ok}"
    echo -e "  ${RED}✗ Missing:${RESET}    ${total_miss}"
    local pct=$(( total_ok * 100 / (total_ok + total_miss + 1) ))
    echo -e "  ${CYAN}Coverage:${RESET}    ${pct}%"
    echo -e "${BOLD}══════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ─── Summary only ────────────────────────────────────────────
output_summary() {
    local total_ok=0 total_miss=0
    for category in "${!TOOL_CATEGORIES[@]}"; do
        for tool in ${TOOL_CATEGORIES[$category]}; do
            if smart_find_tool "$tool" &>/dev/null; then ((total_ok++)); else ((total_miss++)); fi
        done
    done
    echo "Installed: ${total_ok} | Missing: ${total_miss} | Coverage: $(( total_ok * 100 / (total_ok + total_miss + 1) ))%"
}

# ─── Entry point ─────────────────────────────────────────────
list_all_tools() {
    case "${OUTPUT_FORMAT}" in
        --json)    output_json ;;
        --summary) output_summary ;;
        *)         output_text ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    list_all_tools
fi
