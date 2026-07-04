<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-server/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🧠 Zabbix Server

### 📝 Descrição da Arquitetura
Este diretório documenta a arquitetura, implantação e o papel central do **Zabbix Server**, provisionado em nuvem (instância ARM64). Ele atua como o núcleo de inteligência e consolidação de dados de toda a nossa infraestrutura de telemetria.

Enquanto os Proxies operam nas bordas coletando dados brutos, o Server é o motor de correlação responsável por avaliar as métricas contra as *triggers* (regras de negócio), armazenar o histórico no banco de dados relacional (MySQL/MariaDB) e orquestrar a notificação de incidentes. Esta centralização é o pilar fundamental para garantir a governança de TI e minimizar o Tempo Médio de Recuperação (MTTR) em toda a infraestrutura híbrida.

##

### 🏗️ Alinhamento Operacional (FCAPS)

A operação do servidor central consolida as estratégias de Gerência de Redes corporativa:

* **F (Fault Management) & Redução de MTTR:** Transforma dados em ações. Ao receber telemetria dos Proxies, o Server identifica anomalias em tempo real e despacha alertas precisos. Isso elimina o tempo de adivinhação (*troubleshooting* cego), direcionando a equipe para a causa raiz imediata e cortando drasticamente o ciclo de vida do incidente (MTTR).
* **C (Configuration Management):** Atua como a fonte única da verdade (*Single Source of Truth*). Todo o provisionamento de *templates*, regras de *Discovery* (LLD) e perfis de monitoramento é configurado aqui e distribuído para os nós da borda de forma hierárquica.
* **P (Performance Management):** Mantém o histórico de longo prazo consolidado. Isso permite a criação de *baselines* de comportamento da rede e projeções de *Capacity Planning*, evitando que gargalos computacionais se tornem incidentes ativos.

##

### 🖧 Topologia Lógica (OSI Layer 4-7)

| Componente | Função Lógica | Comunicação | Protocolos |
| :--- | :--- | :--- | :--- |
| **Zabbix Server (Processo Core)** | Processamento / Alertas | `Server <- Proxy` | TCP 10051 (Zabbix Trapper) |
| **Banco de Dados (MySQL/MariaDB)** | Armazenamento / Retenção | `Server <-> DB` | TCP 3306 (Local Socket/TCP) |
| **Zabbix Web (Apache + SSL)** | Gerência / Visualização | `Admin -> Web` | TCP 443 (HTTPS) |

##

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Para proteger o núcleo da infraestrutura na nuvem:

1.  **Firewall de Entrada (Ingress):** O acesso à porta `TCP 10051` deve ser restrito (via *Security Lists* da nuvem ou UFW) preferencialmente aos IPs públicos conhecidos dos Zabbix Proxies.
2.  **Acesso Administrativo:** A interface web trafega obrigatoriamente sob criptografia SSL/TLS (`TCP 443`), gerenciada pelo *Reverse Proxy* (Apache).
3.  **Isolamento de Dados:** A comunicação com o banco de dados ocorre estritamente em ambiente local, sem exposição de portas para a WAN.

##

### ⚖️ Escalabilidade e Resiliência (High Availability)

O Zabbix Server foi desenhado para suportar o crescimento da infraestrutura, garantindo que o monitoramento não se torne um gargalo:

* **Clusterização Nativa (Zabbix HA):** Permite a configuração de múltiplos nós do Zabbix Server em modo *Active-Standby*. Se o processo principal falhar durante uma atualização de kernel ou reinício, o nó secundário assume o processamento instantaneamente, garantindo a continuidade do cálculo de *triggers*.
* **Desacoplamento de Serviços:** A arquitetura permite que o Banco de Dados, o Servidor Web e o Processo Core sejam separados em instâncias distintas no futuro, distribuindo a carga de I/O e CPU caso o volume de requisições exija maior *throughput*.

##

### 🛠️ Procedimentos Operacionais (Runbooks)

Para rotinas de manutenção, atualização de pacotes ou *troubleshooting* do núcleo do Zabbix, consulte os procedimentos abaixo:

* 👉 **[SOP: Instalação e Configuração do Zabbix Server e Apache (Ubuntu/ARM64)](./zabbix_server_setup.md)**

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
