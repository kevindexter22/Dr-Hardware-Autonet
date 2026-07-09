# 🎯 SOP: DNS Logs Collection (go-dnscollector + Loki) in LXC

### 📝 Scope Description

This Standard Operating Procedure (SOP) shows the complete process (end-to-end) to collect and organize DNS query logs on the network.

The process includes creating the LXC container in Proxmox, installing go-dnscollector as a service, and configuring the JSON export to Loki.

This is a very important part for network observability. It helps to check requests, find blocked domains correctly, and see the real server answers. It separates them from normal traffic.

##

### 📦 Phase 1: Environment Preparation (Proxmox LXC)

We recommend using a light LXC container (Debian or Ubuntu) for the collector. This avoids using too many resources like a full VM.

1. In Proxmox, create a new LXC container (example: CT ID 200, Hostname dns-collector, Template debian-12 or ubuntu-24.04).

```bash
pct create 200 /var/lib/vz/template/cache/ubuntu-24.04-standard_24.04-1_amd64.tar.zst \
-cores 1 \
-memory 512 \
-swap 256 \
-hostname <YOUR_HOSTNAME.YOUR_DOMAIN.LOCAL> \
-ostype ubuntu \
-storage local-lvm \
-rootfs local-lvm:8 \
-net0 name=eth0,bridge=vmbr0,ip=<SERVER_IP/CIDR>,gw=<GATEWAY_IP> \
-unprivileged 0 \
-features nesting=1
```

2. Access the LXC console and update the system packages:

```bash
apt update; apt upgrade -y
```

3. Install basic dependencies:

```bash
apt install wget curl nano tar -y
```

##

### ⚙️ Installing and Configuring Loki

Access the terminal of your new LXC. The easiest way to run Loki (without docker) is to download the binary directly.

1. Download Loki:

```bash
apt update; apt install unzip wget -y
wget [https://github.com/grafana/loki/releases/download/v3.0.0/loki-linux-amd64.zip](https://github.com/grafana/loki/releases/download/v3.0.0/loki-linux-amd64.zip)
unzip loki-linux-amd64.zip
chmod +x loki-linux-amd64
mv loki-linux-amd64 /usr/local/bin/loki
```

2. Create the configuration (`/etc/loki-config.yaml`):

Create a basic file just to receive logs locally and without complex authentication (because it will be on the internal network).

```bash
# Paste the configurations below:
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /opt/loki
  storage:
    filesystem:
      chunks_directory: /opt/loki/chunks
      rules_directory: /opt/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h
```

3. Start the service:

You can create a systemd service for Loki to run in the background pointing to this configuration (`loki -config.file=/etc/loki-config.yaml`).

```bash
# Create the configuration file:
nano /etc/systemd/system/loki.service

# Paste the configurations below:
[Unit]
Description=Loki Log Aggregation System
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/loki -config.file=/etc/loki-config.yaml
Restart=always
RestartSec=5

# Optional: If you want to limit system usage, uncomment the lines below
# LimitNOFILE=65536
# LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```

4. Enable the service:

```bash
# Reload the systemd service list
systemctl daemon-reload

# Make Loki start automatically on LXC boot
systemctl enable loki

# Start Loki now
systemctl start loki
```

##

### ⚙️ Phase 3: go-dnscollector Installation

1. Let's download the official go-dnscollector binary and configure it as a system service to run in the background.

Download the latest binary version (check the official Github repository for newer versions, if necessary):

```bash
wget [https://github.com/dmachard/go-dnscollector/releases/latest/download/go-dnscollector_linux_amd64.tar.gz](https://github.com/dmachard/go-dnscollector/releases/latest/download/go-dnscollector_linux_amd64.tar.gz)
```

2. Extract and move the binary to the system executables folder:

```bash
tar -zxvf go-dnscollector_linux_amd64.tar.gz
mv go-dnscollector /usr/local/bin/
chmod +x /usr/local/bin/go-dnscollector
```

3. Create the Systemd service file (`/etc/systemd/system/go-dnscollector.service`):

```bash
[Unit]
Description=DNS-collector (Log Shipper for Loki)
# Configured to start only after the network and Loki are up
After=network.target loki.service

[Service]
Type=simple
ExecStart=/usr/local/bin/go-dnscollector -config /etc/dnscollector.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

4. Reload the system daemons to recognize the new service:

```bash
systemctl daemon-reload
```

##

### 🛠️ Phase 4: Pipeline Configuration (JSON Format)

For Grafana to read the fields natively (like source IP, domain, and status), we need to force the collector to send the data in flat-json to Loki.

1. Create the configuration file:

```bash
nano /etc/dnscollector.yml
```

Add the pipeline configuration. In this example, the collector listens to DNS logs on port 5000 (adapt the input to your Pi-hole/Adguard export) and sends them to Loki:

```bash
global:
  trace:
    verbose: true

pipelines:
  # Receives Docker logs via TCP (using the dnstap protocol)
  - name: dns_input
    dnstap:
      listen-ip: 0.0.0.0
      listen-port: 6000
    routing-policy:
      forward: [ loki_output ]

  # Sends structured data to local Loki
  - name: loki_output
    lokiclient:
      server-url: "[http://127.0.0.1:3100/loki/api/v1/push](http://127.0.0.1:3100/loki/api/v1/push)"
      job-name: "dns-logs"
      mode: flat-json
```

2. Start and enable the service to start with the LXC boot:

```bash
systemctl enable --now go-dnscollector
systemctl status go-dnscollector
```

##

### 🧩 Integration:

Now we can integrate Loki with Grafana and create a dashboard to view the requests.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
