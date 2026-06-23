<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🏠 Infraestrutura

### 📝 Descrição

O objetivo principal desse diretório é trazer todas as informações ligadas à estrutura física, dispositivos/hardwares e serviços voltados ao meu homelab.

Trarei aqui a visão do que está sendo implementado, assim como um pouco da base teórica, finalidade da implementação, arquivos de configuração/scripts e problemas com suas possíveis soluções realizados ao longo do tempo.
##

### 🏗️ Topologia / Arquitetura

#### Diagrama L1-L2: Topologia Física e Data Link

```mermaid

graph TD
    %% Classes de Estilo L1/L2
    classDef firewall fill:#c0392b,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    classDef network fill:#2c3e50,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    classDef compute fill:#2980b9,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    
    subgraph WAN [ISP / Borda]
        ONT[ONT Intelbras <br/>Modo Bridge]:::firewall
    end

    subgraph CORE [Core L2 / Mesh]
        R_Mesh1[TP-Link EX521<br/>Master Router]:::network
        R_Mesh2[TP-Link EX521<br/>Mesh Node]:::network
        
        ONT ==>|WAN/PPPoE| R_Mesh1
        R_Mesh1 ==>|Backhaul UTP| R_Mesh2
    end

    subgraph LOC_01 [Local 01 - Compute Edge]
        SW1[Switch TP-Link<br/>8p Gigabit]:::network
        R_Cams[TP-Link wr841n<br/>DD-WRT]:::network
        RPi4B[Raspberry Pi 4B<br/>4GB]:::compute
        RPi3B_1[Raspberry Pi 3B<br/>Zabbix Proxy]:::compute
        RPi3B_2[Raspberry Pi 3B<br/>Samba OPL]:::compute

        R_Mesh1 -->|Uplink| SW1
        R_Mesh1 -->|Uplink| R_Cams
        SW1 --- RPi4B
        SW1 --- RPi3B_1
        SW1 --- RPi3B_2
    end

    subgraph LOC_02 [Local 02 - Compute Core]
        SW2[Switch Overtek<br/>8p Fast/Giga]:::network
        HP[HP Pavilion G4<br/>Bare-metal]:::compute
        RPi3B_3[Raspberry Pi 3B<br/>DNS/Radius]:::compute
        RPi3B_4[Raspberry Pi 3B<br/>Node Extra]:::compute

        R_Mesh2 -->|Uplink| SW2
        SW2 --- HP
        SW2 --- RPi3B_3
        SW2 --- RPi3B_4
    end

```

#### Diagrama L3-L7: Arquitetura Lógica e Ecossistema OSS

```mermaid
graph TD
    %% Classes de Estilo L3-L7
    classDef hypervisor fill:#8e44ad,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    classDef oss fill:#27ae60,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    classDef coreService fill:#d35400,stroke:#FFFFFF,stroke-width:2px,color:#fff;
    classDef cloud fill:#f39c12,stroke:#FFFFFF,stroke-width:2px,color:#fff;

    subgraph VIM [Infraestrutura de Virtualização e Containers]
        PVE[Proxmox VE<br/>HP Pavilion]:::hypervisor
        DOCKER[Docker Engine / CasaOS<br/>RPi 4B]:::hypervisor
        NATIVE[Ubuntu Server Nativo<br/>RPi 3Bs]:::hypervisor
    end

    subgraph AAA_SEC [Control Plane: Segurança e IAM]
        FIPA[FreeIPA - LXC]:::coreService
        FRAD[FreeRADIUS - Nativo]:::coreService
        PVE -.-> FIPA
        NATIVE -.-> FRAD
        FRAD -.->|Consulta LDAP| FIPA
    end

    subgraph NET_SERVICES [Data Plane: Serviços de Rede e Storage]
        UNB[Unbound DNS - Docker]:::coreService
        SMB[Samba v2/v3 - Docker]:::coreService
        VPN[VPN Server - Docker]:::coreService
        
        DOCKER -.-> UNB
        DOCKER -.-> SMB
        DOCKER -.-> VPN
    end

    subgraph OSS_MGMT [Management Plane: Observabilidade FCAPS]
        ZPX[Zabbix Proxy]:::oss
        ZA[Zabbix Agents]:::oss
        GRAF_LOKI[Grafana Loki / DNS Collector]:::oss
        
        DOCKER -.-> ZPX
        NATIVE -.-> ZPX
        NATIVE -.-> ZA
    end

    subgraph PUBLIC_CLOUD [Oracle Cloud OCI]
        ZBS[Zabbix Server]:::cloud
        GRAF[Grafana Dashboards]:::cloud
    end

    %% Fluxos de Mediação de Dados
    ZA ==>|Métricas TCP/XXXX| ZPX
    ZPX ==>|Trapper TCP/XXXX| ZBS
    GRAF_LOKI -.->|Logs| GRAF
    ZBS --- GRAF

```
##

