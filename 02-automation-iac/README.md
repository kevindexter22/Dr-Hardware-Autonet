<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/02-automation-iac/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# ⚙️ Automação & IaC (Infraestrutura como Código)

### 📝 Descrição do Domínio

Este diretório atua como o **Motor de Automação e Orquestração** do laboratório. O objetivo desta camada é transformar tarefas operacionais manuais (cliques e digitação de comandos) em código versionado, testável e repetível (GitOps).

Aqui residem as ferramentas responsáveis por provisionar recursos, aplicar configurações de base (*baselines*) em massa e orquestrar as aplicações de uso final (Workloads) que rodam sobre a infraestrutura.

##

### 🏗️ Arquitetura de Domínios

#### 📦 1. Docker Workloads (`docker-workloads/`)
Responsável pela **Orquestração de Aplicações Finais (VAS - Value-Added Services)**.
* Diferente da infraestrutura crítica, esta pasta abriga os manifestos (`docker-compose.yaml`) de aplicações para o usuário final, como servidores de mídia, blocos de anotações (Trilium) e plataformas de automação pessoal (N8N). Eles rodam *sobre* a infraestrutura, sendo facilmente destruídos e recriados.

#### 🐚 2. Bash / Shell Scripts (`bash-scripts/`)
Responsável pela **Automação Imperativa e Rotinas de SO**.
* Abriga *scripts* para tarefas de sistema operacional, automação de montagem de discos, rotinas de *backup* locais e pequenos *jobs* agendados (Cron) para manutenção da saúde dos nós Linux.

##

### 🚧 Roadmap de Maturidade IaC (Planejado)

As tecnologias abaixo compõem o estado futuro (*To-Be*) da arquitetura do laboratório para substituir gradativamente os *scripts* imperativos por declarações de estado.

* **[⏳ PLANEJADO] Ansible (`ansible/`):** Para **Gerência de Configuração**. Conterá os *Playbooks* para garantir o estado desejado dos servidores (ex: aplicação de *Hardening* de SO, injeção de chaves SSH e instalação de pacotes base em massa).
* **[⏳ PLANEJADO] Terraform (`terraform/`):** Para **Provisionamento Declarativo**. Contonterá os manifestos utilizados para provisionar recursos computacionais imutáveis (ex: criação automatizada de Máquinas Virtuais no Proxmox).
* **[⏳ PLANEJADO] Python Scripts (`python-scripts/`):** Para **Automação de Redes L2-L7, Interoperabilidade e Mediação (ETL)**. Focado na interação programática via APIs (REST/RESTCONF/NETCONF) e bibliotecas de engenharia de redes (Netmiko/NAPALM/Nornir). Atuará na coleta de telemetria, execução de *runbooks* de *troubleshooting* automatizado e integração nativa entre as plataformas do *Management Plane* (OSS).

##

### 🧠 Princípios Arquiteturais (SRE)

Todo código inserido neste diretório deve buscar aderir aos seguintes princípios:
* **Idempotência:** Executar um *script* ou *playbook* uma ou mil vezes deve resultar exatamente no mesmo estado final do sistema, sem causar quebras ou duplicações.
* **Declarativo sobre Imperativo:** Sempre que possível, declare o estado final que você deseja (IaC) em vez de escrever o passo a passo de como chegar lá.
* **Zero Servidores Floco de Neve (*Snowflake Servers*):** Nenhum servidor deve ser configurado manualmente de forma única. Tudo deve ser reconstruível a partir deste repositório.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
