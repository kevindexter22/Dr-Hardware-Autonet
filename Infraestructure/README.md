<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/README2.md" target="_blank" rel="noopener noreferrer">🇬🇧 Inglês</a></h6>

# 🏠 Infraestrutura

### 📝 Descrição

O objetivo principal desse diretório é trazer todas as informações ligadas à estrutura física, dispositivos/hardwares e serviços voltados ao meu homelab.

Trarei aqui a visão do que está sendo implementado, assim como um pouco da base teórica, finalidade da implementação, arquivos de configuração/scripts e problemas com suas possíveis soluções realizados ao longo do tempo.
##

### 🏗️ Topologia / Arquitetura
```mermaid

```


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

#### 📡 Ativos de Redes (Físicos)
- [x] ONT/Modem: Intelbras - instalado pelo meu ISP
- [x] Roteador Principal/Secundário: 2x Huawei WS5800 - Formando uma rede mesh para maior cobertura
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
- [ ] Script para gerar relatórios do PHPIPAM
- [ ] Script de healthcheck para FreeRADIUS
- [ ] Watchdog de sincronismo do MySQL Master-Master
- [ ] Automação de DNS Blacklist (Pi-hole "Caseiro" com Unbound)

##### 💊 *Scripts de Remediação*
- [ ] Zabbix+Proxmox API
- [ ] Zabbix+Genie: Troca automática de canal wi-fi ou reboot remoto

##### 🏗️ *Infraestrutura como Código (IaC) e Configuração*
- [ ] Provisionamento de Microserviços com Terraform: Provisionar uma estrutura completa no proxmox
- [ ] Ciclo de Vida de IPs: Utilizar Terraform como cliente do phpIPAM consultando IPs disponíveis
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
- [ ] PHPIPAM: Gerenciamento de endereços IP
- [ ] GenieACS: Centralização de acesso e gerenciamento via TR-069/TR-098 ou TR-181
- [ ] FreeIPA: Gerenciamento centralizado de identidades, autenticações e políticas
- [ ] Prometheus: Monitoramento e coleta de métricas com alertas em tempo real
- [ ] Pi-hole + Unbound DNS: DNS privado com bloqueio de anúncios e rastreadores
- [ ] DNS Colector + Grafana LOKI: Coleta e indexação de logs DNS para análise e observabilidade
- [ ] Redundância de Serviços Essenciais: Criar backup dos serviços principais para caso de falhas
- [ ] Freeradius + MySQL: Autenticação AAA com banco de dados para controle de acesso e accounting
- [ ] Zabbix VAE (Virtual Appliance Edition): Monitoramento de Hardware, SNMP e Integração Nativa com Proxmox
- [ ] Grafana: Criação de dashboards em geral

#### 📡 Ativos de Redes (Físicos)
- [ ] Substituição/atualização dos Roteadores Principal/Secundário
- [ ] Substituição do switch atual por um switch Gigabit
- [ ] Substituição do TP-Link antigo das câmeras e melhorias no sistema
##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
