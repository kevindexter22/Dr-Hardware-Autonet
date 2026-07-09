# 🌐 High Availability DNS

This repository has the documents and files to make a High Availability (HA) DNS system. You can use it in a HomeLab or a company network.

This solution uses Nginx (L4 Stream Module) and Keepalived (VRRP Protocol). It makes sure the system does not fail (MTTR < 2s) between many nodes. It uses Docker (CasaOS/Raspberry Pi) and LXC (Proxmox).

##

### 🏗️ Logical Architecture

  * Virtual IP (VIP): IP 10.10.0.10 (DNS Gateway for all the network).

  * Node 1 (MASTER): Docker on CasaOS (Raspberry Pi). IP 10.10.0.11 and VRRP Priority: 100.

  * Node 2 (BACKUP): LXC on Proxmox. IP 10.10.0.12 and VRRP Priority: 90.

  * Upstream 1 (Primary DNS): Unbound on CasaOS (IP 10.10.0.13 on port 5353).

  * Upstream 2 (Secondary DNS): Extra DNS Server (example: Pi-hole on 10.10.0.14:53).

##

### ⚠️ Requirements and Host Setup

You must reserve the Virtual IP (10.10.0.10) outside your main router's DHCP pool.

On both nodes (CasaOS host and inside Proxmox LXC), the Linux Kernel must allow services to listen on non-local IPs (VIP). Run this:

```bash
echo "net.ipv4.ip_nonlocal_bind=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

***Port Conflict Prevention (CasaOS):*** *If you use Unbound in a container on Node 1, you must publish the Unbound ports as 5353:53 (TCP and UDP) in the CasaOS panel. Nginx will be the only owner of local port 53.*

##

### 🚀 Phase 1: Deploy Node 1 (MASTER - CasaOS)

1. Access the Raspberry Pi using SSH and create the project folders.

```bash
mkdir -p /DATA/AppData/ha-dns-proxy/nginx
cd /DATA/AppData/ha-dns-proxy
```

2. Nginx Setup (`nginx/nginx.conf`)

Create the `/DATA/AppData/ha-dns-proxy/nginx/nginx.conf` file. Use these L4 settings for UDP (IPv4/IPv6 at the same time) and TCP Keepalive:

```bash
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events { 
    worker_connections 1024; 
}

stream {
    upstream dns_servers {
        # DNS 1: Local Unbound on CasaOS (on port 5353 to avoid conflict)
        server 127.0.0.1:5353 max_fails=2 fail_timeout=5s; 
        
        # DNS 2: Other server on the network (Example: DNS 2)
        server 10.10.0.14:53 backup max_fails=2 fail_timeout=2s;   
    }

    # Proxy for DNS via UDP (Fast queries)
    server {
        listen 53 udp reuseport;
        proxy_pass dns_servers;
        proxy_timeout 2s;
    }

    # Proxy for DNS via TCP (Long answers / Zone Transfer)
    server {
        listen 53 so_keepalive=on;
        proxy_pass dns_servers;
        proxy_timeout 5s;
    }
}
```

3. Keepalived Setup (`keepalived.conf`)

Create the `/DATA/AppData/ha-dns-proxy/keepalived.conf` file and set this node as MASTER:

```bash
global_defs {
    router_id NGINX_DNS_MASTER
}

vrrp_script chk_nginx {
    script "killall -0 nginx"
    interval 2
    weight -20
    fall 2
    rise 2
}

vrrp_instance VI_DNS {
    state MASTER
    interface eth0 
    virtual_router_id 53
    priority 100
    advert_int 1
    
    unicast_src_ip 10.10.0.11  # Replace with the Raspberry Pi physical IP
    unicast_peer {
        10.10.0.12            # Replace with the Node 2 physical IP (LXC Proxmox)
    }

    authentication {
        auth_type PASS
        auth_pass HA_DNS_SECURE
    }

    virtual_ipaddress {
        10.10.0.10/24 dev eth0 label eth0:vip
    }

    track_script {
        chk_nginx
    }
}
```

4. Docker Compose File (`docker-compose.yml`)

Create the file `/DATA/AppData/ha-dns-proxy/docker-compose.yml` with native CasaOS UI support:

```bash
version: '3.8'

