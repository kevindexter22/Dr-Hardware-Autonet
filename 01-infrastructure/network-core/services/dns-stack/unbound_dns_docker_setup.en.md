<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/unbound_dns_docker_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🎯 SOP: Build and Install Unbound DNS + DNSTAP (Docker)

### 📝 Scope Description

This Standard Operating Procedure (SOP) shows how to build and install an Unbound DNS server in a container. It runs natively on CasaOS on a Raspberry Pi 4B (ARM Architecture).

The scope includes building the dnstap module to send DNS logs via TCP. It also includes URL blocking (Adblock/Malware), local host names, and smart forwarding of streaming CDNs to your internet provider's servers. This makes the route better. Network tools (tcpdump, nload, dnstop, dig) are included inside the image.

##

### 🗂️ Phase 1: Folder Structure and Root Hints

Unbound needs the official internet root servers list to work alone.

1. Open the Raspberry Pi terminal (via SSH) and create the folders:

```bash
mkdir -p /DATA/AppData/unbound/unbound.conf.d
mkdir -p /DATA/AppData/unbound/build
```

2. Download the official root.hints file from IANA:

```bash
curl -o /DATA/AppData/unbound/root.hints https://www.internic.net/domain/named.root
```

##

### 🐳 Phase 2: Build Docker Image (ARM)

To use dnstap and add network tools, we will build Unbound from the source code in an Alpine Linux container.

1. Create the file `/DATA/AppData/unbound/build/Dockerfile`:

```bash
# Build Stage
FROM alpine:latest AS builder

RUN apk add --no-cache build-base wget openssl-dev libevent-dev expat-dev fstrm-dev protobuf-c-dev ca-certificates

ARG UNBOUND_VERSION=1.20.0

RUN wget https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz && \
    tar -xzf unbound-${UNBOUND_VERSION}.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure \
      --prefix=/opt/unbound \
      --with-pthreads \
      --with-username=unbound \
      --with-libevent \
      --enable-dnstap \
      --with-conf-file=/opt/unbound/etc/unbound/unbound.conf && \
    make -j$(nproc) && \
    make install

# Final Stage (Light and Working Image)
FROM alpine:latest

# Install running files and network tools
RUN apk add --no-cache openssl libevent expat fstrm protobuf-c ca-certificates shadow tzdata nload dnstop bind-tools tcpdump

# Create unbound user
RUN groupadd -g 1000 unbound && useradd -u 1000 -g 1000 -s /sbin/nologin unbound

# Bring built files from the last stage
COPY --from=builder /opt/unbound /opt/unbound

EXPOSE 53/tcp 53/udp

# Run Unbound in the foreground with mapped config
CMD ["/opt/unbound/sbin/unbound", "-d", "-c", "/opt/unbound/etc/unbound/unbound.conf"]
```

##

### ⚙️ Phase 3: Unbound Configuration

Create the config files in the correct folder.

1. Main File (`/DATA/AppData/unbound/unbound.conf`)

```bash
server:
    directory: "/opt/unbound/etc/unbound"
    chroot: ""
    username: "unbound"
    root-hints: "/opt/unbound/etc/unbound/root.hints"
    
    # Import all configs from the .d folder
    include: "/opt/unbound/etc/unbound/unbound.conf.d/*.conf"
```

2. Base Config and Optimization (`/DATA/AppData/unbound/unbound.conf.d/main.conf`)

***Note:*** *You can turn off DNSSEC validation (`module-config: "iterator"`) to stop false SERVFAIL errors with CDNs and local providers if you have problems.*

```bash
server:
    verbosity: 1
    interface: 0.0.0.0
    port: 53
    
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: yes # Change to yes if you use IPv6 on your network
    
    # Performance and security tweaks
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 2
    
    # Cache size (adjusted for Pi 4)
    msg-cache-size: 32m
    rrset-cache-size: 64m

    # Turn off DNSSEC validation (use only simple iterator)
    # module-config: "iterator"
    # harden-dnssec-stripped: no
``` 
3. Access Control (`/DATA/AppData/unbound/unbound.conf.d/acl.conf`)

```bash
server:
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/8 allow
    access-control: 172.16.0.0/12 allow
    access-control: 192.168.0.0/16 allow
```

4. Local Hosts (`/DATA/AppData/unbound/unbound.conf.d/local-records.conf`)

