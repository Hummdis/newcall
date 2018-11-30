#!/usr/bin/env python

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

# Version 1.0.0

# This file replaces the 'newcall.sh' script because we want to do some more
# complex things that are, quite frankly, harder to do in BASH.

import os
import sys
import socket
import dns.resolver
import traceback

domain = sys.argv[1]

# For this matrix, the switch is 0, the IP is 1 and the formal name is 2.
# Thus, calling the Verisign IP would appear as: servers[8][1]
servers = [ ['imh',  '74.124.210.242',  "InMotion Hosting"],
            ['goog', '8.8.8.8',         "Google Public DNS"],
            ['cf',   '1.1.1.1',         "Cloudflare Public DNS"],
            ['l3',   '209.244.0.3',     "Level3 Public DNS"],
            ['quad', '9.9.9.9',         "Quad9 Public DNS"],
            ['q9bl', '9.9.9.10',        "Quad9 No Blocks DNS"],
            ['open', '208.67.222.222',  "OpenDNS"],
            ['nic',  '165.227.22.116',  "OpenNIC USA"],
            ['veri', '64.6.64.6',       "Verisign Public DNS"],
            ['nort', '199.85.127.10',   "Norton ConnectSafe"],
            ['como', '8.20.247.20',     "COMODO Secure DNS"],
            ['w1',   '51.254.25.115',   "OpenNIC (Czech Republic)"],
            ['w2',   '202.53.93.10',    "OpenNIC (India)"],
            ['w3',   '197.189.228.154', "OpenNIC (South Africa)"],
            ['w4',   '200.49.159.68',   "OpenNIC (Argentina)"],
            ['w5',   '202.46.127.227',  "OpenNIC (Malaysia)"],
            ['w6',   '41.217.204.165',  "OpenNIC (Nigeria)"],
            ['w7',   '45.71.185.100',   "OpenNIC (Ecuador)"],
            ['w8',   '195.154.226.236', "OpenNIC (France)"],
            ['w9',   '82.141.39.32',    "OpenNIC (Germany)"],
            ['w10',  '178.17.170.179',  "OpenNIC (Moldova, Republic of)"],
            ['w11',  '139.99.96.146',   "OpenNIC (Singapore)"],
            ['w12',  '207.148.83.241',  "OpenNIC (Australia)"],
            ['w13',  '5.132.191.104',   "OpenNIC (Austria)"],
            ['w14',  '172.98.193.42',   "OpenNIC (BackplaneDNS)"],
            ['w15',  '91.217.137.37',   "OpenNIC (Russia)"],
            ['w16',  '146.185.176.36',  "OpenNIC (Netherlands)"],
            ['w17',  '192.71.245.208',  "OpenNIC (Italy)"],
            ['w18',  '192.99.85.244',   "OpenNIC (Canada)"],
            ['w19',  '104.238.186.189', "OpenNIC (UK Great Britain)"]
            ]
default_nameserver = servers[5]

def nssearch(opt):
    # Search the 'servers' array for the given option.
    for record in servers:
        for data in record:
            if data == opt:
                return record
    error = "Name Server option '%s' not found. Using default" % (opt)
    print termcolors.RED + error + termcolors.END
    return default_nameserver

class termcolors:
    # Formatting Vars
    END         = '\033[0m'        # Reset to normal TTY
    RED         = '\033[01;31m'    # Bold Red
    GREEN       = '\033[01;32m'    # Bold Green
    YELLOW      = '\033[01;33m'    # Bold Yellow
    BLUE        = '\033[01;94m'    # Bold Light Blue
    CYAN        = '\033[01;36m'    # Bold Cyan
    MAGENTA     = '\033[01;35m'    # Bold Magenta
    WHITE       = '\033[01;37m'    # Bold White
    BLUEBK      = '\033[44m'       # Blue Background   
    UNDERLINE   = '\033[4m'        # Underline
    HEADER      = '\033[01;44;37m' #Blue Background w/ Bold White Text

myResolver = dns.resolver.Resolver() #create a new instance named 'myResolver'

if len(sys.argv) < 3:
    nsopt = default_nameserver
else:
    nsopt = nssearch(sys.argv[2])

myResolver.nameservers = [ nsopt[1] ]

header = "Query using Name Server: %s (%s)" % (nsopt[1], nsopt[2])
print termcolors.HEADER + header + termcolors.END

try:
    
    print termcolors.YELLOW + "'A' Records" + termcolors.END \
        + " for %s:" % (domain)
    dnsA = myResolver.query(domain, "A") #Lookup the 'A' record(s)
    for rdata in dnsA: #for each response
        print "    %s" % (rdata) #print the data
        ip = rdata
    
    # This is broken right now because the 'ip' var is not
    # a sting. It must first be converted to a string to work.
#    print termcolors.YELLOW + "PTR Records" + termcolors.END \
#        + " for %s:" % (ip)
#    req = '.'.join(reversed(ip.split("."))) + ".in-addr.arpa"
#    dnsPTR = myResolver.query(req, "PTR")
#    for ptrdata in dnsPTR:
#        print "    %s" % (ptrdata)        

    print termcolors.YELLOW + "MX Records" + termcolors.END \
        + " for %s:" % (domain)
    dnsMX = myResolver.query(domain, "MX")
    for rdata in dnsMX:
        print "    %s" % (rdata)

    print termcolors.YELLOW + "NS Records" + termcolors.END \
        + " for %s:" % (domain)
    dnsNS = myResolver.query(domain, "NS")
    for rdata in dnsNS:
        print "    %s" % (rdata)

    print termcolors.YELLOW + "TXT Records" + termcolors.END \
        + " for %s:" % (domain)
    dnsTXT = myResolver.query(domain, "TXT")
    for rdata in dnsTXT:
        print "    %s" % (rdata)
    
except Exception:
   print "Query failed."
#    traceback.print_exc()

