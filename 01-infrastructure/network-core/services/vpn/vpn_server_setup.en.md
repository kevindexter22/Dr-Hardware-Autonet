<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/vpn/vpn_server_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🎯 SOP: Installation and Configuration of strongSwan VPN Server (IKEv2 + MSCHAPv2 via ipsec.conf)

### 📝 Scope Description

This Standard Operating Procedure (SOP) shows how to install a strongSwan VPN server. We use the traditional ipsec.conf method.

The scope includes: creating an internal Public Key Infrastructure (PKI) for the server certificate, client authentication using IKEv2 with EAP-MSCHAPv2 (Username and Password), and virtual network setup (IP Pool) with Full Tunneling.

##

### 🗂️ Phase 1: Directory Structure and Public Key Infrastructure (PKI)

To secure the Control Plane (IKEv2), the server needs a digital certificate. This lets clients verify the server's identity. The users will only use a username and password, so they only need to trust the Root CA.

1. Open the terminal and create the temporary folders for the keys:

```bash
mkdir -p ~/pki/{cacerts,certs,private}
chmod 700 ~/pki
```

2. Generate the internal Root Certificate Authority (Root CA):

```bash
pki --gen --type ed25519 --outform pem > ~/pki/private/ca-key.pem
pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
    --type ed25519 --dn "C=BR, O=YourCompany, CN=YourCompany Root CA" \
    --outform pem > ~/pki/cacerts/ca-cert.pem
```

3. Generate the VPN Server Certificate (Change vpn.yourdomain.com.br to your FQDN or public IP):

```bash
pki --gen --type ed25519 --outform pem > ~/pki/private/server-key.pem
pki --issue --lifetime 1825 --cacert ~/pki/cacerts/ca-cert.pem \
    --cakey ~/pki/private/ca-key.pem --in ~/pki/private/server-key.pem \
    --type ed25519 --dn "C=BR, O=yourvpn, CN=vpn.yourdomain.com.br" \
    --san vpn.yourdomain.com.br --flag serverAuth --flag ikeIntermediate \
    --outform pem > ~/pki/certs/server-cert.pem
```

##

### 🐧 Phase 2: OS Preparation and Package Installation

Install strongSwan and the required packages for extauth/EAP authentication. After that, move the generated certificates to the official ipsec folders.

```bash
# 1. Update the system and install stable packages
apt update && apt upgrade -y
apt install -y strongswan strongswan-pki \
    libcharon-extra-plugins libcharon-extauth-plugins

# 2. Move the certificates to the production ipsec folders
cp ~/pki/cacerts/ca-cert.pem /etc/ipsec.d/cacerts/
cp ~/pki/certs/server-cert.pem /etc/ipsec.d/certs/
cp ~/pki/private/server-key.pem /etc/ipsec.d/private/
```

##

### ⚙️ Phase 3: strongSwan Configuration (ipsec.conf and ipsec.secrets)

Configure the encryption daemon, the connection rules, and the credentials.

1. Main Configuration File (`/etc/ipsec.conf`)

Backup the original file and create a new one:

```bash
mv /etc/ipsec.conf /etc/ipsec.conf.bkp
nano /etc/ipsec.conf
```

Insert these settings:

```bash
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=never

conn %default
    keyexchange=ikev2
    # Modern Ciphersuites
    ike=aes256gcm16-prfsha256-ecp256,aes256-sha256-modp2048!
    esp=aes256gcm16-ecp256,aes256-sha256!
    dpdaction=clear
    dpddelay=300s
    rekey=no
    
    # Server Side Settings (Left)
    left=%any
    leftid=@vpn.yourcompany.com.br
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0 # Full Tunnel
    
    # Client Side Settings (Right)
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=1.1.1.1,8.8.8.8
    rightsendcert=never
    eap_identity=%identity

conn ikev2-vpn
    auto=add
```

2. Credentials File (`/etc/ipsec.secrets`)

This file links the server private key and stores the MSCHAPv2 usernames and passwords.

```bash
# VPN server private key
: Ed25519 server-key.pem

# Road Warrior Users (EAP-MSCHAPv2)
joao.silva : EAP "StrongPasswordForJoao123!"
maria.souza : EAP "StrongPasswordForMaria456!"
```

##

### 🛡️ Phase 4: Permissions, Routing, and Firewall Rules

The operating system must forward packets from the VPN virtual subnet to the physical interface. It must also allow the IPsec negotiation ports.

```bash
# 1. Enable IPv4 Packet Forwarding (IP Forwarding)
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 2. Configure Masquerade (NAT) and allow ports (Assuming eth0 is WAN)
nano /etc/ufw/before.rules

# Insert the block below at the top of the file, right after the header comments, but before the *filter line:
# ==========================================
# NAT RULES - VPN ROUTING
# ==========================================
*nat
:POSTROUTING ACCEPT [0:0]
# Masquerade the VPN subnet going out through the WAN interface (eth0)
-A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
COMMIT

# Allow IKE (Internet Key Exchange)
ufw allow 500/udp

# Allow NAT-T (NAT Traversal)
ufw allow 4500/udp

# Allow encapsulated ESP traffic (IP Protocol 50)
ufw allow proto esp

# Disable and enable to correctly flush the underlying iptables
ufw disable
ufw enable

# Check the status to confirm
ufw status
```

This way, the configuration is permanent (it survives reboots). It is declarative and follows the configuration management framework of the basic OS using UFW.

##

### 🚀 Phase 5: Systemd Service and Connection Management

Because we use the classic structure, we manage the daemon directly with the ipsec command.

1. Restart the service to load certificates, secrets, and connections:

```bash
systemctl restart ipsec
systemctl enable ipsec
systemctl status ipsec
```

2. CLI Session Monitoring:

You can check active tunnels and connection logs directly from the server console:

```bash
# Show general VPN status and active sessions (SAs)
ipsec statusall

# Check for failures or IKE negotiation logs
tail -f /var/log/syslog | grep charon

# Monitor real-time IPsec traffic on the physical interface
tcpdump -lnni eth0 udp port 500 or udp port 4500 or esp
```

##

### 💡 Tips

  * **Reloading Credentials:** If you add new users to the `ipsec.secrets` file, you do not need to restart the whole VPN. Just run the command `ipsec rereadsecrets`.

  * **User Delivery:** Give only the `ca-cert.pem` file (from Phase 1) to the users. They must install it on their devices (Windows/iOS/Android) in the Trusted Root Certification Authorities store. Set the connection type to IKEv2 with Username/Password.

  * **Troubleshooting:** If Windows users have connection problems because of fragmentation, you might need to enable IKEv2 fragmentation. Add `fragmentation=yes` to the `ipsec.conf` file.

##

### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
