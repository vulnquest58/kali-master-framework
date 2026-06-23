# Kali Master Framework v7.0.0

<div align="center">

```
  ██╗ ██╗  █████╗ ██╗     ██╗    ███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗
  ██║ ██╔╝██╔══██╗██║     ██║    ████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗
  █████╔╝ ███████║██║     ██║    ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝
  ██╔═██╗ ██╔══██║██║     ██║    ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗
  ██║ ██╗ ██║  ██║███████╗██║    ██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║
  ╚═╝ ╚═╝ ╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
```

**Ultimate Offensive Security Platform for Kali Linux**

[![Version](https://img.shields.io/badge/version-7.0.0-blueviolet?style=for-the-badge)](https://github.com/vulnquest58)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux-557C94?style=for-the-badge&logo=kalilinux)](https://www.kali.org)
[![Modules](https://img.shields.io/badge/modules-27-orange?style=for-the-badge)](#-modules)
[![Tools](https://img.shields.io/badge/tools-350%2B-success?style=for-the-badge)](#-complete-tool-arsenal)
[![Author](https://img.shields.io/badge/author-vulnquest58-red?style=for-the-badge&logo=github)](https://github.com/vulnquest58)

> **Designed & Developed by [vulnquest58](https://github.com/vulnquest58)**

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [What's New in v7.0.0](#-whats-new-in-v700)
- [Architecture](#-architecture)
- [Modules](#-modules)
- [Complete Tool Arsenal](#-complete-tool-arsenal)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [CLI Reference](#-cli-reference)
- [Configuration](#-configuration)
- [Core Engine](#-core-engine)
- [Advanced Features](#-advanced-features)
- [Changelog](#-changelog)
- [Author](#-author)

---

## 🎯 Overview

**Kali Master Framework v7.0.0** is a professional-grade, modular offensive security platform built exclusively for Kali Linux. It orchestrates the installation, configuration, and management of **350+ security tools** across **27 specialized modules** covering the full offensive security lifecycle.

### Key Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Idempotent** | State machine tracks completed steps — safe to re-run |
| **Modular** | Each domain is an independent, self-contained module |
| **Validated** | Pre-install conflict detection + post-install verification |
| **Modern** | Tools updated to 2025/2026 standards (Nuclei v3, Go 1.24, .NET 8) |
| **AI-Ready** | Local LLM integration via ollama — runs 100% offline |
| **OPSEC-First** | TOR routing, MAC spoofing, log sanitization built-in |
| **Resumable** | Interrupted runs pick up exactly where they left off |

---

## 🆕 What's New in v7.0.0

### Core Engine Overhaul

| Component | Change |
|-----------|--------|
| `core/validator.sh` | **NEW** — Pre-install conflict detection, disk space checks, kernel feature validation |
| `core/network.sh` | **NEW** — Dedicated network module: connectivity checks, `git_clone` with auth/retry |
| `core/utils.sh` | Enhanced — parallel install, SHA256 checksum, GitHub API, Nim/dotnet support |
| `core/installers.sh` | Enhanced — `install_nim_tool()`, `install_dotnet_tool()`, `install_npm_tool()`, zip archive support |
| `core/logger.sh` | Enhanced — `debug()`, `section()`, `progress_bar()`, `dryrun()`, ETA tracking |
| `config/globals.sh` | Updated — 27-module paths, `AI_TOOLS_DIR`, `OPSEC_DIR`, `ADAPTIX_DIR`, Nim/dotnet paths |
| `config/tools.conf` | **NEW** — User-extensible INI file for custom tools without modifying core |

### New CLI Flags

```bash
--dry-run          # Preview all actions without making changes
--skip <step>      # Skip specific steps (repeatable)
--list-tools       # Show status of all 350+ tools
--update <tool>    # Update a single tool without full reinstall
--debug            # Verbose debug output
--no-snapshot      # Skip VM snapshot creation
```

### New Modules (v7.0.0)

| Module | Description |
|--------|-------------|
| `26_ai_tools.sh` | ollama LLM runtime, codestral, llama3, AIRecon agent, Nuclei AI integration |
| `27_opsec_tools.sh` | TOR, WireGuard, MAC spoofing, log sanitization, OPSEC profile |

### New Tools Added

#### Bug Bounty
- **Katana** — ProjectDiscovery web crawler
- **SSTImap** — Server-Side Template Injection scanner (Kali 2026)
- **XSStrike** — Advanced XSS detection/testing
- **WPProbe** — WordPress plugin enumeration
- **interactsh-client** — OOB interaction server client
- **pdtm** — ProjectDiscovery Tool Manager
- **Caido** — Modern lightweight Burp Suite alternative

#### Active Directory
- **certipy-ad** — Active Directory Certificate Services attacks
- **pywhisker** — Shadow Credentials attacks
- **DonPAPI** — DPAPI-based credential dumping
- **masky** — DCSync via Kerberos
- **manspider** — SMB spider for sensitive file discovery
- **ldeep** — Advanced LDAP enumeration
- **targetedKerberoast** — Targeted Kerberoasting attacks
- **BloodHound CE** — Community Edition Docker deployment

#### Red Team C2
- **AdaptixC2** — Go-based open-source modular C2 framework (Phase 9)
- Improved **Sliver** profiles and OPSEC configuration
- Improved **Havoc** build with dependency resolution

#### Evasion
- **Nimcrypt2** — Nim-based shellcode loader
- **OffensiveNim** — Nim offensive tool collection
- Indirect syscall templates for EDR bypass

#### Cloud Security
- **Prowler v3** — AWS/Azure/GCP security assessment
- **enumerate-iam** — AWS IAM privilege enumeration
- **Terraform security** scanning integration

#### AI & OPSEC
- **ollama** — Local LLM runtime (no data leakage)
- **codestral** — Code analysis AI model
- **llama3** — General security reasoning model
- **AIRecon** — Autonomous recon agent
- **tor + torsocks + nyx** — Anonymous routing stack
- **WireGuard** — Modern VPN
- **mac-randomize** — Helper for MAC address rotation
- **opsec-clean** — Automated log sanitization
- **ligolo-ng** — Advanced network tunneling

---

## 🏗 Architecture

```
kali-master-framework/
├── kali-master.sh              # Main orchestrator (entry point)
├── config/
│   ├── globals.sh              # Global constants, paths, color codes
│   ├── defaults.sh             # Default values + .env loader
│   └── tools.conf              # User-extensible tool definitions (NEW)
├── core/
│   ├── logger.sh               # Logging, banner, progress, ETA
│   ├── state.sh                # State machine & resume engine
│   ├── utils.sh                # Smart tool finder, wrappers, parallel install
│   ├── installers.sh           # Multi-tier install: apt/go/cargo/pip/nim/dotnet/npm
│   ├── validator.sh            # Pre-install validation & conflict detection (NEW)
│   └── network.sh              # Network helpers, git_clone, connectivity checks (NEW)
├── modules/
│   ├── 01_preflight.sh         # System checks, snapshot, network hardening
│   ├── 02_system_update.sh     # APT update, core packages, Rust/Nim/.NET
│   ├── 03_python_venv.sh       # Python venv, pip packages, AI/AD libraries
│   ├── 04_golang.sh            # Go runtime installation with checksum verify
│   ├── 05_docker.sh            # Docker CE, Compose v2, Portainer
│   ├── 06_bugbounty.sh         # 60+ bug bounty tools (PD suite, Go, Python)
│   ├── 07_reversing.sh         # RE toolkit: GDB/PEDA/GEF, Ghidra, radare2, ImHex
│   ├── 08_ctf.sh               # CTF toolkit: crypto, stego, pwntools, pwninit
│   ├── 09_ad_network.sh        # AD toolkit: Impacket, BloodHound, certipy, pywhisker
│   ├── 10_cloud_security.sh    # Cloud: AWS/Azure/GCP, Prowler, ScoutSuite, Trivy
│   ├── 11_wordlists.sh         # Wordlists: SecLists, rockyou, custom generators
│   ├── 12_shell_config.sh      # Zsh, Powerlevel10k, tmux, productivity tools
│   ├── 13_secrets.sh           # Secret scanning: trufflehog, gitleaks, BetterLeaks
│   ├── 14_vm_hardening.sh      # VM optimizations, kernel tuning, sysctl
│   ├── 15_update_manager.sh    # Ongoing updates for all installed tools
│   ├── 16_helper_scripts.sh    # 30+ custom helper scripts (bb-recon, ad-enum, etc.)
│   ├── 17_redteam_c2.sh        # C2 frameworks: Sliver, Havoc, Mythic, AdaptixC2, Empire
│   ├── 18_c2_redirector.sh     # C2 redirectors, SSL automation, nginx/caddy profiles
│   ├── 19_evasion_tools.sh     # EDR evasion: Nimcrypt2, OffensiveNim, ScareCrow
│   ├── 20_post_exploit.sh      # Post-exploitation: chisel, ligolo-ng, SharpCollection
│   ├── 21_lab_manager.sh       # Lab management: VMs, containers, target configs
│   ├── 22_c2_menu.sh           # Interactive C2 launcher menu
│   ├── 23_auto_fix.sh          # Auto-repair engine for broken tools
│   ├── 24_dashboard.sh         # System dashboard with tool status overview
│   ├── 25_health_check.sh      # Post-install health check & report
│   ├── 26_ai_tools.sh          # AI tools: ollama, codestral, AIRecon (NEW)
│   └── 27_opsec_tools.sh       # OPSEC: TOR, WireGuard, MAC spoof, log clean (NEW)
└── tools/
    ├── check-tools.sh          # Standalone tool status checker (NEW)
    ├── update-tools.sh         # Single-tool updater (NEW)
    └── backup-config.sh        # Configuration backup utility (NEW)
```

---

## 📦 Modules

### Module Map

| # | Module | Tools | Mode | Disk |
|---|--------|-------|------|------|
| 01 | Preflight | Checks, snapshot, DNS, IPv6, git | Full/Min | 0 GB |
| 02 | System Update | 100+ APT packages, Rust, Nim, .NET 8 | Full/Min | 5 GB |
| 03 | Python Venv | 40+ pip packages, AI libs, AD libs | Full/Min | 3 GB |
| 04 | Golang | Go 1.24+ with SHA256 verify | Full/Min | 2 GB |
| 05 | Docker | Docker CE + Compose v2 + Portainer | Full/Min | 5 GB |
| 06 | Bug Bounty | 60+ tools (PD suite, fuzzing, XSS, SQLi) | Full/Min | 3 GB |
| 07 | Reversing | Ghidra, GDB+PEDA+GEF, radare2, ImHex | Full | 8 GB |
| 08 | CTF | Crypto, stego, pwntools, forensics | Full | 4 GB |
| 09 | AD/Network | Impacket, BloodHound, certipy, 30+ tools | Full/Min | 3 GB |
| 10 | Cloud Security | AWS/Azure/GCP, Prowler, ScoutSuite | Full | 3 GB |
| 11 | Wordlists | SecLists, rockyou, custom generators | Full | 10 GB |
| 12 | Shell Config | Zsh, P10k, tmux, bat, fzf, productivity | Full/Min | 1 GB |
| 13 | Secrets | trufflehog, gitleaks, BetterLeaks | Full | 1 GB |
| 14 | VM Hardening | Sysctl, GRUB, kernel tuning | Full | 0 GB |
| 15 | Update Manager | Auto-update all tools | Full | — |
| 16 | Helper Scripts | 30+ custom recon/exploit automation scripts | Full | 0 GB |
| 17 | Red Team C2 | Sliver, Havoc, Mythic, AdaptixC2, Empire | Full | 10 GB |
| 18 | C2 Redirector | nginx/caddy SSL redirectors, Let's Encrypt | Full | 1 GB |
| 19 | Evasion | Nimcrypt2, OffensiveNim, shellcode loaders | Full | 4 GB |
| 20 | Post Exploit | chisel, ligolo-ng, SharpCollection, pspy | Full | 3 GB |
| 21 | Lab Manager | Docker labs, VPN configs, target mgmt | Full | 0 GB |
| 22 | C2 Menu | Interactive C2 launcher TUI | Full | 0 GB |
| 23 | Auto Fix | Self-healing broken tool installs | Full/Min | — |
| 24 | Dashboard | Live system & tool status dashboard | Full/Min | 0 GB |
| 25 | Health Check | Post-install report + coverage metrics | Full/Min | 0 GB |
| **26** | **AI Tools** 🆕 | **ollama, codestral, llama3, AIRecon** | Full | 20 GB |
| **27** | **OPSEC** 🆕 | **TOR, WireGuard, MAC spoof, log clean** | Full | 1 GB |

---

## 🛠 Complete Tool Arsenal

<details>
<summary><b>🕵️ Bug Bounty & Web Application Testing (60+ tools)</b></summary>

### ProjectDiscovery Suite
| Tool | Purpose |
|------|---------|
| `nuclei` v3 | Vulnerability scanner with 8000+ templates |
| `subfinder` | Passive subdomain enumeration |
| `httpx` | Fast HTTP probe & fingerprinting |
| `katana` | Modern web crawler |
| `naabu` | Port scanner |
| `dnsx` | DNS toolkit |
| `interactsh-client` | OOB interaction server |
| `cvemap` | CVE mapping |
| `pdtm` | Tool manager |
| `tlsx` | TLS analysis |
| `shuffledns` | DNS bruteforce |
| `asnmap` | ASN mapper |
| `uncover` | Shodan/Fofa/Censys search |
| `notify` | Multi-platform notifications |
| `alterx` | Subdomain permutation |
| `cloudlist` | Cloud asset enumeration |
| `proxify` | HTTP proxy toolkit |

### Fuzzing & Discovery
| Tool | Purpose |
|------|---------|
| `ffuf` | Fast web fuzzer |
| `gobuster` | Directory/DNS brute forcer |
| `feroxbuster` | Recursive directory scanner (Rust) |
| `dirsearch` | Web path scanner |
| `wfuzz` | Web fuzzer |
| `arjun` | HTTP parameter discovery |

### Web Analysis
| Tool | Purpose |
|------|---------|
| `dalfox` | XSS parameter analysis |
| `XSStrike` | Advanced XSS detection |
| `SSTImap` | SSTI vulnerability scanner |
| `WPProbe` | WordPress plugin enumeration |
| `ghauri` | SQL injection detection |
| `sqlmap` | SQL injection automation |
| `commix` | Command injection testing |
| `corsy` | CORS misconfiguration scanner |

### Recon & OSINT
| Tool | Purpose |
|------|---------|
| `gau` | GetAllUrls — historical URL fetcher |
| `waybackurls` | Wayback Machine URL fetcher |
| `hakrawler` | Fast web crawler |
| `gospider` | JavaScript-aware spider |
| `getJS` | JavaScript file extractor |
| `subjs` | Subdomain from JS files |
| `assetfinder` | Domain asset finder |
| `trufflehog` | Secret/credential scanner |
| `linkfinder` | JS endpoint extractor |
| `gron` | JSON grep-able flattener |
| `unfurl` | URL component parser |

</details>

<details>
<summary><b>🏰 Active Directory & Network Attacks (35+ tools)</b></summary>

### Authentication & Exploitation
| Tool | Purpose |
|------|---------|
| `crackmapexec` / `netexec` | Swiss army knife for AD |
| `evil-winrm` | WinRM shell with PTH |
| `impacket` suite | 20+ attack scripts |
| `responder` | LLMNR/NBT-NS poisoning |
| `mitm6` | IPv6 MITM for WPAD |

### Kerberos Attacks
| Tool | Purpose |
|------|---------|
| `kerbrute` | Kerberos user enumeration |
| `GetNPUsers` | AS-REP Roasting |
| `GetUserSPNs` | Kerberoasting |
| `ticketer` | Ticket forging (Silver/Golden) |
| `targetedKerberoast` | Targeted Kerberoasting 🆕 |

### Certificate Services (AD CS)
| Tool | Purpose |
|------|---------|
| `certipy-ad` | ESC1-ESC8 attacks 🆕 |
| `pywhisker` | Shadow Credentials 🆕 |

### Credential Dumping
| Tool | Purpose |
|------|---------|
| `secretsdump` | DCSync & SAM dump |
| `DonPAPI` | DPAPI credential harvest 🆕 |
| `ldapdomaindump` | LDAP data dump |
| `manspider` | SMB sensitive file spider 🆕 |

### Enumeration
| Tool | Purpose |
|------|---------|
| `bloodhound` + `bloodhound-python` | Attack path visualization |
| `rusthound` | Fast BloodHound collector (Rust) |
| `ldeep` | Advanced LDAP enumeration 🆕 |
| `windapsearch` | LDAP search tool |
| `enum4linux-ng` | SMB/LDAP enumeration |

</details>

<details>
<summary><b>🔴 Red Team C2 Frameworks (6+ frameworks)</b></summary>

| Framework | Protocol | Language | Notes |
|-----------|----------|----------|-------|
| **Sliver** | HTTP/S, DNS, mTLS, WireGuard | Go | Modern, recommended |
| **Havoc** | HTTP/S, SMB | C++/Go | UI-focused |
| **Mythic** | HTTP/S, TCP, SMB, DNS | Python | Docker-based, modular |
| **AdaptixC2** 🆕 | HTTP/S, SMB, TCP, DNS | Go | Open-source, BOF support |
| **Empire** | HTTP/S | Python | Post-exploitation focused |
| **Merlin** | HTTP/2, HTTP/3 | Go | HTTP/2 native |
| **NimPlant** | HTTP/S | Nim | Evasion-focused |
| **Covenant** | HTTP/S | .NET | C# covenant |

</details>

<details>
<summary><b>🛡 EDR Evasion & Anti-Detection (15+ tools)</b></summary>

| Tool | Technique |
|------|-----------|
| **Nimcrypt2** 🆕 | Nim shellcode loader with obfuscation |
| **OffensiveNim** 🆕 | Collection of offensive Nim tools |
| **ScareCrow** | DLL sideloading & EDR bypass |
| **Freeze** | Golang shellcode loader |
| **Donut** | Position-independent shellcode generator |
| **PEzor** | PE packer & obfuscator |
| **GadgetToJScript** | COM-based shellcode execution |
| **Indirect Syscalls** 🆕 | Templates for syscall-based evasion |
| **upx** | UPX packer for size reduction |
| **osslsigncode** | Authenticode signing |
| **msfvenom** | Payload generator |

</details>

<details>
<summary><b>🔬 Reverse Engineering (25+ tools)</b></summary>

| Tool | Purpose |
|------|---------|
| `ghidra` | NSA decompiler |
| `gdb` + pwndbg + GEF + PEDA | Dynamic analysis |
| `radare2` / `rizin` | Reverse engineering framework |
| `ImHex` | Advanced hex editor |
| `jadx` | Android APK decompiler |
| `binwalk` | Firmware analysis |
| `yara` | Malware pattern matching |
| `pwntools` | CTF exploitation framework |
| `capa` | FLARE malware capability detection |
| `floss` | FLARE string extractor |
| `one_gadget` | ROP gadget finder (Ruby) |
| `ropper` | ROP chain builder |
| `pefile` | PE file parser |
| `oletools` | Office malware analysis suite |
| `pwninit` | CTF binary patcher |

</details>

<details>
<summary><b>☁️ Cloud Security (20+ tools)</b></summary>

| Tool | Platform |
|------|---------|
| `aws` CLI | AWS |
| `az` CLI | Azure |
| `gcloud` | GCP |
| `Prowler v3` 🆕 | AWS/Azure/GCP audit |
| `ScoutSuite` | Multi-cloud audit |
| `enumerate-iam` 🆕 | AWS IAM privilege map |
| `cloudfox` | Cloud privilege escalation |
| `pacu` | AWS attack framework |
| `s3scanner` | S3 bucket finder |
| `Trivy` | Container & IaC scanning |
| `Terraform` | Infrastructure as Code |
| `cloud_enum` | Multi-cloud storage enum |

</details>

<details>
<summary><b>🤖 AI Security Tools (NEW in v7.0.0)</b></summary>

| Tool | Purpose |
|------|---------|
| **ollama** | Local LLM runtime (no cloud, no data leakage) |
| **codestral** | Code generation & exploit analysis model |
| **llama3:8b** | General security reasoning |
| **AIRecon** | Autonomous recon agent (local LLM-powered) |
| **Nuclei AI** | AI-enhanced vulnerability scanning |
| **openai SDK** | Optional cloud AI integration |
| **langchain** | LLM chaining for security workflows |

</details>

<details>
<summary><b>🕵 OPSEC Toolkit (NEW in v7.0.0)</b></summary>

| Tool/Script | Purpose |
|-------------|---------|
| **TOR + torsocks** | Traffic anonymization |
| **nyx** | TOR monitor |
| **WireGuard** | Modern VPN |
| **OpenVPN** | Traditional VPN |
| **proxychains4** | Proxy chaining |
| **macchanger** | MAC address spoofing |
| **mac-randomize** | Custom MAC rotation helper |
| **opsec-clean** | Log sanitization script |
| **tor-start** | TOR connectivity verifier |
| **ligolo-ng** | Advanced network tunneling |
| **socat** | Multi-protocol relay |
| **stunnel4** | SSL tunnel |
| **OPSEC Profile** | Pre-engagement settings loader |

</details>

---

## 📋 Requirements

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **OS** | Kali Linux 2024.x | Kali Linux 2026.x |
| **RAM** | 4 GB | 8+ GB |
| **Disk** | 50 GB free | 120+ GB free |
| **CPU** | 2 cores | 4+ cores |
| **Network** | Required | Stable broadband |
| **Privileges** | root | root |

### Disk Space per Domain

| Domain | Estimated Space |
|--------|----------------|
| Base system + APT | ~5 GB |
| Go runtime + tools | ~3 GB |
| Docker + containers | ~5 GB |
| Wordlists (full) | ~10 GB |
| Reverse Engineering | ~8 GB |
| C2 frameworks | ~10 GB |
| AI models (ollama) | ~15–20 GB |
| **Total (full install)** | **~60–80 GB** |

### Optional (but recommended)

```bash
# GitHub Token for higher API rate limits (5000 req/h vs 60)
export GITHUB_TOKEN="ghp_your_token_here"
```

---

## ⚡ Quick Start

```bash
# 1. Clone the framework
git clone https://github.com/vulnquest58/kali-master-framework
cd kali-master-framework

# 2. Make executable
chmod +x kali-master.sh tools/*.sh

# 3a. Full installation (recommended — ~2-4 hours)
sudo ./kali-master.sh

# 3b. Minimal installation (~15-20 minutes)
sudo ./kali-master.sh --minimal

# 3c. Preview without making any changes
sudo ./kali-master.sh --dry-run

# 4. With GitHub token for faster downloads
GITHUB_TOKEN=ghp_xxx sudo ./kali-master.sh
```

---

## 💻 Usage

### Basic Modes

```bash
# Full installation — all 27 modules
sudo ./kali-master.sh

# Minimal — core security tools only
sudo ./kali-master.sh --minimal

# Dry-run — preview every action without executing
sudo ./kali-master.sh --dry-run

# With debug output
sudo ./kali-master.sh --debug

# Auto-fix broken/missing tools
sudo ./kali-master.sh --fix
```

### Targeted Execution

```bash
# Run only Bug Bounty module
sudo ./kali-master.sh --step bugbounty

# Run only C2 frameworks
sudo ./kali-master.sh --step redteam_c2

# Run only AI tools
sudo ./kali-master.sh --step ai_tools

# Run only OPSEC setup
sudo ./kali-master.sh --step opsec_tools

# Run AD tools + C2 (sequential)
sudo ./kali-master.sh --step ad_network
sudo ./kali-master.sh --step redteam_c2
```

### Skipping Steps

```bash
# Skip AI tools (large models)
sudo ./kali-master.sh --skip ai_tools

# Skip multiple steps
sudo ./kali-master.sh --skip ai_tools --skip opsec_tools

# Skip wordlists (saves 10 GB)
sudo ./kali-master.sh --skip wordlists
```

### State Management

```bash
# Force re-run a completed step
sudo ./kali-master.sh --step bugbounty --force

# Reset state of a single step
sudo ./kali-master.sh --reset bugbounty

# Reset ALL state (fresh install)
sudo ./kali-master.sh --reset-all

# Check state without running
ls ~/.kali-master/state/
```

### Tool Management

```bash
# List all tools and their install status
sudo ./kali-master.sh --list-tools

# JSON output for scripting
./tools/check-tools.sh --json > tools_report.json

# Summary statistics
./tools/check-tools.sh --summary

# Update a specific tool
sudo ./kali-master.sh --update nuclei
sudo ./kali-master.sh --update subfinder
```

---

## 📖 CLI Reference

```
Usage: ./kali-master.sh [OPTIONS]

MODES:
  --minimal          Install core tools only (~15-20 min)
  --fix              Auto-fix broken/missing tools
  --dry-run          Preview all actions (no changes)
  --debug            Enable verbose debug output
  --no-snapshot      Skip VM snapshot creation

TARGETING:
  --step <name>      Run a single module only
  --skip <name>      Skip a module (repeatable)
  --force            Re-run even if already completed

STATE:
  --reset <name>     Reset a specific step's state
  --reset-all        Reset all state (fresh install)

TOOLS:
  --list-tools       Show status of all tracked tools
  --update <tool>    Update a single tool

ENVIRONMENT VARIABLES:
  GITHUB_TOKEN       GitHub token (increases rate limit 60→5000/h)
  MINIMAL_MODE=1     Same as --minimal
  FORCE=1            Same as --force
  DRY_RUN=1          Same as --dry-run
  DEBUG_MODE=1       Same as --debug
  PARALLEL_JOBS=4    Concurrent install jobs (default: 4)
  HTTP_TIMEOUT=90    Network timeout in seconds
  MAX_RETRIES=3      Download retry attempts
  SKIP_SNAPSHOT=1    Skip VM snapshot

AVAILABLE STEPS:
  preflight          System validation & network hardening
  system_update      APT packages, Rust, Nim, .NET 8
  python_venv        Python virtual environment & packages
  golang             Go runtime installation
  docker             Docker CE + Compose v2 + Portainer
  bugbounty          Bug bounty toolkit (60+ tools)
  reversing          Reverse engineering suite
  ctf                CTF toolkit
  ad_network         Active Directory & network attacks
  cloud_security     Cloud security assessment
  wordlists          Wordlist collections
  shell_config       Zsh, tmux, productivity tools
  secrets            Secret scanning tools
  vm_hardening       VM optimization & kernel tuning
  update_manager     Tool auto-update system
  helper_scripts     Custom automation scripts
  redteam_c2         C2 frameworks (6+ frameworks)
  c2_redirector      C2 SSL redirectors
  evasion_tools      EDR evasion toolkit
  post_exploit       Post-exploitation tools
  lab_manager        Lab & environment management
  c2_menu            Interactive C2 launcher
  auto_fix           Auto-repair engine
  dashboard          System dashboard
  health_check       Post-install health report
  ai_tools           AI tools & local LLMs [NEW]
  opsec_tools        OPSEC & anonymity toolkit [NEW]
```

---

## ⚙️ Configuration

### `.env` File Support

Create a `.env` file in the framework root:

```bash
# .env — Kali Master Framework v7.0.0

# GitHub token (strongly recommended)
GITHUB_TOKEN=ghp_your_token_here

# Installation behavior
MINIMAL_MODE=0
PARALLEL_JOBS=4
HTTP_TIMEOUT=90
MAX_RETRIES=3

# Skip options
SKIP_SNAPSHOT=1

# Go proxy
GOPROXY=https://proxy.golang.org,direct
```

### `config/tools.conf` — Custom Tools

Add your own tools without modifying core files:

```ini
# config/tools.conf
[go_tools]
mytool|go|github.com/author/mytool/cmd/mytool

[pip_tools]
my-scanner|pip|my-scanner-package

[git_tools]
custom-tool|git|https://github.com/me/custom-tool.git

[apt_packages]
extra-pkg|apt|extra-pkg-name
```

---

## 🔧 Core Engine

### State Machine

The framework uses a file-based state machine in `~/.kali-master/state/`:

```
~/.kali-master/
└── state/
    ├── framework_version       # Current framework version
    ├── preflight.done          # Marks step as completed
    ├── system_update.done
    ├── bugbounty.done
    └── ...
```

Steps with `.done` files are **skipped** on subsequent runs unless:
- `--force` flag is used
- `--reset <step>` is called
- Framework version changes

### Smart Tool Finder

`smart_find_tool()` searches across all package ecosystems:

```
Search order:
1. System PATH (command -v)
2. Go binaries:   ~/go/bin/
3. Cargo:         ~/.cargo/bin/
4. Pip/Local:     ~/.local/bin/
5. Nim:           ~/.nimble/bin/       ← NEW in v7.0.0
6. .NET tools:    ~/.dotnet/tools/     ← NEW in v7.0.0
7. Main venv:     /opt/kali-venv/bin/
8. Angr venv:     /opt/angr-venv/bin/
9. FLARE venv:    /opt/flare-venv/bin/
10. ScoutSuite:   /opt/scoutsuite-venv/bin/
11. Prowler:      /opt/prowler-venv/bin/ ← NEW
12. Tools dir:    /opt/tools/** (recursive depth 5)
13. pipx venvs:   ~/.local/share/pipx/**
```

### Installer Hierarchy

```
install_apt_tool()       → dpkg/apt-get
install_go_tool()        → go install + multi-proxy fallback
install_cargo_tool()     → cargo install
install_venv_tool()      → pip in venv
install_nim_tool()       → nimble install    ← NEW
install_dotnet_tool()    → dotnet tool install ← NEW
install_npm_tool()       → npm install -g   ← NEW
install_github_release() → API + tar.gz/zip ← Enhanced
install_from_url()       → direct + SHA256  ← NEW
install_py_github_tool() → pip then git clone fallback
git_clone()              → auth + retry + depth control ← NEW
```

### Pre-install Validation

The new `validator.sh` module checks before installing:

```bash
pre_install_check "module_name" required_gb tool1 tool2 ...
# ↓ Checks:
# • Disk space (configurable per module)
# • Required prerequisite tools
# • APT source health
# • Kernel feature compatibility
# • Tool conflicts
```

---

## 🚀 Advanced Features

### Dry-Run Mode

```bash
sudo ./kali-master.sh --dry-run
# Every action prints: [DRY] Would run: <command>
# No files are created, no packages installed
# Perfect for previewing what will happen
```

### Parallel Installation

```bash
# Use 8 parallel jobs for faster installs
PARALLEL_JOBS=8 sudo ./kali-master.sh
```

### AI-Assisted Recon (NEW)

```bash
# Start local LLM
ollama serve

# Interactive code analysis
ollama run codestral

# AI-powered autonomous recon
airecon -t target.com --model codestral

# Nuclei with AI-enhanced detection
nuclei -u target.com -ai
```

### OPSEC Workflow (NEW)

```bash
# Load OPSEC profile before any engagement
source /opt/opsec/opsec-profile.sh

# Start TOR routing
tor-start

# Randomize MAC address
mac-randomize eth0

# Route specific tool through TOR
proxychains4 nuclei -u target.com

# After engagement — sanitize traces
opsec-clean
```

### C2 Quick Start

```bash
# Launch C2 selection menu
c2-menu

# Direct C2 launch
sliver-server          # Start Sliver
havoc server           # Start Havoc
mythic-cli start       # Start Mythic (Docker)
nimplant server        # Start NimPlant
```

### Custom Helper Scripts

Post-installation, these custom scripts are available:

| Script | Purpose |
|--------|---------|
| `bb-recon <domain>` | Full automated bug bounty recon pipeline |
| `ad-enum <dc-ip>` | Active Directory enumeration automation |
| `c2-menu` | Interactive C2 framework launcher |
| `tor-start` | Start TOR + verify routing |
| `mac-randomize` | Random MAC address rotation |
| `opsec-clean` | Sanitize logs & digital traces |
| `check-tools` | Show status of all 350+ tools |

---

## 📊 Changelog

### v7.0.0 (June 2026) — Current

**🏗 Architecture**
- Added `core/validator.sh` — pre-install validation engine
- Added `core/network.sh` — dedicated network module with smart `git_clone()`
- Added `config/tools.conf` — user-extensible tool definitions
- All modules now support `--dry-run` and `DEBUG_MODE`
- State machine enhanced with version-aware tracking

**🆕 New Modules**
- `26_ai_tools.sh` — ollama, codestral, llama3, AIRecon, Nuclei AI
- `27_opsec_tools.sh` — TOR, WireGuard, MAC spoof, log sanitization

**🔨 New Installers**
- `install_nim_tool()` — Nim/nimble package manager
- `install_dotnet_tool()` — .NET global tools
- `install_npm_tool()` — Node.js global packages
- `install_from_url()` — Direct URL + SHA256 verification
- `download_verified()` — Checksum-verified downloads
- `github_latest_release()` — GitHub API release fetcher

**🛠 New CLI Flags**
- `--dry-run` `--skip` `--list-tools` `--update` `--debug` `--no-snapshot`

**🧰 New Tools**
- Katana, SSTImap, XSStrike, WPProbe, Caido, AdaptixC2
- certipy-ad, pywhisker, DonPAPI, manspider, targetedKerberoast
- Prowler v3, enumerate-iam, Nimcrypt2, OffensiveNim
- ollama, codestral, llama3, AIRecon
- ligolo-ng, macchanger, tor, wireguard

### v6.7.0 — Previous

- 25 modules, 300+ tools
- Initial modular architecture from monolithic `kali_master_v6.7.0.sh`
- ProjectDiscovery full suite, Sliver+Havoc+Mythic C2
- BloodHound, Impacket, certipy, AWS/Azure/GCP security

---

## 📝 Notes & Tips

> [!TIP]
> Set `GITHUB_TOKEN` before running to avoid rate limiting. Without it, GitHub API allows only 60 requests/hour — many tools may fail to install.

> [!NOTE]
> The full installation takes **2–4 hours** depending on your internet speed and CPU. Use `--minimal` for a 15–20 minute lightweight setup.

> [!IMPORTANT]
> Always take a **VM snapshot** before running the framework. The `01_preflight.sh` module handles this automatically (VMware, VirtualBox, BTRFS, LVM, Timeshift).

> [!WARNING]
> Some modules (AI tools, wordlists) require **10–20 GB** of disk space. Use `--skip ai_tools --skip wordlists` to save space.

> [!CAUTION]
> This framework is intended **exclusively for authorized security testing**. Never use these tools against systems you do not own or have explicit written permission to test.

---

## 🔒 Legal Disclaimer

This framework is provided for **educational and authorized security testing purposes only**.

- All tools installed by this framework must be used on systems you **own** or have **explicit written authorization** to test
- The author assumes **no liability** for misuse of this software
- Always comply with applicable laws in your jurisdiction
- Bug bounty hunters: only test within the **defined scope** of your engagement

---

## 👤 Author

<div align="center">

### Designed & Developed by

[![GitHub](https://img.shields.io/badge/GitHub-vulnquest58-181717?style=for-the-badge&logo=github)](https://github.com/vulnquest58)

**[vulnquest58](https://github.com/vulnquest58)**

*Offensive Security Researcher | Bug Bounty Hunter | Red Team Enthusiast*

---

*"Security through knowledge — break it to fix it."*

[![Follow on GitHub](https://img.shields.io/github/followers/vulnquest58?style=social)](https://github.com/vulnquest58)

</div>

---

## 📜 License

```
MIT License

Copyright (c) 2026 vulnquest58

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<div align="center">

**[⬆ Back to Top](#kali-master-framework-v700)**

Made with ❤️ and a lot of ☕ by **[vulnquest58](https://github.com/vulnquest58)**

</div>