```bash
server:
    # AUTHORITATIVE ZONE DEFINITION (Mandatory)
    # This tells Unbound: "I own this domain; do not look it up on the Internet"
    local-zone: ".local." static

    # --- Direct Records (A Records) ---
    local-data: "proxmox1.local. IN A <Device_IP>"
    local-data: "ipa.local. IN A <Device_IP>"
    local-data: "dnslog.local. IN A <Device_IP>"
    
    # --- Reverse Records (PTR Records) ---
    # Set the reverse zone for your sub-network (Read backwards)
    # If your network is 192.168.0.x, the zone is 0.168.192.in-addr.arpa.
    local-zone: "0.168.192.in-addr.arpa." static
```

5. DNSTAP Integration (`/DATA/AppData/unbound/unbound.conf.d/dnstap.conf`)

```bash
server:
    identity: "dns1"

dnstap:
    dnstap-enable: yes
    # TCP address of the remote receiver (ex: Vector, Fluentd, etc)
    dnstap-ip: "<SERVER_IP>@6000"
    dnstap-tls: no
    # What to log:
    dnstap-send-identity: yes
    dnstap-send-version: yes
    dnstap-log-client-query-messages: yes
    dnstap-log-client-response-messages: yes
```

6. URL Blocking (`/DATA/AppData/unbound/unbound.conf.d/blocklist.conf`)

```bash
server:
    # local-zone: "ads.example.com" always_nxdomain
```

7. CDN Static Routes - Forwarding (`/DATA/AppData/unbound/unbound.conf.d/forward.conf`)

```bash
# ==========================================
# FORWARD FOR VIDEO AND STREAMING CDNS
# ==========================================

# Netflix
forward-zone:
    name: "netflix.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "nflxvideo.net"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "nflxext.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# YouTube and Google Video Ecosystem
forward-zone:
    name: "youtube.com"
   forward-addr: <PRIMARY_DNS_IP>
   forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "googlevideo.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "ytimg.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# Amazon Prime Video
forward-zone:
    name: "primevideo.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "aiv-cdn.net"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# Twitch TV
forward-zone:
    name: "twitch.tv"
   forward-addr: <PRIMARY_DNS_IP>
   forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "ttvnw.net"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# Disney+ and Star+
forward-zone:
    name: "disneyplus.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "bamgrid.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# ==========================================
# FORWARD FOR SOCIAL MEDIA CDNS
# ==========================================

# Meta (Facebook, Instagram, WhatsApp)
forward-zone:
    name: "facebook.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "fbcdn.net"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "instagram.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "cdninstagram.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "whatsapp.net"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# TikTok
forward-zone:
    name: "tiktok.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "tiktokcdn.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "byteoversea.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>

# X (Old Twitter)
forward-zone:
    name: "x.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "twitter.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
forward-zone:
    name: "twimg.com"
    forward-addr: <PRIMARY_DNS_IP>
    forward-addr: <SECONDARY_DNS_IP>
```

##

### 🛡️ Phase 4: Security Permissions

Unbound runs as UID 1000 for security reasons. Change the permissions on the host folder so the container can read the files:

```bash
sudo chown -R 1000:1000 /DATA/AppData/unbound
sudo chmod -R 755 /DATA/AppData/unbound
```

##

### 🚀 Phase 5: Start the Container

1. Create the Docker Compose file (/DATA/AppData/unbound/docker-compose.yml).

You must add network capabilities. This makes Unbound and the capture tools (tcpdump/dnstop) work well.

```bash
version: '3.8'

services:
  unbound:
    build:
      context: /DATA/AppData/unbound/build
      dockerfile: Dockerfile
    container_name: unbound-dns
    hostname: dns1.your_domain.com
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "dig +short @127.0.0.1 localhost || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    ports:
      - "5353:53/udp"
      - "5353:53/tcp"
    volumes:
      - /DATA/AppData/unbound:/opt/unbound/etc/unbound
    environment:
      - TZ=America/Sao_Paulo
    cap_add:
      - NET_ADMIN
      - NET_RAW
# If you use casaos
x-casaos:
  architectures:
    - amd64
    - arm64
  main: unbound
  title:
    en_US: Unbound DNS
  icon: https://www.netdata.cloud/img/unbound.png
```

2. To build the image and start the service in CasaOS Docker V2, run:

```bash
cd /DATA/AppData/unbound
docker compose up -d --build
```

##

### 🧩 Optional:

You can enter the container terminal at any time. You can use the network tools to watch the DNS traffic:

```bash
docker exec -it unbound-dns sh
# Examples of internal use:
# dnstop -l 3 eth0
# tcpdump -i eth0 port 53
# nload
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - MIT License.
