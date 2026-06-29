
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

### 🤖 Agentes de Automação e Autorremediação (Watchdogs)

A arquitetura do servidor de arquivos conta com dois *scripts* executados em *background* para garantir resiliência e otimização de recursos sem intervenção humana.

#### 1. `hdd_mount_script.sh` (Auditoria de Montagem)
* **Função:** Reconciliação do estado de montagem do armazenamento USB.
* **Lógica:** Inspeciona o barramento via `blkid` para validar a presença do disco por UUID. Caso o *automounter* do sistema operacional sequestre a unidade para um ponto de montagem dinâmico, o script força a desmontagem e aplica a regra oficial declarada no `/etc/fstab`, garantindo que o Samba sempre encontre as imagens ISO no caminho `/mnt/ps2hdd`.

#### 2. `ps2_monitor.sh` (Gestão de Energia e Segurança)
* **Função:** *Polling* L3 para desligamento ocioso inteligente.
* **Lógica:** Executa *Echo Requests* (Ping) periódicos para o IP estático do PlayStation 2. Caso o console permaneça inalcançável (Offline) por um período contínuo de `100` minutos (indicando o fim da jogatina), o script aciona o desligamento seguro (`shutdown`) do servidor Linux.
* **Justificativa:** Reduz o *uptime* desnecessário da Raspberry Pi, mitigando desgaste físico da unidade de armazenamento, diminuindo o consumo elétrico e fechando a janela de exposição de rede do protocolo legado SMBv1.

##

### 🚀 Gestão e Manutenção

Para reiniciar o serviço após manutenções ou adição de novos jogos em lote:
```bash
sudo systemctl restart smbd nmbd
sudo systemctl status smbd
``` 

##

ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
