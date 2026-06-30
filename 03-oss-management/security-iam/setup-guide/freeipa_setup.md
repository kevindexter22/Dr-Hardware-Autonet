<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/setup-guide/freeipa_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o FreeIPA - Proxmox LXC

### 📝 Descrição e Escopo



##

###  🗄️ Fase 1: Download e Instalação do Template AlmaLinux 8 no Proxmox

Para que o Proxmox possa criar o container, precisamos garantir que o template oficial do AlmaLinux 8 esteja presente no seu armazenamento (storage).

1. Download do Template via CLI do Proxmox
   
   Acesse o terminal do seu servidor Proxmox VE (via SSH ou shell da WebUI) e execute o comando abaixo para baixar o template     oficial mais recente diretamente do repositório da comunidade (LinuxContainers):
   ```bash
   cd /var/lib/vz/template/cache/
   wget https://images.linuxcontainers.org/images/almalinux/8/amd64/default/default.tar.xz -O almalinux-8-default_amd64.tar.xz
   ```
   *Nota: Se o seu storage de templates for diferente do padrão /var/lib/vz, ajuste o caminho do comando cd.*

2. Criação do Container LXC via CLI (Otimizado)

   Você pode criar o container pela interface gráfica do Proxmox ou rodar este comando diretamente no shell do Proxmox para       criá-lo já com as flags de privilégio e sub-recursos necessárias:
   ```bash
   pct create 100 /var/lib/vz/template/cache/almalinux-8-default_amd64.tar.xz \
   -cores 2 \
   -memory 2548 \
   -swap 512 \
   -hostname <SEU_HOSTNAME.SEU_DOMÍNIO.LOCAL> \
   -ostype almalinux \
   -storage local-lvm \
   -rootfs local-lvm:8 \
   -net0 name=eth0,bridge=vmbr0,ip=<IP_SERVIDOR/CIDR>,gw=<IP_GATEWAY> \
   -unprivileged 0 \
   -features nesting=1
   ```
   * `unprivileged 0`: Define o container como Privilegiado. O FreeIPA no AlmaLinux 8 manipula travas de chaves de segurança         do Kernel (keyrings) que são bloqueadas em containers desprivilegiados.
   * `features nesting=1`: Permite o funcionamento correto do systemd dentro do LXC.

##

###  🐧 Fase 2: Preparação do Sistema Operacional (No Container)

Inicie o container no Proxmox, acesse o console dele e configure a consistência de rede:
```bash
# 1. Iniciar e acessar (se feito via CLI do Proxmox)
pct start 100
pct enter 100

# 2. Corrigir o arquivo /etc/hosts (Crítico para o FreeIPA)
nano /etc/hosts
```

Certifique-se de que a linha do IP estático aponte diretamente para o FQDN antes do nome curto. O arquivo deve ficar assim:
```bash
127.0.0.1   localhost localhost.localdomain
192.168.1.13 <SEU_HOSTNAME.SEU_DOMÍNIO.LOCAL> ipa
```

Atualize os repositórios do AlmaLinux 8:
```bash
dnf update -y
```

##

###  🚀 Fase 3: Instalação do servidor FreeIPA

No AlmaLinux 8, os pacotes do FreeIPA estão contidos em um módulo específico do AppStream chamado idm. 

Precisamos habilitar esse fluxo antes da instalação:
```bash
# 1. Habilitar o módulo Identity Management (IDM) específico do AlmaLinux 8
dnf module enable idm:DL1 -y

# 2. Instalar o servidor FreeIPA com gerenciamento de DNS integrado
dnf install freeipa-server freeipa-server-dns -y
```
Agora vamos executar o instalador automático.

Rode o comando de provisionamento omitindo interações manuais:
```bash
ipa-server-install \
  --realm=<SEU_DOMINIO.LOCAL> \
  --domain=<SEU_DOMINIO.LOCAL> \
  --hostname=<SEU_HOSTNAME.SEU_DOMINIO.LOCAL> \
  --setup-dns \
  --auto-forwarders \
  --allow-zone-overlap \
  -a "SuaSenhaAdminAqui" \
  -p "SuaSenhaDirectoryManagerAqui" \
  -U
```
*Ao término, o FreeIPA Server estará rodando e controlando o domínio .local*

##



##

### 💡 Dicas Pós-Instalação


##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
