<h6 align="right">Leia essa página em <a href="./README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🖧 Routers & Switches (Network Infrastructure)

### 📝 Architecture Description

This folder keeps the documentation, standard settings (*golden configs*), physical topology, and lifecycle management for our routing and switching devices. These devices build our network access and edge layers.

The goal of this documentation is to keep the physical environment (Data Plane) and administrative access (Control Plane) standard. This folder is our Single Source of Truth. We use it for troubleshooting, firmware updates, and fast hardware replacement (RMA).

##

### 🏗️ Operational Alignment (FCAPS)

The network asset management follows standard operations practices:

* **F (Fault Management):** We monitor devices using *polling* (when supported by the hardware) or connectivity analysis. This helps us quickly find cable problems, port negotiation errors, or hardware failures. It reduces the MTTR (Mean Time To Repair).
* **C (Configuration Management):** We control approved *firmware* versions and save base configurations. For unmanaged devices (dumb Layer 2 switches), we document the physical topology to stop network loops or wrong connections.
* **P (Performance Management):** We control the network switching capacity. We guarantee that ports work in *Full-Duplex* with the correct speed (like Gigabit Ethernet). This stops dropped packets from full physical *buffers*.

##

### 🖧 Logical Topology (OSI Layer 1-3)

These devices work on the lower OSI layers. They give the physical and logical transport for the application layers:

| OSI Layer | Physical Component | Logical Function | Standards & Protocols |
| :--- | :--- | :--- | :--- |
| **Layer 3 (Network)** | Routers/Gateways | Routing, NAT, DHCP, Packet Forwarding | IPv4/IPv6, ICMP |
| **Layer 2 (Data Link)** | Switches | Frame switching, Physical Segmentation/VLANs | 802.3 (Ethernet), 802.1Q*, STP* |
| **Layer 1 (Physical)** | Ports/Cabling | Signal transmission, Auto-negotiation | 1000BASE-T, Auto-MDI/MDIX |

*(Note: Support for complex L2 protocols like 802.1Q and STP depends on if the switch is managed or unmanaged).*

##

### 🛡️ Security and Network Requirements (SecOps)

To protect the physical and logical infrastructure:

1.  **Management Plane Isolation (OAM):** For managed devices, administrative access (Web/CLI) must use dedicated IT operation networks or VLANs. We strictly block access from common users or *Guest* networks.
2.  **Physical Security (Layer 1):** We protect the physical environment. This stops people from changing cables, connecting unauthorized devices (like rogue DHCP servers), or creating physical *loops* (connecting two ports on the same switch).
3.  **Update Control:** We never install *firmware* updates without previous compatibility tests and configuration *backups*.

##

### 🛠️ Approved Hardware and Specific Documentation

For architecture details, specific configurations, hardware limits, and device topology, see the specific folders:

* 📁 **[`tp-link_ex521`](./tp-link_ex521/)**: Router/Gateway Documentation (Wi-Fi 6).
* 📁 **[`tp-link_ls1008g`](./tp-link_ls1008g/)**: Unmanaged Desktop Switch Documentation (Layer 2).

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
