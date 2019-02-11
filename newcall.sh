#!/bin/bash

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

<<<<<<< HEAD
# Version 1.7.0
=======
# Version 1.6.15
>>>>>>> master

# VARS

# These are just place holders. They may be set/reset elsewhere.
DOMAIN=$1
FDOMAIN=${LCYAN}${1}${RESTORE}
DNS_SERVER='' # DNS server.
FDNS_SERVER='' # Formatted DNS server.
DNS='' # Used in Loop.  
SERVER='' # Used in propagation check.

# Formatting Vars
RESTORE=$(echo -en '\033[0m')		# Reset to normal TTY
LRED=$(echo -en '\033[01;31m')		# Bold Red
LGREEN=$(echo -en '\033[01;32m')		# Bold Green
LYELLOW=$(echo -en '\033[01;33m')	# Bold Yellow
LBLUE=$(echo -en '\033[01;94m')		# Bold Light Blue
LCYAN=$(echo -en '\033[01;36m')		# Bold Cyan
LMAGENTA=$(echo -en '\033[01;35m')	# Bold Magenta
WHITE=$(echo -en '\033[01;37m')		# Bold White
BBLUE=$(echo -en '\e[44m')      		# Blue Background   
ULINE=$(echo -en '\033[4m')			# Underline

# DNS Servers
# Worldwide Public DNS servers.
# Worldwide servers only used for DNS propagation checking. Using the var
# name will not allow them to work. Only if the IP is entered.
# The default MUST be a truly public server as using a private server, like
# InMotion Hosting or any other non-public DNS server, because it fails if
# the site is not hosted with that DNS server owner.
IMH='74.124.210.242'  # InMotion Hosting
RES='216.194.168.112' # IMH Reseller Servers
GOOG='8.8.8.8'        # Google
CF='1.1.1.1'          # Cloudflare
L3='209.244.0.3'      # Level3
QUAD='9.9.9.9'        # Quad9
Q9BL='9.9.9.10'		  # Quad9 No Blocks DNS --DEFAULT--
OPEN='208.67.222.222' # OpenDNS 
NIC='165.227.22.116'  # OpenNIC (USA)
VERI='64.6.64.6'      # Verisign
NORT='199.85.127.10'  # Norton ConnectSafe
COMO='8.20.247.20' 	  # Comodo Secure DNS
W1='51.254.25.115'    # OpenNIC (Czech Republic)
W2 ='202.53.93.10'     # NetLinx (India)
W3='197.189.228.154'  # PowerDNS (South Africa)
W4='200.49.159.68'    # FiberTel (Argentina)
W5='202.46.127.227'   # CNX (Malaysia)
W6='41.217.204.165'   # Layer3 (Nigeria)
W7='45.71.185.100'    # OpenNIC (Ecuador)
W8='195.154.226.236'  # OpenNIC (France)
W9='82.141.39.32'     # OpenNIC (Germany)
W10='178.17.170.179'  # OpenNIC (Moldova, Republic of)
W11='139.99.96.146'   # OpenNIC (Singapore)
W12='207.148.83.241'  # OpenNIC (Australia)
W13='5.132.191.104'   # OpenNIC (Austria)
W14='172.98.193.42'   # OpenNIC (BackplaneDNS)

# Set the default DNS server here:
DEFDNS="$Q9BL"

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
    cf  : Cloudflare Public DNS
    goog: Google Public DNS
    open: OpenDNS Public DNS
    quad: Quad9 Public DNS
	q9bl: Quad9 Public DNS (No block access) --DEFAULT--
    l3  : Level3 Public DNS
    nic : OpenNIC Public DNS
    veri: Verisign Public DNS
    nort: Norton ConnectSafe
    como: Comodo Secure DNS
    -OR- Any manually entered ${LCYAN}IP${RESTORE} for a public DNS server.

[OPTIONS] To be used in place of a DNS server.

    prop: This will run a DNS propagation test for the SOA record
          and display the result from each of the built-in DNS servers as well
		  as a check of additional worldwide DNS servers for full propagation.
          This check will first obtain the SOA from the authoritative name server for
		  the given domain, then compare it with the full list of DNS servers.
		  servers.  A summary at the end will report how many matches are found.
      NOTE: Using the 'prop' option ${ULINE}will${RESTORE} test international servers.
    a   : Display the 'A' record only.
    mx  : This will run a check for MX records only using the
          default DNS servers.
    ns  : This will run a check of the NS records from WHOIS
          using the default DNS servers.    
    spf : This will run a check for SPF records.
    ptr : This will return the PTR for the given domain.
    arin: This runs an ARIN check on the 'A' record of the domain.    
   dmarc: This will run a check for DMARC records.
    dkim: This will run a check for DKIM records.
    spam: This will check NS, PTR, MX, SPF and DMARC for causes for
          being marked as SPAM or being blacklisted.

EXAMPLES: newcall hummdis.com 
          newcall hummdis.com veri
          newcall hummdis.com 8.8.4.4
          newcall hummdis.com ns mx spf dmarc
