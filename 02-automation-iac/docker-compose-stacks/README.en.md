<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/02-automation-iac/docker-compose-stacks/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🐳 Docker Compose Stacks (Workloads & IaC)

### 📝 Architecture Description

This folder is the central **Infrastructure as Code (IaC)** repository for our containerized applications (*Workloads*). 

We use Docker Compose to set up our services. This guarantees that environments are standard and easy to copy. It also allows fast recreation in *Disaster Recovery* situations.

The architecture uses a **strict separation** between the compute layer (temporary containers) and the data layer (*named volumes* and *bind mounts*). This guarantees that we can update images or recreate *stacks* with zero data or configuration loss.

##

### 🏗️ Operational Alignment (FCAPS)

Container management follows these standard operation disciplines:

* **F (Fault Management) & MTTR:** We reduce the Mean Time To Repair (MTTR) using auto-recovery policies (like `restart: unless-stopped`) and native *Healthchecks*. The Docker *daemon* acts as a supervisor. It restarts failing containers automatically without human action (L0 Automation).
* **C (Configuration Management):** We use the *GitOps* model. The `docker-compose.yml` file is the *Single Source of Truth* for the application topology. It declares the exact image versions (tags), environment variables, and structural dependencies.
* **P (Performance Management):** We can apply resource limits (*cgroups* - CPU and RAM) for each service. This prevents high processing in one *stack* (like Emby transcoding) from taking resources away (*noisy neighbor*) from critical management applications.

##

### 🖧 Logical Topology (OSI Layer 2-7)

| Component | Logical Function | Traffic Scope | Protocols / OSI Layer |
| :--- | :--- | :--- | :--- |
| **Docker Engine** | Container Runtime | `Host <-> Container` | IPC / Kernel Namespaces |
| **User-Defined Bridge** | Microsegmentation (Private Network) | `East-West` (Internal) | Virtual L2 / IPv4 (Layer 3) |
| **Exposed Ports (NAT)** | Ingress (Port Mapping) | `North-South` (External) | TCP/UDP (Layer 4) |
| **Workloads (Services)**| Application and APIs | `Client -> Proxy -> App`| HTTP/HTTPS (Layer 7) |

##

### 🛡️ Security and Network Requirements (SecOps)

Mandatory architecture rules for any *stack* in this folder:

1.  **Network Isolation (Microsegmentation):** We must deploy each *stack* in its own virtual network (custom *bridge*). Traffic between *stacks* must not be free. If `n8n` needs to access `cloudbeaver`, we must configure this communication explicitly.
2.  **Secrets Management:** Do not *hardcode* passwords, API tokens, or cryptographic keys in the `docker-compose.yml` files. This is strictly forbidden. We must inject all credentials using `.env` files (ignored by `.gitignore`) or Docker Secrets.
3.  **Attack Surface (Ports):** Avoid using `network_mode: host` without restrictions. Exposed ports must be limited. Ideally, bind them only to *loopback* (`127.0.0.1:PORT:PORT`). This forces external traffic to go through a *Reverse Proxy* (Ingress Controller) for TLS termination.
4.  **Least Privilege:** When the base image supports it, run the container with a non-root user (using the `user: UID:GID` directive). Avoid using the `privileged: true` flag.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
