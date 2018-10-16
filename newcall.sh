#!/bin/bash

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

# Version 1.6.7

# VARS

# These are just place holders. They may be set/reset elsewhere.
DOMAIN=$1
FDOMAIN=${LCYAN}${1}${RESTORE}
DNS_SERVER='' # DNS server.
FDNS_SERVER='' # Formatted DNS server.
DNS='' # Used in Loop.  
SERVER='' # Used in propagation check.

# Formatting Vars
RESTORE=$(echo -en '\033[0m')       # Reset to normal TTY
LRED=$(echo -en '\033[01;31m')      # Bold Red
LGREEN=$(echo -en '\033[01;32m')    # Bold Green
LYELLOW=$(echo -en '\033[01;33m')   # Bold Yellow
LBLUE=$(echo -en '\033[01;94m')     # Bold Light Blue
LCYAN=$(echo -en '\033[01;36m')     # Bold Cyan
LMAGENTA=$(echo -en '\033[01;35m')  # Bold Magenta
WHITE=$(echo -en '\033[01;37m')     # Bold White
BBLUE=$(echo -en '\e[44m')      # Blue Background   
ULINE=$(echo -en '\033[4m')         # Underline

# DNS Servers
# Worldwide Public DNS servers.
# Worldwide servers only used for DNS propagation checking. Using the var
# name will not allow them to work. Only if the IP is entered.
# The default MUST be a truly public server as using a private server, like IMH,
# because it fails if the site is not hosted with that DNS server owner.
IMH='74.124.210.242'  # InMotion Hosting
RES='216.194.168.112' # IMH Resellers
GOOG='8.8.8.8'        # Google
CF='1.1.1.1'          # Cloudflare --DEFAULT--
L3='209.244.0.3'      # Level3
QUAD='9.9.9.9'        # Quad9
OPEN='208.67.222.222' # OpenDNS 
NIC='174.138.48.29'   # OpenNIC (New York)
VERI='64.6.64.6'      # Verisign
NORT='199.85.127.10'  # Norton ConnectSafe
COMO='8.20.247.20' 	  # Comodo Secure DNS
W1='84.200.69.80'     # DNS Watch
W2='202.53.93.10'     # Unknown (India)
W3='197.189.228.154'  # PowerDNS (South Africa)
W4='200.49.159.68'    # FiberTel (Argentina)
W5='202.46.127.227'   # CNX (Malaysia)
W6='41.217.204.165'   # Layer3 (Nigeria)
W7='45.71.185.100'    # OpenNIC (Ecuador)
W8='31.171.251.118'   # OpenNIC (Switzerland)
W9='51.254.25.115'    # OpenNIC (Czech Republic)
W10='139.59.18.213'   # OpenNIC (India)
W11='139.99.96.146'   # OpenNIC (Singapore)
W12='111.67.20.8'     # OpenNIC (Australia)
W13='5.132.191.104'   # OpenNIC (Austria)

# Set the default DNS server here:
DEFDNS="$CF"

## End VARS

# FUNCTIONS
usage() {
    echo "
Usage: newcall <domain> [dns | ..OPTIONS..]

<domain> - ${WHITE}Required${RESTORE} - This is the TLD to search.

[dns]    - (Optional) The DNS server to be used.
Built-In Public DNS Options include:
    imh | int: InMotion Hosting DNS Server
    res : InMotion Reseller DNS
    cf  : Cloudflare Public DNS --DEFAULT--
    goog: Google Public DNS
    open: OpenDNS Public DNS
    quad: Quad9 Public DNS
    l3  : Level3 Public DNS
    nic : OpenNIC Public DNS
    veri: Verisign
    nort: Norton ConnectSafe
    como: Comodo Secure DNS
    -OR- Any manually entered ${LCYAN}IP${RESTORE} for a public DNS server.

[OPTIONS] To be used in place of a DNS server.

    prop: This will run a DNS propagation test for the SOA record
          and display the result from each of the built-in DNS servers as well as
          a check of additional worldwide DNS servers for full propagation. This
		  check will first obtain the SOA from the authoritative name server for
		  the given domain, then compare it with the full list of DNS servers.
		  servers.  A summary at the end will report how many matches are found.
      NOTE: Using the 'prop' option ${ULINE}will${RESTORE} test international servers.
    mx  : This will run a check for MX records only using the
          default DNS servers.
    ns  : This will run a check of the NS records from WHOIS
          using the default DNS servers.    
    spf : This will run a check for SPF records.
    ptr : This will return the PTR for the given domain.
    arin: This runs an ARIN check on the "A" record of the domain.    
   dmarc: This will run a check for DMARC records.
    spam: This will check NS, PTR, MX, SPF and DMARC for causes for
          being marked as SPAM or being blacklisted.

EXAMPLES: newcall hummdis.com 
          newcall hummdis.com veri
          newcall hummdis.com 64.6.64.6
          newcall hummdis.com ns mx spf dmarc
"
}

