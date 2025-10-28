# Step 5 | Application Setup & Configuration
> **Part of:** Proxmox Container Setup Guide  
> **Applies to:** Debian 13 (Bookworm) Containers & Proxmox Hosts  
> **Goal:** Install, configure, and secure applications such as websites, databases, and game servers

---

## 📘 Goals

- Deploy applications inside containers  
- Configure mount points for persistent storage  
- Set up web servers, databases, and game servers  
- Secure applications with proper permissions and SSL  

---

## 1️⃣ | Website Hosting

- **Decide hosting application**: WordPress, Nginx, Apache, etc.  

- **Create datasets for website directories**
```bash
zfs create tank-fileserver/crafthoundgaming
zfs create tank-fileserver/overthehillstead
```

- **Mount datasets inside the fileserver container**
```bash
pct set 101 -mp3 /tank-fileserver/crafthoundgaming,mp=/srv/crafthoundgaming
pct set 101 -mp4 /tank-fileserver/overthehillstead,mp=/srv/overthehillstead
```

- **Create directories for each domain**
```bash
mkdir -p /srv/crafthoundgaming
mkdir -p /srv/overthehillstead
chmod -R 755 /srv/crafthoundgaming
chmod -R 755 /srv/overthehillstead
```

- **Set up test index pages**
```bash
echo "This site is crafthoundgaming" > /srv/crafthoundgaming/index.html
echo "This site is overthehillstead" > /srv/overthehillstead/index.html
```

- **Copy Apache default config for each site**
```bash
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/crafthoundgaming.conf
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/overthehillstead.conf
```

- **Edit virtual host configs**
```text
# Example: /etc/apache2/sites-available/crafthoundgaming.conf
<VirtualHost *:80>
    ServerName crafthoundgaming.com
    ServerAlias www.crafthoundgaming.com
    DocumentRoot /srv/crafthoundgaming
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

- **Enable configs and restart Apache**
```bash
a2ensite crafthoundgaming.conf
a2ensite overthehillstead.conf
systemctl restart apache2
```

---

## 2️⃣ | Securing Websites with SSL

- **Install Certbot**
```bash
apt install certbot python3-certbot-apache -y
```

- **Verify Apache virtual host configuration**
```bash
apache2ctl configtest
systemctl reload apache2
```

- **Obtain SSL certificate**
```bash
certbot --apache
```

- **Test automatic renewal**
```bash
systemctl status certbot.timer
certbot renew --dry-run
```

---

## 3️⃣ | Installing MariaDB

- **Install MariaDB server**
```bash
apt update && apt upgrade -y
apt install mariadb-server -y
```

- **Secure installation**
```bash
mysql_secure_installation
```

Follow the prompts to remove anonymous users, disable remote root login, and remove test databases.

---

## 4️⃣ | Installing WordPress (Optional)

- **Set up database for WordPress**
```bash
mysql -u root -p
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost' IDENTIFIED BY 'strongpassword';
FLUSH PRIVILEGES;
EXIT;
```

- **Download and configure WordPress**
```bash
cd /srv/crafthoundgaming
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz
```

- **Update `wp-config.php` with database credentials**  

---

## 5️⃣ | Game Server Deployment (Optional)

- **Decide container ID and server name**  
- **Use turnkey LXC template**  
- **Configure CPU, RAM, and storage**  
- **Complete console installation**
```bash
pct enter <gameContainerID>
# Follow prompts for game server setup
```

- **Set server timezone**
```bash
dpkg-reconfigure tzdata
```

- **Start and monitor the game server**
```bash
./mcserver st
./mcserver dt
```

- **Create snapshot before making changes**
```bash
pct snapshot <gameContainerID> pre-update
```

---

## ✅ Summary

After Step 5, you will have:

- Websites hosted in LXC containers with correct mount points  
- Apache virtual hosts configured with SSL certificates  
- MariaDB installed and secured  
- Optional WordPress installations ready for use  
- Optional game servers installed, configured, and snapshotted  

---

Next → Step 6: Optional Applications, Media & Automation
