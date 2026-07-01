<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-agent/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🕵️ Zabbix Agents

### 📝 Scope Description

This folder has the Standard Operating Procedures (SOPs) to install Zabbix collection agents. In the monitoring architecture, the Agent is a key part for **Fault Management** and **Performance Management**. It collects telemetry from the Operating System and applications and sends it to the Zabbix Proxy or Server.

Today, Zabbix has two versions of agents. You should choose based on the *workload* running on the node.

##

### ⚖️ Architecture Analysis: Agent (Classic) vs. Agent 2

The main difference is the programming language and how they handle multiple tasks and data connections.

| Feature | 🟦 Zabbix Agent (Classic) | 🟩 Zabbix Agent 2 |
| :--- | :--- | :--- |
| **Base Language** | `C` | `Go` (Golang) + `C` |
| **Concurrency (Tasks)** | Multiple processes (Daemon) | Native *Multithreading* |
| **Extensibility** | *UserParameters* and *Loadable Modules* | Native *plugins* made in Go |
| **Persistent Connections** | ❌ No | ✅ Yes |
| **Collection Schedule** | Fixed (based on intervals) | Dynamic and scheduled by the plugin |
| **Basic Resource Use** | Very low | A little higher at boot, but scales better |

##

### 🎯 Decision Matrix: When to use each one?

You don't have to choose just one. Zabbix Agent 2 is a direct replacement for the classic Agent. Both support the same basic system keys. But, follow these rules:

#### 🟩 Choose **Zabbix Agent 2** (Recommended Default)
* **Modern Workloads and Databases:** Use this when the host runs PostgreSQL, MySQL, MongoDB, Redis, Docker, SSL certificates, or web services. 
* **Why?** Agent 2 supports *Stateful Checks*. It does not open and close a TCP connection with the database every 30 seconds (which is heavy). Instead, Agent 2 keeps the connection open in the *plugin*, making performance much better.

#### 🟦 Choose **Zabbix Agent (Classic)**
* **Legacy Systems or Extreme IoT:** Use this when the hardware OS is old, does not run Go binaries, or has very little RAM memory (e.g., custom routers, industrial hardware with < 256MB RAM).
* **Why?** The pure C agent uses very little memory. It is almost invisible to the operating system.

##

### 📡 Communication Topology (Active vs. Passive)

Both agents support two communication models. You can change them in the config file:

* **Passive Mode (Polling):** The Zabbix Server/Proxy starts the connection on `TCP 10050` to ask for data. The agent just listens and answers.
* **Active Mode (Trapping):** The Agent starts the connection on `TCP 10051` to the Server/Proxy, asks for the list of items to monitor, and sends the data over time. **This is the recommended default** to reduce network traffic and bypass NAT/Firewall issues.

##

### 🛠️ Operational Procedures (Runbooks)

Choose the correct installation guide for your target machine:

* 👉 **[SOP: Installing Zabbix Agent 2 (Recommended)](./zabbix_agent_2_setup.en.md)**
* 👉 **[SOP: Installing Zabbix Agent Classic (Legacy/Light)](./zabbix_agent_setup.en.md)**

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