"
}

default_search() {
    # For informational purposes, tell the user what DNS server we're using.
    clear # Clear the screen when running this operation.
    echo "${BBLUE}${WHITE}Using $FDNS_SERVER${BBLUE}${WHITE} (${DNS_SERVER})\
 DNS Server for results.${RESTORE}"

    echo ""

    # By default, we'll check IP, Host, MX, and SOA.
    ip_search
    ns_check
    ptr_search
    mx_search
    soa_search
	
	echo ""    
    echo -n "${LGREEN}Checks completed for${RESTORE} $FDOMAIN ${LGREEN}on: "
        date
    # Print reminder.
	echo "Using DNS: $FDNS_SERVER${LGREEN} ($DNS_SERVER)${RESTORE}"
	echo ""
	# We're done. Don't allow the default_search to be stacked.
	exit 0
}

ip_search() {
    # IP information.
    echo "${LYELLOW}IP${RESTORE} (DNS A Record) for ${FDOMAIN}:"
    dig @$DNS_SERVER $DOMAIN +short | sed 's/^/    /'
}

ptr_search () {
    # Host information
    echo "${LYELLOW}PTR Record${RESTORE} record for ${FDOMAIN}:"
    host $(dig @$DNS_SERVER $DOMAIN +short) | sed 's/^/    /'
}

mx_search () {
    # MX information
    echo "${LYELLOW}MX Records${RESTORE} for ${FDOMAIN}:"
    dig @$DNS_SERVER $DOMAIN MX +short | sort -n | sed 's/^/    /'
	echo "${LYELLOW}Primary MX Record IP${RESTORE} for ${FDOMAIN}:"
	# Just get the IP for the primary MX record that's returned,
	# that is the lowest number (highest priority) returned.
	IP=`dig @$DNS_SERVER $DOMAIN MX +short | sort -n | awk '{ print $2; exit }' | \
 		dig +short -f -`
	echo "    $IP"
	# Report the owner of the IP address, if we can get it.
	ARIN=`whois -d $IP | \
		grep 'Organization' | sed 's/^/    /'`
	if [ ! -z "$ARIN" ]
	then 
		echo "$ARIN"
	fi
}

soa_search() {
    # SOA information
    echo "${LYELLOW}SOA Record${RESTORE} for ${FDOMAIN}:"
    dig @$DNS_SERVER $DOMAIN SOA +short | sed 's/^/    /'
}

whois_search() {
    # WHOIS information
    echo "${LYELLOW}WHOIS${RESTORE} for ${FDOMAIN}:"
    whois -d $DOMAIN | \
		grep 'Date:\|Expir\|Status:\|Registrar:' | \
		sed 's/^/ /'
}

whois_check() {
    # This check will provide more details than the default WHOIS search.
    echo "${LYELLOW}WHOIS Expanded${RESTORE} for ${FDOMAIN}:"
    whois -d $DOMAIN | \
		grep 'Date:\|Expir\|Server:\|Status:\|DNSSEC:\|Email:\|Registrar:' | \
		sed 's/^/ /'
}
	
arin_search() {
    # This performs an ARIN check on the domain given.
    echo "${LYELLOW}ARIN${RESTORE} for ${FDOMAIN}:"
    whois -d $(dig @$DNS_SERVER $DOMAIN +short | tail -n1) | \
		grep 'NetRange\|CIDR\|Organization\|City\|Country' | sed 's/^/    /'
}

ns_check() {
    # This performs the NS check for a given domain.
    echo "${LYELLOW}Name Servers${RESTORE} for ${FDOMAIN}:"
    echo "  DIG results:"
	dig $DOMAIN NS +short | sort -n |  sed 's/^/    /'
	echo "  WHOIS NS results:"
	whois -d $DOMAIN | grep -i 'Name Server:' | awk '{$val=$val;print $3}' | \
	   sed 's/^/    /'
}

spf_check() {
    # Find the SPF records and print what's found.
    echo "${LYELLOW}SPF${RESTORE} for ${FDOMAIN}:"
    dig @$DNS_SERVER $DOMAIN TXT | grep 'v=spf' | sed 's/^/    /'
}

dkim_check() {
    # See if there is a DKIM record for the domain.
    echo "${LYELLOW}DKIM${RESTORE} for ${FDOMAIN}:"
    dig @$DNS_SERVER default._domainkey.$DOMAIN TXT | grep -i "v=DKIM" | sed 's/^/    /'
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
    if [ -z "$REV" ]
	then
        FDNS_SERVER=${WHITE}${1}${RESTORE}
    else
        FDNS_SERVER=${WHITE}${REV}${RESTORE}
    fi
}

