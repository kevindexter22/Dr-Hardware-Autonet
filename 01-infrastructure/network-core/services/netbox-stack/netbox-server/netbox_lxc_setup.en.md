
# 📄 SOP: Clean Install of NetBox in LXC (Ubuntu 22.04 + PostgreSQL 16 + Python 3.12)

### 📋 Process Description

This guide shows how to install NetBox as a Single Source of Truth (SSoT). We use an LXC container in Proxmox VE. The setup is updated and safe. 

We use a Zero Trust model (no open ports on the router).

##

### 🛠️ Phase 1: Create the Container (Proxmox VE)

Run this command in the Proxmox CLI. This sets the exact resources and keeps it isolated:

```bash
pct create 101 local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
  -cores 2 \
  -memory 1536 \
  -swap 1024 \
  -disk local-lvm:10 \
  -net0 name=eth0,bridge=vmbr0,ip=10.10.0.250/24,gw=10.10.0.1 \
  -ostype ubuntu \
  -unprivileged 1 \
  -start 1
```

##

### 📦 Phase 2: Update OS and Modern Repositories

Access the LXC terminal as root.

You need to add the official PostgreSQL and Python Core repositories. This installs the updated packages in Ubuntu 22.04.

```bash
apt update && apt upgrade -y
apt install -y curl ca-certificates gnupg software-properties-common git nginx sudo redis-server build-essential libxml2-dev libxslt1-dev libffi-dev libssl-dev zlib1g-dev

# 1. Official PostgreSQL Repository
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# 2. Updated Python Repository (Deadsnakes)
add-apt-repository ppa:deadsnakes/ppa -y

# 3. Native Stack Installation
apt update
apt install -y postgresql-16 postgresql-client-16 libpq-dev python3.12 python3.12-venv python3.12-dev
```

##

### 🗄️ Phase 3: Database Layer

Proxmox LXC templates do not have a defined locale. This forces Postgres to start in ASCII mode.

We fix this by forcing the clone of template0 in UTF-8.

1. Access the postgresql prompt

```bash
sudo -u postgres psql
```

2. Inside the postgres=# prompt, run:

```bash
-- Forces correct encoding, ignoring the broken template1
CREATE DATABASE netbox ENCODING 'utf8' TEMPLATE template0;
CREATE USER netbox WITH PASSWORD 'YourSecurePasswordHere';
ALTER DATABASE netbox OWNER TO netbox;
\q
```

3. PostgreSQL 16 Memory Tuning

Adjust the buffers to fit the 1.5 GB RAM limit of the LXC:

```bash
nano /etc/postgresql/16/main/postgresql.conf
# Change or add the line:
shared_buffers = 256MB
```

4. Save the file and restart the database

```bash
systemctl restart postgresql
```

##

### 🚀 Phase 4: NetBox App Installation and Configuration

1. Clone the Stable Branch

```bash
mkdir -p /opt/netbox/ && cd /opt/netbox/
git clone -b main --depth 1 https://github.com/netbox-community/netbox.git .

# Create system user without login shell for security
useradd --system --shell /bin/bash --home /opt/netbox/ netbox
chown -R netbox:netbox /opt/netbox/
```
 
2. Django Environment Configuration

```bash
cd /opt/netbox/netbox/netbox/
cp configuration_example.py configuration.py

# Generate unique secret key
python3.12 ../generate_secret_key.py
# Copy the generated key and paste it in a notepad so you don't lose it
```

3. Edit the nano configuration.py file. Configure the variables strictly to avoid the HTTP 400 Bad Request error:

```bash
# Allows internal DNS mapping without framework rejection
ALLOWED_HOSTS = ['*']

DATABASE = {
    'NAME': 'netbox',
    'USER': 'netbox',
    'PASSWORD': 'YourSecurePasswordHere',
    'HOST': 'localhost',
    'PORT': '',
    'CONN_MAX_AGE': 300,
}

REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'DATABASE': 0,
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'DATABASE': 1,
    }
}

SECRET_KEY = 'PASTE_THE_GENERATED_KEY_HERE'
```

Save the file.

4. Run the Build Pipeline (Upgrade Script)

Force the script to use the correct Python 3.12 binary to build the virtual environment (venv):

```bash
cd /opt/netbox/
sudo PYTHON=/usr/bin/python3.12 ./upgrade.sh
``` 

5. Create Admin Credentials

``` bash
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox/
python3 manage.py createsuperuser
deactivate
```

##

### 🔄 Phase 5: Service Management and Gunicorn Tuning

Copy the systemd unit files. Adjust the workers so they do not break the LXC RAM memory:

```bash
cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
nano /opt/netbox/gunicorn.py

# Change to optimize container resources:
workers = 1
threads = 2
# Save the configuration file

# Map services in the system
cp /opt/netbox/contrib/*.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now netbox netbox-rq
```

##

### 🔒 Phase 6: Web Layer and SSL Encryption (Acme.sh)

To prevent Nginx startup fails due to missing files, we generate the certificate before activating the web server route block.

##
**⚠️*Note:*** *If you have your own domain and want to use it, follow the documented steps in [netbox_ssl_certificate_domain](#).*
##

1. DNS-01 Challenge via acme.sh

```bash
curl https://get.acme.sh | sh -s email=your-email@domain.com
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
source ~/.bashrc
mkdir -p /etc/ssl/netbox

# Run the issue command for your DNS provider (Ex: DuckDNS/Cloudflare)
export DuckDNS_Token="YOUR_TOKEN"
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d your-lab.duckdns.org -k 2048

# After successful validation, install the structured keys:
/root/.acme.sh/acme.sh --install-cert -d your-lab.duckdns.org \
--key-file       /etc/ssl/netbox/netbox.key  \
--fullchain-file /etc/ssl/netbox/netbox.cer
--reloadcmd      "systemctl reload nginx"
```

2. Validate the certificate renewal automation

```bash
crontab -l
```
*Result: `15 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null`.*

3. Reverse Proxy Configuration (Nginx)

```bash
cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
nano /etc/nginx/sites-available/netbox
```

4. Adjust the main server block. Make sure names and paths match exactly:

```bash
server {
    listen [::]:443 ssl ipv6only=off;
    
    server_name your-lab.duckdns.org;

    # Absolute paths generated by the acme.sh installer
    ssl_certificate /etc/ssl/netbox/netbox.cer;
    ssl_certificate_key /etc/ssl/netbox/netbox.key;

    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Save the file and restart the web stack:

```bash
nginx -t
systemctl restart nginx
```

To test:

```bash
https://your-lab.duckdns.org
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
