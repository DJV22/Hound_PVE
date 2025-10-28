# Step 2 | Repository Setup & SSH Hardening
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Stable package sources and secure SSH access  

---

## 🧱 Repository Setup

Proper repositories ensure system stability and security updates without enterprise subscription warnings.

---

### 1️⃣ Clean Up Default Proxmox Repositories

If your Proxmox host or Debian container shows subscription warnings when updating, disable the enterprise repo and add the community repo.

**Edit the APT sources:**
```bash
nano /etc/apt/sources.list.d/pve-enterprise.list
```

Comment out the enterprise line:
```bash
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```

Then add the **no-subscription** repo:
```bash
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" | sudo tee /etc/apt/sources.list.d/pve-no-subscription.list
```

---

### 2️⃣ Check and Update Debian Repositories

Edit your main sources file:
```bash
nano /etc/apt/sources.list
```

Recommended contents:
```bash
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
```

Update and clean the system:
```bash
apt update && apt full-upgrade -y
apt autoremove -y
```

---

### 3️⃣ Container Repository Setup (Inside Debian 13 LXC)

If you are setting up repositories inside a Debian container:
```bash
nano /etc/apt/sources.list
```

Minimal recommended configuration:
```bash
deb http://deb.debian.org/debian bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free-firmware
```

Then update the system:
```bash
apt update && apt upgrade -y
```

✅ **Repository setup complete.**

---

## 🔐 SSH Hardening

Locking down SSH access is essential to protect your private server and containers from unauthorized access.

---

### 1️⃣ Generate SSH Keys (on Your Local Machine)

If you don’t already have an SSH key pair, create one:
```bash
ssh-keygen -t ed25519 -C "yourname@familyshare"
```

Accept defaults and optionally add a passphrase.

Copy the public key to your server:
```bash
ssh-copy-id root@your_server_ip
```

If that command fails, you can manually copy the public key:
```bash
nano ~/.ssh/authorized_keys
```

Paste your key and save the file.

---

### 2️⃣ Harden SSH Configuration on the Server

Edit the SSH configuration file:
```bash
nano /etc/ssh/sshd_config
```

Modify or add the following lines:
```bash
PermitRootLogin prohibit-password
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PubkeyAuthentication yes
PermitEmptyPasswords no
AllowUsers root your_admin_user
ClientAliveInterval 300
ClientAliveCountMax 2
```

Restart SSH to apply:
```bash
systemctl restart ssh
```

---

### 3️⃣ Optional Security Enhancements

#### 🧱 Fail2ban — Protect Against Brute Force
```bash
apt install fail2ban -y
systemctl enable fail2ban --now
```

#### 🧱 UFW Firewall — Basic Access Control
```bash
apt install ufw -y
ufw allow 22/tcp
ufw enable
ufw status
```

Optionally restrict SSH access to trusted subnets or IPs:
```bash
ufw allow from 10.0.0.0/24 to any port 22
```

---

### 4️⃣ Test Key-Based Login

From your local system, try connecting:
```bash
ssh root@your_server_ip
```

You should be logged in without a password prompt — only with your SSH key.

If you try from another machine without the private key, access should be denied.

✅ **SSH hardening complete!**

---

### ✅ Summary

After completing Step 2, your environment now has:

- Clean, stable, **free-only** Debian and Proxmox repositories  
- **Secure, key-based SSH access** only  
- Optional **Fail2ban and UFW** protections  
- Reduced risk of unauthorized logins or updates breaking your system  

---

*(Next → Step 3: Container Network Configuration & Storage Setup)*
