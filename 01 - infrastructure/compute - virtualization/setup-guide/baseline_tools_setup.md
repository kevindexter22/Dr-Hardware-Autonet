<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/baseline_tools_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🧰 SOP: Ferramentas de Troubleshooting e Aanálise

### 📝 Descrição e Escopo (SecOps & MTTR)

Este documento lista os pacotes fundamentais de observabilidade local e ferramentas de *troubleshooting* (Camadas L2 a L7) que compõem o *Baseline* de sistema de todos os nós (servidores e contêineres nativos) do laboratório. 

O objetivo é padronizar o ecossistema para garantir que, durante um incidente operacional de rede ou alta carga de CPU/Disco, as ferramentas de diagnóstico já estejam disponíveis no *host*, reduzindo o Tempo Médio de Reparo (MTTR).

##

### 🛠️ Pacotes de Rede e Conectividade (L2 - L4)

Utilitários focados no *Data Plane*, roteamento e análise de tráfego em tempo real:

* **`tcpdump`**: Analisador de pacotes em linha de comando (essencial para capturar tráfego de protocolos e validar regras de firewall).
* **`iftop`**: Monitora o uso de banda da rede em tempo real por conexões ativas (identifica qual IP está saturando o link).
* **`nload`**: Monitor visual de tráfego de rede e uso de banda por interface (ex: `eth0` vs `wlan0`).
* **`mtr`**: Utilitário que combina as funções do `ping` e do `traceroute` de forma dinâmica (identifica perda de pacotes e latência em saltos intermediários).
* **`traceroute`**: Mapeia o caminho IP de ponta a ponta na Camada 3.
* **`ping` (`iputils-ping`)**: Teste base de conectividade via protocolo ICMP.
* **`net-tools`**: Pacote base contendo utilitários legados de gestão L2/L3 (`arp`, `ifconfig`, `netstat`).

---

### 📊 Pacotes de Sistema e I/O (Compute & Storage)

Utilitários focados no consumo de recursos de hardware:

* **`htop`**: Visualizador interativo de processos (identifica gargalos de CPU, memória RAM e consumo de *Swap*).
* **`iotop`**: Monitor de utilização de I/O de disco por processo (vital para diagnosticar lentidão em bancos de dados ou saturação de leitura/escrita no Micro-SD).

##

### 🚀 Procedimento de Instalação Manual

Para injetar o *Toolkit* base em um novo servidor Ubuntu/Debian recém-provisionado, execute:
   ```bash
   # 1. Atualize a lista de pacotes do repositório base
   sudo apt update
   # 2. Instale as ferramentas de diagnóstico
   sudo apt install -y net-tools htop iftop nload traceroute iputils-ping mtr-tiny tcpdump iotop
   ```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.

# 2. Instale as ferramentas de diagnóstico em modo não-interativo (-y)
sudo apt install -y net-tools htop iftop nload traceroute iputils-ping mtr-tiny tcpdump iotop
