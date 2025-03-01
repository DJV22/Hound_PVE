bigrig-scripts

A series of BASH scripts for setting up a bare-metal device as a \"large
scale hypervisor\" with Proxmox

# Purpose

The task is to use [Proxmox](https://www.proxmox.com/en/) on a [UM790
Pro](https://store.minisforum.com/collections/all-product/products/minisforum-um790-pro)
with 96GiB of Ram, 1.82 TiB SSD, and a USB bay of five 3.64 TiB SATA
drives. The end result will have scripts to manage the finalized
installation of the OS (Proxmox is Debian based) and the hardware
suitable to providing services with the simulated failure of one SATA
drive to be reconstructed after notification, then register the
reconstruction is complete.

# Milestones

1. Install [PVE](../main/PVE.md) (the Proxmox Virtual Environment)

2. Install [DNS](../main/DNS.md) (the DNS Server Appliance)

2. With reference to this [howto](https://forum.proxmox.com/threads/add-pam-user-to-pve-admin-group.87036/),
   invoke the following:
   ```
   pveum user add <user>@pam
   pveum user list
   pveum acl modify / --roles PVEAdmin --users <user>@pam
   ```
3. Lock down the server with the firewall[^3].
   This is through the PVE Web, Datacenter:firewall/options, select "Firewall" on the right-side panel and
   the "edit" button above that. Select the "Firewall" checkbox on the pop-up and "ok."

4. Prepare for on-going maintenance  
   1. Repositories need to be set for "no subscription" according to the relevant
   [howto](https://www.virtualizationhowto.com/2022/08/proxmox-update-no-subscription-repository-configuration/).
   Both GUI and CLI options are provided on the page.
   2. The system will need an `sudo apt update -y && sudo apt upgrade -y` command, of course.
   3. Install git with `sudo apt install git -y`
   4. Check the [howto](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup)
      for information on setting up your git account on your server, if you need.
   5. gpg is already installed, you must to add your private key and configure according
   to another [howto](https://aalonso.dev/blog/2022/how-to-generate-gpg-keys-sign-commits-and-export-keys-to-another-machine)
   on the \<adminuser\> account[^4].
   6. A local \<adminuser\> "git" repository needs made for this documentation as well as the
      scripts for performing further setup to simplify fresh installations[^6]. Create the
      directory for this and other git "projects," clone the script site, and change to that
      directory. Keep in mind, if you are not using SSH Key forwarding (such as when using the
      built-in shell window of the web GUI), it won't work. SSH into this with key forwarding!
      ```
      mkdir -p ~/projects && cd ~/projects && git clone git@github.com:Romaq/bigrig-scripts.git
      cd ~/projects/bigrig-scripts/bigrig-scripts
      ```

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
