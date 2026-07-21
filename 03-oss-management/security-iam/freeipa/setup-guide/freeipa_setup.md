<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Instalando o FreeIPA - Proxmox LXC

### 📝 Descrição e Escopo

Este procedimento operacional padrão (SOP) documenta o provisionamento e a configuração do **FreeIPA**, que atua como o **Identity and Access Management (IAM) Plane** do laboratório. 

No contexto do framework OSS (FCAPS), este nó é o núcleo primário de **Security Management**, responsável por centralizar a governança de credenciais, auditoria e controle de acesso baseado em funções (RBAC).

* **Arquitetura Lógica (Camada 7):** Atua como a *Single Source of Truth* (SSoT) da infraestrutura. Consolida os serviços de **AuthN** (Autenticação via Kerberos) e **AuthZ** (Autorização via LDAP), além de prover resolução de nomes interna integrada (DNS).
* **Arquitetura de Infraestrutura (Virtualização):** Hospedado de forma otimizada como um contêiner LXC Privilegiado no Proxmox (utilizando AlmaLinux 8). Esta topologia elimina o *overhead* de uma máquina virtual completa (KVM), mantendo acesso direto aos *keyrings* do Kernel necessários para a criptografia do Kerberos.
* **Interoperabilidade e SRE:** Substitui a gestão descentralizada (usuários estáticos no `/etc/passwd` de cada máquina) por um modelo dinâmico acoplado via SSSD e PAM. Isso reduz o MTTR operacional, elimina o *Configuration Drift* e permite a revogação instantânea de acessos (Zero Trust) em todo o parque de servidores (Ubuntu/Debian).

##

###  🗄️ Fase 1: Download e Instalação do Template AlmaLinux 8 no Proxmox

Para que o Proxmox possa criar o container, precisamos garantir que o template oficial do AlmaLinux 8 esteja presente no seu armazenamento (storage).

1. Download do Template via CLI do Proxmox:
   
Acesse o terminal do seu servidor Proxmox VE (via SSH ou shell da WebUI) e execute o comando abaixo para baixar o template oficial mais recente diretamente do repositório da comunidade (LinuxContainers):

```bash
cd /var/lib/vz/template/cache/
wget https://images.linuxcontainers.org/images/almalinux/8/amd64/default/default.tar.xz -O almalinux-8-default_amd64.tar.xz
```

*Nota: Se o seu storage de templates for diferente do padrão /var/lib/vz, ajuste o caminho do comando cd.*

2. Criação do Container LXC via CLI (Otimizado):

Você pode criar o container pela interface gráfica do Proxmox ou rodar este comando diretamente no shell do Proxmox para criá-lo já com as flags de privilégio e sub-recursos necessárias:

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

* `unprivileged 0`: Define o container como Privilegiado. O FreeIPA no AlmaLinux 8 manipula travas de chaves de segurança do Kernel (keyrings) que são bloqueadas em containers desprivilegiados.
* `features nesting=1`: Permite o funcionamento correto do systemd dentro do LXC.

##

###  🐧 Fase 2: Preparação do Sistema Operacional (No Container)

Inicie o container no Proxmox, acesse o console dele e configure a consistência de rede:

```bash
# 1. Iniciar e acessar (se feito via CLI do Proxmox)
pct start 100
pct enter 100

# 2. Corrigir o arquivo /etc/hosts (Crítico para o FreeIPA)
vi /etc/hosts
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
  --realm=<SEU_DOMINIO.LOCAL> \ # Digite em letras maiusculas
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

**☢️ Alerta de Segurança:**

Após finalizar a instalação, realize a configuração de um certificado SSL para a interface web.<br>
Você pode gerar um certificado usando um [Domínio Próprio](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_ssl_certificate_domain.md) ou um [DNS Dinâmico Gratuito](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_ssl_certificate.md).

##

###  🐧 Fase 4: Configuração e Acoplamento do Cliente (Ubuntu/Debian)

No seu servidor cliente (qualquer nó Ubuntu ou Debian), execute a limpeza preventiva e a instalação limpa para se conectar ao novo servidor AlmaLinux 8.

```bash
# 1. Purga de configurações anteriores (se nunca configurou o FreeIPA client, ignore essa parte)
sudo ipa-client-install --uninstall -U
sudo rm -rf /var/lib/sss/db/*
sudo rm -f /etc/krb5.keytab

# 2. Instalação do agente cliente
sudo apt update
sudo apt install freeipa-client sssd-tools -y

# 3. Registro no novo domínio (.click)
sudo ipa-client-install \
  --server=<SERVER_HOSTNAME.SEU_DOMINIO.LOCAL> \
  --domain=<SEU_DOMINIO.LOCAL> \
  --realm=<SEU_DOMINIO.LOCAL> \ # Digite em letras maiusculas
  --principal=admin \
  -w "SuaSenhaAdminAqui" \
  --mkhomedir \
  --unattended \
  --force-join \
  --fixed-primary \
  --no-ntp
```

Ajustes Pós-Instalação no Cliente (Garantia de SSH e PAM)

Para mitigar em definitivo os erros de expiração de token no Ubuntu:

```bash
# Force a injeção do SSSD nas camadas do PAM do Ubuntu
sudo pam-auth-update --enable sss

# Certifique-se de que o SSH aceita a intermediação do PAM
sudo sed -i 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Reinicie as travas de cache
sudo sss_cache -E
sudo systemctl restart sssd ssh
```

Essa estrutura baseada em AlmaLinux 8 como servidor central rodando em LXC dedicado mitiga falhas de concorrência de portas e entrega uma gerência de identidades extremamente performática e limpa para o seu ecossistema Proxmox.

##

### 💡 Dicas
* **Importante:** *Se na configuração aplicada em `/etc/ssh/sshd_config` estiver com a opção `AllowUsers` e os usuários adicionados não forem os mesmos do FreeIPA, ele pode bloquear por segurança ao tentar acessar via ssh.
Sendo assim comente a opção `AllowUsers` ou adicione os usuários criados no FreeIPA a essa regra e reinicie o serviço ssh.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
