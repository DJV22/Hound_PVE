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
      - Now update the PVE appliance templates list by forcing the update. Use the foloowing command "pveam update" in the shell. See link for further information of possible future changes. https://forum.proxmox.com/threads/howto-update-of-appliance-templates.1074/

3. If you need to import your previous ZFS pool you must use the following shell commands after ensuring the drives are connected and available.
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
      - Create a Debian LXC Container with the following settings
         - hostname = "DNS", 8 GiB for disk space, 2 Cores, 1024 MiB of memory
      - After the reboot, log back in. make sure network information is correct (Mac address, ip and gateway)
      - Update using 'apt update && apt upgrade -y'
      - Install curl using 'apt install curl -y'
      - curl -sSL https://install.pi-hole.net | bash
  
      - This [howto] explains how to set up
         - [Pi-hole](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/).
      - Pi.hole does an excellent job configuring itself but after the install and configuring your DHCP to provide dns as the primary DNS host, it is wise to reboot all of the machines to be using DNS for that purpose.
    
      - Alter the DNS Settings for Proxmox
         - Select the server you want to modify in the left menu and then System > DNS in the middle menu. Update as required. Note that this settings just changes the file /etc/resolv.conf.
         - Change /etc/resolve.conf to the following "search local"
       
      - Update pihole with the following console command "pihole -up"
      - set password for pihole bi using the following command in console "pihole setpasswrod NEWPASSWORDHERE"
    
   - SEtup Automatially boot for DNS options and start order should be 1
        
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
    
- Ensure the service is running and returns a good status with the commands below
   - Commands
   - Manage the service using systemd:
      - sudo systemctl status dynu-ip-update-client.service
      - sudo systemctl start dynu-ip-update-client.service
      - sudo systemctl stop dynu-ip-update-client.service
      - sudo systemctl restart dynu-ip-update-client.service
   
   - To view log files:
      - View live log: journalctl -u dynu-ip-update-client.service --no-pager -f
      - View entire log file: journalctl -u dynu-ip-update-client.service
      - View service status: sudo systemctl status dynu-ip-update-client.service -l
    
***
appsettings.json  [view code here](../main/appsettings.json) 
***