services:
  nginx-proxy:
    image: nginx:alpine
    container_name: nginx-dns
    network_mode: "host"
    restart: unless-stopped
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro

  keepalived-ha:
    image: debian:bullseye-slim
    container_name: keepalived-dns
    network_mode: "host"
    pid: "host"
    cap_add:
      - NET_ADMIN
      - NET_BROADCAST
    restart: unless-stopped
    volumes:
      - ./keepalived.conf:/etc/keepalived/keepalived.conf:ro
    command: >
      /bin/bash -c "apt-get update && 
      apt-get install -y keepalived psmisc && 
      keepalived --dont-fork --log-console"

x-casaos:
  architectures:
    - amd64
    - arm64
  main: nginx-proxy
  title:
    en_US: DNS HA Proxy
  icon: [https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/nginx-proxy-manager.png](https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/nginx-proxy-manager.png)
```

***Start the stack:*** `sudo docker compose up -d`

##

### 🛠️ Phase 2: Deploy Node 2 (BACKUP - Proxmox LXC)

Create an unprivileged Ubuntu 22.04 container on Proxmox. To save resources, this LXC can work with only 512MB of RAM.

1. Access the LXC shell and install the packages:

```bash
apt update -y && apt install nginx libnginx-mod-stream keepalived psmisc -y
```

2. Stop and disable the native resolver to free port 53:

```
mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nDNSStubListener=no" > /etc/systemd/resolved.conf.d/disable-stub.conf
systemctl restart systemd-resolved
rm /etc/resolv.conf && echo "nameserver 10.10.0.14" > /etc/resolv.conf
```

3. Change the `nginx.conf` file:

Open the `/etc/nginx/nginx.conf` file and add the line `include /etc/nginx/stream.conf.d/*.conf;` at the end of the file.

**Optional:** I like to make it clean. I clear the file with the command `echo > /etc/nginx/nginx.conf` and add only the line `include /etc/nginx/stream.conf.d/*.conf;`.

4. Create the Nginx L4 file (`/etc/nginx/stream.conf.d/dns.conf`):

```bash
# Uncomment this if you cleared the /etc/nginx/nginx.conf file
# user www-data;
# worker_processes 1;
# error_log /var/log/nginx/error.log warn;
# pid /var/run/nginx.pid;
# include /etc/nginx/modules-enabled/*.conf;

# events {
#    worker_connections 1024;
#}

# General settings
stream {
    upstream dns_servers {
        server 10.10.0.13:5353 max_fails=2 fail_timeout=5s;
        server 10.10.0.14:53 backup max_fails=2 fail_timeout=2s;
    }

    server {
        listen 53 udp reuseport;
        proxy_pass dns_servers;
        # proxy_responses 1;
        proxy_timeout 2s;
    }

    server {
        listen 53 so_keepalive=on;
        proxy_pass dns_servers;
        proxy_timeout 5s;
    }
}
```

5. Create the `/etc/keepalived/keepalived.conf` file:

```bash
global_defs {
    router_id NGINX_DNS_BACKUP
}

vrrp_script chk_nginx {
    script "killall -0 nginx"
    interval 2
    weight -20
    fall 2
    rise 2
}

vrrp_instance VI_DNS {
    state BACKUP              # Important: Passive Node
    interface eth0
    virtual_router_id 53
    priority 90               # Important: Lower priority than Master
    advert_int 1
    
    unicast_src_ip 10.10.0.12  # IP of this LXC
    unicast_peer {
        10.10.0.11              # IP of the Raspberry Pi (CasaOS)
    }

    authentication {
        auth_type PASS
        auth_pass HA_DNS_SECURE
    }

    virtual_ipaddress {
        10.10.0.10/24 dev eth0 label eth0:vip
    }

    track_script {
        chk_nginx
    }
}
```

6. Enable the services:

```bash
systemctl restart nginx keepalived
systemctl enable nginx keepalived
```

##

### 🧪 Validation and Production (Go-Live)

1. Test L4 and VIP: In the terminal of any PC on the network, check the dual resolution (IPv4/IPv6):

```bash
nslookup [www.google.com](https://www.google.com) 192.168.1.17
```

2. Failover Test (Chaos):

  2.1 - Leave a ping 192.168.1.17 -t running.

  2.2 - Stop the container on CasaOS. You will see that the ping drops only 1 packet maximum. Node 2 will take the traffic instantly.

  2.3 - Start the Master again and it will take back the VIP.

3. Go-Live Test:

Access your Wi-Fi router or network DHCP settings. Change the Primary DNS to 192.168.1.17. Leave the secondary empty or add a second DNS of your choice.


##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
