<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/raspberry-pi/raspberry_pi_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o Zabbix Proxy - Raspberry Pi (ARM64)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a instalação do Zabbix Agent em arquitetura ARM (Raspberry Pi) com Ubuntu Server 24.04 LTS. 

O objetivo é que o servidor possa se comunicar diretamente com o Zabbix Server (provisionado em uma VM na oracle cloud), fornecendo as métricas e dados a serem monitorados.

##

### 💾 Fase 1: Instalar e configurar o Zabbix Agent

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
3. Instale o Zabbix Agent ou Zabbix Agent 2:
   ```bash
   apt install zabbix-agent   
   ```
4. Inicie o serviço:
   ```bash
   systemctl restart zabbix-agent
   systemctl enable zabbix-agent 
   ```
   
##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.

