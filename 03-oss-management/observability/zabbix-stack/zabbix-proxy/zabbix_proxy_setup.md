<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-proxy/zabbix_proxy_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o Zabbix Proxy - Raspberry Pi (ARM64)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a instalação do Zabbix Proxy em arquitetura ARM (Raspberry Pi) com Ubuntu Server. 

O objetivo é ter um servidor na rede interna que sirva como uma ponte de comunicação entre o Zabbix Server (provisionado em uma VM na oracle cloud) e os hosts e dispositivos da minha rede interna.

##

### 💾 Fase 1: Instalar e configurar o Zabbix Proxy

1. Acesse o terminal via ssh com privilégios de superusuário:

```bash
sudo su -
```

2. Instale o repositório do Zabbix:

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
apt update
```

3. Instale o Zabbix Proxy:
   ```bash
   apt install zabbix-proxy-sqlite3 -y
   ```
4. Configure o banco de dados para o Zabbix Proxy:
   Edite arquivo /etc/zabbix/zabbix_proxy.conf and adicione o parâmetro DBName indicando o diretório e nome para o BD.
   ```bash
   # Exemplo:
   DBName=/var/lib/zabbix/zbxproxy.db
   ```
5. Inicie o serviço:
   ```bash
   systemctl restart zabbix-proxy
   systemctl enable zabbix-proxy
   ```
   
##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
