<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Virtualization%20and%20Workloads/README2.md" target="_blank" rel="noopener noreferrer">🇬🇧 Inglês</a></h6>

# 🗄️ Virtualização e Containerização

### 📝 Descrição

Nessa seção, documento a gestão de recursos computacionais, detalhando como o hardware é particionado para atender as demandas dos serviços.

##

### 🛠️ Hypervisors e Runtimes

- CasaOS: Utilizado no servidor principal. Ele tem uma interface para gerenciamento de containers rodando sob o docker, permitindo assim, facilidade na gestão e instalação de serviços personalizados via docker compose
- Proxmox VE: Hypervisor para rodar máquinas virtuais e containers LXC para alguns serviços
- Ubuntu Server: Para instalação de serviços direta, sem virtualização ou containerização

##

### 🚀 Implementações Técnicas

- Gestão de Recursos: Overprovisioning controlado de CPU e RAM para otimização de custos energéticos
- Storage Persistence: Montagem de volumes Docker via ExFAT/NFS/Samba para garantir persistência de dados fora dos containers

##

### 📂 Estrutura do Diretório
```text
📂 Virtualization & Workloads/
├── 📄 README.md              (Visão geral e inventário de VMs)
├── 📂 setup-guides/          (Pasta com os manuais)
│   ├── PROXMOX_STEP_BY_STEP.md
│   └── DOCKER_DEPLOYMENT.md
└── 📂 templates/             (Arquivos Prontos)
    └── docker-compose-base.yml
```
##
