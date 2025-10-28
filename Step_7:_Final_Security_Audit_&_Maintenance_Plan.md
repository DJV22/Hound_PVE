# Step 7 | Final Security Audit & Maintenance Plan  
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Perform a final security audit, verify maintenance procedures, and ensure long-term reliability  

---

## 📘 Goals  

- Conduct a complete **security audit** on Proxmox and containers  
- Verify **firewall, SSH, and permissions**  
- Establish **routine maintenance and backup policies**  
- Enable **system health checks and monitoring alerts**  

---

## 1️⃣ | Security Audit Checklist  

### Check for active users and permissions  
```bash  
cat /etc/passwd | grep "/home"  
getent group sudo  
```  

### Review sudoers configuration  
```bash  
visudo  
```  

Make sure only trusted users are listed under `%sudo` or `sudo` privileges.  

### Verify SSH configuration  
```bash  
cat /etc/ssh/sshd_config | grep -E "PermitRootLogin|PasswordAuthentication"  
```  

**Expected values:**  
```  
PermitRootLogin no  
PasswordAuthentication no  
```  

Restart SSH to apply changes:  
```bash  
systemctl restart ssh  
```  

---

## 2️⃣ | Firewall and Network Audit  

### UFW Status  
```bash  
ufw status verbose  
```  

Ensure only required ports (22, 80, 443) are open.  

### Check listening services  
```bash  
ss -tuln  
```  

### Verify Fail2Ban  
```bash  
fail2ban-client status  
fail2ban-client status sshd  
```  

---

## 3️⃣ | Update & Patch Verification  

### Check pending updates  
```bash  
apt update && apt list --upgradable  
```  

### Apply security patches  
```bash  
apt upgrade -y  
```  

### Review unattended-upgrades logs  
```bash  
cat /var/log/unattended-upgrades/unattended-upgrades.log  
```  

---

## 4️⃣ | Backup Verification  

### List Proxmox backups  
```bash  
ls /var/lib/vz/dump/  
```  

### Manually test backup restore (optional)  
```bash  
pct restore <backupID> <newContainerID> --storage local-lvm  
```  

### Validate snapshot list  
```bash  
pct listsnapshot <containerID>  
```  

Ensure all critical containers have recent snapshots.  

---

## 5️⃣ | Log Review and System Integrity  

### System log check  
```bash  
journalctl -p 3 -xb  
```  

### Check authentication logs  
```bash  
grep "Failed password" /var/log/auth.log  
```  

### Check for rootkit or malware (optional)  
```bash  
apt install chkrootkit -y  
chkrootkit  
```  

---

## 6️⃣ | Monitoring and Alerts  

### Configure automatic log rotation  
```bash  
cat /etc/logrotate.conf  
```  

### Check resource usage trends  
```bash  
htop  
iotop  
df -h  
```  

### Optional: Set up email alerts with `apticron`  
```bash  
apt install apticron -y  
nano /etc/apticron/apticron.conf  
```  

---

## 7️⃣ | Routine Maintenance Schedule  

| Task | Frequency | Command / Location |  
|------|------------|--------------------|  
| Update system packages | Weekly | `apt update && apt upgrade -y` |  
| Review logs | Weekly | `journalctl`, `/var/log/syslog` |  
| Test backups | Monthly | `pct restore` (dry run) |  
| Snapshot containers | Before major changes | `pct snapshot <id>` |  
| Review firewall rules | Quarterly | `ufw status verbose` |  
| Check disk usage | Weekly | `df -h` |  

Create a Cron job for automated updates:  
```bash  
crontab -e  
```  

Add:  
```bash  
0 3 * * 0 apt update && apt -y upgrade && apt -y autoremove  
```  

---

## 8️⃣ | Optional Hardening Enhancements  

- Use **AppArmor** or **SELinux** for process isolation  
- Enable **2FA** for Proxmox Web UI  
- Set **container resource limits** (`pct set <id> -memory 2048 -swap 0`)  
- Disable unused kernel modules (e.g., USB, Bluetooth) on servers  
- Use **auditd** for file access tracking  

```bash  
apt install auditd -y  
systemctl enable --now auditd  
```  

---

## ✅ Summary  

After completing Step 7, you will have:  

- Verified system security and user permissions  
- Enforced SSH key-only and firewall rules  
- Ensured automated patching and backup reliability  
- Established a long-term maintenance schedule  
- Gained visibility into system logs, alerts, and performance  

Your Proxmox and Debian containers are now **secure, resilient, and ready for long-term private use**.  

---

**(End of Setup Guide — FamilyShare Deployment Ready)**
