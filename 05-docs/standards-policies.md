<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/05-docs/standards-policies.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 📖 Documento Central de Governança e Padrões

### 📝 Descrição do Escopo

Este documento atua como a **Fonte da Verdade para Governança (Policy Management)** do ecossistema Dr. Hardware Autonet. Ele define as regras sistêmicas de arquitetura, segurança e nomenclatura que toda infraestrutura física, lógica ou código de automação deve obedecer, garantindo o alinhamento com o framework OSS (FCAPS).

##

### 🏷️ 1. Padrões de Nomenclatura de Ativos (Naming Convention)

Define a taxonomia rigorosa para facilitar a descoberta de serviços, inventário no Zabbix e automação via *scripts*.

| Categoria | Padrão de Nomenclatura | Exemplo Prático |
| :--- | :--- | :--- |
| **Elementos de Rede (L1/L2/L3)** | `[TIPO]-[MODELO]-[FUNÇÃO]` | `Router-EX521-Controller` ou `Switch-LS1008G-Access` |
| **Redes Sem Fio (WLAN)** | Focado na finalidade, não no hardware | `Core`, `IoT`, `Guest` |
| **Artefatos de Backup (Configs)** | `config-backup-[NODE]-[DATE].[EXT]` | `config-backup-controller-20260625.bin` |
| **Servidores / LXC / VMs** | `[FUNÇÃO]-[SO/APP]-[AMBIENTE]` | `IAM-FreeIPA-Prod` ou `Storage-Samba-OPL` |

##

### 🗺️ 2. Política de Endereçamento e Segmentação (IPAM)

Estabelece a lógica de roteamento (Camada 3) e contenção de domínios de *broadcast*.

* **Alocação Estática (DHCP Reservations / Static IPs):** Obrigatória para a Camada de Gerência (*Management Plane*), hipervisores, infraestrutura de identidade (FreeIPA | FreeRadius) e instâncias mapeadas por DNAT ou UPnP.
* **Segmentação Lógica (Sub-redes):** O laboratório opera com blocos CIDR distintos para a rede primária, rede de CFTV/Câmeras (WR850N) e segmentos Fast Ethernet, isolando os domínios de colisão e *broadcast*.
* **Gestão de IPAM:** Todo novo IP estático designado deve ser documentado e reservado na base central antes do provisionamento da máquina ou contêiner.

##

### 🛡️ 3. Políticas de Segurança de Rede (SecOps / L4-L7)

Diretrizes arquiteturais para proteção do perímetro físico e lógico contra movimentos laterais e invasões.

* **Superfície de Borda (WAN):** Adoção estrita de *Default Deny* no *Firewall* da borda. Nenhuma porta deve ser exposta sem justificativa técnica pré-aprovada.
* **Isolamento Inter-VLAN (WLAN):** O tráfego de dispositivos da rede `IoT` e `Guest` (*AP Isolation* ativo) possui roteamento bloqueado em nível de *Gateway* para o plano de Administração/Core.
* **Gestão de UPnP (Gaming):** A negociação dinâmica de portas é permitida exclusivamente para otimização de latência em consoles. É estritamente proibida a negociação dinâmica para portas de gerência (ex: TCP 22, 80, 443, 3389).
* **Controle de Protocolos Legados (TR-069):** Agentes CWMP de provedores externos devem permanecer `DESATIVADOS`. A porta de gerência remota L7 será ativada apenas para instâncias de automação interna proprietária.

##

### 🔌 4. Padrões de Topologia Física (Physical Layer)

Regras de resiliência e mitigação de falhas em *hardware* de Camada 1 e 2.

* **Padronização de Enlaces:** *Uplinks* e *Backhauls* cabeados devem utilizar exclusivamente cabeamento estruturado Cat5e ou superior, compatível com Gigabit Ethernet.
* **Prevenção de Loops (Switches Não Gerenciáveis):** Portas de interfaces não alocadas (*Port Allocation*) em equipamentos *Plug-and-Play* devem permanecer fisicamente isoladas (sem cabos conectados soltos) para evitar tempestades de *broadcast*.
* **Documentação Visual:** Todas as conexões físicas críticas de *Uplink* devem estar fisicamente etiquetadas nas duas extremidades do cabo.

##

### ⚙️ 5. Gestão de Mudança e Consistência (Configuration Management)

Garante que o estado atual da infraestrutura não desvie da arquitetura projetada (*Configuration Drift*).

* **Sincronização Lógica de Cluster Mesh:** Alterações de estado nas ACLs do nó *Controller* requerem propagação manual ou automatizada imediata para o nó *Satellite*, garantindo a simetria da segurança de borda.
* **Ciclo de Auditoria Ativa:** Mandatória a inspeção mensal de *logs* de roteamento no Gateway principal, focada em validar o ciclo de vida das portas abertas via UPnP e a detecção de anomalias ou ataques de *Flood*.
* **Infraestrutura como Código (IaC):** Alterações de configuração em servidores Linux (Day 2) devem priorizar a execução via *Playbooks* do Ansible em detrimento de comandos manuais via SSH, garantindo a idempotência.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