default_search() {
    # For informational purposes, tell the user what DNS server we're using.
    echo "Using $FDNS_SERVER DNS Server for results."

    # By default, we'll check IP, Host, MX, and SOA.
    ip_search
    echo "----------"
    ns_check
    echo "----------"
    ptr_search
    echo "----------"
    mx_search
    echo "----------"
    soa_search
    
    echo -n "${LGREEN}Checks completed for${RESTORE} $FDOMAIN ${LGREEN}on: "
        date
    echo "Using DNS: $FDNS_SERVER" # Reprint to remind.

	# We're done. Don't allow the default_search to be stacked.
	exit 0
}

ip_search() {
    # IP information.
    echo "${LYELLOW}IP${RESTORE} (DNS A Record) for $FDOMAIN is:"
    dig @$DNS_SERVER $DOMAIN +short | sed 's/^/    /'
}

ptr_search () {
    # Host information
    echo "${LYELLOW}PTR Record${RESTORE} record for $FDOMAIN is:"
    host $(dig @$DNS_SERVER $DOMAIN +short) | sed 's/^/    /'
}

mx_search () {
    # MX information
    echo "${LYELLOW}MX Records${RESTORE} for $FDOMAIN is:"
    dig @$DNS_SERVER $DOMAIN MX +short | sed 's/^/    /'
}

soa_search() {
    # SOA information
    echo "${LYELLOW}SOA Record${RESTORE} for $FDOMAIN is:"
    dig @$DNS_SERVER $DOMAIN SOA +short | sed 's/^/    /'
}

whois_search() {
    # WHOIS information
    echo "${LYELLOW}WHOIS${RESTORE} for $FDOMAIN is:"
    whois -a -d $DOMAIN | grep 'Date:\|Expir\|Status:\|Registrar:' | sed 's/^/ /'
}

whois_check() {
    # This check will provide more details than the default WHOIS search.
    echo "${LYELLOW}WHOIS Expanded${RESTORE} for $FDOMAIN is:"
    whois -a -d $DOMAIN | grep 'Date:\|Expir\|Server:\|Status:\|DNSSEC:\|Email:\|Registrar:' | sed 's/^/ /'
}
	
arin_search() {
    # This performs an ARIN check on the domain given.
    echo "${LYELLOW}ARIN${RESTORE} for $FDOMAIN is:"
    whois -a -d $(dig @$DNS_SERVER $DOMAIN +short) | grep 'NetRange\|CIDR\|Organization\|City\|Country' | sed 's/^/    /'
}

ns_check() {
    # This performs the NS check for a given domain.
    echo "${LYELLOW}Name Servers${RESTORE} for $FDOMAIN are:"
    echo "  DIG results:"
	dig $DOMAIN NS +short | sed 's/^/    /'
	echo "  WHOIS NS results:"
	whois -a -d $DOMAIN | grep -i 'Name Server:' | sed 's/^/ /'
}

spf_check() {
    # Find the SPF records and print what's found.
    echo "${LYELLOW}SPF${RESTORE} for ${FDOMAIN}:"
    dig @$DNS_SERVER $DOMAIN TXT | grep 'v=spf' | sed 's/^/    /'
}

dmarc_check() {
    # See if there is a DMARC record for the domain.
    echo "${LYELLOW}DMARC${RESTORE} FOR ${FDOMAIN}:"
    dig @$DNS_SERVER _dmarc.$DOMAIN TXT | grep 'v=' | sed 's/^/    /'
}

set_dns() {
    # We have to do this so many times, just make a function for it.
    # It also allows for the loop to work more effectively.
    # Note: $1 in this case is the server passed to this function!
    DNS_SERVER=$1
    REV=`dig -x $DNS_SERVER +short`
    if [ -z "$REV" ]; then
        FDNS_SERVER=${WHITE}${1}${RESTORE}
    else
        FDNS_SERVER=${WHITE}${REV}${RESTORE}
    fi
}

