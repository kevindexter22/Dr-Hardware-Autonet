<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🌐 Network Core and Services

### 📝 Domain Description

This section documents the logical and physical foundation of the lab network (OSI Model Layers 2 and 3). Here you can find the routing, switching, and essential services (Core Services). 

These are necessary for the infrastructure to connect to the internet and for internal nodes to find each other.

##

### 🗺️ Topology and IPAM (IP Address Management)

An overview of the logical segmentation and routing. The exact addresses are kept in the lab's offline vault for security reasons.

- **Main LAN Network:** <LAN_SUBNET_CIDR> (Gateway: <LAN_GATEWAY_IP>)
- **Internal DNS Service:** <INTERNAL_DNS_IP_1> / <INTERNAL_DNS_IP_2>
- **VPN Tunnel (Remote Access):** <VPN_SUBNET_CIDR> (L3 Routed Protocol)

> **Note:** For details about assignment policies, please see the official standards document at `05-docs/standards-policies.md`.

##

### ⚙️ Network Services and Assets

A list of the components that make the connectivity core:

- **Edge Routers:** Physical equipment responsible for NAT, L3 Firewall (ACLs), and connection to the ISP.
- **Name Resolution (DNS/DHCP):** Services to block telemetry at the network level (e.g., Pi-hole / Unbound) and to resolve      local TLD domains.
- **Secure Remote Access (VPN):** Encrypted tunnels to access the lab's Management Plane from external, untrusted networks.

##

### 📂 Directory Structure
```text
01-infrastructure/network-core/
├── 📄 README.md                 # Network Topology Overview (portuguese)
├── 📄 README.en.md              # Network Topology Overview (english)
├── 📂 routers-switches/         # Extracted and cleaned configurations from physical hardware
└── 📂 services/                 # Manual procedures (SOPs) for VPN, DNS setup, etc.
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - MIT License.
