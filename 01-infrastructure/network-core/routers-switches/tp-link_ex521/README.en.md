<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/routers-switches/tp-link_ex521/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🖧 Edge Router: EX521 Router (Main Gateway)

### 📝 Asset Description

This equipment works as the lab's edge router (L3 Gateway). It is responsible for authenticating with the internet provider (ISP), managing NAT (Network Address Translation), and segmenting the first local network.

##

### 🛡️ Edge Protection and Active Firewall

The router acts as the first line of defense (Perimeter Security) against malicious traffic from the WAN.

* **DoS (Denial of Service) Prevention:** Active filters against Flood attacks (SYN/ICMP/UDP) and Port Scanning mitigation.
* **ACL (Access Control List) Policies:** Inbound traffic is blocked by default (Default Deny), except for strict ports in       Port Forwarding.

> **⚖️ Policy Compliance (SecOps):** The *Default Deny* setup and the strict UPnP limits shown below directly follow the guidelines of our **[L4-L7 Governance Document](#)**.

##

### 🔌 Physical Interface Mapping (LAN / WAN)

Documentation of the router's back panel (Port Allocation). It helps to track Layer 1 and 2 for physical maintenance and to prevent network loops.

#### 📍 Node 1: EX521 - Controller (Main Gateway)

| Interface (Port) | Physical Status | Speed (Link) | Destination (Connected to) | Note |
| :--- | :--- | :--- | :--- | :--- |
| **WAN** | `UP` | 1 Gbps | ISP Modem | Receives the external connection and authenticates using PPPoE. |
| **LAN 1** | `UP` | 1 Gbps | Switch TP-Link LS1008G | Main uplink to distribute network access. |
| **LAN 2** | `UP` | 1 Gbps | Router TP-Link WR850N | Dedicated router for cameras. |
| **LAN 3** | `UP` | 1 Gbps | Router EX521 Satellite | Mesh extension node. |

#### 📍 Node 2: EX521 - Satellite (Mesh Extension Node)

| Interface (Port) | Physical Status | Speed (Link) | Destination (Connected to) | Note |
| :--- | :--- | :--- | :--- | :--- |
| **WAN** | `UP` | 1 Gbps | Router EX521 Controller | Used for Ethernet Backhaul. |
| **LAN 1** | `UP` | 1 Gbps | Desktop 1 | Used to connect the computer to the internet. |
| **LAN 2** | `UP` | 1 Gbps | Desktop 3 | Used to connect the computer to the internet. |
| **LAN 3** | `UP` | 100 Mbps | Switch Overtek (Fast Eth) | Lab switch for Fast Ethernet devices. |

##

### 📡 Wireless Architecture (WLAN)

The wireless networks are logically segmented to isolate traffic from different devices. This reduces the lateral movement surface if the network is compromised.

| Purpose	| SSID (Hidden?) | Client Isolation (AP Isolation) |
| :--- | :--- | :--- |
| **Administration/Core** |	No | Active (Access to my internal network and internet, only for my personal devices) |
| **IoT (Smart Devices)** |	No | Active (No access to the admin network) |
| **Guest (Visitors)**	| No | Active (Internet access only) |

##

### 📡 Provider Management (TR-069 / TR-181)

ISPs use the CWMP protocol (TR-069/TR-181) for remote provisioning, firmware updates, and router telemetry collection. In our scenario, we will use it for specific automations.

* **Status:** DISABLED
* **SecOps Justification:** I keep/disable this protocol on the network because I will still implement my personal service to create automations for my network.

##

### 🔒 Access and Management Policy

* Admin access via web port (TCP/<CUSTOM_ADMIN_PORT>) is restricted to internal network IPs only.
* Access passwords and WPA2/WPA3 keys are kept offline in the lab's credential vault.

##

### 🎮 Gaming & NAT Policy (UPnP)

To guarantee the best online gaming experience, the system allows dynamic port negotiation (UPnP).

* **Status:** Active (Restricted).
* **Justification:** Necessary to get Open NAT on video game consoles, guaranteeing minimum latency and efficient matchmaking.
* **Isolation Policy:** Inbound traffic negotiated via UPnP is inspected by the Host Firewall (UFW) on each destination          server/device.
* **Risk Mitigation:**
  * UPnP does not have permission to negotiate server management ports (SSH, Web Admin, Database).
  * Monthly audit of port mapping via router logs.

##

### ⚙️ Mesh Management Considerations

Because the routers are in Mesh, the firewall and TR-069 configuration must be replicated or synchronized consistently between them:

* **State Consistency:** Firewall ACLs configured on the Controller are propagated to the Satellite to guarantee that the        security policy is uniform across the lab.
* **TR-069 Synchronization:** If the TR-069 protocol is active, both nodes will report telemetry to a server.

##

### 📂 About the Configuration Files (Mesh-Ready)

When documenting the configurations, note that the backup file must show the specific "node" configuration:
* **config-backup-controller-sanitized.txt:** Configuration containing the WAN/NAT rules.
* **config-backup-satellite-sanitized.txt:** Configuration focused on bridging and radio.

⚠️ ***Note:*** *For security reasons, these files are stored offline in a backup storage. This is because .bin files can contain encrypted passwords and other sensitive information.*

##

ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
