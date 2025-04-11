Outline for installing ProxMox Virtual Environment
---------------------------------------------------------------
1.	Install [PVE](../main/PVE.md) (the Proxmox Virtual Environment)
a.	Download the latest version of Proxmox and flash ISO onto a USB stick for installation.
b.	Complete the install selecting your desired format and setup.
i.	I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)
ii.	pve.local is the FQDN I used for the installation
2.	Prepare for on-going maintenance
a.	Setup Repositories: Repositories need to be set for "no subscription" according to the relevant [howto](https://www.virtualizationhowto.com/2022/08/proxmox-update-no-subscription-repository-configuration/).
b.	I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible. 
c.	The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
d.	Disable the following repositories
i.	Enterprise ceph-quincy
ii.	pve-enterprise
e.	Enable the following repositories
i.	no subscription ceph-quincy
ii.	no subscription ceph-reef
f.	Disable the no subscription message (From the console of PVE)
i.	change directories to `cd /usr/share/javascript/proxmox-widget-toolkit`
ii.	Make a backup `cp proxmoxlib.js proxmoxlib.js.bak`
iii.	Then open the file in nano `nano proxmoxlib.js`
iv.	While in nano use ctrl-w to search for "No valid subscription". You should see `" .data.status.toLowerCase() !== 'active') {`
v.	now go to the ! before the == and delete it
vi.	it should now look like `".data.status.toLowerCase() == 'active') {"`
vii.	save the file ctrl-x and exit nano
g.	Restart the ProxMox service `systemctl restart pveproxy.service`
h.	Reload your browser tab and log back in
i.	This just changes the logic of the code from not active to is active.
i.	Update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages. This should prompt for all the latest updates. 
j.	A pop up window will show the updates taking place and finish when displays “Task OK”.
k.	Close that window and press upgrade. When complete it will show "Your System is up-to-date".
l.	In the Shell window use the following command to force the update ‘pveam update` 
i.	More information is available at the link provided. https://forum.proxmox.com/threads/howto-update-of-appliance-templates.1074/
3.	Install required applications
a.	Install unzip `apt install unzip`
b.	install sudo `apt install sudo`
4.	Configure your console to your desired settings
a.	edit bashrc file to allow for color and alias by using the following command `nano .bashrc`
b.	make the appropriate changes and save the file
c.	reload bash with `source .bashrc` command
5.	SECURE TUNNELING THROUGH SSH
a.	In the Shell of your PVE machine as "root" do the following
b.	Check what is inside /etc/ssh/sshd_config.d, review any configurations that may be present, if any are present then verify they are needed and not overwritten.
c.	This line may be present near the top of the file in case anything that was installed requires configurations no need to change it, just be aware of it. `Include /etc/ssh/sshd_config.d/*.conf`
d.	Configure /etc/ssh/sshd_config - be sure to make comments in the file just in case something fails
i.	# PermitRootLogin yes, PermitRootLogin no
ii.	# PasswordAuthentication yes, PasswordAuthentication no
iii.	# PermitTunnel no, PermitTunnel yes
e.	Add your key to the file location 
i.	.ssh/authorized_keys or .ssh/authorized_keys2
f.	Save changes and restart ssh service with the following command `systemctl restart ssh`
6.	Create users for logging into ssh with the following commands `adduser username` and follow prompts
a.	I used crafthound for my purposes
b.	add crafthound to the sudo group with the following command `usermod -aG sudo crafthound`
c.	add you key to authorized keys file for crafthound
7.	Importing pools and storage drives
a.	If you need to import your previous ZFS pool you must use the following shell commands after ensuring the drives are connected and available. `zpool import (poolname)`
i.	In this case I have the following pools and commands
1.	`zpool import -f tank-fileserver`
2.	`zpool import -f tank-backups`
b.	If the import fails you may have to use "zpool import -f (poolname) flag to force the import. This may need to be followed be the "zpool -e" flag to make it permanent.
8.	Configure the storage for use
a.	On Datacenter:Storage use the Add button and select Directory with the following settings
i.	ID of "tank-backups" 
ii.	directory is /tank-backups/vz. 
iii.	The Shared: box should be off, as there are no additional nodes in this setup.
iv.	Content: add VZDump backup file, Container template, and ISO image. This is where "whole-machine" backups, LXC Container templates, and bootable ISO images will go.
b.	Turn OFF those options from "local"
i.	select it and use "Edit"
ii.	deactivate all content except "Snippets". If "Snippets" come into use, they will be small, benefit from the faster drive, and you can't save the options unless one of those is selected anyway.
iii.	local-zfs pool content should only be: disk image and containers.
  
Create tank-fileserver or Import as needed
- to import
   - use command `zpool import -f tank-fileserver` from pve console
- to create it 
   - Goto PVE - ZFS on the right column, select create zfs from top right and complete information
      - RaidZ config 3 20TB disk 1 parity 2 actual drives equaling 40TB of storage. If 1 disk fails you can recover data.
      - name - media, compression on by default, ashift 12 bu default and Waid level RAIDZ     

   - Do not enable firewall on any containers because it will interfere with portfowarding and gateway we currently have
---------------------------------------------------------------
4. Install [DNS](../main/DNS.md) (the DNS Server Appliance)
   - To create a DNS Server Appliance follow these steps
      - Create a Debian LXC Container with the following settings
         - hostname = "DNS", 8 GiB for disk space, 2 Cores, 1024 MiB of memory
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
        
6. mediaserver Creation 04/06/25
   - DownnloadLXC Fileserver template
   - create container using the following settings
      - hostname = "mediaserver",
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
         - Use the following commands to link the created zfs filesystem to the fileserver from the PVE command line1: make sure each is identified as a unique mount point (mp0, mp1 etc)
            - pct set 101 -mp0 /tank-fileserver/home,mp=/home
            - pct set 101 -mp1 /tank-fileserver/share,mp=/share
            - pct set 101 -mp2 /tank-fileserver/media,mp=srv/storage
          
   - Use your browser to connect to the GUI.
   - We will now prepare the offered Samba shares. Go to the Samba configuration
   - Select cdrom and Delete Selected Shares.
   - Select storage and the configuration page will appear.
   - Rename storage to share, and change the "Directory to share" to /share, then Save.
   - Add System users and groups through https://fileserver:12321/useradmin/?xnavigation=1. For example, let's create the username "bob" by selllecting the Create a new user button.
      - Example crafthound user is created here
      - Create known users
         - crafthound - id 1000
         - tootsie - id 1001
         - djshadow - id 1002
         
   - Setup options for mediaserver container
     - `automatially boot yes`
     - `start order should be 2`
    
  - Add media folders on gui of samba server and share with correct settings
  - Setting permissions for folders
   - I used the settings `chmod 2770 (name of directory)` this allows users and group Read and Write access, but others have no access. Change as you need. Search Debian permission explanation ubuntu for more information
   - 

---------------------------------------------------------------    
7. WEB SERVER CREATION
   - Download your selected template and save it to "tank"
   - Create container in PVE using gui. `Create CT`
   - I used the following setting while creating container
      - ID - 102, Hostname - webserver, Insert Password and SSH Key,
      - Select Template - I will be using TurnKey WordPress version (18.2) at the time of installation.
      - size 32 GB, 2 cores, 1024 memory, 1024 swap
      - Enter Network information (MAC address, Static IP, Gateway)
      - Confirm settings and create container
   - After intstallation reboot container and login to console as root
      - complete installation by following prompts
      - 
      - ensure passwords are secure and are unique
      - after following prompts enter domain name information and confirm ip settings
      - after information is verified you can add advanced menu items
      - install lets encrypt following the advanced menu (`conconsole` command in shell if closed advanced menu) 
         - follow prompts
         - get certificate
         - toggle renew certificate to enable
         - save settings and reboot
    
      - create local dns record webserver.local - dedicated ip (10.0.0.50)
  - Setup options for webserver container
     - `automatially boot yes`
     - `start order should be 3`
        - Make sure the users exist both on fileserver machine and mediaserver machine with the correct id #'s
           - 
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
