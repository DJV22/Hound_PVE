Hound_PVE

A series of BASH scripts for setting up a bare-metal device as a \"large
scale hypervisor\" with Proxmox

# Purpose

The task is to use [Proxmox](https://www.proxmox.com/en/) on a [UM890
Pro](https://store.minisforum.com/products/minisforum-um890pro?_pos=1&_sid=b97dfcda4&_ss=r)
with 96GB of Ram, (2) 4.0 TB SSD. The end result being a usable homelab in which  a website, Fileserver, Home automation, and gameservers can be kept and managed for personal use.


# Outline
1. Download latest version of Proxmox and flash ISO onto a USB stick for installation.
2. Complete the install selecting your desired format and setup. I used the UM890 PRO with 96GB of Ram, (2) 4.0 TB SSD (ZFS RAID1 configuration)
3. Setup Repositories - I chose to go with the No Subscription route currently. This may change in the future so I may support the good people that made this possible.
  a. The following can be done by going to (PVE:Updates:Repositories) on the Right hand of the screen.
    disable 
      Enterprise ceph-quincy
   Enable
       no subsription ceph-quincy
       no subscription ceph-reef
 4. update all packages by selecting (PVE:Updates) on the right hand panel and refresh packages. This should prompt for all the latest updates. Then when TASK ok show in the pop up window. Close that window and press upgrade. When complete it will show "Your System is up-to-date".

# IP Configuration for HoundLab (my Homelab)
  1. Domain / Router - 10.0.0.1
  2. Houndlab (PVE) - 10.0.0.2
  3. DNS (PI.HOLE) - 10.0.0.3
  4. FileServer - 10.0.0.4
  5. Website - 10.0.0.50
  
# Milestones

