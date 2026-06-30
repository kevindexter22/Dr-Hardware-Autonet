<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🏡 Bem vindo à Dr. Hardware Autonet

💡 A ideia desse projeto é criar um homelab para evoluir a infraestrutura da minha casa e documentar o desenvolvimento de minhas habilidades em tecnologia ao mesmo tempo, trazendo aprendizagem, experiência e melhorias para o dia a dia.

🔁 Vou compartilhar aqui cada etapa do que estou fazendo, seja algo implementado de fato em meu lab ou alguma tecnologia/solução que testei em laboratório virtualizado, e o motivo por trás de cada uma, assim como, os desafios e problemas com os quais esbarrar e como fiz para resolver (independente do nível de dificuldade).

🗂️ Para uma melhor organização e facilidade de compreensão, esse repositório conta com a seguinte nomenclatura:

```text 
Dr-Hardware-Autonet/
├── 🏠 01-infrastructure/               # INFRAESTRUTURA FÍSICA E LÓGICA (Home Lab)
│   ├── compute-virtualization/         # Hypervisors (Proxmox, ESXi) e Containers (K8s, Docker)
│   ├── network-core/                   # Roteamento, Switching e Serviços Base (DHCP, DNS, BGP, OSPF)
│   └── storage/                        # NAS, SAN, Ceph, etc.
│
├── ⚙️ 02-automation-iac/               # GESTÃO DE CONFIGURAÇÃO E AUTOMAÇÃO (Redução de MTTR)
|   ├── bash-scripts/                   # Scripts customizados
│   ├── docker-compose-stacks/          # Arquivos para provisionamento de serviços em containers docker
│   ├── ansible/                        # Playbooks para provisionamento e gerência de configuração
│   ├── terraform/                      # IaC para provisionamento de recursos
│   └── python-scripts/                 # Scripts customizados 
│
├── 👁️ 03-oss-management/               # SISTEMAS DE SUPORTE À OPERAÇÃO (FCAPS)
│   ├── observability/                  # Métricas (Prometheus, Grafana), Logs (ELK/Loki) e Tracing
│   ├── security-iam/                   # Autenticação, Autorização (Radius, TACACS+, Vault)
│   └── alerts-mediation/               # Regras de alerta, webhooks e mediação de dados
│
├── 🧪 04-labs-rnd/                     # PESQUISA E DESENVOLVIMENTO (Simuladores e PoCs)
│   ├── network-simulations/            # EVE-NG, GNS3, PNETLab, Packet Tracer
│   └── devops-sandboxes/               # Testes isolados de orquestração e CI/CD
│
├── 📖 05-docs/                         # DOCUMENTAÇÃO OFICIAL E ENGENHARIA
│   ├── architecture-diagrams/          # Topologias (L2/L3), fluxos de API e diagramas lógicos
│   ├── runbooks-troubleshooting/       # Guias de mitigação de falhas (SOPs)
|   ├── standards-policies.en.md        # Políticas de IPAM, VLANs e nomenclaturas adotadas (Inglês)
│   └── standards-policies.md           # Políticas de IPAM, VLANs e nomenclaturas adotadas (Português)
│
├── .gitignore                          # Exclusão de arquivos sensíveis (.env, tfstate, etc.)
├── LICENSE                             # Licenciamento do projeto
├── README.md                           # Painel de Controle Principal (Português)
└── README.en.md                        # Painel de Controle Principal (Inglês)
```

😉 "Espero que minha jornada te ajude e inspire a ter novas ideias e a construir seus próprios projetos. Vamos evoluir juntos!"

##

###### ℹ️ Distribuido sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais informações.
