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

5. Set domain name using https://www.dynu.com (optional if fixed IP)
       1. Run `sudo ./DynuSetup.sh`  
       Answer the following questions for Dynu:  
       1. Dynamic DNS service provider: *other*  
       2. Dynamic DNS update protocol: *dyndns2*  
       3. Dynamic DNS server: *api.dynu.com*  
       4. Username: \<your-dynu-user-name\>  
       5. Password: \<your-dynu-password\>  
       6. Re-enter password: \<your-dynu-password\>  
       7. IP address discovery method: *Web-based IP discovery service*[^5]  
       8. Hosts to update: \< example.com, www.example.com \>  
    2. When the script completes, verify an update to [the Dynu Control Panel](https://www.dynu.com/en-US/ControlPanel/DDNS),
    then confirm the update on the Proxmox host using `sudo journalctl -u ddclient`

6. Set up email notifications per the [howto](https://www.naturalborncoder.com/linux/2023/05/19/setting-up-email-notifications-in-proxmox-using-gmail).

7. Prepare the zfs storage tank.
   1. Within the GUI, use `Datacenter/<host>:Disks/ZFS` and click the "Create: ZFS" button.
   2. Use "tank" for the name, "Add Storage: [X]", RAID Level: RAIDZ, Compression: on, ashift 12, select all 5 SATA drives,
      then the "Create" button. This "tank" is already mounted as `/tank` at the root.
   3. ~~Install Ceph through the PVE (Note: be sure to select the "No Subscription" repository!)~~
8. Download .iso files to the storage tank.

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
