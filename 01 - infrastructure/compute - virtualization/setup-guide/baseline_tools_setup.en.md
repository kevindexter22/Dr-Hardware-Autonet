<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/baseline_tools_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🧰 SOP: OS Baseline & Troubleshooting Toolkit

### 📝 Description and Scope (SecOps & MTTR)

This document lists the basic local monitoring and troubleshooting tools (Layers L2 to L7) that are part of the system baseline for all nodes (servers and native containers) in the lab.

The goal is to standardize the environment. During a network problem or high CPU/Disk usage, the diagnostic tools must already be on the server. This reduces the Mean Time to Repair (MTTR).

##

### 🛠️ Network and Connectivity Packages (L2 - L4)

Tools focused on the Data Plane, routing, and real-time traffic analysis:

* **`tcpdump`**: Command-line packet analyzer (essential to capture protocol traffic and test firewall rules).
* **`iftop`**: Monitors real-time network bandwidth usage per active connection (finds which IP is using the link).
* **`nload`**: Visual network traffic and bandwidth monitor per interface (e.g., `eth0` vs `wlan0`).
* **`mtr`**: Tool that mixes `ping` and `traceroute` dynamically (finds packet loss and latency in middle hops).
* **`traceroute`**: Maps the end-to-end IP path at Layer 3.
* **`ping` (`iputils-ping`)**: Base connectivity test using the ICMP protocol.
* **`net-tools`**: Base package with legacy L2/L3 management tools (`arp`, `ifconfig`, `netstat`).

##

### 📊 System and I/O Packages (Compute & Storage)

Tools focused on hardware resources:

* **`htop`**: Interactive process viewer (finds CPU, RAM memory, and Swap bottlenecks).
* **`iotop`**: Disk I/O monitor per process (very important to find slow database queries or Micro-SD read/write limits).

---

### 🚀 Manual Installation Guide

To add the base toolkit to a new Ubuntu/Debian server, run:

```bash
# 1. Update the repository package list
sudo apt update

# 2. Install the diagnostic tools
sudo apt install -y net-tools htop iftop nload traceroute iputils-ping mtr-tiny tcpdump iotop
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
