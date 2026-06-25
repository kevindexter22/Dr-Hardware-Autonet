<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/proxmox_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ (SOP) Provisionando Bare-Metal - Proxmox VE

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para o provisionamento inicial do Hypervisor Proxmox VE.

O objetivo é instalar o sistema operacional e preparar o hardware para executar sistemas e serviços tanto em KVM como em LXC (Linux Containers). Estaremos realizando também algumas configurações de otimização, adequação dos repositórios (uma vez que utilizaremos a versão open source), definiremos um IP estático para facilitar a gerência do servidor e definiremos um segundo disco voltado a storage para armazenar ISOs, Imagens de containers e backups.

##

### 💾 Fase 1: Preparação Física e Instalação (Host OS)

#### A. Configuração de BIOS/UEFI

Antes de iniciar, acesse a BIOS do computador e garanta que:

1. A opção Virtualization Technology (VT-x) esteja Habilitada. Sem isso, o KVM não funcionará.
2. Boot Order: Configure o pendrive bootável do Proxmox VE como primário.

#### B. Parâmetros de Instalação (Proxmox Installer)

Após iniciar o instalador do Sistema Operacional, durante o processo defina os parâmetros conforme abaixo:

1. **Target Hard Disk:** Selecione estritamente qual será o disco onde instalará o sistema. Ex.: SSD de 480 GB.
2. **Options (Filesystem):** Clique em options e certifique-se de que o sistema de arquivos está definido como EXT4.
3. **Network Setup:** Defina um IP estático para a interface de rede cabeada (eth0/eno1). *Obs.: Evite usar wi-fi para o hypervisor, para melhor latência e largura de banda.* 

### 🚀 Fase 2: Otimizações Pós-Instalação (Tuning)

Após o primeiro boot, acesse a interface web de gerência (https://<IP_DO_PROXMOX>:8006) e, em seguida, abra o shel do node para aplicar os ajustes de infraestrutura.

#### A. Adequação dos Repositórios (Software Management)
