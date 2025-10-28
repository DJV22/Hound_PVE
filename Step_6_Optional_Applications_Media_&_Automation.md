# Step 6 | Optional Applications, Media & Automation
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Extend functionality with optional apps, media services, and automation tools

---

## 📘 Goals

- Add media servers (Plex, Jellyfin, etc.)  
- Configure file sharing and backups  
- Add automation tools (Cron, Watchtower, Ansible)  
- Optimize performance and security  

---

## 1️⃣ | Media Server Setup (Optional)

### Install Jellyfin (Recommended Open Source Media Server)
```bash
apt update
apt install apt-transport-https ca-certificates gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /etc/apt/keyrings/jellyfin.gpg
echo "deb [signed-by=/etc/apt/keyrings/jellyfin.gpg] https://repo.jellyfin.org/debian bookworm main" | tee /etc/apt/sources.list.d/jellyfin.list
apt update
apt install jellyfin -y
```

**Start and enable Jellyfin service**
```bash
systemctl enable --now jellyfin
```

**Access the Web UI:**  
Open your browser and go to  
`http://<containerIP>:8096`

---

## 2️⃣ | File Sharing via Samba (Optional)

### Install Samba inside container
```bash
apt install samba -y
```

### Configure Samba shares
```bash
nano /etc/samba/smb.conf
```

**Example Configuration**
```text
[FamilyShare]
   path = /srv/familyshare
   browseable = yes
   read only = no
   guest ok = no
   valid users = familyadmin
```

### Add user to Samba
```bash
smbpasswd -a familyadmin
systemctl restart smbd
```

---

## 3️⃣ | Automated Backups and Snapshots

### Create a cron job for daily LXC snapshots
```bash
crontab -e
```

Add the following line:
```bash
0 3 * * * pct snapshot 101 auto-backup-$(date +\%F)
```

### Backup directory sync to NAS or external storage
```bash
rsync -avz /tank-fileserver/ /mnt/nas-backup/
```

---

## 4️⃣ | Container Auto Updates (Optional)

### Enable Unattended Upgrades
```bash
apt install unattended-upgrades apt-listchanges -y
dpkg-reconfigure unattended-upgrades
```

### Review logs
```bash
cat /var/log/unattended-upgrades/unattended-upgrades.log
```

---

## 5️⃣ | Monitoring and Alerts (Optional)

### Install and configure Netdata
```bash
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### Access Netdata web dashboard
`http://<containerIP>:19999`

---

## 6️⃣ | Automation Tools (Optional)

### Cron Jobs
```bash
crontab -e
```

**Example: Weekly maintenance task**
```bash
0 2 * * 0 apt update && apt -y upgrade && apt -y autoremove
```

### Watchtower (For Docker Containers)
```bash
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower
```

---

## 7️⃣ | Performance Optimization

- Use **ZFS compression** for better performance  
- Set memory and CPU limits for containers  
- Use **Proxmox backup compression** to save space  
- Avoid swap usage by tuning container memory settings  

---

## 8️⃣ | Optional Integrations

- **Nextcloud** for private cloud storage  
- **Vaultwarden** for secure password management  
- **Uptime Kuma** for monitoring container uptime  
- **Tailscale** for private VPN network between family devices  

Example: Install Uptime Kuma  
```bash
docker run -d --restart=always -p 3001:3001 \
  -v uptime-kuma-data:/app/data \
  --name uptime-kuma louislam/uptime-kuma
```

---

## ✅ Summary

After Step 6, you will have:

- Optional media servers (Jellyfin, Plex, etc.)  
- File sharing configured via Samba  
- Automated LXC backups and updates  
- Monitoring with Netdata or Uptime Kuma  
- Optional automation via Cron, Docker, or Watchtower  
- Optimized performance and security across containers  

---

Next → Step 7: Final Security Audit & Maintenance Plan
