Hound_PVE

A series of BASH scripts for setting up a bare-metal device as a \"large
scale hypervisor\" with Proxmox

# Purpose

The task is to use [Proxmox](https://www.proxmox.com/en/) on a [UM890
Pro](https://store.minisforum.com/products/minisforum-um890pro?_pos=1&_sid=b97dfcda4&_ss=r)
with 96GB of Ram, (2) 4.0 TB SSD. The end result being a usable homelab in which  a website, Fileserver, Home automation, and gameservers can be kept and managed for personal use.


# Outline
1.	Download the latest version of Proxmox and flash ISO onto a USB stick for installation.
2.	Complete the install selecting your desired format and setup. 
  a.	I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)
3.	Setup Repositories 
  a.	I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible.
4.	The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
  a.	Disable
    i.	Enterprise ceph-quincy
  b.	Enable
    i.	no subscription ceph-quincy
    ii.	no subscription ceph-reef
5.	Update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages. 
  a.	This should prompt for all the latest updates. Then when TASK ok show in the pop-up window. Close that window and press upgrade. When complete it will show "Your System is up-to-date".

# IP Configuration for HoundLab (my Homelab)
  1. Domain / Router - 10.0.0.1
  2. Houndlab (PVE) - 10.0.0.2
  3. DNS (PI.HOLE) - 10.0.0.3
  4. FileServer - 10.0.0.4
  5. Website - 10.0.0.50
  
# Milestones
1. PVE
Install PVE (the Proxmox Virtual Environment)

Download the latest version of Proxmox and flash ISO onto a USB stick for installation.
Complete the install selecting your desired format and setup.
I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)
Prepare for on-going maintenance

Setup Repositories: Repositories need to be set for "no subscription" according to the relevant howto.
I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible.
The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
Disable
Enterprise ceph-quincy
Enable
no subscription ceph-quincy
no subscription ceph-reef
Update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages.
This should prompt for all the latest updates. Then when TASK ok show in the pop-up window. Close that window and press upgrade. When complete it will show "Your System is up-to-date".
Now update the PVE appliance templates list by forcing the update. Use the foloowing command "pveam update" in the shell. See link for further information of possible future changes. https://forum.proxmox.com/threads/howto-update-of-appliance-templates.1074/
If you need to import your previous ZFS pool you must use the following shell commands after ensuring the drives are connected and available.

zpool import (poolname), If the import fails you may have to use "zpool import -f (poolname) flag to force the import. This may need to be followed be the "zpool -e" flag to make it permanent.
On Datacenter:Storage use the Add button and select Directory.
Give it an ID of "tank" and the directory is /tank/vz. The Shared: box should be off, as there are no additional nodes in this setup.
Select the Content: button and add VZDump backup file, Container template, and ISO image. This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go
We want to turn OFF those options from "local", select it and use "Edit" and deactivate those selections in Content:, and make sure "Snippets" is active. If "Snippets" come into use, they will be small, benefit from the faster drive, and you can't save the options unless one of those is selected anyway.

2. DNS

Install DNS (the DNS Server Appliance)

If restoring from a backup of a previous install follow these steps

locate the backup from your vzdump backup location, in this instance it will be in the tank pool.
verify the configuration is as it should be by clicking show cnfiguration button.
once you are satisfied it is correct clock Retore and select start on restore.
If creating a new appliance for DNS follow these steps

Create a Debian LXC Container with the following settings

hostname = "DNS", 8 GiB for disk space, 2 Cores, 1024 MiB of memory
After the reboot, log back in. make sure network information is correct (Mac address, ip and gateway)

Update using 'apt update && apt upgrade -y'

Install curl using 'apt install curl -y'

curl -sSL https://install.pi-hole.net | bash

This [howto] explains how to set up

Pi-hole.
Pi.hole does an excellent job configuring itself but after the install and configuring your DHCP to provide dns as the primary DNS host, it is wise to reboot all of the machines to be using DNS for that purpose.

Alter the DNS Settings for Proxmox

Select the server you want to modify in the left menu and then System > DNS in the middle menu. Update as required. Note that this settings just changes the file /etc/resolv.conf.
Change /etc/resolve.conf to the following "search local"
Update pihole with the following console command "pihole -up"

set password for pihole bi using the following command in console "pihole setpasswrod NEWPASSWORDHERE"

SEtup Automatially boot for DNS options and start order should be 1

3. FILE SERVER
4. ARM SERVER
5. WEB SERVER
6. GAME SERVERS
