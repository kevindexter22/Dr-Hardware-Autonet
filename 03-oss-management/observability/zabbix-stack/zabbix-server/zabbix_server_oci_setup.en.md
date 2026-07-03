<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-server/zabbix_server_oci_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🎯 SOP: Zabbix Server Installation (Oracle Cloud - OCI)

### 📝 Scope Description

This Standard Operating Procedure (SOP) details the installation of **Zabbix Server 7.0 LTS** (with MySQL database and Apache frontend) on an Ubuntu 24.04 instance hosted on Oracle Cloud Infrastructure (OCI). 

As the central node (*Core*) of the monitoring architecture, this server will receive all encrypted connections from the distributed Zabbix Proxies and Agents (Edge).

##

### 🛡️ Phase 1: Port Opening and SecOps (Cloud and OS)

For the Zabbix Server to communicate with the outside world, we need to open traffic in two layers: on the Oracle Cloud dashboard (VCN) and on the Ubuntu internal firewall.

**1.1. Cloud Layer (OCI Security Lists):**

1. Go to the OCI dashboard > **Networking** > **Virtual Cloud Networks**.

2. Open your VCN > **Security Lists** > **Default Security List**.

3. Add the following *Ingress Rules*:

   **Rule 1: Web Interface**
   * **TCP 80 / 443:** To access the Zabbix Web dashboard (Frontend).

   **Rule 2: Zabbix Trapper (Communication with Proxies)**
   * **Source Type:** CIDR
   * **Source CIDR:** `0.0.0.0/0` *(Note: In strict production, restrict this to your home router's Public IP)*
   * **IP Protocol:** TCP
   * **Destination Port Range:** `10051`
   * **Description:** Allow Zabbix Active Proxy/Agent traffic

**1.2. Operating System Layer (Ubuntu OCI Iptables):**

Ubuntu images on OCI use `iptables` by default. Run the commands below via SSH on your VM to open the ports locally and save the rule:

```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 10051 -j ACCEPT
sudo netfilter-persistent save
```

##

### 🗄️ Phase 2: Database Installation

Install the native Ubuntu MySQL Server:

```bash
sudo apt update
sudo apt install mysql-server -y
```

##

#### ⚙️ Phase 3: Zabbix Packages Installation (7.0 LTS) and Database Configuration

1. Install the official Zabbix repository:

```bash
wget [https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb](https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb)
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update
```

2. Install the Server, Frontend, and Agent:

```bash
apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

3. Create the initial database:

```bash
mysql -uroot -p
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;
```

4. On the Zabbix server, import the initial schema and data (you will need to enter the password you created before):

```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```

5. Disable the log_bin_trust_function_creators option after importing the database schema:

```bash
mysql -uroot -p
password
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;
```

6. Configure the database for the Zabbix server by editing the /etc/zabbix/zabbix_server.conf file:

```bash
DBPassword=password
```

7. Start the Zabbix server and agent processes:
```bash
systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2
```

##

### 🚀 Phase 4: Frontend Access

1. Open your browser and go to the Public IP of your OCI instance:

```bash
http://<OCI_PUBLIC_IP>/zabbix
```

2. Follow the Web installation wizard (Next, Next, Finish).

* **Note:** Default Zabbix credentials (First Access):
   * **Username:** Admin (with a capital 'A')
   * **Password:** zabbix

##

**🧩 Optional adjustment:**

Since we will be [installing and configuring Grafana](#) on the same server to integrate with *Zabbix Server*, we will be [enabling and configuring the Apache proxy](#) to route HTTP traffic internally.

##

**☢️ Security Alert:**

* Change the Admin user password immediately after your first login.
* Configure an SSL certificate for Apache.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.

