# Milestones

---------------------------------------------------------------
 - [ ] 1. Install [PVE](../main/PVE.md) (the Proxmox Virtual Environment)
      - Download the latest version of Proxmox and flash ISO onto a USB stick for installation.
      - Complete the install selecting your desired format and setup.
      - I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)
      - pve.local

---------------------------------------------------------------
 - [ ] 2. Prepare for on-going maintenance  
    - Setup Repositories: Repositories need to be set for "no subscription" according to the relevant [howto](https://www.virtualizationhowto.com/2022/08/proxmox-update-no-subscription-repository-configuration/).
    - I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible.
    - The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
      - Disable
        * Enterprise ceph-quincy
        * pve-enterprise
      - Enable
         * no subscription ceph-quincy
         * no subscription ceph-reef
   - From the console of PVE
    - change directories to:
    - `cd /usr/share/javascript/proxmox-widget-toolkit`
    - Make a backup
    - cp proxmoxlib.js proxmoxlib.js.bak
    - Then open the file in nano
    - `nano proxmoxlib.js`
    - While in nano use ctrl-w to search for "No valid subscription"
    - `" .data.status.toLowerCase() !== 'active') {`
    - now go to the ! before the == and delete it
    - it should now look like `".data.status.toLowerCase() == 'active') {"`
    - save the file ctrl-x and exit nano
    - Restart the ProxMox service `systemctl restart pveproxy.service`
    - Reload your browser tab and log back in
      - This just changes the logic of the code from not active to is active.

   - Update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages.
      - This should prompt for all the latest updates. Then when TASK ok show in the pop-up window. Close that window and press upgrade. When complete it will show "Your System is up-to-date".
      - Now update the PVE appliance templates list by forcing the update. Use the following command `pveam update` in the shell. See link for further information of possible future changes. https://forum.proxmox.com/threads/howto-update-of-appliance-templates.1074/
      - install unzip `apt install unzip`
      - install sudo `apt install sudo`
      - edit bashrc file to allow for color and alias
      - `nano .bashrc`
      - make appropriate changes and save file
      - reload bash with `source .bashrc` command
   - SECURE TUNNELING THROUGH SSH
   - In the Shell of your PVE machine as "root" do the following
   - Check what is inside /etc/ssh/sshd_config.d, review any configurations that may be present, if any are present then verify they are needed and not overwritten.
   - This line may be present near the top of the file in case anything that was installed requires configurations no need to change it just be aware of it
      - Include /etc/ssh/sshd_config.d/*.conf
   - Configure /etc/ssh/sshd_config - be sure to make comments in the file jus in case something fails
      -  PermitRootLogin no
      -  PasswordAuthentication no
      -  PermitTunnel yes
   -  Add your key to the file location
      - #AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2
   - Save changes and restart ssh service with the following command
      - `systemctl restart ssh`
      
   - Create user for loggin into ssh with the following commands
      - `adduser crafthound` and follow prompts
      - add crafthound to the sudo group with the following command
      - `usermod -aG sudo crafthound`
      - add you key to authorized keys file
---------------------------------------------------------------
 - [ ] 3. Create your ZFS pools or Import them as needed
  - To create your ZFS pool do the following
   - Goto PVE - ZFS on the right column, select create zfs from top right and complete information
      - Name - use your desired name
       - I used the following
        - first add `tank-backups`
        - second add `tank-fileserver` 
      - compression on by default
      - ashift 12 by default
      - Raid level I chose RAIDZ (My config breakdown = 3 20TB disk 1 parity 2 actual drives equaling 40TB of storage. If 1 disk fails you can recover data)
      - Do not enable firewall on any containers because it will interfere with portfowarding and gateway we currently have
   - Adding datasets to match planned file structure configuration from the PVE shell console
    - for tank-backups use the following command to create a zfs dataset for ProxMox storage
     - `zfs create tank-backups/vz` This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go.
      - Once created you can add it to ProxMox storage by following these steps
       - On Datacenter:Storage use the Add button and select Directory.
       - Give it an ID of "tank-backups" and the directory is /tank-backups/vz. The Shared: box should be off, as there are no additional nodes in this setup.
       - Select the Content: button and add VZDump backup file, Container template, and ISO image. This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go
       - We want to turn OFF those options from "local", this removes this data from the root zfs storage (id:local)
       - Select it and use "Edit" to deactivate those selections in Content:, and make sure "Snippets" is active.
       - If "Snippets" come into use, they will be small.
   - local-zfs pool should only have disk image and containers.
 
       -
       -    from the faster drive, and you can't save the options
     - for tank-fileserver use the following commands - This creates the datasets to be used once the fileserver container is created.
     - `zfs create tank-fileserver/home`
     - `zfs create tank-fileserver/share`
     - `zfs create tank-fileserver/media`
     - Use the command `zfs list` to ensure all datasets were properly created and ready for use.


 - to import your previous ZFS pool you must use the following shell commands after ensuring the drives are connected and available
      - In this case I used the following commands from pve console
      - `zpool import -f tank-fileserver`
      - `zpool import -f tank-backups`
      - If the import fails you may have to use "zpool import -f (poolname) flag to force the import. This may need to be followed be the "zpool -e" flag to make it permanent.
     - Use the command `zfs list` to ensure all datasets were properly imported and ready for use.
 - Once imported you can add it to ProxMox storage by following these steps
   - On Datacenter:Storage use the Add button and select Directory.
   - Give it an ID of "tank-backups" and the directory is /tank-backups/vz. The Shared: box should be off, as there are no additional nodes in this setup.
   - Select the Content: button and add VZDump backup file, Container template, and ISO image. This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go
   - We want to turn OFF those options from "local", this removes this data from the root zfs storage (id:local)
   - Select it and use "Edit" to deactivate those selections in Content:, and make sure "Snippets" is active.
   - If "Snippets" come into use, they will be small.
   - local-zfs pool should only have disk image and containers.
---------------------------------------------------------------
 - [ ] 4. Install [DNS](../main/DNS.md) (the DNS Server Appliance)
   - To create a DNS Server Appliance follow these steps
      - Create a Debian LXC Container with the following settings
         - hostname = "DNS", 8 GiB for disk space, 2 Cores, 1024 MiB of memory
         - Network information is based on your individual needs. For my situation the following applies
          - IPV4 `10.0.0.3/24` GATEWAY ` 10.0.0.1`
      - After the reboot, log back in. make sure network information is correct (Mac address, ip and gateway)
      - Update using 'apt update && apt upgrade -y'
      - Install curl using 'apt install curl -y'
      - curl -sSL https://install.pi-hole.net | bash
      - setup upstream DNS providers
         - I used the following `75.75.75.75, 75.75.76.76`
         - Allow third party list to block adds by selecting yes to include unified hosts list
         - Select to allow query logging
         - Select Show everything
         - it will show you the information including password to login and how to change it
         - SAVE THIS INFORMATION
  
      - This [howto] explains how to set up
         - [Pi-hole](https://www.naturalborncoder.com/2023/07/installing-pi-hole-on-proxmox/).
      - Pi.hole does an excellent job configuring itself but after the install and configuring your DHCP to provide dns as the primary DNS host, it is wise to reboot all of the machines to be using DNS for that purpose.
    
      - Alter the DNS Settings for Proxmox
         - Select the server you want to modify in the left menu and then System > DNS in the middle menu. Update as required. Note that this settings just changes the file /etc/resolv.conf.
         - Change /etc/resolve.conf to the following "search local"
       
      - Update pihole with the following console command "pihole -up"
      - set password for pihole bi using the following command in console "pihole setpassword NEWPASSWORDHERE"
    
  - Setup options for dns container
     - `automatially boot yes`
     - `start order should be 1`
   
     - goto 10.0.0.3:80/admin
     - login in using information provided during install
     - goto setting on left column, all settings
     - select Netowrk Time Sync tab and deselect all options and this will clear the warning.
     - goto tools, update Gravity and update it
     - you can add upstream DNS servers from the Settings tab, You should see the custom ones added at installation
     - change dns domain setting to local from default lan
---------------------------------------------------------------
        
6. fileserver Creation 04/06/25
   - DownnloadLXC Fileserver template
   - create container using the following settings
      - hostname = "fileserver",
      - 32GB storage, 2 cores, 2048 mem, 1024 swap
   - Start the fileserver container to create it and completed the install
      - follow prompts
      - create password for samba root user and jeelyfin user accounts
      - skip api key insatllation
      - enter email for security alerts
      - install security updates
      - configure advanced menu settings (confconsole) if need to revisit from console
      - apt update && apt upgrade -y
      - verify all updates installed may have to use commad `apt list --upgradeable`
      -  create a samba password and complete the prompts in order to finish
      -  BE SURE TO SAVE INFORMATION WHEN CONTAINER COMPLETED (IP, ADDRESSES)
      -  set region data and any other relevant information.
      -  reboot appliance
      -  apt update && apt upgrade -y
      -  once install is completed shutdown and link the filesystem in zfs to the fileserver using commands below
    
  - Use the following commands to link the created zfs filesystem to the fileserver from the PVE command line: make sure each is identified as a unique mount point (mp0, mp1 etc)
   - tank-fileserver home
    - `pct set 101 -mp0 /tank-fileserver/home,mp=/home`
   - tank-fileserver share
    - `pct set 101 -mp1 /tank-fileserver/share,mp=/share`
   - tank-fileserver media
    - `pct set 101 -mp2 /tank-fileserver/media,mp=/srv/media`
   - verify using zfs list

   - Use your browser to connect to the GUI.
   - We will now prepare the offered Samba shares. Go to the Samba configuration
   - Select cdrom and Delete Selected Shares.
   - Select storage and the configuration page will appear.
   - Rename storage to share, and change the "Directory to share" to /share, then Save.
   - Add System users and groups through https://fileserver:12321/useradmin/?xnavigation=1.
      - Example crafthound user is created here
      - Create known users
         - crafthound 
         - tootsie
         - djshadow 
         
   - Setup options for fileserver container
     - `automatially boot yes`
     - `start order should be 2`
    
  - Add media folders on gui of samba server and share with correct settings
   - home - should already exist with path equal to all home directories and security set to read/write to all known users
   - share - should have been created from changing storage above
   - media - create a new file share, name it media, directory to share /srv/media both available and browseable set to yes click save
  
  - Setting permissions for folders
  - from the pve console make sure to configure settings accordingly
   - both the share and the media folder should be mirrored with settings
   - owner should be equal to "fileserver root" = to id 100000, use command from pve console `chown 100000:100000 /tank-fileserver/share` and `chown 100000:100000 /tank-fileserver/media`
   - group should be equal to "fileserver users" = to 100100, use command from pve console `chgrp -Rv 100100 /tank-fileserver/share/` and `chgrp -Rv 100100 /tank-fileserver/media/`
  - Be sure to set permissions for share and media folders using the following commands
   - `chmod 2770 /tank-fileserver/share/`
   - `chmod 2770 /tank-fileserver/media/`
   
   - verify the changes took place with the command `ls -la /tank-fileserver/`
---------------------------------------------------------------    
7. WEBSITE HOSTING
 - Decide what hositng application to use (wordpress, Nginx,)

 - Create the datasets for the website directory to be used
  - use the following command `zfs create tank-fileserver/crafthoundgaming` and `zfs create tank-fileserver/overthehillstead`
    - This allows you to setup the mountpoints below that refer to the datasets created above (if using multiple mount points make sure to use a new sequential mount point ex. mp3)
    -  `pct set 101 -mp3 /tank-fileserver/crafthoundgaming,mp=/srv/crafthoundgaming`
    -  `pct set 101 -mp4 /tank-fileserver/overthehillstead,mp=/srv/overthehillstead`

 - `https://www.liquidweb.com/blog/configure-apache-virtual-hosts-ubuntu-18-04/ `
- Make a Directory for Each Site
- create a folder for each domain needed, the locationwill be where you will host the website files. I used /srv/domainname the should be owned by user and group root when created
 - crafthoundgaming is for crafthoundgaming.com
  - `mkdir -p /srv/crafthoundgaming`
 - overthehillstead is for overthehillstead.com
  - `mkdir -p /srv/overhillstead.com`
 - Set Folder Permissions
 - modify folder properties accordingly
  - `chmod -R 755 /srv/crafthoundgaming` and `chmod -R 755 /srv/overthehillstead` 
 - Set up an Index Page
 - for testing purposes create an index.html file in each folder and paste a line of text with each domain name inside. I used the following; this site is crafthoundgaming or overthillstead respectively.
  - use command inside each directory `nano index.html` use this text for crafthoundgaming `this site is crafthoundgaming` close and save the file
 - Copy the Config File for Each Site
  - `cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/crafthoundgaming.conf`
  - `cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/overthehillstead.conf`
 - Edit the Config File for Each Site
  - `nano /etc/apache2/sites-available/crafthoundgaming.conf`
  - `nano /etc/apache2/sites-available/overthehillstead.conf`
  
  - make sure to change the information from the default that was copied to apply to your current domain for the example of crafthoundgaming.conf do the following
> <VirtualHost \*:80>
> 
> ServerName crafthoundgaming.com
> 
> ServerAlias www.crafthoundgaming.com
>
> ServerName crafthoundgaming.com
>
> ServerAlias www.crafthoundgaming.com
>
> ErrorLog ${APACHE\_LOG\_DIR}/error.log
>
> CustomLog ${APACHE\_LOG\_DIR}/access.log combined
>
> </VirtualHost>

- repeat this for overthehillstead.conf
- Enable Your Config File
 - I did this by creating a symbolic link to each of the newly created .conf files. in order to do this you must use the following command
  - `ln -s /etc/apache2/sites-available/crafthoundgaming.conf crafthoundgaming.conf` and `ln -s /etc/apache2/sites-available/overthehillstead.conf overthehillstead.conf`
  - once you do that restart the apache service with the following command `systemctl restart apache2`
  - visit you site to verify configurations are working. You may need to open your port 80 using port forwarding.

  -

How To Secure Apache with Let's Encrypt on Ubuntu 20.04
- https://www.digitalocean.com/community/tutorials/how-to-secure-apache-with-let-s-encrypt-on-ubuntu-20-04
- Installing Certbot
 - apt install certbot python3-certbot-apache
- Checking your Apache Virtual Host Configuration
 - nano /etc/apache2/sites-available/crafthoundgaming.conf
 - make sure you ServerName and ServerAlias lines are correctly filled out
  - `ServerAlias www.crafthoundgaming.com`
  - `ServerName crafthoundgaming.com`
 - if that is verified now check config by using the following command
  - `apache2ctl configtest` you should get s `syntax ok` response if you get an error check for spelling errors
  - now reload appache service with the command `systemctl reload apache2`
  - with these settings certbot should be able to find the correct VirtualHost block and update it.

  - At this point you can configure UFW to allow the firewall but I decided to skip this step

  - Obtaining an SSL Certificate
   - use the following command `certbot --apache`
    - This script will prompt you to answer a series of questions in order to configure your SSL certificate.
     you will be asked to provide an email, agree to read terms of service, share email for other purposes, finally it will ask you to confirm the domains you want to provide certificates for.
    - Select the appropriate domains or leave blank to select them all.
    - You should see an output that obtains and enable the certificates. It may prompt you to allow http traffic to be redirected to https select your apprpriate response.
    - After this step, Certbot’s configuration is finished, and you will be presented with the final remarks about your new certificate, where to locate the generated files, and how to test your configuration using an external tool that analyzes your certificate’s authenticity
    - The certbot package we installed takes care of renewals in order to test it run the following command `systemctl status certbot.timer`
    - To test the renewal process, you can do a dry run with certbot:
    - `certbot renew --dry-run`
     - If no errors are preset you are good to go!

---------------------------------------------------------------
> !!!!!!!!!!!!!!!!!!!!!!!!!! THIS IS A PLACEHOLDER FOR AFTER I DEFOG MY BRAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
---------------------------------------------------------------
Installing MariaDB - `https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-debian-11`
 - apt update && apt upgrade -y - This updates all available packages
 - apt install mariadb-server - This installs MariaDB which is an alternative database to MySQL in the LAMP stack
 - mysql_secure_installation - This will take you through a series of prompts where you can make some changes to your MariaDB installation’s security options.
  - press ENTER to indicate “none”.
  - ype n and then press ENTER.
  - Type n and then press ENTER.
   - From there, you can press Y and then ENTER to accept the defaults for all the subsequent questions.
    - This will remove some anonymous users and the test database, disable remote root logins, and load these new rules so that MariaDB immediately implements the changes you have made.

Installing wordpress on the local machine
---------------------------------------------------------------

---------------------------------------------------------------    
8. Gameserver creation
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

   
9. SET options for booting after restart and boot order for each container / virtual machine
10. 
11.  confconsole commmand gets us to advanced menu in container
12.  
