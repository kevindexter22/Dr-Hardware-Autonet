<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-proxy/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Portuguese</a></h6>

# 👁️ Zabbix Proxy

### 📝 Architecture Description
This directory documents the architecture and installation of the **Zabbix Proxy**. It works as a distributed collection node (*Edge Computing*) on ARM64 hardware (Raspberry Pi). 

The proxy acts as a telemetry data mediator between the internal network (LAN) and the central node (Zabbix Server) in the cloud. This topology reduces WAN connection overload, optimizes local *polling*, and guarantees resilience in metric collection during internet link instability.

##

### 🏗️ Operational Alignment (FCAPS)

The introduction of this component in the infrastructure directly meets the Network Management pillars:

*   **F (Fault Management):** Implements the *Store-and-Forward* model. If the WAN or central server is offline, the local database (SQLite3) acts as a *buffer*. It saves metrics and critical events to sync later, reducing visibility loss and MTTR.
*   **C (Configuration Management):** Centralizes local agent pointing. LAN devices (routers, switches, servers) report to the Proxy's local IP, unifying the management surface.
*   **P (Performance Management):** Reduces collection latency (ICMP/SNMP/Traps) by doing local Layer 2/3 *polling*. It transfers only compressed and consolidated data to the cloud.

##

### 🖧 Logical Topology (OSI Layer 4-7)

| Component | Logical Function | Communication | Protocols |
| :--- | :--- | :--- | :--- |
| **Zabbix Proxy (ARM64)** | Mediation / Cache (SQLite3) | `Proxy -> Server` | TCP 10051 (Active Proxy Mode) |
| **Zabbix Proxy (Docker Container)** | Mediation / Cache (SQLite3) | `Proxy -> Server` | TCP `CUSTOM_PORT` (Active Proxy Mode) |
| **Zabbix Server (Cloud)** | Processing / Alerts | `Server <- Proxy` | TCP 10051 (Zabbix Trapper) |

##

### 🛡️ Security and Network Requirements (SecOps)

To ensure communication integrity and infrastructure isolation:

1.  **Edge Firewall:** Only outgoing traffic (Egress) on port `TCP 10051` or another chosen port is needed in *Active Proxy* mode. No *Inbound* rule (NAT/Port Forwarding) should be exposed on the WAN for this service.

##

### ⚖️ Scalability and Resilience (Proxy Groups)

The logical telemetry architecture supports horizontal scalability by adding multiple proxies. They operate under the **Proxy Groups** logic (native Zabbix 7.0+ feature). Adding a second Proxy in the same group guarantees:

* **High Availability (Fault Management - HA):** Removes the *single point of failure* in local collection. If there is OS *downtime* or *"crash"*, scheduled maintenance, or a network failure in one node, the *Zabbix Agent* (LAN) traffic and *polling* routines do an automatic *failover* to the surviving node. This ensures zero MTTR for metric reception.
* **Load Balancing (Performance Management):** The computational load of active checks, parallel ICMP tests, and previous *Trap* processing is dynamically distributed among the group nodes. This avoids CPU/IOPS bottlenecks in single devices, optimizing the data *throughput* to the cloud *Zabbix Server*.

##

### 🛠️ Operational Procedures (Runbooks)

For *Bare-Metal* provisioning or *Troubleshooting* of this infrastructure node, please check the Standard Operating Procedures (SOPs) below:

*   👉 **[SOP: Zabbix Proxy Installation and Configuration (Ubuntu/ARM64)](./zabbix_proxy_setup.en.md)**

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
