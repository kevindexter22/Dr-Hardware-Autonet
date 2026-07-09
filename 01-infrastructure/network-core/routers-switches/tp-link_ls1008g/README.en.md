<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/routers-switches/tp-link_ls1008g/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🖧 Access Switch: TP-Link LS1008G (Unmanaged)

### 📝 Asset Description

The TP-Link LS1008G is an 8-port unmanaged L2 access switch. In my network architecture, it works just to add more physical ports (OSI Layer 1 and 2). It connects end nodes (Hosts/Raspberry Pis/PCs) to the core network.

##

### 🗺️ Role in Physical Topology

* **Physical Location:** `Living Room`
* **Uplink (Source Connection):** Connected to port `LAN_1` of the `EX521_Controller` device using a Cat6A cable.
* **Connected Devices (Downlinks):**

| Interface (Port) | Physical Status | Speed (Link) | Destination (Connected to) | Note |
| :--- | :--- | :--- | :--- | :--- |
| **Port 1** | `UP` | 1 Gbps | Router EX521 Satellite | Used for uplink and internet communication |
| **Port 2** | `UP` | 1 Gbps | PlayStation 4 | Used for internet connection |
| **Port 3** | `UP` | 100 Mbps | Raspberry Pi 3B (ZBX_Proxy/ZBX_Agent) | Used to send metrics to the Zabbix server |
| **Port 4** | `UP` | 1 Gbps | Raspberry Pi 4B (CasaOS Server) | Used for service communication with the internet |
| **Port 5** | `UP` | 100 Mbps | Raspberry Pi 3B (OPL_Samba_Server) | Used to load games over the network |
| **Port 6** | `UP` | 100 Mbps | PlayStation_2_OPL | Used to communicate with the OPL_Samba server |
| **Port 7** | `UP` | 1 Gbps | PlayStation_4 | Used for console internet connection |
| **Port 8** | `UP` | 1 Gbps | Empty | Empty |

##

### ⚠️ Architecture and SecOps Limitations

Because it is a Plug-and-Play device with no control plane, it has these limits:

* **Single Broadcast Domain (Flat Network):** The switch does not support VLANs (IEEE 802.1Q). All connected devices are in the same broadcast domain created by the main router/gateway.
* **No Spanning Tree (STP):** There is no protection against Layer 2 Loops. If you accidentally connect a cable between two ports on this switch, it will cause a Broadcast Storm and break the network.
* **Observability Blind Spot:** It does not support SNMP, Syslog, or Port Mirroring (SPAN). Zabbix cannot monitor the L2 traffic inside the switch. Telemetry only comes from the agents installed on the end hosts (OS).

##

### 🛡️ Risk Mitigation

To fix the lack of management and keep the lab safe:

* Security isolation (*Firewall/ACL*) for all nodes on this switch is done **only by the host firewalls (UFW)** or by the main gateway (Edge Router) before the traffic goes down to the switch.
* Cables and ports must be physically organized and labeled. This prevents accidental loops caused by human error during maintenance.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
