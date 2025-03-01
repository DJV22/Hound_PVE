 Outline of build for the DNS host
======

## Build Goal (Working Rules)
   1. The purpose of this document is as follows:
      * Provide a NAT interface machines can connect to hidden behind PVE.
   2. Don't do *anything* or make changes if not *explicitly* required by the overall goal.

## Install Actions
   1. There is a [howto](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_network_configuration) on setting up
      a Masquerading (NAT) with IP Tables.
   2. The recommended path is to use the GUI which helps avoid making mistakes. This would be under Datacenter/ pve | System/ Network. "Create:
      Linux Bridge" ...
   3. Unfortunately, the "admin" manual is big on presuming underestanding and short on instructions. 
   [Setup NAT on Proxmox](https://bobcares.com/blog/setup-nat-on-proxmox/) may provide useful information.
   4. The part where I failed is that I attempted to link to enp2s0. I should have linked to vmbr0. The instructions also provide more clues,
      but not really instructions on how to arrange it. As a for-instance, I have a command to do port-forwarding, but there is no instruction
      on where and how to put that such that it is a natural part of the boot process, happening automatically.
   5. ComputingForGeeks.com may actually have a better [Guide](https://computingforgeeks.com/create-private-network-bridge-proxmox-with-nat/)
      for what I'm attempting to do. I have a functional network, additional VMs pull DHCP out of the EERO machine I'm using, and each machine
      gets IPv6 as well as IPv4 from its DHCP.
   6. Still not adequate. I have the device set up, but my VPN VM is doing DHCP for something that will never answer. SDN offers DHCP, but as
      I recall, it doesn't handle the port-forwarding. [I'll have to find that quote and put it back here as a note.](https://forum.proxmox.com/threads/is-it-possible-to-do-port-forwarding-when-using-sdn.154445/) "Port forwarding needs to be done manually." Still kinda nutz.
   7. https://thelinuxforum.com/articles/924-how-to-create-a-private-nat-network-interface-on-proxmox-ve-8 may actually explain it *if* I can
      still do port-forwarding.
   8. I begged help from https://thelinuxforum.com/member/2-kasimba/activities. Tomorrow, I will play with SDN more and then see if it works
      as expected, then further try to grasp that one last little piece that does port-forwarding.
## Footnotes:
   [^1]: ...
