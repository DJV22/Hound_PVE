# Milestones

1. Install [PVE](../main/PVE.md) (the Proxmox Virtual Environment)
   - Download the latest version of Proxmox and flash ISO onto a USB stick for installation.
   - Complete the install selecting your desired format and setup.
   - I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)

2. Prepare for on-going maintenance  
   - Setup Repositories: Repositories need to be set for "no subscription" according to the relevant [howto](https://www.virtualizationhowto.com/2022/08/proxmox-update-no-subscription-repository-configuration/).
   - I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible.
   - The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
      - Disable
        * Enterprise ceph-quincy
      - Enable
         * no subscription ceph-quincy
         * no subscription ceph-reef
   - Update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages. 
      - This should prompt for all the latest updates. Then when TASK ok show in the pop-up window. Close that window and press upgrade. When complete it will show "Your System is up-to-date".

3. If you need to import your previous ZFS pool you must use the following shell commands after ensuring teh drives are connected and available.
   - zpool import (poolname), If the import fails you may have to use "zpool import -f (poolname) flag to force the import. This may need to be followed be the "zpool -e" flag to make it permanent.
   * On Datacenter:Storage use the Add button and select Directory.
   * Give it an ID of "tank" and the directory is /tank/vz. The Shared: box should be off, as there are no additional nodes in this setup.
   * Select the Content: button and add VZDump backup file, Container template, and ISO image. This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go
   * We want to turn OFF those options from "local", select it and use "Edit" and deactivate those selections in Content:, and make sure "Snippets" is active. If "Snippets" come into use, they will be small, benefit from the faster drive, and you can't save the options unless one of those is selected anyway.

4. Install [DNS](../main/DNS.md) (the DNS Server Appliance)
   - If restoring from a backup of a previous install follow these steps
      - locate the backup from your vzdump backup location, in this instance it will be in the tank pool.
      - verify the configuration is as it should be by clicking show cnfiguration button.
      - once you are satisfied it is correct clock Retore and select start on restore.
   - If creating a new appliance for DNS follow these steps
     - There is a [howto](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/) on installing
      Pi-Hole into a Proxmox container. Reference notes follow.
      - [TKL Core](https://www.turnkeylinux.org/core) is used consistent with other TKL templates.
      - A name of "DNS" dictates what the machine is and does primarily.
      - I am using 8 GiB for disk space, 2 Cores, 512 MiB of memory. These values can be changed and updated as required
      as determined by practical use.
      - Logging in at the console, obvious configuations should be entered as obvious (e.g. your email address).
      - After the reboot, log back in.
      - `apt update && apt upgrade` would be next.
      - The "Postfix Configuration" window will come up, presuming no postfix configuation files are present. Select
         "Local only", then use your FQDN as the domain name.
      - This [howto] explains how to set up
         - [Pi-hole](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/).
      - Pi.hole does an excellent job configuring itself but after the install and configuring your DHCP to provide dns as the primary DNS host, it is wise to reboot all of the machines to be using DNS for that purpose.
        
5. Set the PVE's IP using https://www.dynu.com. This is done to direct the Domain to the correct system. (optional if fixed IP)
   * IP update client for Linux runs as a system service (systemd) and supports IPv4 and IPv6 updates. Users can use the group feature to update a specific collection of hostnames.
- Installation
   - Please note that IP update client for Linux requires .NET Core 6.0. Use the following commands based on the Linux distribution to install the IP update client software.
      - Debian 12 (.deb file)
         - wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
         - dpkg -i packages-microsoft-prod.deb
         - rm packages-microsoft-prod.deb
         - apt update
         - apt install dotnet-runtime-6.0
         - wget --trust-server-names https://www.dynu.com/support/downloadfile/67
         - apt install ./dynu-ip-update-client_1.0.1-1_amd64.deb
- Configuration
   - Please check the man page for documentation.
      - man dynu-ip-update-client
   - The configuration file should be at /usr/share/dynu-ip-update-client/appsettings.json location.
      - sudo nano /usr/share/dynu-ip-update-client/appsettings.json
    
***
appsettings.json  [view code here](../main/appsettings.json) 
***
7. Set up email notifications per the [howto](https://www.naturalborncoder.com/linux/2023/05/19/setting-up-email-notifications-in-proxmox-using-gmail).

8. Prepare the zfs storage tank.
   1. Within the GUI, use `Datacenter/<host>:Disks/ZFS` and click the "Create: ZFS" button.
   2. Use "tank" for the name, "Add Storage: [X]", RAID Level: RAIDZ, Compression: on, ashift 12, select all 5 SATA drives,
      then the "Create" button. This "tank" is already mounted as `/tank` at the root.
   3. ~~Install Ceph through the PVE (Note: be sure to select the "No Subscription" repository!)~~
9. Download .iso files to the storage tank.

# Footnotes
[^1]: Proxmox Virtual Environment, usually but not necessarily the web
page GUI control panel, but may also be a "PVE" command line.
[^2]: A "sudo user" on both the shell and on PVE avoid exposing root privilages without a means
to limit root privilage as conditions change. This also limits the need for exposing root
in further stages of installation and development, such as with "git" identity on the
server.
[^3]: The [PVE Firewall](https://pve.proxmox.com/wiki/Firewall#_configuration_files) has
a hard-coded exceptions: "WebGUI(8006) and ssh(22) from your local network."
[^4]: While a GPG key isn't necessary, strictly speaking, it is a good practice and assumed
as part of these instructions for the consistency of PVE rebuild events. If you *have* a GPG
key within Github, it *will* be required here.
[^5]: This selection avoids confusing your internal network interface from the external
interface presented to the world.
