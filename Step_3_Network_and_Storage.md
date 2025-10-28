# Step 3 | Container Network Configuration & Storage Setup
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Configure container networking and persistent storage

---

## 📘 Goals

- Set **static IPs** for your Debian 13 containers  
- Enable **bridge networking** for LAN access  
- Configure **DNS, gateway, and hostname**  
- Add **mount points** and **binds** for persistent storage  
- Set up **backups** and **ZFS storage pools**

---

### 1️⃣ | Understand Proxmox Networking

Proxmox uses Linux bridges (`vmbr0`, etc.) to connect containers (LXC) and VMs to your physical network.

Example host network file:
```bash
nano /etc/network/interfaces
```

Typical configuration:
```bash
auto lo
iface lo inet loopback

auto eno1
iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
    address 10.0.0.2/24
    gateway 10.0.0.1
    bridge_ports eno1
    bridge_stp off
    bridge_fd 0
```

- `eno1`: physical NIC  
- `vmbr0`: virtual bridge for container LAN access  

✅ Containers behave like normal devices on the LAN.

---

### 2️⃣ | Configure Network for a Container (Static IP)

#### Using the Web UI

1. Select container → **Network** tab  
2. Click **Edit**  
3. Set:
   - IPv4: **Static**  
   - IP: `10.0.0.10/24`  
   - Gateway: `10.0.0.1`  
   - DNS: `1.1.1.1`  
4. Check “Start at boot”

#### Using CLI

```bash
nano /etc/pve/lxc/101.conf
```

Example entry:
```
net0: name=eth0,bridge=vmbr0,hwaddr=12:34:56:78:90:AB,ip=10.0.0.10/24,gw=10.0.0.1
```

Restart container:
```bash
pct stop 101 && pct start 101
```

Test connectivity:
```bash
ping -c 3 8.8.8.8
ping -c 3 google.com
```

---

### 3️⃣ | Set Hostname and DNS Inside Container

```bash
hostnamectl set-hostname familyshare
nano /etc/hosts
```

Example `/etc/hosts`:
```
127.0.0.1 localhost
10.0.0.10 familyshare.local familyshare
```

Configure DNS in `/etc/resolv.conf`:
```
nameserver 1.1.1.1
nameserver 8.8.8.8
```

---

### 4️⃣ | Add Persistent Storage to Containers

#### Create ZFS Dataset
```bash
zfs create -o mountpoint=/tank/familyshare tank/familyshare
```

#### Add Mount Point to Container
```bash
pct set 101 -mp0 /tank/familyshare,mp=/mnt/familyshare
```

Inside container:
```bash
ls /mnt/familyshare
```

---

### 5️⃣ | Configure Storage Backups

Create backup directory on host:
```bash
mkdir -p /tank/backups
```

Add in Proxmox GUI → Datacenter → Storage → Add → Directory
- ID: `local-backups`
- Directory: `/tank/backups`
- Content: `VZDump backup file`
- Enable: ✅

#### Schedule Automatic Backups
- Datacenter → **Backup**  
- Add Job:
  - Storage: `local-backups`
  - Schedule: daily/weekly (`0 3 * * 0` for Sundays)
  - Mode: snapshot
  - Optional email notifications

---

### 6️⃣ | Verify Configuration

```bash
ip addr show
ping -c 3 8.8.8.8
df -h
pct list
```

Check that:
- Container IP and bridge active  
- Network pings succeed  
- Mount points are writable  
- Backups listed under `/tank/backups`  

✅ Networking & storage successfully configured!

---

### 🔧 Optional Enhancements

- Add secondary mount for `/var/www/uploads` for large media  
- Use `rsync` or `rclone` to offload backups to external NAS/cloud  
- Create ZFS snapshots: `zfs snapshot tank/familyshare@daily`  

---

### ✅ Summary

After Step 3, your environment has:
- Static network configuration for containers  
- LAN bridge connectivity  
- Correct hostname and DNS settings  
- Persistent storage mounts  
- Automated backup workflow via ZFS or directories  

Next → **Step 4: Container Security, Updates & Monitoring**
