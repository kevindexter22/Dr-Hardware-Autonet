<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 📊 Grafana Stack

### 📝 Scope Description

Welcome to the project's Grafana Stack directory.

This environment is the visual layer (Frontend) of our observability architecture.

The main goal of Grafana here is to centralize, combine, and show the raw data collected by our infrastructure, turning it into actionable dashboards.

##

### 🗂️ Directory Structure

The organization of this stack is divided into these folders to make maintenance and updates easier:

* 📁 `/grafana-server`: Contains the Standard Operating Procedures (SOPs) for setting up, installing, and configuring the Grafana server (hosted on Oracle Cloud - OCI), plus the VPN tunnel settings to access the local network.

* 📁 `/integrations`: Guides to connect with our Data Sources, install plugins, and map metrics.

* 📁 `/maintenance`: Backup scripts, update routines, dashboard export as code (JSON), and general troubleshooting.

##

### 🔌 Data Sources

In this setup, Grafana works as a single pane of glass. It reads data from two main engines:

1. **Zabbix (Metrics and Alerts):**

   * **Function:** Active health monitoring of the infrastructure (CPU, RAM, network traffic, service status, ICMP ping).

   * **Integration:** Done using the official Zabbix plugin (Zabbix API).

2. **Loki (Log Aggregation):**

   * **Function:** Receives and indexes network and application logs (example: DNS query logs from Pi-hole/AdGuard collected via go-dnscollector).

   * **Integration:** Done using direct LogQL queries through a secure VPN tunnel (IPsec).

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
