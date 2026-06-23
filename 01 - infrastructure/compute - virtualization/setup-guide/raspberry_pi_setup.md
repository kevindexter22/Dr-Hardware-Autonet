<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/raspberry_pi_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ (SOP) Provisionando Bare-Metal - Raspberry Pi

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para o provisionamento inicial dos nós de processamento baseados em arquitetura ARM (Raspberry Pi). 

O objetivo é preparar a imagem do Sistema Operacional base (Ubuntu Server ou Raspberry Pi OS) de forma manual (sem necessidade de interface de vídeo/teclado local), injetando configurações de rede L2/L3 e credenciais de acesso remoto (via *Cloud-Init*) diretamente no armazenamento físico (Micro-SD). Isso prepara a instância para posterior integração e gerência automatizada via *Infraestructure as Code* (IaC) ou para a instalçao de serviços nativamente.

---

### 💾 Fase 1: Preparação da Mídia Física (Camada 1 / L1)

Para garantir a integridade dos blocos de dados e evitar falhas de alocação em cartões previamente utilizados na infraestrutura, realizamos a formatação do cartão Micro-SD utilizando a ferramenta **Raspberry Pi Imager**.

#### 1. Limpeza da Tabela de Partições
1. Abra o Raspberry Pi Imager.
2. Em **CHOOSE DEVICE**, selecione o modelo de hardware correspondente ao nó (ex: Raspberry Pi 3B).
3. Em **OPERATING SYSTEM**, selecione a opção de formatação **ERASE** (MS-DOS FAT32).
4. Em **CHOOSE STORAGE**, selecione a unidade do seu Micro-SD.
5. Execute a limpeza confirmando em **YES** na janela de aviso.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f28cb4e-450e-4235-8563-23947dd24357" width="300" />
  <img src="https://github.com/user-attachments/assets/f7b0d48e-96ef-4998-937b-7725c7a10362" width="300" />
  <img src="https://github.com/user-attachments/assets/e7333177-5124-4592-985b-43d2de2c97f3" width="300" />
</p>
---

### 🐧 Fase 2: Instalação do Sistema Operacional Base (OS / NFVI)

A arquitetura do laboratório padroniza o **Ubuntu Server** pela sua estabilidade em *stacks* de rede e suporte nativo ao *Netplan*, mas o procedimento aplica-se analogamente ao **Raspberry Pi OS Lite**.

1. No Raspberry Pi Imager, selecione o SO homologado para o seu *Resource Pool* (ex: *Other general-purpose OS > Ubuntu Server 24.04 LTS 64-bit* ou *Raspberry Pi OS Lite 64-bit*).
2. Clique em **NEXT**.
3. Na janela de personalização de instalação, selecione **NO, CLEAR SETTINGS**. A injeção de metadados será realizada manualmente na partição de *boot* para garantir controle estrito das políticas de rede.
4. Confirme a gravação e aguarde a validação do *checksum* e o término do processo.

<p align="center">
  <img src="https://github.com/user-attachments/assets/66009c77-24ba-4888-ac26-9b4696b6decb" width="300" />
  <img src="https://github.com/user-attachments/assets/602d52e8-3d5b-4d8e-8c34-36d658a9c557" width="300" />
</p>
---

### ⚙️ Fase 3: Injeção de Configurações via Cloud-Init (Camadas 2 e 3)

Para que o *Control Plane* gerencie o nó remotamente após a inicialização, o equipamento deve ingressar no domínio de *broadcast* correto e expor o serviço SSH (TCP/22). Modificaremos a partição montada como `bootfs` (RPi OS) ou `system-boot` (Ubuntu).

Remova e reinsira o cartão Micro-SD no computador para montar as partições de sistema.

#### 1. Endereçamento Estático e Uplink (Netplan / Network-Config)
Edite o arquivo `network-config`. Este manifesto será lido pelo *Cloud-Init* no primeiro *boot* para orquestrar as interfaces de rede.

Descomente e ajuste os parâmetros da interface correspondente ao seu *uplink* (`wlan0` para conectividade *wireless* ou `eth0` para rede ethernet), definindo o roteamento e o IP estático do *Management Plane*:

<p align="center">
  <img src="https://github.com/user-attachments/assets/242187c5-5651-4171-85d5-efe24e809576" width="300" />
</p>

> **Nota Arquitetural:** Para conexões Wi-Fi, garanta o preenchimento correto das chaves WPA em `access-points`.

#### 2. Configuração de Identidade e SecOps (Exclusivo RPi OS)
*Importante: O Ubuntu Server habilita o serviço SSH por *default* (Credenciais padrão: `ubuntu` / `ubuntu`). Os passos abaixo são estritamente para a distribuição baseada no Raspberry Pi OS.*

1. **Ativação do Daemon SSH:** Crie um arquivo em branco nominado `ssh` na raiz da partição de inicialização.
```bash
touch /media/<seu_usuario>/bootfs/ssh
```
2. **Injeção de Credenciais e Hash SHA-512:** Crie o manifesto userconf.txt para provisionar o usuário administrador do sistema e sua respectiva senha criptografada.

Gere o hash via shell (Linux/WSL):
```bash
echo "sua_senha_operacional" | openssl passwd -6 -stdin
```

Adicione o output no arquivo /media/<seu_usuario>/bootfs/userconf.txt seguindo o formato de chave-valor usuario:hash:
```bash
admin_lab:$6$dU2DKSj1d8KE57Uy$Q.5BPFHoWNzupp7YQWbteJMt8/ANu...
```

### ✅ Fase 4: Validação e Handover (Post-Boot)

1. Ejete o Micro-SD com segurança, insira-o no hardware do Raspberry Pi e energize o equipamento.

2. A partir do seu bastion host ou terminal de gerência, monitore a disponibilidade da rede via ICMP (Camada 3):
```bash
ping <IP_ESTATICO_CONFIGURADO>
```

3. Estabeleça o túnel encriptado inicial para validar a chave de host (RSA/ED25519) e confirmar o provisionamento:
```bash
ssh <usuario>@<IP_ESTATICO_CONFIGURADO>
``` 

Uma vez autenticado, o Bootstrap Bare-Metal está concluído. O nó encontra-se pronto para a transição de estado, aguardando o deployment de serviços ou orquestração contínua via ferramentas de Automação (ex: Ansible/Terraform).

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
