Outlines of Approaches to System Organization
======

## Organization Goal (Working Rules)
   1. The overall design goal is a stable platform with the given hardware. The attached systems should be as follows:
      * Necessary to support "game servers" and other isolated systems.
      * Necessary to support a "home/office" network.
   2. Don't do *anything* or make changes if not *explicitly* required by the overall goal. While a "game server" is not
      necessary, strictly speaking, the subsystems for it to exist, be in a stable and healthy VM environment are.

## Machine Organization
   1. Gateway (plus two bridges)  
      These are part of the mesh network. The Gateway provides DHCP and IPv4, IPv6 LAN addresses. Note: It does *NOT*
      provide DNS, but rather custom (as currently set) IPv4 addresses. The Primary is a local DNS, the Secondary is
      a DNS provided by the external ISP in the event the Primary is unavailable (or doesn't exist yet).
   2. PVE (physical machine)  
      This is the Proxmox Virtual Environment hosting all other self-contained systems as either a Linux Container or
      a Virtual Machine. The PVE must be a) Stable to provide hardware resources such as a single SATA Raid device. All
      other considerations fall under the "don't do anything unless required" policy.
   4. DNS (LXC)  
      This DNS appliance provides identity to the entire local network, as "Local DNS" is not supplied by the Gateway
      host. In cases where DNS is supplied by the local gateway or by other means, this machine should of course be
      completely ignored.
   5. Fileserver (LXC)  
      This Fileserver appliance provides controlled access to "shared SATA" file storage on PVE. The notion of "fast"
      storage is built into the root file-system of each machine running off PVE's SDD drive. Other appliances such as
      a "Linux Nginx MariaDB PHP" server can simply use network protocols to communicate if needed to other clients
      on the LAN. "Slow SATA" through the SMB Fileserver is adequate for "slow filesystem" sharing.
   6. Other supported systems (LXC and VM systems)  
      Gameservers, potential VMWare Windows machines, any other container of interest. It must be isolated so as not
      to potentially harm any other system on the network.

## Fileserver Organization
   1. PVE has direct access to and provides the support of "storage" as defined in "Datacenter-Storage".
      * PVE will store data on the root SSD that benefit from speed, but is *not* consider protected from drive failure:
        - "local" filesystem provides "Snippets" for speed. To avoid confusion, there is a
           [link to Snippets information](https://forum.proxmox.com/threads/explaining-snippets-feature.53553/). While
           set initially on "local", the "ISO Image", "(LXC) Container Templates" and "VZ Dump" folders will be moved
           to the "/tank" SATA system, mentioned later in this outline.
        - "local-zfs" block device provides the "Disk image" and "Container" storage for root filesystems and block
           device backup storage for host snapshot backups managed by PVE.
      * PVE will provide a ZFS pool named "tank" hosting RAIDz protected from single SATA drive failure, and is thus
        suitable (if slow) for "Long Term Storage" prior to rotating backups off-host and/ or off-site. The "tank" is
        also available to each host on the LAN for file sharing as appropriate. Obviously, hosts that do not store
        "long term data" beyond the service they provide need not have access to the "tank." This arrangement is as
        follows:
        - `/tank` is the directory source on PVE providing the ZFS Datasets which can be independently configured by
          ZFS fir quotas and other options as desired. Note: No quotas are actually set at this time, but such changes
          can be made "on-the-fly" as determined appropriate with ZFS.
        - `/tank/filesystem/backup/` is a dataset for each host to make and manage data packups, such as a minecraft
          server backing up `./world` and `./log` files rather than the entire machine. Subfolders per host.
        - `/tank/filesystem/homes/` is a dataset for each named user on the network to store backups of their private
          files they would wish to carry between Windows clients or have as their "home" directory on a *nix host
          dedicated to client use. Subfolders per LAN user.
        - `/tank/filesystem/shared/` is a dataset for files to be easily shared among hosts and clients without an
          explicitly defined host, client, or user. This is appropriate of media such as music or images, with
          sub-folders created based upon the expected content within.
        - `/tank/vz/` is a dataset for various backups, LXC templates, and ISO images. The directories are matained
          by the PVE software.
          
   2. Given the above datasets provided by PVE, the Fileserver will in turn host the datasets on the shared network
        as appropriate to SMB clients:
        - `templates` for `/tank/template` images... this is likely only of use for Windows clients to drop ISO images
          for use by PVE, but allows for LXC templates to be uploaded also and directly available to PVE.
        - `backups` for `/tank/filesystem/backup/<host>`, as mentioned to allow a given host to create subset backups
          appropriate to its function.
        - `home` for `/tank/filesystem/home/<user>`.
        - `shared` for `/tank/filesystem/shared`.
