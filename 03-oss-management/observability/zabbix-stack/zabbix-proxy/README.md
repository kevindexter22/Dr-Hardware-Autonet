<h6 align="right">Read this page in <a href="./README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 👁️ Zabbix Proxy

### 📝 Descrição da Arquitetura
Este diretório documenta a arquitetura e a implantação do **Zabbix Proxy**, operando como um nó de coleta distribuída (*Edge Computing*) em hardware ARM64 (Raspberry Pi). 

O proxy atua como um mediador de dados de telemetria entre a rede interna (LAN) e o nó centralizador (Zabbix Server) provisionado na nuvem. Esta topologia reduz a sobrecarga de conexões na WAN, otimiza o *polling* local e garante resiliência na coleta de métricas em cenários de instabilidade no link de internet.

---

### 🏗️ Alinhamento Operacional (FCAPS)

A introdução deste componente na infraestrutura atende diretamente aos pilares de Gerência de Redes:

*   **F (Fault Management):** Implementa o modelo *Store-and-Forward*. Em caso de indisponibilidade da WAN ou do servidor central, o banco de dados local (SQLite3) atua como *buffer*, armazenando métricas e eventos críticos para posterior sincronização, mitigando a perda de visibilidade e reduzindo o MTTR.
*   **C (Configuration Management):** Centraliza o apontamento dos agentes locais. Dispositivos da LAN (roteadores, switches, servidores) reportam para o IP local do Proxy, unificando a superfície de gerência.
*   **P (Performance Management):** Reduz a latência de coleta (ICMP/SNMP/Traps) ao realizar o *polling* na camada 2/3 localmente, transferindo para a nuvem apenas dados consolidados e comprimidos.

---

### 🖧 Topologia Lógica (OSI Layer 4-7)

| Componente | Função Lógica | Comunicação | Protocolos |
| :--- | :--- | :--- | :--- |
| **Zabbix Proxy (ARM64)** | Mediação / Cache (SQLite3) | `Proxy -> Server` | TCP 10051 (Active Proxy Mode) |
| **Zabbix Server (Cloud)** | Processamento / Alertas | `Server <- Proxy` | TCP 10051 (Zabbix Trapper) |

---

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Para garantir a integridade da comunicação e isolamento da infraestrutura:

1.  **Firewall (Borda):** Apenas o tráfego de saída (Egress) na porta `TCP 10051` é necessário no modo *Active Proxy*. Nenhuma regra de *Inbound* (NAT/Port Forwarding) deve ser exposta na WAN para este serviço.

---

### 🛠️ Procedimentos Operacionais (Runbooks)

Para provisionamento *Bare-Metal* ou *Troubleshooting* deste nó de infraestrutura, consulte os Procedimentos Operacionais Padrão (SOPs) abaixo:

*   👉 **[SOP: Instalação e Configuração do Zabbix Proxy (Ubuntu/ARM64)](./zabbix_proxy_setup.md)**

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
