
# 🎯 SOP: Instalação do Zabbix Server (Oracle Cloud - OCI)

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a instalação do **Zabbix Server 7.0 LTS** (com banco de dados MySQL e frontend Apache) em uma instância Ubuntu 24.04 hospedada na Oracle Cloud Infrastructure (OCI). 

Sendo o nó central (*Core*) da arquitetura de monitoramento, este servidor será responsável por receber todas as conexões criptografadas dos Zabbix Proxies e Agents distribuídos (Edge).

##

### 🛡️ Fase 1: Liberação de Portas e SecOps (Nuvem e SO)

Para que o Zabbix Server se comunique com o mundo externo, precisamos liberar o tráfego em duas camadas: no painel da Oracle Cloud (VCN) e no firewall interno do Ubuntu.

**1.1. Camada de Nuvem (OCI Security Lists):**
1. Acesse o painel da OCI > **Networking** > **Virtual Cloud Networks**.
2. Abra a sua VCN > **Security Lists** > **Default Security List**.
3. Adicione as seguintes *Ingress Rules* (Regras de Entrada):

   **Regra 1: Interface Web**
   * **TCP 80 / 443:** Para acesso ao painel Web do Zabbix (Frontend).

   **Regra 2: Zabbix Trapper (Comunicação com os Proxies)**
   * **Source Type:** CIDR
   * **Source CIDR:** `0.0.0.0/0` *(Nota: Em produção estrita, restrinja para o IP Público do seu roteador de casa)*
   * **IP Protocol:** TCP
   * **Destination Port Range:** `10051`
   * **Description:** Allow Zabbix Active Proxy/Agent traffic

**1.2. Camada de Sistema Operacional (Iptables do Ubuntu OCI):**
As imagens do Ubuntu na OCI usam `iptables` por padrão. Execute os comandos abaixo via SSH na sua VM para liberar as portas localmente e salvar a regra:
```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 10051 -j ACCEPT
sudo netfilter-persistent save
```

##

### 🗄️ Fase 2: Instalação do Banco de Dados

Instale o MySQL Server nativo do Ubuntu:
   ```bash
   sudo apt update
   sudo apt install mysql-server -y
   ```

##

### ⚙️ Fase 3: Instalação dos Pacotes Zabbix (7.0 LTS) e configuração do Banco de Bados

1. Instalação do repositório oficial do zabbix:
   ```bash
   wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
   dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
   apt update
   ``` 
2. Instalação do Server, do Frontend e do Agent:
   ```bash
   apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
   ```
3. Criar o Banco de Dados inicial:
   ```bash
   mysql -uroot -p
   mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
   mysql> create user zabbix@localhost identified by 'password';
   mysql> grant all privileges on zabbix.* to zabbix@localhost;
   mysql> set global log_bin_trust_function_creators = 1;
   mysql> quit;
   ```
4. No servidor do Zabbix, importe o esquema inicial e os dados (será solicitado a inserir a senha que foi criada anteriormente):
   ```bash
   zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
   ```
5. Desative a opção log_bin_trust_function_creators após importar o database schema:
   ```bash
   mysql -uroot -p
   password
   mysql> set global log_bin_trust_function_creators = 0;
   mysql> quit;
   ```
6. Configure o banco de dados para o servidor Zabbix, editando o arquivo `/etc/zabbix/zabbix_server.conf`:
   ```bash
   DBPassword=password
   ```
7. Inicie o servidor zabbix e os processos agentes:
   ```bash
   systemctl restart zabbix-server zabbix-agent apache2
   systemctl enable zabbix-server zabbix-agent apache2
   ```

##

### 🚀 Fase 4: Acesso ao Frontend

1. Abra o navegador e acesse o IP Público da sua instância OCI:
   ```bash
   http://<IP_PUBLICO_DA_OCI>/zabbix
   ```
2. Siga o assistente de instalação Web (Next, Next, Finish).

* **Observação:** Credenciais padrão do Zabbix (Primeiro Acesso):
  * Username: Admin (com 'A' maiúsculo)
  * Password: zabbix

> **⚠️ Alerta de Segurança:**<br>
> *Troque a senha do usuário Admin imediatamente após o primeiro login.*<br>
> *Realize a configuração de um certificado SSL para o apache.*

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
