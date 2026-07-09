<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/unbound_dns_lxc_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🎯 SOP: Compile and Install Unbound DNS + DNSTAP (LXC)

### 📝 Scope Description

This Standard Operating Procedure (SOP) shows how to compile and install a container Unbound DNS server. It runs natively on Proxmox.

The scope includes compiling the dnstap module to export DNS logs via TCP. It also includes URL blocking (Adblock/Malware), local host resolution, and smart forwarding of specific Streaming CDNs to the internet provider's servers. This makes the route faster.

##

### 🗂️ Phase 1: Directory Structure and Root Hints

Unbound needs the official internet root servers list to resolve names alone.

1. Access the container terminal and create the folders:

```bash
# Create inventory structure
mkdir -p /etc/unbound/unbound.conf.d
```

2. Download the official IANA root.hints file:

```bash
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.root
```

##

### 🐧 Phase 2: OS Prep and Compile (In Container)

Inside the LXC (Ubuntu 22.04), install the build tools and Protobuf. Then, compile Unbound from the official NLnet Labs repository.

```bash
# 1. Update system and install required tools
apt update && apt upgrade -y
apt install -y build-essential libssl-dev libexpat1-dev \
    libsystemd-dev libevent-dev libprotobuf-c-dev protobuf-c-compiler \
    libfstrm-dev wget ca-certificates

# 2. Download the requested release (1.20.0)
wget https://nlnetlabs.nl/downloads/unbound/unbound-1.20.0.tar.gz
tar xzf unbound-1.20.0.tar.gz
cd unbound-1.20.0

# 3. Build config with OSS telemetry
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --disable-shared \
    --enable-pie \
    --enable-relro-now \
    --enable-dnstap \
    --with-libevent \
    --with-conf-file=/etc/unbound/unbound.conf

# 4. Compile and Install (Use -j1 for 1 vCPU limit)
make -j1
make install
```

##

### ⚙️ Phase 3: Unbound Configuration

Create the config files in the correct folder.

1. Main File (`/etc/unbound/unbound.conf`)

```bash
server:
    directory: "/etc/unbound"
    chroot: ""
    username: "unbound"
    root-hints: "/etc/unbound/root.hints"
    
    # Import all configs from .d folder
    include: "/etc/unbound/unbound.conf.d/*.conf"
```

2. Base Config and Optimization (`/etc/unbound/unbound.conf.d/main.conf`)

**Note:** You can turn off DNSSEC validation (`module-config: "iterator"`) to stop fake SERVFAIL errors with CDNs and local providers if you have problems.

```bash
server:
    verbosity: 1
    interface: 0.0.0.0
    port: 53
    
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: yes # Change to yes if you use IPv6 on your network
    
    # Performance and security optimizations
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 1
    
    # Cache size (adjusted for lxc)
    msg-cache-size: 50m
    rrset-cache-size: 100m

    # Turn off DNSSEC validation (uses simple iterator only)
    # module-config: "iterator"
    # harden-dnssec-stripped: no
```

3. Access Control (`/etc/unbound/unbound.conf.d/acl.conf`)

```bash
server:
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/8 allow
    access-control: 172.16.0.0/12 allow
    access-control: 192.168.0.0/16 allow
```

4. Local Host Resolution (`/etc/unbound/unbound.conf.d/local-records.conf`)

```bash
server:
    # --- Direct Records (A Records) ---
    local-data: "proxmox1.local. IN A <Device_IP>"
    local-data: "ipa.local. IN A <Device_IP>"
    local-data: "dnslog.local. IN A <Device_IP>"
    
    # --- Reverse Records (PTR Records) ---
    # Set the reverse zone for your subnet (Read backwards)
    # If your network is 192.168.0.x, the zone is 0.168.192.in-addr.arpa.
    local-zone: "0.168.192.in-addr.arpa." static
```

5. DNSTAP Integration (`/etc/unbound/unbound.conf.d/dnstap.conf`)

```bash
server:
    identity: "dns2"

dnstap:
    dnstap-enable: yes
    # Remote collector TCP address (e.g., Vector, Fluentd, or other listener)
    dnstap-ip: "<SERVER_IP>@6000"
    dnstap-tls: no
    # What to log:
    dnstap-send-identity: yes
    dnstap-send-version: yes
    dnstap-log-client-query-messages: yes
    dnstap-log-client-response-messages: yes
```

6. URL Blocking (`/etc/unbound/unbound.conf.d/blocklist.conf`)

```bash
server:
    # local-zone: "ads.example.com" always_nxdomain
```

7. CDN Static Routes - Forwarding (`/etc/unbound/unbound.conf.d/forward.conf`)

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

### 🛡️ Phase 4: Permissions and Local Resolution

Unbound on Ubuntu LXC has a conflict on port 53 with systemd-resolved. Also, we need to create an unprivileged service user.

```bash
# 1. Create system user without login
useradd -r -s /bin/false unbound

# 2. Apply strict permissions to the config folder
chown -R unbound:unbound /etc/unbound
chmod -R 750 /etc/unbound

# 3. Free port 53 socket by disabling Ubuntu's native resolver
systemctl disable --now systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

##

### 🚀 Phase 5: Systemd Service and Startup

To let Proxmox (via LXC) manage the daemon lifecycle, we must create the Systemd service. It will start as `root` (to get the protected port 53) and then drop privileges to the unbound user.

Create the file `/etc/systemd/system/unbound.service`:

```bash
[Unit]
Description=Unbound DNS Resolver (with DNSTAP Support)
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/sbin/unbound -d -c /etc/unbound/unbound.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Reload the daemons and start the service:

```bash
systemctl daemon-reload
systemctl enable --now unbound
systemctl status unbound
```

##

### 🧩 Optional Tweak:

You can access the container terminal at any time. Use the installed network tools to monitor the DNS traffic:

```bash
# Internal use examples:
# dnstop -l 3 eth0
# tcpdump -i eth0 port 53
# nload
```

##

### 💡 Tips

  * Always run the native validator before restarting the service after you change the .conf:

```bash
    /usr/sbin/unbound-checkconf /etc/unbound/unbound.conf
```

  * To confirm the compile linked the correct telemetry library, run unbound -V. The output must show: Linked libs: libevent [...] dnstap.

  * If the container does not make the TCP bind with the collector, check the stream drops directly in the central log using journalctl -eu unbound.service.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
