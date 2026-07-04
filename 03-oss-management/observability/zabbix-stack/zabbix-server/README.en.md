<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-server/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🧠 Zabbix Server

### 📝 Architecture Description
This directory documents the architecture, installation, and the main role of the **Zabbix Server** in the cloud (ARM64 instance). It works as the brain and data center for all our telemetry infrastructure.

The Proxies work on the edges and collect raw data. The Server is the engine. It checks the metrics against the *triggers* (business rules), saves the history in the relational database (MySQL/MariaDB), and sends incident alerts. This central system is very important to guarantee IT control and to reduce the Mean Time to Recovery (MTTR) in our hybrid infrastructure.

##

### 🏗️ Operational Alignment (FCAPS)

The central server operation helps our corporate network management strategies:

* **F (Fault Management) & MTTR Reduction:** It changes data into actions. When it receives data from the Proxies, the Server finds problems in real time and sends clear alerts. This stops blind guessing (*troubleshooting*). It shows the team the exact problem and makes the incident time (MTTR) much shorter.
* **C (Configuration Management):** It works as the *Single Source of Truth*. We configure all *templates*, *Discovery* rules (LLD), and monitoring profiles here. Then, it sends them to the edge nodes.
* **P (Performance Management):** It keeps the long-term history. This helps us see normal network behavior (*baselines*) and plan for the future (*Capacity Planning*). This stops system limits from becoming active problems.

##

### 🖧 Logical Topology (OSI Layer 4-7)

| Component | Logical Function | Communication | Protocols |
| :--- | :--- | :--- | :--- |
| **Zabbix Server (Core Process)** | Processing / Alerts | `Server <- Proxy` | TCP 10051 (Zabbix Trapper) |
| **Database (MySQL/MariaDB)** | Storage / Retention | `Server <-> DB` | TCP 3306 (Local Socket/TCP) |
| **Zabbix Web (Apache + SSL)** | Management / View | `Admin -> Web` | TCP 443 (HTTPS) |

##

### 🛡️ Security and Network Requirements (SecOps)

To protect the core of the cloud infrastructure:

1.  **Incoming Firewall (Ingress):** Access to port `TCP 10051` must be restricted (using cloud *Security Lists* or UFW). It should only allow known public IPs from the Zabbix Proxies.
2.  **Admin Access:** The web interface must use SSL/TLS encryption (`TCP 443`). The *Reverse Proxy* (Apache) manages this.
3.  **Data Isolation:** Communication with the database happens only in the local environment. We do not open ports to the WAN.

##

### ⚖️ Scalability and Resilience (High Availability)

The Zabbix Server is designed to support infrastructure growth. It makes sure monitoring does not become a bottleneck:

* **Native Clustering (Zabbix HA):** We can configure multiple Zabbix Server nodes in *Active-Standby* mode. If the main process fails during a kernel update or restart, the second node takes over immediately. This keeps the *trigger* calculation working.
* **Service Separation:** The architecture allows us to separate the Database, the Web Server, and the Core Process into different instances in the future. This distributes the CPU and I/O load if we need more *throughput*.

##

### 🛠️ Operational Procedures (Runbooks)

For maintenance, package updates, or *troubleshooting* the Zabbix core, please read the procedures below:

* 👉 **[SOP: Zabbix Server and Apache Installation and Configuration (Ubuntu/ARM64)](./zabbix_server_setup.en.md)**
  
##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
