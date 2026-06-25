<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/proxmox_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ (SOP) Provisionando Bare-Metal - Proxmox VE

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para o provisionamento inicial do Hypervisor Proxmox VE.

O objetivo é instalar o sistema operacional e preparar o hardware para executar sistemas e serviços tanto em KVM como em LXC (Linux Containers). Estaremos realizando também algumas configurações de otimização, adequação dos repositórios (uma vez que utilizaremos a versão open source), definiremos um IP estático para facilitar a gerência do servidor e definiremos um segundo disco voltado a storage para armazenar ISOs, Imagens de containers e backups.

##

### 💾 Fase 1: Preparação Física e Instalação (Host OS)

