#!/usr/bin/env python3
import os
import sys
import subprocess
import argparse
import datetime
import time
import re
from pathlib import Path

# --- Configuration & Globals ---
VERSION = "2.0.0"
HOME = str(Path.home())
RUN_PATH = os.path.join(HOME, "bin")
TEMP_DIR = f"/tmp/{os.getlogin()}"
WHOIS_DATA = os.path.join(HOME, "tmp", ".whois.data")
TUCOWS_DATA = os.path.join(HOME, "tmp", ".tucows.whois.data")
LAST_DNS_FILE = os.path.join(HOME, "bin", ".last_dns")
COLOR_FILE = os.path.join(HOME, ".newcall_colors")

# DNS Servers
DNS_SERVERS = {
    'IMH': '74.124.210.242', 'RES': '216.194.168.112', 'HUB': '173.205.127.4',
    'GOOG': '8.8.4.4', 'CF': '1.0.0.1', 'L3': '209.244.0.3', 'QUAD': '9.9.9.9',
    'Q9BL': '9.9.9.10', 'OPEN': '208.67.222.222', 'NIC': '172.98.193.42',
    'VERI': '64.6.64.6', 'NORT': '199.85.127.10', 'COMO': '8.20.247.20'
}

# --- ANSI Colors ---
class Colors:
    NC = '\033[0m'
    ALERT = '\033[1;31m'
    WARN = '\033[1;33m'
    HEAD = '\033[38;5;117m'
    COOL = '\033[32m'
    INFO = '\033[38;5;111m'
    HIL1 = '\033[36m'
    HIL2 = '\033[35m'
    WHT = '\033[01;7m'
    TITLE = '\033[44m'
    ULNE = '\033[4m'

# --- Helper Functions ---
def run_command(cmd, shell=False):
    """Utility to run shell commands and return output."""
    try:
        result = subprocess.run(cmd, shell=shell, check=False, 
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                               universal_newlines=True)
        return result.stdout.strip()
    except Exception as e:
        return ""

def get_default_dns():
    """Logic to rotate DNS servers to prevent rate limiting."""
    if not os.path.exists(LAST_DNS_FILE):
        Path(LAST_DNS_FILE).touch()
        last_dns = 0
    else:
        with open(LAST_DNS_FILE, 'r') as f:
            try:
                last_dns = int(f.read().strip())
            except:
                last_dns = 0
    
    next_dns = (last_dns % 9) + 1
    with open(LAST_DNS_FILE, 'w') as f:
        f.write(str(next_dns))
    
    mapping = {
        1: DNS_SERVERS['GOOG'], 2: DNS_SERVERS['CF'], 3: DNS_SERVERS['L3'],
        4: DNS_SERVERS['QUAD'], 5: DNS_SERVERS['OPEN'], 6: DNS_SERVERS['NIC'],
        7: DNS_SERVERS['VERI'], 8: DNS_SERVERS['NORT'], 9: DNS_SERVERS['COMO']
    }
    return mapping.get(next_dns, DNS_SERVERS['IMH'])

def set_whois(domain):
    """Sets the WHOIS server and saves data to temp file."""
    os.makedirs(os.path.dirname(WHOIS_DATA), exist_ok=True)
    tld = domain.split('.')[-1]
    
    if tld in ['com', 'net', 'edu']:
        whois_serv = f"{tld}.whois-servers.net"
    else:
        # Fetch redirected WHOIS server
        raw_iana = run_command(f"whois -f -h whois.iana.org {domain}", shell=True)
        match = re.search(r"(?:refer|redirected to):\s+(\S+)", raw_iana, re.I)
        whois_serv = match.group(1) if match else "whois.iana.org"

    raw_data = run_command(f"whois -f -d -h {whois_serv} {domain}", shell=True)
    with open(WHOIS_DATA, 'w') as f:
        f.write(raw_data)
    return raw_data

# --- Tool Functions ---
def ip_search(domain, dns_server):
    print(f"{Colors.HEAD}IP{Colors.NC} (DNS A Record) for {Colors.HIL1}{domain}{Colors.NC}:")
    ip = run_command(["dig", f"@{dns_server}", domain, "+short"])
    if ip:
        print(f"    {ip}")
    else:
        print(f"    {Colors.ALERT}No 'A' record (a.k.a. glue record) found.{Colors.NC}")
    return ip

def mx_search(domain, dns_server):
    print(f"{Colors.HEAD}MX Records{Colors.NC} for {Colors.HIL1}{domain}{Colors.NC}:")
    mx = run_command(["dig", f"@{dns_server}", domain, "MX", "+short"])
    if mx:
        sorted_mx = "\n".join([f"    {line}" for line in sorted(mx.splitlines())])
        print(sorted_mx)
        
        # Primary MX IP
        primary_mx_host = sorted(mx.splitlines())[0].split()[-1]
        mx_ip = run_command(["dig", "+short", primary_mx_host])
        if mx_ip:
            print(f"{Colors.HEAD}Primary MX Record IP{Colors.NC}: {mx_ip.splitlines()[0]}")
    return mx

def check_redirect(domain):
    print(f"{Colors.HEAD}Starting Domain Redirect Check{Colors.NC}")
    result = run_command(f"curl -sA 'IMH Newcall Redirect Check' -I http://{domain} | egrep 'HTTP|Location'", shell=True)
    print(result)

# --- Main CLI Logic ---
def main():
    parser = argparse.ArgumentParser(description=f"Newcall DNS Lookup Tool - v{VERSION}")
    parser.add_argument("domain", help="The domain/TLD to search")
    parser.add_argument("options", nargs='*', help="DNS server or specific checks (mx, spf, etc.)")
    parser.add_argument("--version", "-v", action="version", version=f"v{VERSION}")

    if len(sys.argv) < 2:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()
    domain = args.domain.lower().replace("http://", "").replace("https://", "").strip("/")
    
    # DNS Server Setup
    dns_server = get_default_dns()
    
    # Process Options
    if not args.options:
        # Default Full Search
        print(f"{Colors.TITLE}Using {dns_server} DNS Server for results.{Colors.NC}\n")
        set_whois(domain)
        ip_search(domain, dns_server)
        mx_search(domain, dns_server)
        # ... add other default checks here ...
    else:
        for opt in args.options:
            if opt == 'mx':
                mx_search(domain, dns_server)
            elif opt == 'redirect':
                check_redirect(domain)
            elif opt == 'a':
                ip_search(domain, dns_server)
            # Add other mappings for spf, dkim, etc.

    print(f"\n{Colors.COOL}Checks completed for {Colors.NC}{domain}{Colors.COOL} on: {datetime.datetime.now()}")

if __name__ == "__main__":
    main()
