# 🌐 DNS Stack (Unbound, HA & Telemetry)

### 📝 Architecture Description

This folder documents the architecture, setup, and operation of the Internal Recursive DNS Stack. We designed this environment to be the main corporate name resolution infrastructure. It guarantees fast responses (low latency), protection against failures, and deep traffic visibility.

The core resolution uses Unbound (supporting deployments via Docker or LXC). It works as a caching resolver with DNSSEC validation. 

To keep the service running, we built a High Availability (HA) layer. We use Keepalived to manage the Virtual IP (VIP - VRRP protocol). We also use Nginx as a Stream Proxy (Layer 4) between the Unbound instances. 

The system also has strong telemetry using DNS Collector and Loki. This allows us to keep structured logs and analyze traffic for security and advanced troubleshooting.

##

### 🏗️ Operational Alignment (FCAPS)

The operation of this stack follows corporate Network Management strategies and OSS frameworks:

   * **F (Fault Management) & MTTR Reduction:** Keepalived (VRRP) hides hardware or OS failures from the user. It moves the VIP instantly if a system goes down. Sending structured logs to Loki stops decentralized troubleshooting. Operations teams can quickly find error codes (like `SERVFAIL` or `NXDOMAIN`) using central dashboards.

   * **C (Configuration Management):** Native support for immutable infrastructure and standard setup. It gives flexibility to run Unbound in application isolation (Docker) or system isolation (LXC).

   * **P (Performance Management):** Unbound's strong cache improves the speed of local queries. It reduces the load on public upstream resolvers. We improved the traffic architecture in lab tests to get the fastest response time possible.

   * **S (Security Management):** The architecture makes operational security (SecOps) stronger in two ways. First, it checks zone integrity with DNSSEC. Second, it keeps logs (via DNS-Collector) for security audits. This helps find problems, botnet traffic, or data leaks early.

##

### 🖧 Logical Topology (OSI Layer 3-7)

| Component | Logical Function | Communication | Protocols / OSI Layer |
| :--- | :--- | :--- | :--- |
| **Keepalived (VIP)** | Gateway Redundancy | `Client -> VIP` | VRRP (IP/Layer 3) |
| **Nginx (Stream Proxy)** | Proxy / Direct Failover | `VIP -> Nginx -> Unbound` | UDP/TCP 53 (Layer 4) |
| **Unbound (Resolver)** | Resolution and Cache | `Nginx <- Unbound -> Upstream` | DNS (Layer 7) / UDP 53 |
| **DNS-Collector** | Capture and Parsing | `Unbound -> Collector` | PCAP / DNSTap (Layer 7) |
| **Loki** | Retention (Observability) | `Collector -> Loki` | HTTP/REST TCP 3100 (Layer 7) |

##

### 🛡️ Security and Network Requirements (SecOps)

To protect the resolution and telemetry infrastructure:

  1. **Ingress Rules (Firewall):** The nodes with VIP/Nginx must allow free traffic from corporate clients only on ports `UDP 53` and `TCP 53`. We must block external queries (from WAN) to stop DNS amplification/reflection attacks.

  2. **Inter-node Security:** The VRRP traffic (Multicast `224.0.0.18` or Unicast) from Keepalived must be allowed only between the nodes in the HA cluster.

##

### ⚖️ Scalability and Resilience (High Availability)

We improved the topology using real performance metrics and end-to-end resilience:

  * **Proxy Design Evolution (Lessons Learned):** The first architecture used Nginx for active load balancing (*Round Robin*) between many Unbound backends. However, lab stress tests showed a problem. The routing and multipath inspection at the transport layer (Layer 4) added too much delay (latency) to UDP requests. To fix this, we changed the routing to a *Direct Failover* model (strict Active-Standby). The traffic now flows without splitting packets. This gives the fastest possible response speed.

  * **Resilient Frontend (VRRP):** Keepalived guarantees business continuity at Layer 3. If the primary node stops, the secondary node takes the VIP in milliseconds. Client applications do not see the failure.

  * **Compute Decoupling:** Using containers as a standard guarantees easy changes. If we need to move physical hosts or do Disaster Recovery (DR), the operation is simple and fast.

##

### 🛠️ Operational Procedures

To deploy the environment, manage failures, and do maintenance, see the documents for each module:

   * 👉 [SOP: High Availability Configuration (Nginx Proxy + Keepalived)](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/HA_nginx_proxy_keepalived_setup.en.md)

   * 👉 [SOP: Unbound Installation and Configuration via Docker](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/unbound_dns_docker_setup.en.md)

   * 👉 [SOP: Unbound Installation and Configuration via LXC](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/unbound_dns_lxc_setup.en.md)

   * 👉 [SOP: DNS Telemetry Collection with DNS-Collector and Loki](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/dns_collector_loki_setup.en.md)

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
