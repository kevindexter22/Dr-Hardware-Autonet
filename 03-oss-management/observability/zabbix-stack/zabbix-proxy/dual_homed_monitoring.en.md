<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-proxy/dual_homed_monitoring.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🏗️ Solution Design: Isolated Monitoring via Dual-Homing (Zabbix Proxy)

### 🚨 The Problem (Context)

In distributed network setups, we often see isolated subnets (like guest Wi-Fi, IoT, or Out-of-Band management networks). These networks do not have direct routing to the main LAN or the cloud. 
The architectural challenge was: **How to get telemetry (monitor) devices on this isolated Wi-Fi without breaking security rules (opening firewall ports) or buying new hardware?**

##

### 💡 The Proposed Solution

The adopted solution was to make the existing Zabbix Proxy (Raspberry Pi - ARM64) a **Dual-Homed** node (connected to two networks at the same time).

Using the hardware's native Wi-Fi radio, the node was physically connected to the second network. It acts as a safe bridge. It does local *polling* on the isolated Wi-Fi and uses its main cable interface (LAN) to send the data to the Zabbix Server.

##

### 🖧 Logical Topology and Data Flow

| Interface | Network / VLAN | Flow Function (FCAPS) |
| :--- | :--- | :--- |
| **`wlan0`** (Wi-Fi) | Isolated Network / IoT | **Ingress (Collection):** Listens and asks for data from Zabbix agents on the wireless network. |
| **`eth0`** (Cable) | Main LAN | **Egress (Outflow):** Sends the processed data safely to the cloud. |

##

### 🛡️ Security (SecOps) and Routing Considerations

This solution needs strict controls to stop the monitoring node from becoming an attack point or a data leak bridge (*Data Leakage*):

1. **Default Gateway Hijack Prevention:** The `wlan0` interface was configured (via Netplan) to **ignore** the default route from the Wi-Fi DHCP (`dhcp4-overrides: use-routes: false`). This guarantees that all traffic to the internet/cloud goes out only through the cable network (`eth0`).
2. **Traffic Isolation (No IP Forwarding):** IPv4 packet forwarding (`net.ipv4.ip_forward=0`) is disabled in the Linux kernel (sysctl). This ensures that an infected device on the Wi-Fi cannot use the Zabbix Proxy as a router to invade the main LAN.
3. **Edge Encryption:**
   All data sent from the `eth0` interface to the cloud (Zabbix Server) is always encrypted using TLS/PSK.

##

### ⚙️ Technical Implementation (Reference)

The configuration that turns on this topology without breaking the routing was applied at the Operating System level:

```yaml
# Example of logical route block on the second interface (Netplan)
wifis:
  wlan0:
    dhcp4: true
    dhcp4-overrides:
      use-routes: false  # Ensures the main LAN (eth0) keeps the Default Route
    access-points:
          "<NETWORK_SSID>":
            password: "<NETWORK_PASSWORD>"
```

If you prefer to configure a static IP, it will look like this:

```yaml
# Example of logical route block on the second interface (Netplan)
wifis:
  wlan0:
    dhcp4: false
    addresses:
      - <NETWORK_IP/CIDR>
    dhcp4-overrides:
      use-routes: false  # Ensures the main LAN (eth0) keeps the Default Route
    access-points:
          "<NETWORK_SSID>":
            password: "<NETWORK_PASSWORD>"
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
