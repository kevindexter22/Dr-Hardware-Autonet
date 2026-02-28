<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Virtualization%20and%20Workloads/README2.md" target="_blank" rel="noopener noreferrer">🇬🇧 Inglês</a></h6>

# 🗄️ Virtualização e Containerização

### 📝 Descrição

Nessa seção, documento a gestão de recursos computacionais, detalhando como o hardware é particionado para atender as demandas dos serviços.

##

### 💻 Hardware

- HP Pavilion G4-1270BR
  - Processador: Core i5 3th, Dual Core 2.5 GHz
  - Memória RAM: 8 GB DDR3, 1600 MHz
  - Armazenamento:
    - SSD: Kingston 480 GB
    - HDD: Sumsung 750 GB
  - Graphics: Intel HD Graphics 6000
 
- Raspberry Pi 4B
  - Processador: Broadcom BCM2711, Quad-core Cortex-A72 (ARM v8) 64-bit SoC @ 1.5 GHz
  - Memória RAM: 4GB LPDDR4-3200 SDRAM
  - Armazenamento: Cartão Micro-SD 64 GB
  - Conectividade:
    - Wireless: Wi-Fi Dual-band 2.4 GHz e 5.0 GHz (802.11ac) e Bluetooth 5.0 (com BLE)
    - Rede Cabeada: Gigabit Ethernet 10/100/1000 Mbps
  - Portas USB: 2 portas USB 3.0 e 2 portas USB 2.0

- Raspberry Pi 3B
  - Processador: Broadcom BCM2837, Quad-core Cortex-A53 (ARMv8) 64-bit SoC @ 1.2 GHz
  - Memória RAM: 1 GB LPDDR2
  - Armazenamento: Cartão Micro-SD 16 ou 32 GB
  - Conectividade:
    - Wireless: Wi-Fi 802.11n (2.4 GHz) e Bluetooth 4.1 (Classic e BLE)
    - Rede Cabeada: Fast Ethernet 10/100 Mbps
  - Portas USB: 4 portas USB 2.0
  
##

### 🛠️ Hypervisors e Runtimes

- CasaOS: Utilizado no servidor principal. Ele tem uma interface para gerenciamento de containers rodando sob o docker, permitindo assim, facilidade na gestão e instalação de serviços personalizados via docker compose.
- Proxmox VE: Hypervisor para rodar máquinas virtuais e containers LXC para alguns serviços.
- Ubuntu Server: Para instalação de serviços direto, sem virtualização ou containerização.

##

### 🚀 Implementações Técnicas

- Gestão de Recursos: Overprovisioning controlado de CPU e RAM para otimização de custos energéticos.
- Storage Persistence: Montagem de volumes Docker via ExFAT/NFS/Samba para garantir persistência de dados fora dos containers.

##

### 📂 Estrutura do Diretório

```text
📂 Virtualization & Workloads/
├── 📄 README.md              # Visão geral e inventário de VMs
├── 📄 README2.md             # Visão geral e inventário de VMs (inglês)
├── 📂 setup-guides/          # Pasta com os manuais
└── 📂 templates/             # Arquivos Prontos
```
##
###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.

