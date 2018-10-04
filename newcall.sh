#!/bin/bash

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

# Version 1.4.5 | Created 2018/09/12 | Updated: 2018/09/29
# Changes
#       1.4.5: Changed colors so odd characters don't print.
#       1.4.4: WHOIS command using "grep -i" now.
#       1.4.3: Small modifications/adjustments.
#       1.4.2: Change the usage output just a bit. Nothing major.
#       1.4.1: Updated many areas to reduce lines of code.
#       1.4.1: Added Quad9, Reseller, Level3 as DNS built-ins.
#       1.4.1: Changed how the DNS server displays so that it's the name, not IP.
#       1.4.1: Updated manner in which colors are processed and displayed.

# Vars
RESTORE=$(echo -en '\033[0m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')

# DNS Servers
GOOG='8.8.8.8'         #Google
CF='1.1.1.1'           #CloudFlare
L3='209.244.0.3'       #Level3
QUAD='9.9.9.9'         #Quad9
IMH='74.124.210.242'   #InMotion Hosting
RES='216.194.168.112'  #IMH Resellers
OPEN='208.67.222.222'  #OpenDNS

# Functions
usage() {
    echo "Usage: newcall <domain> [dns]"
    echo ""
    echo "<domain> - ${WHITE}Required${RESTORE} - This is the TLD to search."
    echo ""
    echo "[dns]    - (Optional) The DNS server to be used."
    echo ""
    echo "${WHITE}Built-In Public DNS Options include:${RESTORE}"
    echo "  Default: 1.1.1.1 (Cloudfare Public DNS)"
    echo "  'imh' or 'int': InMotion DNS"
    echo "  'res': InMotion Reseller DNS"
    echo "  'goog': Google Public DNS"
    echo "  'open': OpenDNS Public DNS"
    echo "  'quad': Quad9 Public DNS"
    echo "  'l3': Level3 Public DNS"
    echo "  -OR- Any manually entered IP for a public DNS server."
    echo ""
    echo "EXAMPLES: newcall hummdis.com goog"
    echo "          newcall hummdis.com"
    echo "          newcall hummdis.com 64.6.64.6"
}

perform_search() {
    # For informational purposes, tell the user what DNS server we're using.
    echo "Using $FDNS_SERVER DNS Server for results."
    sleep 1

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
        # Some WHOIS servers respond in lowercase. We need to pass the '-i' in grep.
        whois $DOMAIN | grep 'Creation\|Expir\|Admin Email\|Server\|Status\|DNSSEC'
    echo "------"
    echo -n "${LGREEN}Checks completed for${RESTORE} $FDOMAIN ${LGREEN}on:"
        date
    echo "Using DNS: $FDNS_SERVER" # Reprint to remind.
}

set_dns() {
    # We have to do this so many times, just make a function for it.
    DNS_SERVER=$1
    FDNS_SERVER=${LCYAN}`dig @$DNS_SERVER -x $DNS_SERVER +short`${RESTORE}
}

prop_check() {
    # This is the DNS propgation check for the given domain. We'll check all
    # of the DNS servers we know.
    echo "${LRED}***** CHECKING DNS PROPAGATION FOR ${DOMAIN}${RESTORE}"
    for DNS in $GOOG $CF $L3 $QUAD $IMH $RES $OPEN
    do
        set_dns $DNS
        echo "DNS: ${LBLUE}${FDNS_SERVER}${RESTORE}:"
        echo ${LYELLOW}`dig @$DNS $DOMAIN SOA +short`${RESTORE}
    done
}

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
    '') # Default is Cloudfare.
        set_dns $CF
        perform_search
        ;;
    prop) # Check all for propagation.
        prop_check 
        ;;
    *) # Use whatever was passed as the 2nd argument. We assume valid IP.
        set_dns $2
        perform_search
        ;;
esac

exit 0
