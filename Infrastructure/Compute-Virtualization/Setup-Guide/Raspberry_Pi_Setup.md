<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Compute-Virtualization/Setup-Guide/Raspberry_Pi_Setuap.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

 <h6 align="right">Read this page in <a href="./Raspberry_Pi_Setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Bare-Metal Provisioning - Raspberry Pi

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para o provisionamento inicial (Bootstrap) dos nós de processamento baseados em arquitetura ARM (Raspberry Pi). 

O objetivo é preparar a imagem do Sistema Operacional base (Ubuntu Server ou Raspberry Pi OS) de forma *headless* (sem monitor/teclado), injetando configurações de rede e credenciais de acesso remoto (via Cloud-Init) diretamente no armazenamento físico (Micro-SD), preparando o nó para posterior gestão via automação (Ansible).

---

### 💾 Fase 1: Preparação da Mídia (Erase / Flash)

Utilizaremos a ferramenta **Raspberry Pi Imager** para garantir a integridade das partições gravadas.

#### 1. Limpeza da Tabela de Partições (Erase)
Para evitar falhas de alocação de blocos em cartões previamente utilizados:
1. Abra o Raspberry Pi Imager.
2. Em **CHOOSE DEVICE**, selecione o modelo de hardware alvo (ex: Raspberry Pi 3B).
3. Em **OPERATING SYSTEM**, selecione **ERASE** (MS-DOS FAT32).
4. Em **CHOOSE STORAGE**, selecione o Micro-SD alvo.
5. Execute a limpeza confirmando em **YES**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f28cb4e-450e-4235-8563-23947dd24357" width="300" />
  <img src="https://github.com/user-attachments/assets/f7b0d48e-96ef-4998-937b-7725c7a10362" width="300" />
  <img src="https://github.com/user-attachments/assets/e7333177-5124-4592-985b-43d2de2c97f3" width="300" />
</p>

---

### 🐧 Fase 2: Instalação do Sistema Operacional (VIM / OS Base)

A topologia do laboratório adota preferencialmente o **Ubuntu Server** pela sua previsibilidade em ambientes de rede e suporte nativo ao *Netplan*, porém os passos se aplicam igualmente ao **Raspberry Pi OS Lite**.

1. No Raspberry Pi Imager, selecione o SO desejado (ex: *Other general-purpose OS > Ubuntu Server 24.04 LTS 64-bit* ou *Raspberry Pi OS Lite 64-bit*).
2. Clique em **NEXT**.
3. Quando questionado sobre personalização prévia, selecione **NO, CLEAR SETTINGS**. (A injeção de configurações será feita manualmente no *bootfs* para garantir controle estrito do ambiente).
4. Confirme a gravação e aguarde o término do processo.

<p align="center">
  <img src="https://github.com/user-attachments/assets/66009c77-24ba-4888-ac26-9b4696b6decb" width="300" />
  <img src="https://github.com/user-attachments/assets/602d52e8-3d5b-4d8e-8c34-36d658a9c557" width="300" />
</p>

---

### ⚙️ Fase 3: Injeção de Configurações Headless (Cloud-Init Bootstrap)

Para gerenciar o servidor remotamente, o nó precisa inicializar na rede L2 correta e expor a porta TCP/22 (SSH). Faremos isso alterando a partição de boot (`bootfs` no RPi OS ou `system-boot` no Ubuntu).

Ao reinserir o cartão no computador, acesse o volume de boot montado.

#### 1. Configuração de Rede (Static IP / Wi-Fi)
Edite o arquivo `network-config`. Este arquivo é lido pelo Cloud-Init/Netplan durante o primeiro boot para definir a topologia de rede da interface.

Descomente e edite as linhas correspondentes à interface de uplink (`wlan0` para Wi-Fi ou `eth0` para Cabeada), definindo o IP estático do *Management Plane*:

<p align="center">
  <img src="https://github.com/user-attachments/assets/242187c5-5651-4171-85d5-efe24e809576" width="300" />
</p>

#### 2. Configuração de Identidade e SSH (Apenas Raspberry Pi OS)
*Nota: O Ubuntu Server habilita o SSH por padrão (Credenciais: `ubuntu` / `ubuntu`). Os passos abaixo aplicam-se à distribuição baseada no RPi OS.*

1. **Habilitar o Daemon SSH:** Crie um arquivo vazio chamado `ssh` na raiz da partição de boot.
   ```bash
   touch /media/<seu_usuario>/bootfs/ssh
