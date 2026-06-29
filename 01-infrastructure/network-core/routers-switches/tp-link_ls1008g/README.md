<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/routers-switches/tp-link_ls1008g/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🖧 Access Switch: TP-Link LS1008G (Não Gerenciável)

### 📝 Descrição do Ativo

O TP-Link LS1008G é um *switch* L2 de acesso não gerenciável de 8 portas. Na arquitetura da minha rede, ele atua puramente como um expansor de densidade de portas físicas (Camada 1 e 2 do Modelo OSI) para conectar nós finais (Hosts/Raspberry Pis/PCs) ao núcleo da rede.

##

### 🗺️ Papel na Topologia Física

* **Localização Física:** `Sala`
* **Uplink (Conexão de Origem):** Conectado à porta `LAN_1` do equipamento `EX521_Controller` via cabo Cat6A.
* **Dispositivos Conectados (Downlinks):**

| Interface (Porta) | Status Físico | Velocidade (Link) | Destino (Conectado a) | Observação |
| :--- | :--- | :--- | :--- | :--- |
| **Porta 1** | `UP` | 1 Gbps | Router EX521 Satellite | Usada para uplink e comunicação com a internet |
| **Porta 2** | `UP` | 1 Gbps | Smart TV Sala | Usada para conexão com a internet |
| **Porta 3** | `UP` | 100 Mbps | Raspberry Pi 3B (ZBX_Proxy/ZBX_Agent) | Usada para transferir métricas ao zabbix server |
| **Porta 4** | `UP` | 1 Gbps | Raspberry Pi 4B (CasaOS Server) | Usada para comunicação de serviços com a internet |
| **Porta 5** | `UP` | 100 Mbps | Raspberry Pi 3B (OPL_Samba_Server) | Usado para virtualização de jogos a partir da rede |
| **Porta 6** | `UP` | 100 Mbps | PlayStation_2_OPL | Usado para comunicação com servidor OPL_Samba |
| **Porta 7** | `UP` | 1 Gbps | PlayStation_4 | Usado para comunicação do console com a internet |
| **Porta 8** | `UP` | 1 Gbps | Vaga | Vaga |

##

### ⚠️ Limitações Arquiteturais e SecOps

Por ser um equipamento *Plug-and-Play* sem plano de controle, aplicam-se as seguintes restrições de arquitetura:

* **Domínio de Broadcast Único (Rede Plana):** O *switch* não suporta a criação de VLANs (IEEE 802.1Q). Todos os dispositivos conectados a ele pertencem ao mesmo domínio de colisão/broadcast imposto pelo roteador/gateway superior.
* **Ausência de Spanning Tree (STP):** Não há proteção contra *Loops* de Camada 2. Uma conexão acidental de um cabo entre duas portas deste *switch* causará um *Broadcast Storm*, derrubando a rede.
* **Ponto Cego de Observabilidade:** Não possui suporte a SNMP, Syslog ou *Port Mirroring* (SPAN). O tráfego L2 intra-switch não pode ser monitorado pelo Zabbix. A telemetria depende estritamente dos agentes instalados nos *hosts* finais (SO).

##

### 🛡️ Mitigação de Riscos

Para compensar a falta de gerência e manter a segurança do laboratório:

* O isolamento de segurança (*Firewall/ACL*) de todos os nós conectados a este *switch* é feito **exclusivamente pelos *firewalls* de host (UFW)** ou pelo gateway principal (Edge Router) antes do tráfego descer para o *switch*.
* Cabos e portas devem estar fisicamente organizados e etiquetados para evitar *loops* acidentais por erro humano durante manutenções.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
