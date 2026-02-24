<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/README2.md" target="_blank" rel="noopener noreferrer">🇬🇧 Inglês</a></h6>

# 🏠 Infraestrutura

### 📝 Descrição

O objetivo principal desse diretório é trazer todas as informações ligadas à estrutura física, dispositivos/hardwares e serviços voltados ao meu homelab.

Trarei aqui a visão do que está sendo implementado, assim como um pouco da base teórica, finalidade da implementação, arquivos de configuração/scripts e problemas com suas possíveis soluções realizados ao longo do tempo.
##

### 🏗️ Topologia / Arquitetura

##

### 🚀 Implementações Realizadas

#### 🗄️ Hardware e Virtualização
- [x] Raspberry Pi 4B 4GB: Rodando CasaOS que é um ambiente simplificado para gestão de containers Docker
- [x] HP Pavilion G4: Proxmox VE que é um Hypervisor para gerenciamentos de máquinas virtuais e cotainers (LXC)
- [x] Raspberry Pi 3B: Possuo algumas rodando o Ubuntu 24.04 LTS com serviços específicos

#### 📊 Monitoramento e Serviços
- [x] Zabbix Stack: Servidor principal com Proxy para mnitoramento de rede descentralizado
- [x] Grafana: Dashboards avançadas para visualizações de métricas e saúde do hardware
- [x] Samba server (OPL): Servidor de arquivos dedicado para carregamento de jogos de PS2
- [x] Docker Ecosystem: Diversos microsserviços implementados via Docker

#### 📡 Ativos de Redes (Físicos)
- [x] ONT/Modem: Intelbras - instalado pelo meu ISP
- [x] Roteador Principal/Secundário: 2x Huawei WS5800 - Formando uma rede mesh para maior cobertura
- [x] Switch: Overtek OT2808S/W/UX 8 Portas - Onde ligo meus dispositivos que não precisam estar em gigabit
- [x] Roteador TP-Link wr-841n com OpenWRT - Onde conecto minhas câmeras IP
##

### 🗓️ Roadmap (Próximos Passos)
- [ ] FreeIPA
- [ ] Prometheus
- [ ] Pi-hole + Unbound DNS
- [ ] DNS Colector + Grafana LOKI
- [ ] Freeradius + MySQL (Docker+Cloud - Redundância)
- [ ] Redundância de Serviços Essenciais 
##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
