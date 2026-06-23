<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🗄️ Compute & Virtualization

### 📝 Description

In this section, I document the lab's computer resources (NFVI). It shows the physical hardware and the virtualization layer (VIM) that divides and gives resources to the services.

---

### 💻 Hardware Inventory (Resource Pool)

| Device | Main Role | CPU / Architecture | RAM | Storage | Connectivity (Network) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HP Pavilion G4-1270BR** | Core Hypervisor | Core i5 3rd Gen (Dual 2.5GHz) | 8 GB DDR3 | 480 GB SSD + 750 GB HDD | Gigabit Ethernet (via adapter/integrated) |
| **Raspberry Pi 4B** | Edge Container Host | Cortex-A72 Quad-core (ARMv8 64-bit) | 4 GB LPDDR4 | 64 GB Micro-SD | Gigabit Ethernet, Wi-Fi 5 |
| **Raspberry Pi 3B (x4)** | Micro-Services / Node | Cortex-A53 Quad-core (ARMv8 64-bit) | 1 GB LPDDR2 | 16/32 GB Micro-SD | Fast Ethernet (10/100), Wi-Fi 4 |

---

### 🛠️ Hypervisors and Runtimes (VIM / CaaS)

* **CasaOS (RPi 4B):** It is the main container manager on the edge. It gives a simple interface for the Docker Engine, making it fast to manage and start services with `docker-compose`.
* **Proxmox VE (HP Pavilion):** Bare-Metal hypervisor. It isolates and manages Virtual Machines (VMs) and System Containers (LXC) for heavier infrastructure services.
* **Ubuntu Server (Bare-Metal):** The base Operating System (OS) used directly on the Raspberry Pi 3B nodes. It runs services with less overhead (no virtualization layer).

---

### 🚀 Technical Policies and Implementations

* **Resource Management (Capacity Management):** Controlled *overprovisioning* of vCPUs and RAM in Proxmox. This maximizes the number of services and saves energy on older hardware.
* **Storage Persistence:** Standard volume mounts for the Docker environment using ExFAT, NFS, or SMB. This keeps the operational data safe and saved outside the containers.

---

### 📂 Directory Structure

```text
01-infrastructure/compute-virtualization/
├── 📄 README.md              # Overview and Hardware Inventory (Portuguese)
├── 📄 README.en.md           # Overview and Hardware Inventory (English)
├── 📂 setup-guides/          # Standard Operating Procedures (SOPs) for base setup
└── 📂 templates/             # Base images, Cloud-Init, and infrastructure files
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - MIT License.
