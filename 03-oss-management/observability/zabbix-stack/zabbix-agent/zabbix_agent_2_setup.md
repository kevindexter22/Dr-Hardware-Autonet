<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/raspberry-pi/raspberry_pi_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o Zabbix Agent 2 - Raspberry Pi (ARM64)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a instalação do Zabbix Agent 2 em arquitetura ARM (Raspberry Pi) com Ubuntu Server 24.04 LTS. 

O objetivo é que o servidor possa se comunicar diretamente com o Zabbix Server (provisionado em uma VM na oracle cloud) via Agent, fornecendo as métricas e dados a serem monitorados.

##

### 💾 Fase 1: Instalar e configurar o Zabbix Agent 2

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
3. Instale o Zabbix Agent 2:
   ```bash
   apt install zabbix-agent2
   ```
4. Instale os plugins para o Zabbix Agent 2:
   ```bash
    apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql 
   ``` 
5. Inicie o serviço:
   ```bash
   systemctl restart zabbix-agent
   systemctl enable zabbix-agent 
   ```
   
##

### 💾 Fase 2: Ajustando a comunicação entre o Zabbix Agent 2 e o Zabbix Server

Para que a comunicação funcione, precisamos liberar o IP de nosso Zabbix Server e/ou Zabbix Proxies no arquivo de configuração.

1. Abra o arquivo `/etc/zabbix/zabbix_agent2.conf` e faça os seguintes ajustes:
   ```bash
   # Procure pelas opções Server e ServerActive e adicione o IP do Servidor ou proxy:
   Server=<IP_DO_SERVIDOR/PROXY> # Permite que o servidor ou proxy faça conexões passivas
   ServerActive=<IP_DO_SERVIDOR/PROXY> # Permite que o servidor ou proxy faça conexões passivas
   # É possível adicionar mais de um servidor/proxy separando por vírgula, conforme exemplo o abaixo:
   Server=<IP_DO_SERVIDOR>,<IP_DO_PROXY>
   ServerActive=<IP_DO_SERVIDOR>,<IP_DO_PROXY>

   # Configure o hostname do servidor
   Hostname=<NOME_DO_HOST_NO_ZABBIX> # Deve ser exatamente o nome registrado na interface web do servidor   
   ```
2. Para aplicar as configurações é necessário reiniciar o serviço:
   ```bash
   sudo systemctl restart zabbix-agent2
   sudo systemctl status zabbix-agent2 # Mostra se o serviço iniciou corretamente
   ```
   
## 

### ℹ️ Diferença entre Métricas Passivas e Ativas:

* **Métricas Passivas (Server):** O Servidor Zabbix pede os dados, e o Agente responde na hora. É ideal para acompanhar o status em tempo real.
* **Métricas Ativas (ServerActive):** O Agente pede a lista de tarefas, coleta os dados sozinho e envia para o Servidor. É ideal para logs e redes instáveis.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.