Atualmente a topologia da infraestrutura está conforme os diagramas acima:

Temos uma ONT Intelbras 121AC (vinda do meu ISP) configurada em bridge e linkada ao Roteador Mesh TP-Link EX521.

O core principal conta com 2 roteadores TP-Link em mesh, em dois locais diferentes, para uma maior cobertura e estão conectados via Cabo UTP para maior estabilidade, assim como o switch principal é um Switch Gigabit com 8 Portas.

No local 01 possui 3 Raspberry Pi, sendo 2 modelo 3B e uma o modelo 4B com 4GB de memória. Todos com Ubuntu 24.04 LTS como sistema operacional. 

Em uma das Raspberry Pi 3B estou rodando o Zabbix Proxy e na outra possuo o Samba para utilização junto ao OPL para acesso local via rede (como o OPL só tem compatibilidade com o protocolo SMB 1.0 e ele possui diversas vulnerabilidades, esse servidor fica limitado ao acesso local somante e só é ligado nos momentos de utilização).

Na Raspberry Pi 4B estou utilizando o Casa OS (que é basicamente um servidor docker com interface gráfica para gerência).
Nele estou rodando diversos containeres com serviços direcionados ao meu uso pessoal.

No local 02 possuo um notebook HP Pavilion G4 com Proxmox para execução de VMs e Containers LXC e 4 Raspberry Pi 3B onde vou executar mais alguns serviços. 

Possuo também VMs na Oracle Cloud onde armazeno alguns servidores que interagem com minha infraestrutura diretamente.

Nos roteadores e servidores são feitas as configurações necessárias para garantir a segurança e integridade da infraestrutura, tais como redes wifi separadas da principal (para convidados e dispositivos IoT), firewalls e demais medidas necessárias. 

Como não disponho de espaço físico para um rack que centralizaria todos os dispositivos e servidores do homelab, mantenho tudo descentralizados, de acordo com espaço do local e serviços que serão executados. Apesar desse detalhe, os dispositivos são gerenciados dentro da mesma rede local.

##

### 🚀 Implementações Realizadas

#### 🗄️ Hardware e Virtualização
- [x] Raspberry Pi 4B 4GB: Rodando CasaOS que é um ambiente simplificado para gestão de containers Docker
- [x] HP Pavilion G4: Rodando Proxmox VE que é um Hypervisor para gerenciamentos de VMs e cotainers (LXC)
- [x] Raspberry Pi 3B: Possuo algumas rodando o Ubuntu 24.04 LTS com serviços específicos

#### 🤖 Automação e Scripting
##### 🧩 *Shell Script (Bash)*
- [x] Ubuntu Post-Install: Script de automação para configuração e padronização de Desktops e Notebooks
- [x] Update Tool: Script para atualização centralizada (apt, snap, flatpak e pacotes.deb)
- [x] Drive Persistence: Garante a persistência de pontos de montagem de HDs Externos para serviços de rede e OPL
- [x] Smart Shutdown: Script para desligamento inteligente do Host Samba_OPL baseado no estado do PS2

#### 📊 Monitoramento e Serviços
- [x] Zabbix Stack: Servidor principal na OCI com Proxy para monitoramento de rede descentralizado
- [x] Grafana: Dashboards avançadas para visualizações de métricas e saúde do hardware
- [x] Samba server (OPL): Servidor de arquivos dedicado para carregamento de jogos de PS2
- [x] Docker Ecosystem: Diversos microsserviços implementados via Docker
- [x] FreeIPA: Gerenciamento centralizado de identidades, autenticações e políticas

