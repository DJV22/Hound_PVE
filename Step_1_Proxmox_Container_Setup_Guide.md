# Proxmox Container Setup Guide
> **Author:** crafthound  
> **Environment:** Debian 13 (Bookworm) on Proxmox VE 8.x  
> **Last Updated:** October 2025  

---

## 🧭 Overview

This guide walks through installing and configuring **Proxmox VE** on a Debian-based system, along with **optional shell customizations** that improve usability and safety for system administrators.  

Includes:
- Proxmox VE installation and setup  
- System updates  
- Recommended shell enhancements (`.bashrc` configuration)  
- Tips for safe, efficient administration  

---

## 1 | Install Proxmox VE (PVE)

### Hardware Example
| Component | Spec |
|------------|------|
| System | Minisforum UM890 PRO |
| Memory | 96 GB DDR5 |
| Storage | (2) × 4 TB NVMe SSD — ZFS RAID1 |
| Hostname | `pve.local` |

---

### Installation Steps

1. **Download the Latest ISO**  
   Get the current Proxmox VE image from  
   👉 [https://www.proxmox.com/en/downloads](https://www.proxmox.com/en/downloads)

2. **Create the Installer USB**  
   - Use **Balena Etcher**, **Ventoy**, or `dd` on Linux.  
   - Example (Linux):  
     ```bash
     sudo dd if=proxmox-ve_8.iso of=/dev/sdX bs=4M status=progress
     sync
     ```

3. **Boot and Install**  
   - Choose **Install Proxmox VE**.  
   - Select **ZFS (RAID1)** for the two SSDs.  
   - Set:
     - Root password  
     - Email address (for alerts)  
     - Management interface IP (static recommended)  

4. **First Login**  
   - On the PVE console, note the assigned IP.  
   - From another PC on the same network open:  
     ```
     https://<proxmox-ip>:8006
     ```  
     Example → `https://10.0.0.2:8006`  
   - Login as **root** using the password you set.

5. **Update and Reboot**
   ```bash
   apt update && apt full-upgrade -y
   reboot
   ```

---

## ⚙️ Customize Your Bash Shell (Optional but Recommended)

A customized Bash shell makes administration faster, safer, and clearer.  
This section details how to back up, modify, and enhance your Bash environment.

---

### 1️⃣ Backup and Edit `.bashrc`

Before editing:
```bash
cp ~/.bashrc ~/.bashrc.bak
nano ~/.bashrc
```

Scroll to the bottom and append the following configuration block:

```bash
# === Custom Bash Settings for Proxmox Admin ===

# Enable colorized output for common tools
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls -alF $LS_OPTIONS'
alias la='ls -A $LS_OPTIONS'

# Safer root prompt (shows hostname + path clearly)
PS1='\[\e[1;31m\]\u@\h:\[\e[1;34m\]\w\[\e[0m\]\$ '

# Show timestamp in command history
HISTTIMEFORMAT="%F %T "

# Handy maintenance shortcuts
alias update='apt update && apt full-upgrade -y'
alias rebootnow='reboot'
alias cls='clear'
alias editbash='nano ~/.bashrc'

# Confirm before destructive operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Show disk and memory usage quickly
alias dfh='df -hT'
alias duh='du -sh * 2>/dev/null | sort -h'

# Custom greeting
echo -e "\e[32mWelcome to Proxmox VE Admin Shell on $(hostname -f)\e[0m"
```

Save and exit (**Ctrl + O**, **Enter**, **Ctrl + X**), then reload to apply changes:

```bash
source ~/.bashrc
```

---

### 2️⃣ Verify Your Customizations

Test the shell:

```bash
ll
history | tail
echo $PS1
```

You should see:
- **Colorized output** from `ls`
- A **red prompt** showing your username, hostname, and path
- **Timestamps** in command history

---

### 3️⃣ Optional Enhancements

#### Global Profile (All Users)
To apply the same configuration system-wide:

```bash
cp ~/.bashrc /etc/skel/.bashrc
cp ~/.bashrc /root/.bashrc
```

#### Distinct Host Prompts
Use different prompt colors for production, staging, and development:

```bash
case "$HOSTNAME" in
  pve-prod*) PS1='\[\e[1;31m\]\u@\h:\w\$\[\e[0m\] ' ;;  # Red
  pve-test*) PS1='\[\e[1;33m\]\u@\h:\w\$\[\e[0m\] ' ;;  # Yellow
  *) PS1='\[\e[1;32m\]\u@\h:\w\$\[\e[0m\] ' ;;           # Green
esac
```

#### Revert to Default
If needed:
```bash
mv ~/.bashrc.bak ~/.bashrc
source ~/.bashrc
```

---

### 4️⃣ Extra Tips

- Test color codes interactively:
  ```bash
  echo -e "\e[1;34mBlue Text\e[0m"
  ```
- Add your hostname to `/etc/motd` for quick visibility after login.  
- Consider version-controlling your `.bashrc` for long-term consistency.  
- Use distinct prompt colors per host to avoid command mistakes on production systems.

---

✅ **Step 1 Complete**  
Proxmox VE is installed, updated, and your Bash shell is now customized for clarity, safety, and efficiency.

---

*(Next → Step 2: Repository Setup & SSH Hardening)*
