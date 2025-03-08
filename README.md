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

4. SECURE TUNNELING THROUGH SSH
   - In the Shell of your PVE machine as "root" do the following
   - Check what is inside /etc/ssh/sshd_config.d, review any configurations that may be present, if any are present then verify they are needed and not overwritten.
   - This line may be present near the top of the file in case anything that was installed requires configurations no need to change it just be aware of it
      - Include /etc/ssh/sshd_config.d/*.conf
   - Configure /etc/ssh/sshd_config - be sure to make comments in the file jus in case something fails
      -  PermitRootLogin no
      -  PasswordAuthentication no
      -  PermitTunnel yes
   - Save changes and restart ssh service with the following command
      - `systemctl restart ssh`
      - 
5. Install [DNS](../main/DNS.md) (the DNS Server Appliance)
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
    
  - Setup options for dns container
     - `automatially boot yes`
     - `start order should be 1`
        
6. Fileserver Creation
   - DownnloadLXC Fileserver template
   - create container using the following settings
      - hostname = "fileserver", 8 GiB for disk space, 2 Cores, 1024 MiB of memory
   - Create the following zfs datasets on PVE
      - zfs create -p tank/fileserver/tub for host specific use, including host "internal" backups. Becomes /tank on the client.
      - chmod 777 /tank/fileserver/tub for the initial setup of permissions. This will be corrected later.
      - zfs create -p tank/fileserver/home as a home folder for client users on the network.
      - chmod 777 /tank/fileserver/home
      - zfs create -p tank/fileserver/share for files to be shared amount the network users and/ or host clients.
      - chmod 777 /tank/fileserver/share
      - #zfs create -p rpool/fileserver/share is not created as this time, but may be useful if "fast" sharing is required. The amount of space for this purpose would be significantly smaller, and is considered an edge use case at this time.

   - Start the fileserver container to create it and completed the install
      -  create a samba password and complete the prompts in order to finish
      -  BE SURE TO SAVE INFORMATION WHEN CONTAINER COMPLETED (IP, ADDRESSES)
      -  set region data and any other relevant information.
      -  reboot appliance
      -  apt update && apt upgrade -y
      -  postfix configuration - ma ilsetup select no configuration because issues with gmail proxy
      -  once install is completed shutdown and link the filesystem in zfs to the fileserver using commands below
         - Use the following commands to link the created zfs filesystem to the fileserver from the PVE command line1: make sure each is identified as a unique mount point (mp0, mp1 etc)
            - pct set 101 -mp0 /tank/fileserver/tub,mp=/tank
            - pct set 101 -mp1 /tank/fileserver/home,mp=/home
            - pct set 101 -mp2 /tank/fileserver/share,mp=/share
          
   - Use your browser to connect to the GUI.
   - We will now prepare the offered Samba shares. Go to the Samba configuration
   - Select cdrom and Delete Selected Shares.
   - The "homes" sharing will actually be split between "tub" for host only and "home" for user only when added as functional "users" and attached as SMB clients. The "share" the only folder specific for managed sharing between multiple hosts and users depending upon need and policy. So the "homes" share we will leave as is.
   - Select storage and the configuration page will appear.
   - Rename storage to share, and change the "Directory to share" to /share, then Save.
   - Add System users and groups through https://fileserver:12321/useradmin/?xnavigation=1. For example, let's create the username "bob" by selecting the Create a new user button.
      - Example crafthound user is created here
      - Create known users
         - crafthound
         - tootsie
         - djshadow
         - mediaserver
         - 
   - Enter "bob" for the username and give it a password which will match the SMB password in later steps. For the "Home directory," allow it to use "Automatic" which will default to /home.
   - For the "Primary Group," select "New group with same name as user" and add "users" as the Seconary Group. Be sure to select the "right arrow" button to move this to the "In groups" panel.
   - The defaults should be fine, but the ideal policy is, "don't add or change anything you do not have to." Permissions should be planned such that "users" group projects, "client" machine projects and such can be protected at this level.
  - Setup options for fileserver container
     - `automatially boot yes`
     - `start order should be 2`

7. WEB SERVER CREATION
   - Download your selected template and save it to "tank"
   - Create container in PVE using gui. `Create CT`
   - I used the following setting while creating container
      - ID - 102, Hostname - webserver, Insert Password and SSH Key,
      - Select Template - I will be using TurnKey WordPress version (18.2) at the time of installation.
      - size 32 GB, 2 cores, 1024 memory, 1024 swap
      - Enter Network information (MAC address, Static IP, Gateway)
      - Confirma settings and create container
   - After intstallation reboot container and login to console as root
      - complete installation by following prompts
      - 
      - ensure passwords are secure and are unique
      - after following prompts enter domain name information and confirm ip settings
      - after information is verified you can add advanced menu items
      - install lets encrypt
         - follow prompts
         - get certificate
         - toggle renew certificate to enable
         - save settings and reboot
    
      - 
  - Setup options for webserver container
     - `automatially boot yes`
     - `start order should be 3`
8. MEDIA SERVER
   - Create a container with the following settings
      - ID - 103, Hostname - mediaserver, Insert Password and SSH Key,
      - Select Template - I will be using TurnKey LXC Media Server
      - size 32 GB, 2 cores, 2048 memory, 1024 swap
      - Enter Network information (MAC address, Static IP, Gateway, and DNS)
      - Confirm all settings and create container
   - Once the container is created and Task show OK Start the container
   - in the console of the mediaserver container login as root
      - Follow all prompts being sure to document user accounts created through these steps
         - Samba root account
         - Jellyfin user account
         - Initialize API Key - skip this step
         - Security alerts - enter email information
         - Install Security updates
         - Confirm and save Media Server appliance services
         - configure advanced Menu items as needed
            - I confiugred Region Settings, mail relay settings
       
         - Make usre to create a user `mediaserver` in fileserver samba webadmin
       
         - change file storage location by doing the folowing on media server console
            - mkdir -p ~/tmp
            - copy existing storage directory and contents to tmp directory with the following command from the tmp directory
               - `cp -Av /srv/storage` - verify changes `ls -la`
            - remove storage directory with following command
               - `cd /srv`
               - `rm -Rvf storage/`
            - then make storage directory again
               - `mkdir storage`
            - 

9. Gameserver creation
   - Decide on a container ID
   - Decide gameserver name - usually based on what game it is for and how the game is played ex. Minecraft survival = houndcraft, ex. minecraft create mod = houndcreate or another option is 1 gameserver per game (minecraft, Palworld, Ark) and each gameserver can have different instances run based on desires.
   - good practice to have a template based on initial design for ease of creating on the fly
   - Using a turnkey LXC template for gameserver use the following settings
      - 32 GiB, 12 cores, 18 GB memory, and 6 GB swap. You can adjust according to your individual needs. All other settings should be default and should be confirmed
   - Completing the install
   - goto console login in as root, follow prompts to create server.
      - I use the following settings
      - (insert settings here)
   -  After logging back in as root, you are prompted with, "For Advanced commandline config run: confconsole."
   -  From there, you are provided the connection ports and an option for the "Advanced Menu" to do further configuration.
   -  While the logfiles and other system clock functions for the server are driven by the "real" clock on pve, and that clock runs on UTC time, you may want to set the "Region config" TZ data. It's possible you want the server to think in your "local time" as it applies rather than UTC.
   -  While there are other settings to explore, from the Advanced Menu you may select a particular "Game server". Naturally, you can't "Update" the server until you "Select game", so do that.
   -  You get a warning you may be prompted for further information, then continue.
   -  For this example, select Minecraft (Java Edition). At that point installing the necessary dependencies will begin. On this particular server, it requires a Server admin username, the "Wizard, Op" account name you wish to use on the server. It will also ask for the server name.
   -  We are told the server is successfully installed and we can connect. You can now quit the consoleconfig running to get back to the prompt.
   -  Starting the new game server
   -  The command ss -lnt will show you if the server is actually running if you know what port to look for. In this case, I'm expecting 25565 to be open, but it is not.
   -  sudo -i -u gameuser will put you in as the "gameuser" account the games run from so you can explore.
   -  cd gameserver puts you in the right directory. You do not need to use ./linuxgsm.sh, you already did that in the console configuration.
   -  ./mcserver brings up a menu of options. You can use the 1-3 letter combination to select from the options offered, such as ./mcserver dt to see current details about the game.
   -  ./mcserver st returns an error: "[ FAIL ] Starting mcserver: Unable to start Whimpercraft"
   -  Now would be a good time to make a snapshot before making changes so you can return to this configuration. To do this, go back to Datacenter/pve/whimpercraft:Backup, then select the "Bacup now" button. The defaults are fine, just use the "Backup" button offered
   -  With that safely in hand, we can explore changes and roll them back to this save point as needed.
   -  Depending on the game server, you may have to ask questions for help outside the scope of this tutorial. In this case, ~/gamesever/log/console shows the current Java is not up to date with this version of minecraft. According to the Minecraft Wiki, the current release of Minecraft uses Java 21. This will prevent the server from working, as the installed java is 17, and a default package is not available to update at this time.
   -  A debian package for Java21 is not currently available to me, so I will follow the instructions on the howto for that.
   -  mkdir -p ~/Downloads && cd Downloads
   -  Having moved the file in there, I follow the directions including tracing down which version of Java is actually running so java -version returns openjdk version "22.0.1" 2024-04-16. This is an exercise best left to the user, although I can provide help as needed, perhaps clarify here.
   -  The server will run at this point, but I neto follow further directions to run the Forge backup I am using. Once I have made the suggested changes, the server runs as expected.

   
10. SET options for booting after restart and boot order for each container / virtual machine
11. 
12.  
