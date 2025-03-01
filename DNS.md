 Outline of build for the DNS host
======

## Build Goal (Working Rules)
   1. The purpose of this machine is as follows:
      * Provide external and internal identity of the "mik-maq.com" network, which will also be identified locally as
        "BitterGreen" (the wireless name) or "local" (the hostname with .local implied).
      * The external identity will be maintained through [Dynu](https://dynu.com).
      * Internal "domain" identity will be provided by [Pi-Hole](https://pi-hole.net) with the added benefit of domain
        ad blocking.
      * Does *not* provide file services managed by a "fileserver" LTK appliance.
      * Does *not* provide a domain certificate, as this is best maintained for and by the webservice open to the
        external world.
      * Does *not* provide user identity. The plan is to maintain this only on the "fileserver" host, then elsewhere
        as required per situation.
      * Notifications by Gotify are pending, but may be implimented on this host.
   2. Don't do *anything* or make changes if not *explicitly* required by the overall goal.

## Todo
   1. I am amiss in not doing a snapshot of the fileserver host before configuring and verifying the rollback process.
   2. I need to set up automated snapshots vs. recovery as part of this build. I've already done this, but it needs fully
      worked out within this document.
   3. I'm seriously considering using the DHCP/DNSMASQ built-in to replace that function within my router. This would not
      only remove the tedium of manually editing the DNS entries, but the router seems to "hold onto" DNS settings even
      after I changed it which complicated setting up this host in practice.

## Install Actions
   1. There is a [howto](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/) on installing
      Pi-Hole into a Proxmox container. Reference notes follow.
   2. [TKL Core](https://www.turnkeylinux.org/core) is used consistent with other TKL templates.
   3. A name of "DNS" dictates what the machine is and does primarily.
   4. I am using 8 GiB for disk space, 2 Cores, 512 MiB of memory. These values can be changed and updated as required
      as determined by practical use.
   5. Logging in at the console, obvious configuations should be entered as obvious (e.g. your email address).
   6. After the reboot, log back in.
   8. `apt update && apt upgrade` would be next.
   9. The "Postfix Configuration" window will come up, presuming no postfix configuation files are present. Select
      "Local only", then use your FQDN as the domain name.
   14. This [howto] explains how to set up
       [Pi-hole](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/).
   15. Pi.hole does an excellent job configuring itself but after the install and configuring your DHCP to provide dns
       as the primary DNS host, it is wise to reboot all of the machines to be using DNS for that purpose.
   
   
## The following steps are pending fit as Gotify becomes better understood.
   1. For the purpose of receiving notifications, we need a [gotify server](https://github.com/gotify/server). As
      this host handles various "non-Turnkey Linux" issues, it is the natural place to put the Gotify server.
   2. Gotify reqires Docker, so follow the [howto] on installing Docker to this instance.
   3. With Docker installed, follow the directions to [install Gotify](https://gotify.net/docs/install)

      
## Footnotes:
   [^1]: ...