#### 📡 Ativos de Redes (Físicos)
- [x] ONT/Modem: Intelbras - instalado pelo meu ISP
- [x] Roteador Principal/Secundário: 2x TP-Link EX521 - Formando uma rede mesh para maior cobertura
- [X] Substituição do switch principal por um switch Gigabit
- [x] Switch: Overtek OT2808S/W/UX 8 Portas - Onde ligo meus dispositivos que não precisam estar em gigabit
- [x] Roteador TP-Link wr841n com OpenWRT - Onde conecto minhas câmeras IP
##

### 🗓️ Roadmap (Próximos Passos)

#### 🗄️ Hardware e Virtualização
- [ ] Upgrade no HP Pavilion G4
- [ ] Aquisição de um novo hardware (configuração e finalidade a decidir)

#### 🤖 Automação e Scripting
##### 🧩 *Shell Script (Bash)*
- [ ] Automação de Backups dos arquivos de configuração e dump de bancos mais importantes
- [ ] Script de healthcheck e conectividade para o Túnel VPN
- [ ] Script para gerar relatórios do Netbox
- [ ] Script de healthcheck para FreeRADIUS
- [ ] Watchdog de sincronismo do MySQL Master-Master
- [ ] Automação de DNS Blacklist (Pi-hole "Caseiro" com Unbound)
- [ ] Backup de configurações de cada servidor,serviço e banco de dados

##### 💊 *Scripts de Remediação*
- [ ] Zabbix+Proxmox API
- [ ] Zabbix+Genie: Troca automática de canal wi-fi ou reboot remoto

##### 🏗️ *Infraestrutura como Código (IaC) e Configuração*
- [ ] Provisionamento de Microserviços com Terraform: Provisionar uma estrutura completa no proxmox
- [ ] Ciclo de Vida de IPs: Utilizar Terraform como cliente do Netbox consultando IPs disponíveis
- [ ] Configuração "Post-Boot": Conectar SSH com Ansible e instalar os serviços necessários
- [ ] Gestão de template e imutabilidade: Um processo valida e baixa a imagem atual do S.O. e o ansible converte em template
- [ ] Ansible para ACS: Padronização de Provisioning Flows e vparams no GenieACS

##### 🔄 *Orquestração e Gestão*
- [ ] GitOps: Armazenamento dos scripts e playbooks em repositórios (GitHub) para versionamento
- [ ] Rundeck Integration: Orquestrar o ciclo de análise Redis → Gemini API → Ação via Ansible/GenieACS

##### 👁️‍🗨️ *Observabilidade Inteligente (AIOps)*
- [ ] Criar Webhook Zabbix <-> Gemini API para análise de causa raiz (RCA)
- [ ] Implementar enriquecimento de alertas com logs do Grafana Loki
- [ ] Validar sugestões de correção automática via Rundeck no Homelab
- [ ] Dashboard de Telemetria TR-181 no Grafana: Visualização de Sinal/Ruído e CPU dos roteadores via Redis Data Source
- [ ] Análise Preditiva: Usar Gemini para analisar tendências de queda de sinal no Redis antes que o cliente perceba

#### 📊 Monitoramento e Serviços
- [ ] Netbox: Gerenciamento de endereços IP
- [ ] GenieACS: Centralização de acesso e gerenciamento via TR-069/TR-098 ou TR-181
- [ ] Unbound DNS: DNS privado 
- [ ] DNS Colector + Grafana LOKI: Coleta e indexação de logs DNS para análise e observabilidade
- [ ] Redundância de Serviços Essenciais: Criar backup dos serviços principais para caso de falhas
- [ ] Freeradius + MySQL: Autenticação AAA com banco de dados para controle de acesso e accounting
- [ ] Zabbix VAE (Virtual Appliance Edition): Monitoramento de Hardware, SNMP e Integração Nativa com Proxmox
- [ ] Grafana: Criação de dashboards em geral

#### 📡 Ativos de Redes (Físicos)
- [ ] Substituição do TP-Link antigo das câmeras e melhorias no sistema

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
