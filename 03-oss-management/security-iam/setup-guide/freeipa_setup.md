<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/setup-guide/freeipa_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o FreeIPA - Proxmox LXC

### 📝 Descrição e Escopo



##

### 🐧 Fase 1: Download e Instalação do Template AlmaLinux 8 no Proxmox

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
   -hostname <SEU_HOSTNAME> \
   -ostype almalinux \
   -storage local-lvm \
   -rootfs local-lvm:8 \
   -net0 name=eth0,bridge=vmbr0,ip=<IP_ADDRESS/CIDR>,gw=<IP_GATEWAY> \
   -unprivileged 0 \
   -features nesting=1
   ```


##

### ⚙️ Fase 2: Instalando o FreeIPA


##

### 🖥️ Fase 3: 


##

### 💡 Dicas Pós-Instalação


##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
