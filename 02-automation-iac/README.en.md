<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/02-automation-iac/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# ⚙️ Automation & IaC (Infrastructure as Code)

### 📝 Domain Description

This folder is the **Automation and Orchestration Engine** of the lab. The goal of this layer is to change manual tasks (clicks and typing commands) into code. This code is versioned, testable, and repeatable (GitOps).

Here you can find the tools to provision resources. They apply base settings (*baselines*) to many servers and orchestrate end-user applications (Workloads) that run on the infrastructure.

##

### 🏗️ Domain Architecture

#### 📦 1. Docker Compose Stacks (`docker-compose-stacks/`)
Responsible for **End-User Application Orchestration (VAS - Value-Added Services)**.
* Unlike critical infrastructure, this folder has the manifests (`docker-compose.yaml`) for end-user apps. Examples are media servers, notes (Trilium), and personal automation platforms (N8N). They run *on top* of the infrastructure. You can easily destroy and create them again.

#### 🐚 2. Bash / Shell Scripts (`bash-scripts/`)
Responsible for **Imperative Automation and OS Routines**.
* It has *scripts* for operating system tasks, disk mount automation, local *backup* routines, and small scheduled *jobs* (Cron). These keep the Linux nodes healthy.

##

### 🚧 IaC Maturity Roadmap (Planned)

The technologies below are the future state (*To-Be*) of the lab architecture. They will slowly replace imperative *scripts* with state declarations.

* **[⏳ PLANNED] Ansible (`ansible/`):** For **Configuration Management**. It will have *Playbooks* to guarantee the desired state of servers (e.g., OS *Hardening*, SSH key injection, and mass base package installation).
* **[⏳ PLANNED] Terraform (`terraform/`):** For **Declarative Provisioning**. It will have manifests to provision immutable compute resources (e.g., automatic Virtual Machine creation in Proxmox).
* **[⏳ PLANNED] Python Scripts (`python-scripts/`):** For **L2-L7 Network Automation, Interoperability, and Mediation (ETL)**. Focused on programmatic interaction using APIs (REST/RESTCONF/NETCONF) and network engineering libraries (Netmiko/NAPALM/Nornir). It will collect telemetry, run automated *troubleshooting runbooks*, and natively integrate the *Management Plane* (OSS) platforms.

##

### 🧠 Architectural Principles (SRE)

All code in this folder must follow these principles:
* **Idempotency:** Running a *script* or *playbook* one time or a thousand times must give the exact same final system state. It must not cause breaks or duplicates.
* **Declarative over Imperative:** Whenever possible, declare the final state you want (IaC) instead of writing the step-by-step to get there.
* **Zero Snowflake Servers:** No server should have a unique manual configuration. Everything must be rebuildable from this repository.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
