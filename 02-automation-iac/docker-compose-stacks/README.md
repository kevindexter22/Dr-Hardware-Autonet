<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/02-automation-iac/docker-compose-stacks/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🐳 Docker Compose Stacks (Workloads & IaC)

### 📝 Descrição da Arquitetura

Este diretório atua como o repositório central de **Infraestrutura como Código (IaC)** para as aplicações conteinerizadas da nossa arquitetura (*Workloads*). 

Utilizamos o Docker Compose para o provisionamento declarativo de serviços, garantindo a padronização, reprodutibilidade e rápida recriação de ambientes em cenários de *Disaster Recovery*.

O modelo arquitetural baseia-se no **desacoplamento estrito** entre a camada de computação (contêineres efêmeros) e a camada de persistência de dados (*named volumes* e *bind mounts*). Isso garante que atualizações de imagem ou recriações de *stacks* ocorram com zero perda de estado ou de informações de configuração.

##

### 🏗️ Alinhamento Operacional (FCAPS)

A gestão dos contêineres segue as disciplinas de operações estruturadas:

* **F (Fault Management) & MTTR:** Redução do Tempo Médio de Recuperação através de políticas de autorrecuperação (ex: `restart: unless-stopped`) e implementação de *Healthchecks* nativos. O *daemon* do Docker atua como supervisor, reiniciando instâncias degradadas automaticamente sem intervenção humana (L0 Automation).
* **C (Configuration Management):** Transição para o paradigma *GitOps*. O arquivo `docker-compose.yml` é a Fonte Única da Verdade (*Single Source of Truth*) para a topologia da aplicação, declarando versões exatas de imagens (tags), variáveis de ambiente e dependências estruturais.
* **P (Performance Management):** Capacidade de aplicar limites restritivos de recursos (*cgroups* - CPU e RAM) por serviço, prevenindo que picos de processamento em uma *stack* (como transcodificação no Emby) causem contenção de recursos (*noisy neighbor*) para aplicações críticas de gerência.

##

### 🖧 Topologia Lógica (OSI Layer 2-7)

| Componente | Função Lógica | Escopo de Tráfego | Protocolos / Camada OSI |
| :--- | :--- | :--- | :--- |
| **Docker Engine** | Container Runtime | `Host <-> Container` | IPC / Kernel Namespaces |
| **User-Defined Bridge** | Microsegmentação (Rede Privada) | `East-West` (Interno) | Virtual L2 / IPv4 (Layer 3) |
| **Exposed Ports (NAT)** | Ingress (Mapeamento de Portas) | `North-South` (Externo) | TCP/UDP (Layer 4) |
| **Workloads (Serviços)**| Aplicação e APIs | `Client -> Proxy -> App`| HTTP/HTTPS (Layer 7) |

##

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Diretrizes arquiteturais obrigatórias para qualquer *stack* implantada neste diretório:

1.  **Isolamento de Rede (Microsegmentação):** Cada *stack* deve ser provisionada em sua própria rede virtual (*bridge* customizada). O tráfego inter-stack não deve ocorrer livremente. Se o `n8n` precisar acessar o `cloudbeaver`, essa comunicação deve ser explicitamente declarada.
2.  **Gestão de Segredos:** É estritamente proibido o *hardcode* de senhas, tokens de API ou chaves criptográficas nos arquivos `docker-compose.yml`. Todas as credenciais devem ser injetadas via arquivos `.env` (ignorados pelo `.gitignore`) ou utilizando Docker Secrets.
3.  **Superfície de Ataque (Ports):** Evitar o uso irrestrito de `network_mode: host`. As portas expostas devem ser limitadas e, idealmente, vinculadas apenas ao *loopback* (`127.0.0.1:PORTA:PORTA`) para que o tráfego externo transite obrigatoriamente por um *Reverse Proxy* (Ingress Controller) para terminação TLS.
4.  **Privilégios Mínimos:** Sempre que suportado pela imagem base, executar o contêiner com um usuário não-root (diretiva `user: UID:GID`) e evitar a flag `privileged: true`.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