prop_check() {
    # This is the DNS propagation check for the given domain. We'll check all
    # of the DNS servers we know, including some not used unless this is run.
    clear # Clear the screen before we perform this test.
    echo -e "${LYELLOW}***** WORLDWIDE DNS PROPAGATION CHECK FOR:\
${RESTORE} $FDOMAIN ${LYELLOW}*****${RESTORE}"
    
	DNS_COUNT=0
	MATCH=0
	for DNS in $IMH $RES $GOOG $CF $L3 $QUAD $Q9BL $OPEN $NIC $VERI $COMO \
			   $NORT $W1 $W2 $W3 $W4 $W5 $W6 $W7 $W8 $W9 $W10 $W11 $W12 \
			   $W13 $W14
    do
        DNS_COUNT=$((DNS_COUNT+1))	
		set_dns $DNS
        
        # If there is not a PTR for the DNS record, display the IPv4.
        if [ -z "$FDNS_SERVER" ]
		then
            SERVER=${LCYAN}${DNS}${RESTORE}
        else # Display the PTR as given to us.
            SERVER=$FDNS_SERVER
        fi
        
        if [ "$DNS_COUNT" = 1 ]
		then
            # First, we want to query the authoritative name server for the 
			# given domain.  This way we can confirm if the SOA from other
			# servers match the authoritative.
            AUTH_NS=`dig +noall +answer +authority +short $DOMAIN NS | \
                awk '{ print $1 }' ORS=' ' | awk '{ print $1 }'`
            AUTH=`dig @$AUTH_NS $DOMAIN SOA +short | awk '{ print $3 }'`
            
            # Most domains have at least two name servers. However, to prevent
            # the response from being too slow, we'll limit the check to just 
            # two servers.
            if [ -z "$AUTH" ]
            then
                echo "${LRED}--ERROR--${RESTORE}"
                echo "Unable to obtain a valid SOA from the first\
 authoritative name server."
                echo -e "    Trying next available name server...\n"
                    
                AUTH_NS=`dig +noall +answer +authority +short $DOMAIN NS | \
                    awk '{ print $1 }' ORS=' ' | awk '{ print $2 }'`
                AUTH=`dig @$AUTH_NS $DOMAIN SOA +short | awk '{ print $3 }'`
                if [ -z "$AUTH" ]
                then
                    echo "${LRED}--ERROR--${RESTORE}"
                    echo "Unable to obtain a valid SOA from the second\
  authoritative name server."
                    echo -e "\n${LRED}***** QUIT *****${RESTORE}"
                    echo "Unable to obtain a valid SOA from an authoritative\
 name server ${AUTH_NS}."
                    echo "Since this is the reported master, we have nothing\
 to compare other SOA records to."
                    exit 1
                fi
            else
                # We have a valid result out of the gate. Use this.
                echo "${BBLUE}${WHITE}Authoritative NS (${AUTH_NS})\
 SOA Serial: ${AUTH}${RESTORE}"
                RESULT=`dig @$DNS $DOMAIN SOA +short | awk '{ print $3 }'`
            fi
        else
            # We need the results of the query so that we can display an actual
			# timeout message since 'dig' doesn't display one for us. Also 
			# reports if nothing is returned.
            RESULT=`dig @$DNS $DOMAIN SOA +short | awk '{ print $3 }'`
        fi
        
        # If the result is empty, display a notice with the IP address.
		# Due to potential error responses, omit any words that show up.
		RE='^[0-9]+$'
		if ! [[ $RESULT =~ $RE ]]
		then
        	if [ -z "$RESULT" ] || [ "$RESULT" = '' ]
			then
				SOA="No response from server (IP: ${DNS})"
        	else
				SOA="Invalid response from server (IP: ${DNS})"
			fi
		else
  			SOA="$RESULT"
        fi
    	
    	# Compare the two and increment if they match.
		if [ "$SOA" = "$AUTH" ]
		then
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
if [ -z "$2" ]
then
    # Leave $1 alone! Just set the $2 variable to the default NS
    set -- "$1" "$DEFDNS"
fi

# Loop through each of the passed arguments starting at the second one.
for i in "${@:2}"
do
    case $i in
        int | imh) # IMH Masters
            # See note in DNS variables to know why this can't be default.
            set_dns $IMH
            default_search
			;;
        res) # IMH Reseller
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
		q9bl) # Quad9 Non-Secure
			set_dns $Q9BL
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
        dkim) # Check DKIM records.
            set_dns $DEFDNS
            dkim_check
            ;;
        a) # Check the "A" records only.
            set_dns $DEFDNS
            ip_search
            ;;
        spam) # Check NS, PTR, MX, SPF and DMARC to find causes of spam.
            # This is NOT stackable. Only run this command.
            set_dns $DEFDNS
            ns_check
            ptr_search
            mx_search
            spf_check
            dmarc_check
			dkim_check
            exit 0
            ;;
		ptr) # Print the PTR results.
			set_dns $DEFDNS
			ptr_search
			;;
        *) # Use the IP passed as the 2nd arg. Validate IP, else show usage.
			if [[ "$2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
			then
				set_dns $2
				default_search
			else
				echo "${LRED}Invalid IPv4 address provided.${RESTORE}"
				usage
				exit 2
			fi
			;;
    esac
done

# All done!

exit 0
