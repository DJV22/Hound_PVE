Outline of build for a generic host
======

## Build Goal (Working Rules)
   1. The purpose of this machine is as follows:
      * Serve files as per [ORGANIZATION.md](../main/ORGANIZATION.md).
      * Provide a given game on the host.
      * Perform game data saves as appropriate.
   2. Don't do *anything* or make changes if not *explicitly* required by the overall goal.
   3. Before you begin with this example, see if the game server you wish to use is [supported](https://linuxgsm.com/servers/)!

## Todo
   1. Have a plan on the firewall.
   2. When the fileserver is online, save the internal game backups.

## Creation Actions
   1. Decide on a name for the gameserver. I would suggest forethought on how likely it is you will be using
      multiple sets of the same game. For instance, "Valheim" is one game server you could be using, but in
      my case it is unlikely I will play "Valheim" as anything other than "Valheim", so I would name my server
      based on that. In the case of Minecraft, I may have multiple Minecraft servers running at the same time,
      each based on a "server name", and possibly even having wildly different mods and configurations. For
      this instruction, I will build "whimpercraft", but the same technical details will apply except where
      noted.
   2. It would be good to make sure you hae the "gameserver" template available. To do this, select
      `Dataserver/pve/tank (pve):CT Templates`. There is a "Templates" button that will list many available
      options. [Turnkey Linux](https://www.turnkeylinux.org) has a website full of details, discussion, and
      notice of updates. Search, select, and download from the window.
   4. In the top right, there is a `Create CT` button. On the window that comes up, I'm using a "CT ID:" of
      500 (or higher, as needed) to keep the gameservers in the same general group order on the left. Select
      the "tank" storage and the gameserver template.
      For "Disk" size, 32 GiB would be plenty of space. You are welcome to decide to raise or lower this
      according to how much disk space you think you will need.
   5. I'm using 12 out of 16 cores so the game will run as smooth as possible. This can be adjusted downwards
      based on your game experience. It is likely wise to leave a few cores left over for other systems even
      if the game server were to pin the CPU so you can regain control.
   6. There is an online [converter](https://www.convertunits.com/from/GiB/to/MiB) handy, and I will convert
      18 GiB to 18432 MiB of memory and 6 GiB (6144 MiB) of swap. And again, your experience with your
      server should inform you to adjust accordingly.
   7. Network, DNS settings I'm using "defaults from what I already do." For this network, I use DHCP.
   8. On the confirm page, look over all the settings to make sure you didn't miss anything and that it looks
      "sane." You can toggle the "Start after created" button to have it going right away.
      
## Completing the install
   1. If your router does not perform local DNS, now is a good time to add those into your local domain
      configuration.
   2. With the server running on your screen, you can select the ">_ Console" button to bring up a web
      console terminal. Login with your root and password.
   3. On login, you should enter a password for the `Gameuser` account. It does *not* need to be the same as
      `root`. Twice to confirm a match.
   4. Skip the Turnkey backup API unless you paid for a subscription.
   5. Enter your email for server system messages. It will also register you for TurnkeyLinux security
      allerts, but you can unsubscribe.
   6. Allow security updates to install, and allow it to reboot, of course. Cool fact: If you do not close
      the terminal session, it will warn you that it's closed briefly, then reconnect with a login. If you
      know it's just rebooting, you need not open another terminal window!
   8. After logging back in as `root`, you are prompted with, "For Advanced commandline config run:
      confconsole."
   9. From there, you are provided the connection ports and an option for the "Advanced Menu" to do further
      configuration.
   10. While the logfiles and other system clock functions for the server are driven by the "real" clock on
       pve, and that clock runs on UTC time, you may want to set the "Region config" TZ data. It's possible
       you want the server to think in your "local time" as it applies rather than UTC.
   11. While there are other settings to explore, from the Advanced Menu you may select a particular
       "Game server". Naturally, you can't "Update" the server until you "Select game", so do that.
   12. You get a warning you may be prompted for further information, then continue.
   13. For this example, select Minecraft (Java Edition). At that point installing the necessary dependencies
       will begin. On this particular server, it requires a Server admin username, the "Wizard, Op" account
       name you wish to use on the server. It will also ask for the server name.
   14. We are told the server is successfully installed and we can connect. You can now quit the consoleconfig
       running to get back to the prompt.

## Starting the new game server
   1. The command `ss -lnt` will show you if the server is actually running if you know what port to look for.
      In this case, I'm expecting 25565 to be open, but it is not.
   2. `sudo -i -u gameuser` will put you in as the "gameuser" account the games run from so you can explore.
   3. `cd gameserver` puts you in the right directory. You do not need to use `./linuxgsm.sh`, you already did
      that in the console configuration.
   4. `./mcserver` brings up a menu of options. You can use the 1-3 letter combination to select from the
      options offered, such as `./mcserver dt` to see current details about the game.
   5. `./mcserver st` returns an error: "\[ FAIL \] Starting mcserver: Unable to start Whimpercraft"
   6. Now would be a good time to make a snapshot before making changes so you can return to this configuration.
      To do this, go back to `Datacenter/pve/whimpercraft:Backup`, then select the "Bacup now" button. The
      defaults are fine, just use the "Backup" button offered.
   7. With that safely in hand, we can explore changes and roll them back to this save point as needed.
   8. Depending on the game server, you may have to ask questions for help outside the scope of this tutorial.
      In this case, `~/gamesever/log/console` shows the current Java is not up to date with this version of
      minecraft. According to the [Minecraft Wiki](https://minecraft.wiki/w/Java_Edition#System_requirements),
      the current release of Minecraft uses Java 21. This will prevent the server from working, as the installed
      java is 17, and a default package is not available to update at this time.
   9. A debian package for Java21 is not currently available to me, so I will follow the instructions on the
      [howto](https://computingforgeeks.com/install-java-jdk-or-openjdk-21-on-debian/) for that.
      * `mkdir -p ~/Downloads && cd Downloads`
      * Having moved the file in there, I follow the directions including tracing down which version of Java
        is actually running so `java -version` returns `openjdk version "22.0.1" 2024-04-16`. This is an exercise
        best left to the user, although I can provide help as needed, perhaps clarify here.
      * The server *will* run at this point, but I need to follow further
        [directions](https://github.com/GameServerManagers/LinuxGSM/discussions/3817) to run the Forge backup
        I am using. Once I have made the suggested changes, the server runs as expected.
   
## The following steps are optional.
   1. [^1]...

      
## Footnotes:
   [^1]: Example footnote.
