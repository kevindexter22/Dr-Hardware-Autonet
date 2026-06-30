
# 📖 Central Governance and Standards Document

### 📝 Scope Description
This document is the **"Source of Truth" for Policy Management** in the Dr. Hardware Autonet lab. It defines the rules for architecture, security, and naming. All physical hardware, logical networks, and automation code must follow these rules. This keeps the lab aligned with the OSS framework (FCAPS).

##

### 🏷️ 1. Asset Naming Standards (Naming Convention)

It defines strict rules to easily find services, list them in Zabbix, and automate them with *scripts*.

| Category | Naming Standard | Practical Example |
| :--- | :--- | :--- |
| **Network Elements (L1/L2/L3)** | `[TYPE]-[MODEL]-[ROLE]` | `Router-EX521-Controller` or `Switch-LS1008G-Access` |
| **Wireless Networks (WLAN)** | Focus on the use, not the hardware | `Core`, `IoT`, `Guest` |
| **Backup Files (Configs)** | `config-backup-[NODE]-sanitized.[EXT]` | `config-backup-controller-sanitized.bin` |
| **Servers / LXC / VMs** | `[ROLE]-[OS/APP]-[ENVIRONMENT]` | `IAM-FreeIPA-Prod` or `Storage-Samba-OPL` |

##

### 🗺️ 2. Addressing and Segmentation Policy (IPAM)

It sets the routing logic (Layer 3) and contains *broadcast* domains.

* **Static Allocation (DHCP Reservations / Static IPs):** Required for the Management Plane, hypervisors, identity infrastructure (FreeIPA), and instances using DNAT or UPnP.
* **Logical Segmentation (Subnets):** The lab uses different CIDR blocks for the main network, CCTV/Camera network (WR850N), and Fast Ethernet segments. This isolates collision and *broadcast* domains.
* **IPAM Management:** Every new static IP must be documented and reserved in the central database before you create the machine or container.

##

### 🛡️ 3. Network Security Policies (SecOps / L4-L7)

Architecture rules to protect the physical and logical network against lateral movement and attacks.

* **Edge Surface (WAN):** Strict use of *Default Deny* on the edge *Firewall*. No port should be open without an approved technical reason.
* **Inter-VLAN Isolation (WLAN):** Traffic from `IoT` and `Guest` devices (*AP Isolation* is ON) is blocked at the *Gateway* level. They cannot reach the Administration/Core network.
* **UPnP Management (Gaming):** Dynamic port negotiation is only allowed to improve latency on game consoles. It is strictly forbidden to use dynamic negotiation for management ports (e.g., TCP 22, 80, 443, 3389).
* **Legacy Protocols Control (TR-069):** External ISP CWMP agents must stay `DISABLED`. The L7 remote management port will only be active for internal automation.

##

### 🔌 4. Physical Topology Standards (Physical Layer)

Rules to ensure resilience and prevent failures in Layer 1 and 2 *hardware*.

* **Cable Standards:** Wired *Uplinks* and *Backhauls* must only use Cat5e cables or better. They must support Gigabit Ethernet.
* **Loop Prevention (Unmanaged Switches):** Empty ports on *Plug-and-Play* equipment must stay physically isolated (no loose cables connected). This prevents *broadcast* storms.
* **Visual Documentation:** All critical *Uplink* connections must have physical labels on both ends of the cable.

##

### ⚙️ 5. Change and Consistency Management (Configuration Management)

It makes sure the current state of the lab does not change from the planned architecture (*Configuration Drift*).

* **Mesh Cluster Logic Sync:** If you change the ACL state on the *Controller* node, you must manually or automatically copy it to the *Satellite* node right away. This keeps edge security symmetrical.
* **Active Audit Cycle:** You must inspect the main Gateway routing *logs* every month. Focus on checking the UPnP open ports and finding *Flood* attacks or anomalies.
* **Infrastructure as Code (IaC):** To change configurations on Linux servers (Day 2), you should use Ansible *Playbooks* instead of manual SSH commands. This guarantees idempotency.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
