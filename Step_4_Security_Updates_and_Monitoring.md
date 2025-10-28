# Step 4 | Container Security, Updates & Monitoring
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Keep containers secure, up-to-date, and monitored

---

## 📘 Goals

- Keep containers and Proxmox host **up-to-date**  
- Apply **security hardening** for containers and users  
- Enable **monitoring** for resource usage and logs  
- Configure **automatic updates or notifications**

---

### 1️⃣ | System Updates
---
#### Update Proxmox Host
```bash
apt update && apt full-upgrade -y

### Update Debian LXC Containers
```bash
pct enter <containerID>
apt update && apt upgrade -y
apt autoremove -y

### Optional: Enable Unattended Security Updates

```bash
apt install unattended-upgrades -y
dpkg-reconfigure unattended-upgrades
---
### 2️⃣ | User and Permission Security

- **Limit root login:** Already done in Step 2 (SSH key-based only)

- **Create admin user inside container:**

```bash
adduser familyadmin
usermod -aG sudo familyadmin

**Set file permissions for sensitive directories:**

```bash
chown -R root:root /etc /var/www
chmod -R 700 /etc
chmod -R 750 /var/www

Remove unnecessary users:

bash
Copy code
deluser --remove-home unwanteduser
3️⃣ | Fail2Ban & Firewall (Optional, Recommended)
Fail2Ban
bash
Copy code
apt install fail2ban -y
systemctl enable --now fail2ban
UFW Firewall
bash
Copy code
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
4️⃣ | Resource Monitoring
Proxmox GUI: Check CPU, RAM, disk, and network usage per container

Inside containers: Install monitoring tools if desired:

bash
Copy code
apt install htop iftop iotop -y
htop
Logs: Check system logs regularly:

bash
Copy code
journalctl -xe
tail -f /var/log/syslog
5️⃣ | Snapshots and Backups
Snapshots before major changes:

bash
Copy code
pct snapshot <containerID> pre-update
Regular backup schedule (from Step 3) ensures recovery if updates fail

6️⃣ | Optional: Automatic Update Notifications
Install apticron inside container to get email notifications of available updates:

bash
Copy code
apt install apticron -y
nano /etc/apticron/apticron.conf
Configure admin email to receive alerts

✅ Summary
After completing Step 4, you will have:

Fully patched and updated containers

SSH key-only access for admins

Firewall and Fail2Ban protections

Resource monitoring setup

Regular snapshots and backup schedule

(Next → Step 5: Application Setup & Configuration)
