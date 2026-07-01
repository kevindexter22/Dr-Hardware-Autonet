<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-agent/zabbix_agent_2_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛠️ SOP: Installing Zabbix Agent 2 - Raspberry Pi (ARM64)

### 📝 Description and Scope

This document defines the Standard Operating Procedure (SOP) to install Zabbix Agent 2 on ARM architecture (Raspberry Pi) with Ubuntu Server 24.04 LTS. 

The goal is to allow the server to talk directly to the Zabbix Server (running on an Oracle Cloud VM) using the Agent, sending metrics and data to be monitored.

##

### 💾 Phase 1: Install and configure Zabbix Agent 2

1. Access the terminal via SSH with root privileges:
   ```bash
   sudo su -
   ```
2. Install Zabbix Agent 2:
    ```bash
    apt install zabbix-agent2
    ```
3. Install the plugins for Zabbix Agent 2:
    ```bash
    apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql 
    ```
4. Start the service:
    ```bash
    systemctl restart zabbix-agent
    systemctl enable zabbix-agent
    ```

##

💾 Phase 2: Adjusting communication between Zabbix Agent 2 and Zabbix Server

For the communication to work, we need to allow the IP of our Zabbix Server and/or Zabbix Proxies in the configuration file.

1. Open the file /etc/zabbix/zabbix_agent2.conf and make the following changes:
    ```bash
    # Look for the Server and ServerActive options and add the Server or proxy IP:
    Server=<SERVER/PROXY_IP> # Allows the server or proxy to make passive connections
    ServerActive=<SERVER/PROXY_IP> # Allows the server or proxy to make passive connections

     # You can add more than one server/proxy by separating them with a comma, like the example below:
    Server=<SERVER_IP>,<PROXY_IP>
    ServerActive=<SERVER_IP>,<PROXY_IP>

    # Configure the server hostname
    Hostname=<HOST_NAME_IN_ZABBIX> # It must be exactly the name registered in the server web interface

    # You can change the Zabbix Agent passive mode port in the parameter:
    ListenPort=10050 # Change from 10050 to the desired port  
    ```
2. To apply the settings, you need to restart the service:
    ```bash
    sudo systemctl restart zabbix-agent2
    sudo systemctl status zabbix-agent2 # Shows if the service started correctly
    ```
    
##

ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
