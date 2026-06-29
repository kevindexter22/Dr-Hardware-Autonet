<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🗄️ Computação & Virtualização

### 📝 Descrição

Nesta seção, documento o inventário e a gestão de recursos computacionais do laboratório (NFVI), detalhando o hardware físico e a camada de virtualização/orquestração (VIM) responsável por particionar e entregar os recursos aos serviços.

---

### 💻 Inventário de Hardware (Resource Pool)

| Dispositivo | Função Principal | CPU / Arquitetura | RAM | Storage | Conectividade (Rede) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HP Pavilion G4-1270BR** | Hypervisor Core | Core i5 3rd Gen (Dual 2.5GHz) | 8 GB DDR3 | 480 GB SSD + 750 GB HDD | Gigabit Ethernet (via adaptador/integrada) |
| **Raspberry Pi 4B** | Container Host Edge | Cortex-A72 Quad-core (ARMv8 64-bit) | 4 GB LPDDR4 | 64 GB Micro-SD | Gigabit Ethernet, Wi-Fi 5 |
| **Raspberry Pi 3B (x4)** | Micro-Serviços / Node | Cortex-A53 Quad-core (ARMv8 64-bit) | 1 GB LPDDR2 | 16/32 GB Micro-SD | Fast Ethernet (10/100), Wi-Fi 4 |

---

### 🛠️ Hypervisors e Runtimes (VIM / CaaS)

*   **CasaOS (RPi 4B):** Atua como o orquestrador principal de contêineres na borda. Fornece uma interface simplificada sobre o Docker Engine, agilizando a gestão e implantação de microsserviços via `docker-compose`.
*   **Proxmox VE (HP Pavilion):** Hypervisor Bare-Metal responsável por isolar e gerenciar Máquinas Virtuais (VMs) e Contêineres de Sistema (LXC) para os serviços de infraestrutura mais pesados.
*   **Ubuntu Server (Bare-Metal):** Sistema Operacional base adotado nativamente nas instâncias de Raspberry Pi 3B para execução direta de serviços com menor overhead (sem camada de virtualização).

---

### 🚀 Políticas e Implementações Técnicas

*   **Gestão de Recursos (Capacity Management):** Aplicação de *overprovisioning* controlado de vCPUs e RAM no Proxmox para maximizar a densidade de serviços e otimizar os custos energéticos do hardware legado.
*   **Storage Persistence:** Padronização da montagem de volumes para o ecossistema Docker, utilizando ExFAT, NFS ou SMB, garantindo a persistência e a integridade dos dados operacionais fora do ciclo de vida dos contêineres.

---

### 📂 Estrutura do Diretório

```text
01-infrastructure/compute-virtualization/
├── 📄 README.md              # Visão Geral e Inventário de Hardware (Português)
├── 📄 README.en.md           # Visão Geral e Inventário de Hardware (Inglês)
├── 📂 setup-guides/          # Procedimentos Operacionais Padrão (SOPs) de provisionamento base
└── 📂 templates/             # Imagens base, Cloud-Init e manifestos de infraestrutura
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
