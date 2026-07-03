<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/05-docs/runbooks-troubleshooting/dual_homed_monitoring.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 📘 Runbook & Architecture: Isolated Monitoring via Dual-Homing

### 🚨 The Problem (Context)
In network scenarios, we often have isolated subnets (like guest Wi-Fi or IoT) that do not route to the main network. The challenge was: **How to monitor devices on this isolated Wi-Fi without opening firewall ports or buying new hardware?**

##

### 💡 The Solution (Design)

The solution was to make the existing Zabbix Proxy (Raspberry Pi) a **Dual-Homed** node (connected to two networks at the same time). It uses Wi-Fi to access the isolated network and the network cable to send data to the Zabbix Server.

| Interface | Network / VLAN | Flow Function (FCAPS) |
| :--- | :--- | :--- |
| **`wlan0`** (Wi-Fi) | Isolated Network / IoT | **Ingress (Collection):** Collects metrics from agents on the wireless network. |
| **`eth0`** (Cable) | Main LAN | **Egress (Outflow):** Sends data safely to the cloud. |

> **Note:** For technical implementation details and Netplan code blocks, see the [Proxy Technical Implementation Documentation](../../03-oss-management/observability/zabbix-stack/zabbix-proxy/dual_homed_monitoring.en.md).

##

### 🛡️ Security and Routing (SecOps)

To make sure the Proxy does not become an unsafe bridge between networks:

1. **No Default Gateway Hijack:** The Wi-Fi interface (`wlan0`) was configured in Netplan with `use-routes: false`. This ensures the internet continues to go out through the cable (`eth0`).

2. **Isolation (No IP Forwarding):** Packet forwarding (`net.ipv4.ip_forward=0`) is disabled in Linux. Nobody on the Wi-Fi network can use the Proxy as a router to invade the main network.

##

### 🔧 Troubleshooting (What to do if it breaks)

If the Wi-Fi monitoring stops or the Proxy loses connection to the cloud, follow these steps:

1. **Check the Default Route (Critical):**
Run `ip route`. The line that starts with `default via` **must** point to the `eth0` interface. If it points to `wlan0`, the traffic is going the wrong way.
* *Fix:* Check the `/etc/netplan/*.yaml` file and run `sudo netplan apply`.

2. **Check the Wi-Fi Connection:**
Run `ip a show wlan0`. Check if the interface got an IP address. If it does not have an IP, the radio might be disconnected.
* *Fix:* Check the passwords in Netplan and run `sudo wpa_cli status`.

3. **Test the Isolation:**
Try to ping from the Wi-Fi network to a main network IP using the Proxy. The ping must **fail**, ensuring the security isolation is active.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
