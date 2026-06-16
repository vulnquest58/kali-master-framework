#!/usr/bin/env python3
"""
Kali Tool Database Builder v3.0
Builds comprehensive SQLite database from apt-cache dump and configured lists
Supports: APT packages, ProjectDiscovery suite, bug bounty tools, aliases, dependencies
"""

import sqlite3
import subprocess
import re
import os
import time
from pathlib import Path
from typing import Dict, List, Optional

# Configuration
DB_DIR = Path.home() / ".kali-autoinstall"
DB_PATH = DB_DIR / "db" / "tools.sqlite"

# Ensure directories exist
DB_DIR.mkdir(parents=True, exist_ok=True)
(DB_DIR / "db").mkdir(exist_ok=True)
(DB_DIR / "cache").mkdir(exist_ok=True)
(DB_DIR / "logs").mkdir(exist_ok=True)
(DB_DIR / "custom").mkdir(exist_ok=True)


class ToolDatabaseBuilder:
    def __init__(self):
        self.conn = sqlite3.connect(str(DB_PATH))
        self.conn.row_factory = sqlite3.Row
        self.setup_schema()
        self.stats = {
            "apt": 0, "pip": 0, "go": 0, "cargo": 0,
            "github": 0, "snap": 0, "kali_tools": 0
        }
    
    def setup_schema(self):
        """Initialize database schema"""
        self.conn.executescript("""
            DROP TABLE IF EXISTS tools;
            DROP TABLE IF EXISTS tags;
            DROP TABLE IF EXISTS aliases;
            DROP TABLE IF EXISTS dependencies;
            DROP TABLE IF EXISTS post_install;
            
            CREATE TABLE tools (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                cmd             TEXT NOT NULL,
                pkg_name        TEXT NOT NULL,
                source          TEXT NOT NULL,
                source_url      TEXT,
                install_cmd     TEXT,
                description     TEXT,
                category        TEXT,
                version         TEXT,
                size_bytes      INTEGER,
                verified        INTEGER DEFAULT 0,
                verified_at     INTEGER,
                popularity      INTEGER DEFAULT 0,
                created_at      INTEGER DEFAULT (strftime('%s', 'now')),
                updated_at      INTEGER DEFAULT (strftime('%s', 'now')),
                UNIQUE(cmd, source)
            );
            
            CREATE TABLE tags (
                tool_id     INTEGER,
                tag         TEXT,
                FOREIGN KEY(tool_id) REFERENCES tools(id),
                UNIQUE(tool_id, tag)
            );
            
            CREATE TABLE aliases (
                alias       TEXT PRIMARY KEY,
                tool_cmd    TEXT NOT NULL,
                confidence  REAL DEFAULT 1.0,
                source      TEXT DEFAULT 'user'
            );
            
            CREATE TABLE dependencies (
                tool_cmd        TEXT,
                requires_cmd    TEXT,
                requires_type   TEXT DEFAULT 'soft',
                UNIQUE(tool_cmd, requires_cmd)
            );
            
            CREATE TABLE post_install (
                tool_cmd    TEXT PRIMARY KEY,
                command     TEXT NOT NULL,
                description TEXT
            );
            
            CREATE INDEX idx_tools_cmd ON tools(cmd);
            CREATE INDEX idx_tools_source ON tools(source);
            CREATE INDEX idx_tools_category ON tools(category);
            CREATE INDEX idx_tags_tag ON tags(tag);
            CREATE INDEX idx_aliases_alias ON aliases(alias);
            CREATE INDEX idx_dependencies_tool ON dependencies(tool_cmd);
            CREATE INDEX idx_post_install_tool ON post_install(tool_cmd);
        """)
        self.conn.commit()

    def parse_apt_cache(self):
        """Parse apt-cache dumpavail for available packages"""
        print("[1/6] Parsing APT cache...")
        
        try:
            result = subprocess.run(
                ["apt-cache", "dumpavail"],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode != 0:
                print(f"  ⚠ apt-cache failed: {result.stderr}")
                return
            
            packages = self._parse_deb822(result.stdout)
            
            for pkg in packages:
                pkg_name = pkg.get("Package", "")
                if not pkg_name:
                    continue
                
                binaries = self._extract_binaries_from_apt(pkg_name, pkg)
                
                for binary in binaries:
                    self._insert_tool(
                        cmd=binary,
                        pkg_name=pkg_name,
                        source="apt",
                        source_url=f"https://pkg.kali.org/pkg/{pkg_name}",
                        install_cmd=f"apt install {pkg_name}",
                        description=pkg.get("Description", "").split("\n")[0][:200],
                        category=self._guess_category(pkg_name),
                        version=pkg.get("Version", ""),
                        size_bytes=int(pkg.get("Installed-Size", 0)) * 1024,
                        tags=self._extract_tags(pkg)
                    )
                    self.stats["apt"] += 1
            
            print(f"  ✓ Found {self.stats['apt']} APT tools")
            
        except Exception as e:
            print(f"  ✗ APT parsing failed: {e}")
    
    def _parse_deb822(self, text: str) -> List[Dict]:
        """Parse Debian 822 format"""
        packages = []
        current = {}
        
        for line in text.split("\n"):
            if line == "":
                if current:
                    packages.append(current)
                    current = {}
            elif line.startswith(" "):
                if current:
                    last_key = list(current.keys())[-1]
                    current[last_key] += "\n" + line.strip()
            elif ":" in line:
                parts = line.split(":", 1)
                if len(parts) == 2:
                    current[parts[0].strip()] = parts[1].strip()
        
        if current:
            packages.append(current)
        
        return packages
    
    def _extract_binaries_from_apt(self, pkg_name: str, pkg_info: Dict) -> List[str]:
        """Extract possible binary names from package description/name"""
        binaries = [pkg_name]
        
        if pkg_name.endswith("-tools"):
            binaries.append(pkg_name.replace("-tools", ""))
        if pkg_name.startswith("python3-"):
            binaries.append(pkg_name.replace("python3-", ""))
        
        desc = pkg_info.get("Description", "")
        binary_pattern = re.compile(r'\b([a-z][a-z0-9-]{2,20})\s+(?:command|binary|tool)', re.I)
        for match in binary_pattern.finditer(desc):
            binaries.append(match.group(1))
        
        return list(set(binaries))
    
    def parse_kali_tools_page(self):
        """Populate official Kali Tools list"""
        print("[2/6] Parsing Kali tools page...")
        
        kali_tools = {
            # Information Gathering
            "nmap": {"category": "recon", "desc": "Network scanner"},
            "masscan": {"category": "recon", "desc": "Port scanner"},
            "zenmap": {"category": "recon", "desc": "Nmap GUI"},
            
            # Web Application Testing
            "sqlmap": {"category": "web", "desc": "SQL injection tool"},
            "nikto": {"category": "web", "desc": "Web server scanner"},
            "burpsuite": {"category": "web", "desc": "Web proxy (non-free)"},
            "dirb": {"category": "web", "desc": "Directory brute-forcer"},
            "dirbuster": {"category": "web", "desc": "Directory brute-forcer GUI"},
            "wfuzz": {"category": "web", "desc": "Web fuzzer"},
            "whatweb": {"category": "web", "desc": "Web technology identifier"},
            "wpscan": {"category": "web", "desc": "WordPress scanner"},
            "joomscan": {"category": "web", "desc": "Joomla scanner"},
            
            # Password Attacks
            "hydra": {"category": "password", "desc": "Login cracker"},
            "medusa": {"category": "password", "desc": "Login cracker"},
            "john": {"category": "password", "desc": "John the Ripper"},
            "hashcat": {"category": "password", "desc": "Password recovery"},
            "crackmapexec": {"category": "password", "desc": "Network pentesting"},
            "netexec": {"category": "password", "desc": "Network execution (nxc)"},
            
            # Wireless Attacks
            "aircrack-ng": {"category": "wireless", "desc": "WiFi cracking"},
            "reaver": {"category": "wireless", "desc": "WPS attack"},
            "pixiewps": {"category": "wireless", "desc": "WPS pixie dust"},
            "wifite": {"category": "wireless", "desc": "WiFi auditor"},
            
            # Exploitation Tools
            "metasploit-framework": {"category": "exploitation", "desc": "Exploitation framework"},
            "msfconsole": {"category": "exploitation", "desc": "Metasploit console"},
            
            # Sniffing & Spoofing
            "wireshark": {"category": "sniffing", "desc": "Network analyzer"},
            "tshark": {"category": "sniffing", "desc": "Terminal Wireshark"},
            "tcpdump": {"category": "sniffing", "desc": "Packet analyzer"},
            "bettercap": {"category": "sniffing", "desc": "MITM framework"},
            "responder": {"category": "sniffing", "desc": "LLMNR/NBT-NS poisoner"},
            "ettercap-text-only": {"category": "sniffing", "desc": "MITM suite"},
            
            # Vulnerability Analysis
            "openvas": {"category": "vuln", "desc": "Vulnerability scanner"},
            "nessus": {"category": "vuln", "desc": "Vulnerability scanner (non-free)"},
            "nuclei": {"category": "vuln", "desc": "Vulnerability scanner"},
            
            # Active Directory
            "bloodhound": {"category": "ad", "desc": "AD attack paths"},
            "impacket-scripts": {"category": "ad", "desc": "Network protocols"},
            "evil-winrm": {"category": "ad", "desc": "WinRM shell"},
            "certipy": {"category": "ad", "desc": "AD CS attacks"},
            "kerbrute": {"category": "ad", "desc": "Kerberos brute-forcer"},
            
            # Reverse Engineering
            "ghidra": {"category": "re", "desc": "Reverse engineering"},
            "radare2": {"category": "re", "desc": "Reverse engineering"},
            "gdb": {"category": "re", "desc": "GNU debugger"},
            "binwalk": {"category": "re", "desc": "Firmware analysis"},
            "volatility": {"category": "re", "desc": "Memory forensics"},
            
            # Forensics
            "autopsy": {"category": "forensics", "desc": "Digital forensics"},
            "sleuthkit": {"category": "forensics", "desc": "File system forensics"},
            "testdisk": {"category": "forensics", "desc": "Data recovery"},
            
            # Stress Testing
            "siege": {"category": "stress", "desc": "HTTP load testing"},
            "slowhttptest": {"category": "stress", "desc": "Slow HTTP DoS"},
        }
        
        for tool, info in kali_tools.items():
            self._insert_tool(
                cmd=tool,
                pkg_name=tool,
                source="kali_tools",
                source_url=f"https://www.kali.org/tools/{tool}/",
                install_cmd=f"apt install {tool}",
                description=info["desc"],
                category=info["category"],
                tags=[info["category"], "kali-official"]
            )
            self.stats["kali_tools"] += 1
        
        print(f"  ✓ Added {self.stats['kali_tools']} Kali official tools")

    def parse_projectdiscovery(self):
        """Add ProjectDiscovery tools"""
        print("[3/6] Adding ProjectDiscovery suite...")
        
        pd_tools = {
            "nuclei": "github.com/projectdiscovery/nuclei/v3/cmd/nuclei",
            "subfinder": "github.com/projectdiscovery/subfinder/v2/cmd/subfinder",
            "httpx": "github.com/projectdiscovery/httpx/cmd/httpx",
            "naabu": "github.com/projectdiscovery/naabu/v2/cmd/naabu",
            "katana": "github.com/projectdiscovery/katana/cmd/katana",
            "dnsx": "github.com/projectdiscovery/dnsx/cmd/dnsx",
            "asnmap": "github.com/projectdiscovery/asnmap/cmd/asnmap",
            "cdncheck": "github.com/projectdiscovery/cdncheck/cmd/cdncheck",
            "mapcidr": "github.com/projectdiscovery/mapcidr/cmd/mapcidr",
            "tlsx": "github.com/projectdiscovery/tlsx/cmd/tlsx",
            "shuffledns": "github.com/projectdiscovery/shuffledns/cmd/shuffledns",
            "uncover": "github.com/projectdiscovery/uncover/cmd/uncover",
            "interactsh-client": "github.com/projectdiscovery/interactsh/cmd/interactsh-client",
            "notify": "github.com/projectdiscovery/notify/cmd/notify",
            "alterx": "github.com/projectdiscovery/alterx/cmd/alterx",
            "cvemap": "github.com/projectdiscovery/cvemap/cmd/cvemap",
            "pdtm": "github.com/projectdiscovery/pdtm/cmd/pdtm",
            "cloudlist": "github.com/projectdiscovery/cloudlist/cmd/cloudlist",
            "proxify": "github.com/projectdiscovery/proxify/cmd/proxify",
            "simplehttpserver": "github.com/projectdiscovery/simplehttpserver/cmd/simplehttpserver",
        }
        
        for tool, go_pkg in pd_tools.items():
            self._insert_tool(
                cmd=tool,
                pkg_name=tool,
                source="go",
                source_url=f"https://{go_pkg}",
                install_cmd=f"go install {go_pkg}@latest",
                description=f"ProjectDiscovery {tool}",
                category="bug-bounty",
                tags=["bug-bounty", "recon", "projectdiscovery"]
            )
            self.stats["go"] += 1
        
        print(f"  ✓ Added {len(pd_tools)} ProjectDiscovery tools")

    def parse_bugbounty_tools(self):
        """Add popular bug bounty tools"""
        print("[4/6] Adding bug bounty tools...")
        
        bb_tools = {
            # Go tools
            "ffuf": ("go", "github.com/ffuf/ffuf/v2", "Fuzzing tool"),
            "gobuster": ("go", "github.com/OJ/gobuster/v3", "Directory brute-forcer"),
            "gau": ("go", "github.com/lc/gau/v2/cmd/gau", "URL discovery"),
            "hakrawler": ("go", "github.com/hakluke/hakrawler", "Web crawler"),
            "waybackurls": ("go", "github.com/tomnomnom/waybackurls", "Wayback Machine URLs"),
            "assetfinder": ("go", "github.com/tomnomnom/assetfinder", "Subdomain finder"),
            "httprobe": ("go", "github.com/tomnomnom/httprobe", "HTTP probing"),
            "anew": ("go", "github.com/tomnomnom/anew", "Deduplication"),
            "qsreplace": ("go", "github.com/tomnomnom/qsreplace", "Query string replacer"),
            "gf": ("go", "github.com/tomnomnom/gf", "Pattern matching"),
            "meg": ("go", "github.com/tomnomnom/meg", "Multi-host requests"),
            "unfurl": ("go", "github.com/tomnomnom/unfurl", "URL parsing"),
            "gron": ("go", "github.com/tomnomnom/gron", "JSON flattening"),
            "dalfox": ("go", "github.com/hahwul/dalfox/v2", "XSS scanner"),
            "trufflehog": ("go", "github.com/trufflesecurity/trufflehog/v3", "Secret scanner"),
            "gitleaks": ("go", "github.com/gitleaks/gitleaks", "Git secret scanner"),
            "cloudfox": ("go", "github.com/BishopFox/cloudfox", "AWS enumeration"),
            "ghauri": ("go", "github.com/r0oth3x49/ghauri", "SQLi tool"),
            "feroxbuster": ("cargo", "feroxbuster", "Directory brute-forcer"),
            
            # Python tools
            "arjun": ("pip", "arjun", "HTTP parameter discovery"),
            "waymore": ("pip", "waymore", "Wayback Machine enhanced"),
            "dnsgen": ("pip", "dnsgen", "DNS generation"),
            "dirsearch": ("pip", "dirsearch", "Directory scanner"),
            "commix": ("pip", "commix", "OS command injection"),
            "xsstrike": ("git", "https://github.com/s0md3v/XSStrike.git", "XSS scanner"),
            "corsy": ("git", "https://github.com/s0md3v/Corsy.git", "CORS scanner"),
            "linkfinder": ("git", "https://github.com/GerbenJavado/LinkFinder.git", "JS endpoints extractor"),
            "sublist3r": ("pip", "sublist3r", "Subdomain enumeration"),
        }
        
        for tool, (source, source_url, desc) in bb_tools.items():
            if source == "go":
                install_cmd = f"go install {source_url}@latest"
            elif source == "cargo":
                install_cmd = f"cargo install {source_url}"
            elif source == "pip":
                install_cmd = f"pip install {source_url}"
            else:
                install_cmd = source_url
            
            self._insert_tool(
                cmd=tool,
                pkg_name=tool,
                source=source,
                source_url=source_url,
                install_cmd=install_cmd,
                description=desc,
                category="bug-bounty",
                tags=["bug-bounty", "recon"]
            )
            self.stats[source] += 1
        
        print(f"  ✓ Added {len(bb_tools)} bug bounty tools")

    def add_common_aliases(self):
        """Add command aliases"""
        print("[5/6] Adding command aliases...")
        
        aliases = {
            "ff": "ffuf",
            "gob": "gobuster",
            "nuc": "nuclei",
            "sub": "subfinder",
            "http": "httpx",
            "nucle": "nuclei",
            "subfindr": "subfinder",
            "httx": "httpx",
            "nmpa": "nmap",
            "msf": "msfconsole",
            "nxc": "netexec",
            "cme": "crackmapexec",
            "r2": "radare2",
            "vol": "volatility",
            "ws": "wireshark",
        }
        
        for alias, tool in aliases.items():
            self.conn.execute(
                "INSERT OR REPLACE INTO aliases (alias, tool_cmd, confidence, source) VALUES (?, ?, ?, ?)",
                (alias, tool, 0.95, "system")
            )
        self.conn.commit()
        print(f"  ✓ Added {len(aliases)} aliases")

    def build_dependency_graph(self):
        """Build dependency graph and post-installation commands"""
        print("[6/6] Building dependency graph...")
        
        dependencies = {
            "bloodhound": {
                "requires": ["neo4j"],
                "post_install": "systemctl enable neo4j && systemctl start neo4j"
            },
            "metasploit-framework": {
                "requires": ["postgresql"],
                "post_install": "msfdb init"
            },
            "openvas": {
                "requires": ["redis-server", "postgresql"],
                "post_install": "gvm-setup"
            },
            "ghidra": {
                "requires": ["default-jdk"],
                "post_install": None
            },
            "wireshark": {
                "requires": ["libpcap-dev"],
                "post_install": "usermod -aG wireshark $USER"
            },
        }
        
        for tool, info in dependencies.items():
            for req in info.get("requires", []):
                self.conn.execute(
                    "INSERT OR REPLACE INTO dependencies (tool_cmd, requires_cmd, requires_type) VALUES (?, ?, ?)",
                    (tool, req, "hard")
                )
            
            if info.get("post_install"):
                self.conn.execute(
                    "INSERT OR REPLACE INTO post_install (tool_cmd, command, description) VALUES (?, ?, ?)",
                    (tool, info["post_install"], f"Post-install for {tool}")
                )
        
        self.conn.commit()
        print(f"  ✓ Built dependency graph for {len(dependencies)} tools")

    def _insert_tool(self, cmd: str, pkg_name: str, source: str, source_url: str,
                     install_cmd: str, description: str, category: str,
                     version: str = "", size_bytes: int = 0, tags: List[str] = None):
        """Insert tool entry securely"""
        try:
            cursor = self.conn.execute("""
                INSERT OR REPLACE INTO tools 
                (cmd, pkg_name, source, source_url, install_cmd, description, 
                 category, version, size_bytes, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (cmd, pkg_name, source, source_url, install_cmd, description,
                  category, version, size_bytes, int(time.time())))
            
            tool_id = cursor.lastrowid
            
            if tags:
                for tag in tags:
                    self.conn.execute(
                        "INSERT OR REPLACE INTO tags (tool_id, tag) VALUES (?, ?)",
                        (tool_id, tag)
                    )
        except Exception as e:
            pass

    def _guess_category(self, pkg_name: str) -> str:
        """Guess tool category"""
        categories = {
            "recon": ["nmap", "masscan", "amass", "subfinder", "sublist3r"],
            "web": ["sqlmap", "nikto", "dirb", "wfuzz", "burp"],
            "password": ["hydra", "medusa", "john", "hashcat", "crack"],
            "exploitation": ["metasploit", "msf", "exploit"],
            "sniffing": ["wireshark", "tcpdump", "ettercap", "bettercap"],
            "wireless": ["aircrack", "wifite", "reaver"],
            "forensics": ["autopsy", "sleuthkit", "volatility"],
            "ad": ["bloodhound", "impacket", "crackmapexec", "evil-winrm"],
            "re": ["ghidra", "radare", "gdb", "binwalk"],
        }
        
        for cat, keywords in categories.items():
            if any(kw in pkg_name.lower() for kw in keywords):
                return cat
        
        return "general"

    def _extract_tags(self, pkg_info: Dict) -> List[str]:
        """Extract tags from description text"""
        tags = []
        desc = pkg_info.get("Description", "").lower()
        
        tag_keywords = {
            "security": ["security", "pentest", "vulnerability"],
            "network": ["network", "tcp", "udp", "port"],
            "web": ["web", "http", "https", "url"],
            "forensics": ["forensic", "analysis", "recovery"],
            "exploitation": ["exploit", "payload", "shellcode"],
        }
        
        for tag, keywords in tag_keywords.items():
            if any(kw in desc for kw in keywords):
                tags.append(tag)
        
        return tags

    def build_all(self):
        """Run builder execution"""
        print("\n" + "="*60)
        print("KALI TOOL DATABASE BUILDER v3.0")
        print("="*60 + "\n")
        
        start_time = time.time()
        
        self.parse_apt_cache()
        self.parse_kali_tools_page()
        self.parse_projectdiscovery()
        self.parse_bugbounty_tools()
        self.add_common_aliases()
        self.build_dependency_graph()
        
        # Get final counts
        tool_count = self.conn.execute("SELECT COUNT(*) FROM tools").fetchone()[0]
        alias_count = self.conn.execute("SELECT COUNT(*) FROM aliases").fetchone()[0]
        dep_count = self.conn.execute("SELECT COUNT(*) FROM dependencies").fetchone()[0]
        
        duration = time.time() - start_time
        
        print("\n" + "="*60)
        print("BUILD COMPLETE")
        print("="*60)
        print(f"  Tools:        {tool_count:,}")
        print(f"  Aliases:      {alias_count:,}")
        print(f"  Dependencies: {dep_count:,}")
        print(f"  Duration:     {duration:.2f}s")
        print(f"  Database:     {DB_PATH}")
        print("="*60 + "\n")
        
        # Update last_sync
        with open(DB_DIR / "last_sync", "w") as f:
            f.write(str(int(time.time())))
        
        self.conn.close()


if __name__ == "__main__":
    builder = ToolDatabaseBuilder()
    builder.build_all()
