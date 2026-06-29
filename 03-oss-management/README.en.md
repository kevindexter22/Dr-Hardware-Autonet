<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 👁️ OSS Management (Operations Support Systems)

### 📝 Domain Description

This folder works as the **Management Plane** of the lab. Based on the global **FCAPS** framework, this layer has all the *stacks* and platforms. They are responsible for keeping the health, security, and active visibility of all physical and virtual infrastructure.

The tools here are not regular user applications (Workloads). They are the critical systems that watch the network and server foundation (Network Core & Compute).

##

### 🏗️ Domain Architecture

#### 📊 1. Observability (F and P of FCAPS)
Responsible for Fault and Performance Management. It centralizes metric collection, L2-L7 telemetry, and log analysis of the lab.
* **`myspeed/`**: Stack for automatic link quality monitoring (recurring throughput and latency).
* **`zabbix-stack/`**: Main monitoring ecosystem using agents and interrogators (*Proxies*, *Agents*, and *Templates*).

##

#### 🔐 2. Security & IAM (S of FCAPS)
Responsible for Security Management. It is the Identity and Access Control core of the network.
* It holds the *Identity and Access Management* (IAM) stacks, like *Single Sign-On* (SSO) providers, user directories (LDAP/Active Directory), and network authentication control (RADIUS, FREEIPA).

##

#### 🚨 3. Alerts & Mediation
Responsible for organizing incident intelligence.
* It receives the raw triggers from the *Observability* layer, filters the noise, and sends actionable alerts to the right notification channels (Webhooks, Telegram, N8N, e-mail).

##

### 🛠️ Organization Pattern (GitOps)

Each tool inside these folders is a **Cohesive Stack**. Following SRE practices, inside each tool's folder (e.g., `zabbix-stack`), you will find everything that belongs to it:
* Declarative Manifests (`docker-compose.yaml`).
* Base Installation Guides and Manuals (SOPs).
* Specific configuration files and maintenance *scripts*.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
