<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Virtualization%20and%20Workloads/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Portuguese</a></h6>

# 🗄️ Virtualization and Containerization

### 📝 Description

In this section, I document how I manage computer resources. I explain how the hardware is divided to run different services.

##

### 💻 Hardware

- HP Pavilion G4-1270BR
  - Processor: Core i5 3rd Gen, Dual Core 2.5 GHz
  - RAM Memory: 8 GB DDR3, 1600 MHz
  - Storage:
    - SSD: Kingston 480 GB
    - HDD: Samsung 750 GB
  - Graphics: Intel HD Graphics 6000
 
- Raspberry Pi 4B
  - Processor: Broadcom BCM2711, Quad-core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5 GHz
  - RAM Memory: 4GB LPDDR4-3200 SDRAM
  - Storage: 64 GB Micro-SD Card
  - Connectivity:
    - Wireless: Dual-band Wi-Fi 2.4 GHz and 5.0 GHz (802.11ac) and Bluetooth 5.0 (with BLE)
    - Wired Network: Gigabit Ethernet 10/100/1000 Mbps
    - USB Ports: 2 USB 3.0 ports and 2 USB 2.0 ports

- Raspberry Pi 3B
  - Processor: Broadcom BCM2837, Quad-core Cortex-A53 (ARMv8) 64-bit SoC @ 1.2 GHz
  - RAM Memory: 1 GB LPDDR2
  - Storage: 16 or 32 GB Micro-SD Card
  - Connectivity:
    - Wireless: Wi-Fi 802.11n (2.4 GHz) and Bluetooth 4.1 (Classic and BLE)
    - Wired Network: Fast Ethernet 10/100 Mbps
    - USB Ports: 4 USB 2.0 ports
  
##

### 🛠️ Hypervisors and Runtimes

- **CasaOS:** Used on the main server. It has an interface to manage Docker containers. This makes it easy to install and manage custom services using Docker Compose.
- **Proxmox VE:** A hypervisor used to run Virtual Machines (VMs) and LXC containers for some services.
- **Ubuntu Server:** Used to install services directly, without virtualization or containers.

##

### 🚀 Technical Implementations

- **Resource Management:** Controlled CPU and RAM overprovisioning to save energy costs.
- **Storage Persistence:** Using Docker volumes with ExFAT/NFS/Samba to keep data safe outside the containers.

##

### 📂 Directory Structure

```text
📂 Virtualization & Workloads/
├── 📄 README.md              # Overview and VM inventory
├── 📄 README2.md             # Overview and VM inventory (English)
├── 📂 setup-guides/          # Folder with manuals
└── 📂 templates/             # Ready-to-use files
```

##

###### ℹ️ Part of the project Dr. Hardware Autonet - Licensed under the MIT license.
