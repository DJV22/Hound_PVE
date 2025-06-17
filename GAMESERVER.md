Outline of build for a generic host for crafthoundgaming.com aka CraftHound Gaming
======

## Build Goal (Working Rules)
   1. The purpose of this machine is to provide a gameserver for crafthoundaming.com
   2. The provided gameserver will be accessible online.
   3. It will provide automatic daily backups and restarts as per outlined by cragfthoundgaming with discord webhook notifications.
   4. This will be maintained by CraftHound Gaming on their local hardware.

## Creation Actions - Minecraft gameserver example
   1. Create a container using the Turnkey Gameserver template `it should have been downloaded into the CT Templates directory`
   `SETTINGS`
   - CT ID: 500 `adjust accordingly`
   - Hostname: houndcraft `adjust accordingly`
   - Password: insertpasswordhere `make a unique password for the "root" user to log into console to complete creation`
   - Disk size: 32 GiB `adjust accordingly`
   - Cores: 12 `adjust accordingly`
   - Memory: 18 GB (18432) `adjust accordingly`
   - Swap: 6 GB (6144) `adjust accordingly`
   - All other settings should be default and should be confirmed
   2. Start the container and log into console to complete configurations.
   - user: root
   - password: insertpasswordhere `use the unique password created at installation`
   - follow the steps of the confconsole script when it starts `if it does not start type in "confconsole" into console
      - You will configure a password for the "gameuser" account, install api-key if you have one, and update security settings along with providing an email for notifications if you choose. all of these settings are dependent on you specific use case. At the end of this you can install game servers configure timezone and network settings. using the confconsole command you can return and edit these at any time.
   - Once you are complete the installation of a game server in this case we chose Minecraft:Java Edition, you can quit confconsole and returm to the console prompt.
   3. Complete the install - I reccomend doing the update and upgrade commands just to be sure everything is up to date. `apt update && apt upgrade -y` 
## Starting the new game server
   1. `sudo -i -u gameuser` will put you in as the "gameuser" account the games run from so you can explore.
   2. `cd gameserver` puts you in the right directory.
   3. `./mcserver` brings up a menu of options. You can use the 1-3 letter combination to select from the
      options offered, such as `./mcserver dt` to see current details about the game.
   4. Now would be a good time to backup your work so you have a stable configuration to return if any issues arise. To do this, follow these steps
   - In this container go to backups in the center column under. `It should be approximately 7 below "Summary"`
   - Then select the "Bacup now" button. `The defaults are fine, this allows us to roll back to this save point as needed`
## Java Install 
`this step may not be needed or slightly differ depending on the version of minecraft you are using`
   1. For this version of Minecraft Server `1.21.5` Java 21 will need to be installed. use the commands below or search for help online to make sure you have the correct version needed.
   - `wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb`
   - `dpkg -i jdk-21_linux-x64_bin.deb`
   - `java -version` will veriyfy it was downloaded and installed properly
   2. The server is now configure and ready to run. You can use the `./mcserver` commands while logged in as gameuser `sudo -u gameuser -i` and going to the gameserver directory `cd gameserver`
## Optional Steps
`Currently the houndcraft container is running a Minecraft: Java Edition server. You can edit server properties files and lgsm configs to make the server fit your needs. Seek reference material online to assist with that.
- Follow the steps to create additional containers for specific servers changing the appropriate settings along the way.[^1]
- 

      
## Footnotes:
   [^1]: Example Minecraft Servers - Fabric, Forge, Neoforge, for modded servers.

## Todo
   1. setup daily backups and server restarts
   2. allocate thos backups to the fileserver location
   3. provide a fail safe restart if server issues arise
       

