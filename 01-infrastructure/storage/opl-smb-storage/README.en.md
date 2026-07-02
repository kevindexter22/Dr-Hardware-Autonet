<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/storage/opl-smb-storage/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🎮 OPL Samba Storage (PS2 Game Server)

### 📝 Descrição do Escopo

Este diretório documenta a configuração e o provisionamento do servidor de arquivos Samba (SMB/CIFS) dedicado ao ecossistema de *Retro Gaming*. O serviço é desenhado especificamente para hospedar e transmitir imagens ISO para o console PlayStation 2 via rede utilizando o **Open PS2 Loader (OPL)**.

O serviço roda fisicamente em um Raspberry Pi 3B, tirando proveito da interface *Fast Ethernet* (100 Mbps), que é perfeitamente simétrica à capacidade da placa de rede nativa do PS2.

##

### ⚙️ Arquitetura e Tuning do Serviço

* **Protocolo Base:** SMBv1 (NT1) com NTLMv1
* **Ponto de Montagem (Host):** `/mnt/ps2hdd`
* **Compartilhamento de Rede:** `\\<IP_DA_RASPBERRY_PI>\PS2Jogos`
* **Autenticação:** Aberta (`guest ok = yes`) mapeada para o usuário `root`.
* **Network Tuning (L4):** Otimizações de soquete ativadas (`TCP_NODELAY`, `IPTOS_LOWDELAY`) e buffers de recepção/envio travados em 64KB (`SO_RCVBUF=65536 SO_SNDBUF=65536`) para eliminar latência e travamentos em vídeos (FMVs) durante a jogatina.

##

### 🛡️ Considerações de Segurança (SecOps) e Isolamento

O PlayStation 2 é um equipamento legado que exige a utilização de protocolos obsoletos e inseguros (SMBv1/NTLMv1). Além disso, o compartilhamento foi desenhado sem autenticação para maximizar a compatibilidade com o OPL. 

Para mitigar a imensa superfície de ataque que isso gera na rede interna, a segurança **não é feita na camada da aplicação (Samba), mas sim na camada de rede (Firewall L3/L4)**:

1. **Default Deny no UFW:** O serviço Samba da Raspberry Pi rejeita sumariamente qualquer tentativa de conexão na porta `TCP/445` e `TCP/139` vinda da rede geral.

2. **Exceção de IP (Whitelist):** Existe uma regra explícita no *Firewall* de Host (UFW) permitindo tráfego SMB **apenas e exclusivamente** a partir do endereço de IP estático atribuído ao PlayStation 2 (`<IP_DO_PS2>`).

3. Qualquer outro computador ou contêiner na rede que tentar acessar o diretório `PS2Jogos` terá a conexão "dropada".

##

### 📂 Estrutura de Diretórios (Padrão OPL)

O ponto de montagem do servidor Samba espelha a taxonomia obrigatória exigida pelo Open PS2 Loader para o reconhecimento automático dos *assets*:

```text
PS2Jogos/
├── ART/            # Capas (Cover Art), fundos e ícones dos jogos
├── CD/             # Imagens de jogos originais em formato CD (.iso / < 700MB)
├── DVD/            # Imagens de jogos originais em formato DVD (.iso / > 700MB)
├── THM/            # Temas visuais customizados para a interface do OPL
└── VMC/            # Memory Cards Virtuais (Arquivos .bin com saves dos jogos)
```

##

### 🤖 Automation and Self-Healing Agents (Watchdogs)

The file server architecture has two background scripts. They keep the system working and save resources automatically.

1. `hdd_mount_script.sh` (Mount Audit)
* **Function:** Fixes the mount state of the USB storage.
* **Logic:** It uses blkid to check if the disk UUID is connected. Sometimes the system mounts the drive in a random place. If   this happens, the script unmounts it and uses the official rule in /etc/fstab. This makes sure Samba always finds the ISO      images in the /mnt/ps2hdd folder.

2. `ps2_monitor.sh` (Power and Security Management)
* **Function:** L3 polling for smart idle shutdown.
* **Logic:** It sends regular Pings to the PlayStation 2 static IP. If the console is offline for 100 minutes (meaning the       game is over), the script safely shuts down the Linux server (shutdown).
* **Reason:** It stops the Raspberry Pi from running when not needed. This saves the physical storage drive, uses less           electricity, and closes the security risk of the old SMBv1 protocol.

##

### 🚀 Management and Maintenance

To restart the service after maintenance or after adding new games:

```bash
sudo systemctl restart smbd nmbd
sudo systemctl status smbd
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