prop_check() {
    # This is the DNS propgation check for the given domain. We'll check all
    # of the DNS servers we know, including some not used unless this is run.
    echo -e "\n${LYELLOW}***** WORLDWIDE DNS PROPAGATION CHECK FOR:${RESTORE} $FDOMAIN ${LYELLOW}*****${RESTORE}"
    
	DNS_COUNT=0
	MATCH=0
	for DNS in $IMH $RES $GOOG $CF $L3 $QUAD $OPEN $NIC $VERI $COMO $NORT \
	           $W1 $W2 $W3 $W4 $W5 $W6 $W7 $W8 $W9 $W10 $W11 $W12 $W13
    do
        DNS_COUNT=$((DNS_COUNT+1))
		set_dns $DNS
        
        # If there is not a PTR for the DNS record, for whatever reason, display the IPv4.
        if [ -z "$FDNS_SERVER" ]; then
            SERVER=${LCYAN}${DNS}${RESTORE}
        else # Display the PTR as given to us.
            SERVER=$FDNS_SERVER
        fi
        
        if [ "$DNS_COUNT" == 1 ]; then
            # First, we want to query the authoritative name server for the given domain.  This way
            # we can confirm if the SOA from other servers match the authoritative.
            AUTH_NS=`dig +noall +answer +authority $DOMAIN NS | awk '{ print $5 }' ORS=' ' | awk '{ print $1 }'`
            AUTH=`dig @$AUTH_NS $DOMAIN SOA +short | awk '{ print $3 }'`
            if [ -z "$AUTH" ]; then
                echo "Unable to obtain a valid SOA from authoritative name server ${AUTH_NS}."
                echo "Since this is the master, we have nothing to compare to."
                exit 1
            else
                # We have a valid result out of the gate. Use this.
                echo "${BBLUE}${WHITE}Authoritative NS (${AUTH_NS}) SOA Serial: ${AUTH}${RESTORE}"
                RESULT=`dig @$AUTH_NS $DOMAIN SOA +short`
                SOA=$AUTH
            fi
        else
            # We need the results of the query so that we can display an actual timeout message since
            # 'dig' doesn't display one for us. Also reports if nothing is returned.
            RESULT=`dig @$DNS $DOMAIN SOA +short`
        fi
        
        # If the result is empty, display a notice with the IP address of the server.
        if [ -z "$RESULT" ]; then
            ANSWER="No response from server (IP: ${DNS})"
            SOA='' # Reset so there's no match.
        else
  			SOA=`echo $RESULT | awk '{ print $3 }'`
        fi
    	
    	# Compare the two and increment if they match.
		if [ "$SOA" == "$AUTH" ]; then
            MATCH=$((MATCH+1))
            ANSWER=${LGREEN}${SOA}${RESTORE}
        else
            ANSWER=${LRED}${SOA}${RESTORE}
        fi
        
        # Print the results. Remember, FDNS_SERVER is already formatted.
        echo "DNS: ${SERVER}:"
        echo "    $ANSWER"
    done
    
    # Print the match results.
    echo "${LYELLOW}**** MATCH RESULTS: $MATCH OF ${DNS_COUNT} ****${RESTORE}"
	echo -e ""
}

## End FUNCTIONS

# Main portion. Process the arguments and perform checks.
# Make sure we got a domain provided. If not, display usage and exit.
case $1 in
    '' | -h | --help) # Nothing | -h | --help passed.
        usage
        exit 1
        ;;
    *)  # We have something! Then set the variables.
        # We're trusting the user gave a valid TLD. If not, the results will
        # show that it's invalid.
        DOMAIN=$1
        FDOMAIN=${LCYAN}${1}${RESTORE}
        ;;
esac

# If no argument is passed with the domain, we have to set $2 to something
# for the loop to work correctly and allow stacking of commands.
if [ -z "$2" ]; then
    # Leave $1 alone! Just set the $2 variable to the default NS
    set -- "$1" "$DEFDNS"
fi

# Loop through each of the passed arguments starting at the second one.
for i in "${@:2}"
do
    case $i in
        int | imh) # InMotion
            # See note in DNS variables to know why this can't be default.
            set_dns $IMH
            default_search
			;;
        res) # InMotion Reseller
            set_dns $RES
            default_search
            ;;
        goog) # Google
            set_dns $GOOG
            default_search
            ;;
        open) # OpenDNS
            set_dns $OPEN
            default_search
			;;
        quad) # Quad9
            set_dns $QUAD
            default_search
            ;;
        l3) # Level3
            set_dns $L3
            default_search
            ;;
        nic) # OpenNIC
            set_dns $NIC
            default_search
            ;;
        cf | '') # Cloudfare
            set_dns $CF
            default_search
            ;;
        veri) # Verisign
            set_dns $VERI
            default_search
            ;;
        nort) # Norton ConnectSafe
            set_dns $NORT
            default_search
            ;;
        como) # Comodo Secure DNS
            set_dns $COMO
            default_search
            ;;
        prop) # Check world DNS propagation.
            prop_check
            ;;
		# These can be stacked.
        arin) # Perform an ARIN IP check.
            set_dns $DEFDNS
            arin_search
            ;;
        mx) # Run the MX lookup only.
            set_dns $DEFDNS
            mx_search
            ;;
        ns) # Run a Name Server check only.
            ns_check
            ;;
        whois) # Get more WHOIS information.
            whois_check
            ;;
        spf) # Show only SPF records.
            set_dns $DEFDNS
            spf_check
            ;;
        dmarc) # Check DMARC records.
            set_dns $DEFDNS
            dmarc_check
            ;;
        a) # Check the "A" records only.
            set_dns $DEFDNS
            ip_search
            ;;
        spam) # Check NS, PTR, MX, SPF and DMARC entries to help find causes of spam.
            # This is NOT stackable. Only run this command, not others stacked.
            set_dns $DEFDNS
            ns_check
            ptr_search
            mx_search
            spf_check
            dmarc_check
            exit 0
            ;;
		ptr) # Print the PTR results.
			set_dns $DEFDNS
			ptr_search
			;;
        *) # Use the IP passed as the 2nd arg. We do validate IP, else show usage.
			if [[ "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
				set_dns $2
				default_search
			else
				echo "Invalid IPv4 address provided."
				usage
				exit 2
			fi
			;;
    esac
done

# All done!

exit 0
