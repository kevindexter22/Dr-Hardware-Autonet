<h6 align="right">Read this page in <a href="./README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🕵️ Zabbix Agents (Data Collection Nodes)

### 📝 Descrição do Escopo

Este diretório consolida os Procedimentos Operacionais Padrão (SOPs) para a implantação dos agentes de coleta do Zabbix. Na arquitetura de monitoramento, o Agente é a peça fundamental para as camadas de **Fault Management** e **Performance Management**, sendo responsável por extrair telemetria do Sistema Operacional e das aplicações e enviá-las ao Zabbix Proxy ou Server.

Atualmente, o ecossistema Zabbix oferece duas versões de agentes. A escolha entre eles deve ser baseada nos requisitos do *workload* hospedado no nó.

##

### ⚖️ Análise de Arquitetura: Agent (Clássico) vs. Agent 2

A principal diferença arquitetural reside na linguagem de programação e na forma como lidam com a concorrência e persistência de dados.

| Recurso | 🟦 Zabbix Agent (Clássico) | 🟩 Zabbix Agent 2 |
| :--- | :--- | :--- |
| **Linguagem Base** | `C` | `Go` (Golang) + `C` |
| **Concorrência** | Múltiplos processos (Daemon) | *Multithreading* nativo |
| **Extensibilidade** | *UserParameters* e *Loadable Modules* | *Plugins* nativos desenvolvidos em Go |
| **Conexões Persistentes** | ❌ Não  | ✅ Sim |
| **Agendamento de Coleta** | Fixo (baseado em intervalos) | Dinâmico e agendado pelo próprio plugin |
| **Uso de Recursos Base** | Extremamente baixo | Levemente maior no *boot*, mas escala melhor |

##

### 🎯 Matriz de Decisão: Quando usar cada um?

A adoção não precisa ser excludente. O Zabbix Agent 2 é um *drop-in replacement* (substituto direto) para o Agente clássico, o que significa que ambos suportam as mesmas chaves de sistema base. No entanto, siga estas diretrizes:

#### 🟩 Opte pelo **Zabbix Agent 2** (Padrão Recomendado)
* **Workloads Modernos e Bancos de Dados:** Sempre que o host executar PostgreSQL, MySQL, MongoDB, Redis, Docker, certificados SSL, ou serviços web. 
* **Por quê?** O Agent 2 suporta *Stateful Checks*. Em vez de abrir e fechar uma conexão TCP com o banco de dados a cada 30 segundos (gerando alto *overhead*), o Agent 2 mantém a conexão aberta no nível do *plugin*, otimizando radicalmente a performance.

#### 🟦 Opte pelo **Zabbix Agent (Clássico)**
* **Sistemas Legados ou IoT Extremo:** Quando o SO do hardware for antigo, não suportar binários compilados em Go, ou tiver restrições severas de memória RAM (ex: roteadores customizados, hardwares de automação industrial com < 256MB RAM).
* **Por quê?** O agente em C puro tem um *footprint* de memória estático e quase invisível para o sistema operacional.

##

### 📡 Topologia de Comunicação (Active vs. Passive)

Ambos os agentes suportam dois modelos de comunicação, ajustáveis via arquivo de configuração:

* **Modo Passivo (Polling):** O Zabbix Server/Proxy inicia a conexão `TCP 10050` solicitando os dados. O agente apenas ouve e responde.
* **Modo Ativo (Trapping):** O Agente inicia a conexão `TCP 10051` com o Server/Proxy, solicita a lista de itens que precisa monitorar e envia os dados periodicamente. **É o padrão recomendado** para reduzir gargalos de rede e superar cenários com NAT/Firewall.

##

### 🛠️ Procedimentos Operacionais (Runbooks)

Escolha o manual de provisionamento adequado para a sua máquina alvo:

* 👉 **[SOP: Instalação do Zabbix Agent 2 (Recomendado)](./zabbix_agent_2_setup.md)**
* 👉 **[SOP: Instalação do Zabbix Agent Clássico (Legado/Leve)](./zabbix_agent_setup.md)**

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
