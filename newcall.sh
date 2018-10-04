#!/bin/bash

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

# Version 1.5.0

# VARS

# These are just place holders. They're set elsewhere.
DOMAIN='' # The passed domain.
FDOMAIN='' # Formatted domain.
DNS_SERVER='' # DNS server.
FDNS_SERVER='' # Formatted DNS server.
DNS='' # Used in Loop

# Formatting Vars
RESTORE=$(echo -en '\033[0m')       # Reset to normal TTY
LRED=$(echo -en '\033[01;31m')      # Bold Red
LGREEN=$(echo -en '\033[01;32m')    # Bold Green
LYELLOW=$(echo -en '\033[01;33m')   # Bold Yellow
LBLUE=$(echo -en '\033[01;94m')     # Bold Light Blue
LCYAN=$(echo -en '\033[01;36m')     # Bold Cyan
LMAGENTA=$(echo -en '\033[01;35m')  # Bold Magenta
WHITE=$(echo -en '\033[01;37m')     # Bold White
ULINE=$(echo -en '\033[4m')         # Underline

# DNS Servers - If you add any here, be sure to add them to the CASE construct.
# Worldwide Public DNS servers from public-dns.info. Valid as of: Oct '18.
# Worldwide servers only used for DNS propagation checking. Enterying the var
# name will NOT allow them to work. Only if the IP is entered.
GOOG='8.8.8.8'              #Google
CF='1.1.1.1'                #Cloudflare
L3='209.244.0.3'            #Level3
QUAD='9.9.9.9'              #Quad9
IMH='74.124.210.242'        #InMotion Hosting
RES='216.194.168.112'       #IMH Resellers
OPEN='208.67.222.222'       #OpenDNS
NIC='174.138.48.29'         #OpenNIC
UK='5.133.40.77'            #PowerDNS (UK)
INDIA='103.49.206.241'      #Ongole (India)
CHINA='180.76.76.76'        #Baidu DNS (China)
SAFRICA='197.189.228.154'   #PowerDNS (South Africa)
DUNDER='212.186.238.209'    #UPC Business (Australia)
SAMERICA='200.49.159.68'    #FiberTel (Argentina)

## End VARS

# FUNCTIONS
usage() {
    echo ""
    echo "${LRED}Usage${RESTORE}: newcall <domain> [dns]"
    echo ""
    echo "<domain> - ${WHITE}Required${RESTORE} - This is the TLD to search."
    echo ""
    echo "[dns]    - (Optional) The DNS server to be used."
    echo ""
    echo "${WHITE}Built-In Public DNS Options include:${RESTORE}"
    echo "  Default: 1.1.1.1 (Cloudflare Public DNS)"
    echo "  'imh' or 'int': InMotion Hosting DNS"
    echo "  'res': InMotion Reseller DNS"
    echo "  'goog': Google Public DNS"
    echo "  'open': OpenDNS Public DNS"
    echo "  'quad': Quad9 Public DNS"
    echo "  'l3': Level3 Public DNS"
    echo "  'nic': OpenNIC Public DNS"
    echo "  'vz': Verizon Germany DNS"
    echo "  -OR- Any manually entered IP for a public DNS server."
    echo ""
    echo "  '${LRED}prop${RESTORE}': This will run a DNS propagation test for the SOA record"
    echo "          and display the result from each of the built-in DNS"
    echo "          servers. You'll need to compare the SOA serial numbers"
    echo "          of each output to see if the SOAs match. If they do,"
    echo "          then propagation has reached the DNS server in question."
    echo "  ${LBLUE}NOTE:${RESTORE} Using the 'prop' option ${ULINE}will${RESTORE} test international servers."
    echo ""
    echo "EXAMPLES: newcall hummdis.com goog"
    echo "          newcall hummdis.com"
    echo "          newcall hummdis.com 64.6.64.6"
    echo ""
}

perform_search() {
    # For informational purposes, tell the user what DNS server we're using.
    echo "Using $FDNS_SERVER DNS Server for results."

    # IP information.
    echo "------"
    echo "The ${LYELLOW}IP${RESTORE} for $FDOMAIN is:"
        dig @$DNS_SERVER $DOMAIN +short
    echo "------"

    # Host information
    echo "The ${LYELLOW}PTR${RESTORE} record for $FDOMAIN is:"
        host $(dig @$DNS_SERVER $DOMAIN +short)
    echo "------"

    # MX information
    echo "The ${LYELLOW}MX${RESTORE} for $FDOMAIN is:"
        dig @$DNS_SERVER $DOMAIN MX +short
    echo "------"

    # SOA information
    echo "The ${LYELLOW}SOA${RESTORE} for $FDOMAIN is:"
        dig @$DNS_SERVER $DOMAIN SOA +short
    echo "------"

    # WHOIS information
    echo "The ${LYELLOW}WHOIS${RESTORE} for $FDOMAIN is:"
        whois -H $DOMAIN | grep 'Date:\|Expir\|Email:\|Server:\|Status:\|DNSSEC:'
    echo "------"
    echo -n "${LGREEN}Checks completed for${RESTORE} $FDOMAIN ${LGREEN}on: "
        date
    echo "Using DNS: $FDNS_SERVER" # Reprint to remind.
}

set_dns() {
    # We have to do this so many times, just make a function for it.
    # It also allows for the loop to work more effectively.
    DNS_SERVER=$1
    FDNS_SERVER=${LCYAN}`dig -x $DNS_SERVER +short`${RESTORE}
}

prop_check() {
    # This is the DNS propgation check for the given domain. We'll check all
    # of the DNS servers we know.
    echo "${LRED}***** CHECKING DNS PROPAGATION FOR: ${DOMAIN} *****${RESTORE}"
    for DNS in $IMH $RES $CF $GOOG $L3 $QUAD $OPEN $NIC $SAMERICA $UK $INIDA $JAPAN $SAFRICA $DUNDER
    do
        set_dns $DNS
        echo "DNS: ${LBLUE}${FDNS_SERVER}${RESTORE}:"
        echo ${LYELLOW}`dig @$DNS $DOMAIN SOA +short | cut -d ' ' -f3 -`${RESTORE}
    done
}

## End FUNCTIONS

# Actual tool process.

# Make sure we got a domain provided. If not, display usage and exit.
case $1 in
    ''|'-h'|'--help') # Nothing | -h | --help passed.
        usage
        exit 1
        ;;
    *)  # We have something! Then set the variables.
        # We're trusting the user gave a valid TLD. If not, the results will
        # show that it's invalid.
        DOMAIN=$1
        FDOMAIN=${LCYAN}$1${RESTORE}
        ;;
esac

# Now, to determine the DNS server entered/requested.
case $2 in
    imh|int) # InMotion
        set_dns $IMH
        perform_search
        ;;
    res) # InMotion Reseller
        set_dns $RES
        perform_search
        ;;
    goog) # Google
        set_dns $GOOG
        perform_search
        ;;
    open) # OpenDNS
        set_dns $OPEN
        perform_search
        ;;
    quad) # Quad9
        set_dns $QUAD
        perform_search
        ;;
    l3) # Level3
        set_dns $L3
        perform_search
        ;;
    prop) # Check all for propagation.
        prop_check 
        ;;
    nic) # OpenNIC
        set_dns $NIC
        perform_search
        ;;
    '') # Default is Cloudfare.
        set_dns $CF
        perform_search
        ;;
    *) # Use whatever was passed as the 2nd argument. We assume valid IP.
        set_dns $2
        perform_search
        ;;
esac

# All done!

exit 0
