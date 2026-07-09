# 🌐 DNS Stack (Unbound, HA & Telemetry)

### 📝 Descrição da Arquitetura

Este diretório documenta a arquitetura, implantação e operação da Stack de DNS Recursivo Interno. O ambiente foi desenhado para atuar como a infraestrutura crítica de resolução de nomes corporativa, garantindo baixa latência, resiliência contra falhas e visibilidade profunda de tráfego.

O núcleo de resolução é provido pelo Unbound (suportando *deployments via Docker ou LXC*), atuando como *caching resolver* com validação DNSSEC. 

Para garantir a continuidade do serviço, implementamos uma camada de Alta Disponibilidade (HA) utilizando Keepalived para gestão de IP Virtual (VIP - protocolo VRRP) e Nginx operando como Stream Proxy (Layer 4) entre as instâncias do Unbound. 

O ecossistema é complementado por uma robusta esteira de telemetria baseada em DNS Collector e Loki, permitindo a retenção de logs estruturados e a análise de tráfego para fins de segurança e troubleshooting avançado.

##

### 🏗️ Alinhamento Operacional (FCAPS)

A operação desta stack consolida as estratégias de Gerência de Redes corporativa e frameworks de OSS:

   * **F (Fault Management) & Redução de MTTR:** O uso do Keepalived (VRRP) abstrai falhas de hardware ou SO do cliente final, transferindo o VIP instantaneamente em caso de queda. O envio de logs estruturados para o Loki elimina o *troubleshooting* descentralizado, permitindo que a equipe de operações identifique rapidamente códigos de erro (como `SERVFAIL` ou `NXDOMAIN`) através de painéis centralizados.

   * **C (Configuration Management):** Suporte nativo a infraestruturas imutáveis e provisionamento padronizado, oferecendo flexibilidade de execução do Unbound tanto em isolamento a nível de aplicação (Docker) quanto de sistema (LXC).

   * **P (Performance Management):** O mecanismo de cache agressivo do Unbound otimiza a latência das consultas locais e reduz a carga sobre upstream resolvers públicos. A arquitetura de tráfego foi refinada via testes de laboratório para priorizar o menor tempo de resposta possível.

   * **S (Security Management):** A arquitetura reforça a postura de segurança operacional (SecOps) de duas maneiras: validando a integridade das zonas via DNSSEC e provendo retenção de logs (via DNS-Collector) para auditoria forense, permitindo a identificação precoce de anomalias, tráfego de botnets ou exfiltração de dados via DNS.

##

### 🖧 Topologia Lógica (OSI Layer 3-7)

| Componente	| Função Lógica	| Comunicação	| Protocolos / Camada OSI |
| Keepalived (VIP)	| Redundância de Gateway	| Client -> VIP	VRRP | (IP/Layer 3) |
| Nginx (Stream Proxy)	| Balanceamento de Carga	| VIP -> Nginx -> Unbound	| UDP/TCP 53 (Layer 4) |
| Unbound (Resolver)	| Resolução e Cache	| Nginx <- Unbound -> Upstream	DNS | (Layer 7) / UDP 53 |
| DNS-Collector	| Captura e Parsing de Tráfego	| Unbound -> Collector	| PCAP / DNSTap (Layer 7) |
| Loki	| Retenção de Logs (Observabilidade)	| Collector -> Loki	| HTTP/REST TCP 3100 (Layer 7) |

##

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Para proteger a infraestrutura de resolução e telemetria:

  1. **Regras de Ingress (Firewall):** Os nós que hospedam o VIP/Nginx devem permitir tráfego irrestrito de clientes corporativos exclusivamente nas portas `UDP 53` e `TCP 53`. Consultas externas (da WAN) devem ser bloqueadas para evitar ataques de amplificação/reflexão DNS.

  2. **Segurança Inter-nós:** O tráfego VRRP (Multicast `224.0.0.18` ou Unicast) gerado pelo Keepalived deve ser permitido apenas entre os nós que compõem o cluster de HA.

##

### ⚖️ Escalabilidade e Resiliência (High Availability)

A topologia foi refinada com base em métricas reais de desempenho e resiliência ponta a ponta:

  * **Evolução do Design de Proxy (Lessons Learned):** A arquitetura original previa a utilização do Nginx para realizar o balanceamento de carga ativo (*Round Robin*) entre múltiplos backends do Unbound. No entanto, testes de estresse em laboratório evidenciaram que o *overhead* de roteamento e inspeção multicaminho na camada de transporte (Layer 4) inseria uma latência inaceitável nas requisições UDP. Para mitigar esse gargalo, o roteamento foi alterado para um modelo de *Failover Direto* (Active-Standby estrito). O tráfego agora flui sem divisão de pacotes, privilegiando a velocidade de resposta absoluta.

  * **Frontend Resiliente (VRRP):** O Keepalived garante a continuidade de negócio na camada 3. Se o nó primário sofrer interrupção, o nó secundário assume o VIP em milissegundos, mascarando a falha para as aplicações clientes.

  * **Desacoplamento de Computação:** A padronização via contêineres garante que eventuais migrações de host físico ou recuperação de desastres (DR) ocorram com o mínimo de fricção operacional.

##

### 🛠️ Procedimentos Operacionais

Para implantação do ambiente, gestão de falhas e manutenção evolutiva, consulte os procedimentos documentados de cada módulo:

   * 👉 [SOP: Configuração de Alta Disponibilidade (Nginx Proxy + Keepalived)](#)

   * 👉 [SOP: Instalação e Configuração do Unbound via Docker](#)

   * 👉 [SOP: Instalação e Configuração do Unbound via LXC](#)

   * 👉 [SOP: Coleta de Telemetria DNS com DNS-Collector e Loki](#)

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
