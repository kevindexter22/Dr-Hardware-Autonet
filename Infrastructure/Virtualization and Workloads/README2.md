<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Virtualization%20and%20Workloads/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Portuguese</a></h6>

# 🗄️ Virtualization and Containerization

### 📝 Description

In this section, I document how I manage computer resources. I explain how the hardware is divided to run different services.

---

### 🛠️ Hypervisors and Runtimes

- **CasaOS:** Used on the main server. It has an interface to manage Docker containers. This makes it easy to install and manage custom services using Docker Compose.
- **Proxmox VE:** A hypervisor used to run Virtual Machines (VMs) and LXC containers for some services.
- **Ubuntu Server:** Used to install services directly, without virtualization or containers.

---

### 🚀 Technical Implementations

- **Resource Management:** Controlled CPU and RAM overprovisioning to save energy costs.
- **Storage Persistence:** Using Docker volumes with ExFAT/NFS/Samba to keep data safe outside the containers.

---

### 📂 Directory Structure

```text
📂 Virtualization & Workloads/
├── 📄 README.md              # Overview and VM inventory
├── 📄 README2.md             # Overview and VM inventory (English)
├── 📂 setup-guides/          # Folder with manuals
└── 📂 templates/             # Ready-to-use files
```
##
