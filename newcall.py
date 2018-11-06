#!/usr/bin/env python

# Created by Jeffrey Shepherd (http://dev.hummdis.com).
# This work is licensed under the Creative Commons Attribution-ShareAlike
# 4.0 International License. To view a copy of this license,
# visit http://creativecommons.org/licenses/by-sa/4.0/.

# Version 1.0.0 | Created 2018/10/02 | Updated: 2018/10/02

# This file replaces the 'newcall.sh' script because we want to do some more
# complex things that are, quite frankly, harder to do in BASH.

import os
import sys
import socket
import dns.resolver

domain = sys.argv[1]

myResolver = dns.resolver.Resolver() #create a new instance named 'myResolver'
myResolver.nameservers = ['8.8.8.8', '1.1.1.1', '9.9.9.9']

try:
    dnsA = myResolver.query(domain, "A") #Lookup the 'A' record(s)
    for rdata in dnsA: #for each response
        print rdata #print the data

    dnsMX = myResolver.query(domain, "MX")
    for rdata in dnsMX:
        print rdata

    dnsNS = myResolver.query(domain, "NS")
    for rdata in dnsNS:
        print rdata

    dnsTXT = myResolver.query(domain, "TXT")
    for rdata in dnsTXT:
        print rdata
    
except:
    print "Query failed."

