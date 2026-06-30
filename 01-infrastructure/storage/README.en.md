
# 💾 Storage Infrastructure (NAS/SAN)

### 📝 Scope Description
This domain manages the persistent storage infrastructure. The focus is on ensuring data integrity (Fault Management), optimizing I/O performance (Performance Management), and consistency in volume mounting (Configuration Management).

##

### 🏗️ Storage Architecture

The storage topology is segmented by functionality and protocol, ensuring the necessary isolation for each *workload*:

* **Local Storage (Proxmox/CasaOS):** Focused on block persistence and local volumes for containers and virtual machines.
* **Network Storage (NAS/SMB):** Focused on sharing resources for specific endpoints (such as the PS2 console), using the SMBv1 protocol for legacy compatibility.

##

### 📂 Directory Structure (Workloads)

| Directory | Protocol | Logical Function (FCAPS) |
| :--- | :--- | :--- |
| `casaos-local-storage/` | Mount (UUID) | Local mount management and block persistence. |
| `opl-smb-storage/` | SMB (v1) | File sharing for endpoints (PS2/OPL) and I/O automation. |

##

### ⚙️ Configuration Management and Automation

File system integrity is maintained through IaC practices and proactive monitoring:

* **UUID Management:** Hard drive mounts in `casaos-local-storage` use persistent identifiers (UUIDs) to prevent *Configuration Drift* after hardware reconfiguration events or *reboots*.
* **Active Monitoring:** The `opl-smb-storage` directory contains endpoint monitoring logic and automated *shutdown* routines. These scripts ensure data integrity before physical device disconnection (Failure/corruption mitigation).

##

### 🛡️ Security and Integrity Policies

* **Access Control:** Access to *shares* is restricted by IP address and service credentials, limiting lateral movement of potential attackers on the local network.
* **Integrity:** Mount verification routines (fstab/systemd mounts) are validated to ensure there are no *race conditions* during system startup.

##

### 🔄 References and Governance

For details on global naming policies and security standards, refer to the official documentation:
👉 **[Central Governance and Standards Document](#)**

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
