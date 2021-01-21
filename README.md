# Newcall DNS Lookup Tool

## Intallation

1. Login to the desired machine as any user (no Root required).
2. Run the following command:

    `mkdir -p ~/bin; wget -O ~/bin/newcall https://raw.githubusercontent.com/Hummdis/newcall/master/newcall; chmod +x ~/bin/newcall`

3. You're all set. You can now being using `newcall domain.com` to perform DNS lookups.

## Update
To perform an update, just run:

    newcall update

That will update your currently used version to the latest available here on Github.

## Usage

```Usage: newcall <domain> [dns | ..OPTIONS..]

<domain> - Required - This is the TLD to search.

[dns]    - (Optional) The DNS server to be used.
Built-In Public DNS Options include:
    imh | int:	InMotion Hosting DNS Server
    res:	InMotion Reseller DNS
    hub: 	Web Hosting Hub DNS
    cf:		Cloudflare Public DNS
    goog:	Google Public DNS
    open: 	OpenDNS Public DNS
    quad: 	Quad9 Public DNS
    q9bl: 	Quad9 Public DNS (No block access)
    l3:		Level3 Public DNS
    nic:	OpenNIC Public DNS
    veri:	Verisign Public DNS
    nort:	Norton ConnectSafe
    como:	Comodo Secure DNS
    -OR- Any manually entered IP for a public DNS server.

[OPTIONS] To be used in place of a DNS server.

     prop: This will run a DNS propagation test for the SOA record
           and display the result from each of the built-in DNS servers as well
           as a check of additional worldwide DNS servers for full propagation.
           This check will first obtain the SOA from the authoritative name
           server for the given domain, then compare it with the full list of
           DNS servers. A summary at the end will report how many matches are
           found.
           NOTE: Using the 'prop' option will test
           international servers.
        a: Display the 'A' record only.
       mx: This will run a check for MX records only using the
           default DNS servers.
       ns: This will run a check of the NS records from WHOIS
           using the default DNS servers
      spf: This will run a check for SPF records.
      ptr: This will return the PTR for the given domain.
     arin: This runs an ARIN check on the 'A' record of the domain.
    dmarc: This will run a check for DMARC records.
     dkim: This will run a check for DKIM records.
     spam: This will check NS, PTR, MX, SPF and DMARC for causes for
           being marked as SPAM or being blacklisted.  If this argument is
           passed with others, this is the only one that will run.
      caa: Perform a CAA check to ensure that the SSL being issued can be done
           by the CA that's issuing the SSL.
      ssl: Run a setup of standard tasks for installation of SSL certificates,
           as well as running a CAA check. If this argument is passed with
           others it will be the only one that runs.
    whois: Provides and extended output of WHOIS data.  It's not the full WHOIS,
           just additional informaiton provided over the default test.
whoisfull: This will perform a full 'whois' lookup of the domain. If this
           argument is passed with others, it will be th eonly one that runs.
  reg -or-
 isus -or-
   tucows: These three options will all trigger the Regisrar lookup process to see where a
	   domain is registered.
   update: This will update the Newcall script to the latest version available on Github.

EXAMPLES: newcall hummdis.com
          newcall hummdis.com veri
          newcall hummdis.com 8.8.4.4
          newcall hummdis.com ns mx spf dmarc
          newcall hummdis.com spam
```

## Custom Colors
You can now customize the colors you use for Newcall.  Download the `.newcall_colors` file and make the needed BASH color code changes you want.

    wget -O ~/.newcall_colors https://raw.githubusercontent.com/Hummdis/newcall/master/.newcall_colors

Now, READ THE HEADER COMMENTS and make the desired edits that you want to do.  Since this will be a custom file, this will not auto download with updates or other version changes. This file must be manually downloaded.

## License
This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

## Credit
Special thank you to the following individuals for thier contributions in code, debugging and feedback:

    Jamie P.
    Nick P.
    Shehab A.
    Jonathan Su.
    Alex Kr.
    Taylor S.
    Paul S.
