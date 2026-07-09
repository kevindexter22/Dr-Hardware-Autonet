# 🎯 SOP: IPsec VPN Tunnel (OCI ➔ CasaOS) for Grafana

### 📝 Scope Description

This Standard Operating Procedure (SOP) shows how to set up an IPsec VPN tunnel (IKEv2 with EAP-MSCHAPv2) using StrongSwan. The goal is to connect the cloud (OCI Instance, running Grafana) to the local network (CasaOS/Proxmox, running Loki). This allows Grafana to read internal databases safely, without opening ports to the public internet.

##

### 🛡️ Phase 1: VPN Server Setup (CasaOS / Local Network)

The server needs to be ready to authenticate the client using a certificate (for the server) and username/password (EAP) for the client.

1. Edit the StrongSwan secrets file on CasaOS:

```bash
sudo nano /etc/ipsec.secrets
```

2. To avoid the *EAP_MSCHAPv2 method failed error* and make sure the server validates the client correctly, use the `%any` format for the EAP connection:

```bash
# Private key of the server certificate
: RSA "server-key.pem"

# EAP credentials for the client (OCI)
%any : EAP "your_secure_password"
```

3. Restart the IPsec service on CasaOS to apply the rules:

```bash
sudo ipsec restart
```

##

### ☁️ Phase 2: VPN Client Installation and Setup (Oracle Cloud / Grafana)

The OCI instance will act as a client, connecting to your home network to access Loki's internal IP.

1. StrongSwan Installation on OCI:

Before starting the setup, we need to install the IPsec service and the authentication plugins (necessary to support EAP-MSCHAPv2). In the OCI terminal (Ubuntu/Debian), run:

```bash
sudo apt update
sudo apt install strongswan libcharon-extra-plugins -y
```

2. IPsec Setup (`ipsec.conf`):

Edit the main configuration file on the client (OCI):

```bash
sudo nano /etc/ipsec.conf
```

Make sure the connection has the exact EAP identity (`eap_identity`) that matches the user configured on the server:

```bash
conn vpn-lab
    # ... [Your IP and certificate settings here] ...
    
    # Server authentication (remote)
    rightauth=pubkey
    
    # Client authentication (local - OCI)
    leftauth=eap-mschapv2
    eap_identity="your_new_user"
    
    # Requests a virtual IP from the CasaOS network
    leftsourceip=%config
    auto=add
```

3. Authentication (`ipsec.secrets`):

Edit the secrets file on OCI to insert the tunnel password:

```bash
sudo nano /etc/ipsec.secrets
```

Add the authentication credential:

```bash
your_new_user : EAP "your_secure_password"
```

Start the VPN Connection:

4. Stop stuck connections and start the new tunnel:

```bash
sudo ipsec stop
sudo ipsec start
sudo ipsec up vpn-lab
```

*If the connection is successful, the terminal will return the message connection 'vpn-lab' established successfully.*

##

### 📊 Phase 3: Grafana Data Source Connection

With the tunnel established (`ESTABLISHED`), OCI now has a direct route to your lab's internal network.

1. Go to the Grafana web panel (hosted on OCI).

2. Navigate to `Connections ➔ Data sources ➔ Add data source`.

3. Select the Loki integration.

4. In the URL field, insert the local network IP address where Loki is running in LXC, followed by port 3100:

   * http://<LOKI_INTERNAL_IP>:3100 (Ex: http://10.10.0.50:3100)

5. Scroll down to the end and click `Save & Test`.

6. If the VPN is routing traffic correctly, Grafana will return a green alert showing *"Data source successfully connected"*.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
