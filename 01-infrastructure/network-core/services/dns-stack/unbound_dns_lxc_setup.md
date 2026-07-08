

# 🎯 SOP: Compilação e Instalação do Unbound DNS + DNSTAP (Docker)

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a compilação e instalação de um servidor Unbound DNS containerizado, rodando nativamente sobre proxmox.

O escopo inclui a compilação do módulo dnstap para exportação de logs de consultas DNS via TCP, configuração de bloqueios de URLs (Adblock/Malware), resolução de hosts locais, e repasse inteligente (Forwarding) de CDNs específicas de Streaming para os servidores do provedor de internet, otimizando a rota.

##

### 🗂️ Fase 1: Estrutura de Diretórios e Root Hints

O Unbound precisa da lista oficial de servidores raiz da internet (Root Servers) para realizar a resolução autônoma.

1. Acesse o terminal do container e crie a estrutura de pastas:

```bash
# Criação da estrutura de inventário
mkdir -p /etc/unbound/unbound.conf.d
```

2. Baixe o arquivo root.hints oficial da IANA:

```bash
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.root
```

##

### 🐧 Fase 2: Preparação do SO e Compilação (No Container)
Dentro do LXC (Ubuntu 22.04), instale as dependências de compilação, o framework Protobuf e compile o Unbound a partir do repositório oficial da NLnet Labs.

```bash
# 1. Atualização da base e instalação de dependências rigorosas
apt-get update && apt-get upgrade -y
apt-get install -y build-essential libssl-dev libexpat1-dev \
    libsystemd-dev libevent-dev libprotobuf-c-dev protobuf-c-compiler \
    libfstrm-dev wget ca-certificates

# 2. Download da release solicitada (1.20.0)
wget https://nlnetlabs.nl/downloads/unbound/unbound-1.20.0.tar.gz
tar xzf unbound-1.20.0.tar.gz
cd unbound-1.20.0

# 3. Configuração de build com injeção de telemetria OSS
./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --disable-shared \
    --enable-pie \
    --enable-relro-now \
    --enable-dnstap \
    --with-libevent \
    --with-conf-file=/etc/unbound/unbound.conf

# 4. Compilação e Instalação (Uso de -j1 respeitando a restrição de 1 vCPU)
make -j1
make install
```

##

### ⚙️ Fase 3: Configuração do Unbound

Crie os arquivos de configuração na pasta apropriada.

1. Arquivo Principal (`/etc/unbound/unbound.conf`)

```bash
server:
    directory: "/etc/unbound"
    chroot: ""
    username: "unbound"
    root-hints: "/etc/unbound/root.hints"
    
    # Importa todas as configurações do diretório .d
    include: "/etc/unbound/unbound.conf.d/*.conf"
```

2. Configuração Base e Otimização (`/etc/unbound/unbound.conf.d/main.conf`)

***Nota:*** *A validação DNSSEC pode ser desabilitada (module-config: "iterator") para evitar falsos positivos de SERVFAIL com CDNs e provedores locais caso perceba problemas.*

```bash
server:
    verbosity: 1
    interface: 0.0.0.0
    port: 53
    
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    do-ip6: yes # Altere para yes se usar IPv6 na sua rede
    
    # Otimizações de performance e segurança
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: no
    edns-buffer-size: 1232
    prefetch: yes
    num-threads: 1
    
    # Tamanho do cache (ajustado para o lxc)
    msg-cache-size: 50m
    rrset-cache-size: 100m

    # Desliga a validação DNSSEC (usa apenas o iterador simples)
    # module-config: "iterator"
    # harden-dnssec-stripped: no
``` 

3. Controle de Acesso (`/etc/unbound/unbound.conf.d/acl.conf`)

```bash
server:
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/8 allow
    access-control: 172.16.0.0/12 allow
    access-control: 192.168.0.0/16 allow
```

4. Resolução de Hosts Locais (`/etc/unbound/unbound.conf.d/local-records.conf`)

```bash
server:
    # --- Apontamentos Diretos (A Records) ---
    local-data: "proxmox1.local. IN A <IP_Dispositivo>"
    local-data: "ipa.local. IN A <IP_Dispositivo>"
    local-data: "dnslog.local. IN A <IP_Dispositivo>"
    
    # --- Apontamentos Reversos (PTR Records) ---
    # Define a zona reversa da sua sub-rede (Lida de trás pra frente)
    # Se sua rede é 192.168.0.x, a zona é 0.168.192.in-addr.arpa.
    local-zone: "0.168.192.in-addr.arpa." static
```

5. Integração DNSTAP (`/etc/unbound/unbound.conf.d/dnstap.conf`)

```bash
server:
    identity: "dns2"

dnstap:
    dnstap-enable: yes
    # Endereço TCP do coletor remoto (ex: Vector, Fluentd, ou outro listener)
    dnstap-ip: "<IP_DO_SERVIDOR>@6000"
    dnstap-tls: no
    # O que registrar:
    dnstap-send-identity: yes
    dnstap-send-version: yes
    dnstap-log-client-query-messages: yes
    dnstap-log-client-response-messages: yes
```

6. Bloqueio de URLs (`/etc/unbound/unbound.conf.d/blocklist.conf`)

```bash
server:
    # local-zone: "ads.exemplo.com" always_nxdomain
```

7. Rotas Estáticas de CDNs - Forwarding (`/etc/unbound/unbound.conf.d/forward.conf`)

```bash
# ==========================================
# REPASSE PARA CDNs DE VÍDEO E STREAMING
# ==========================================

# Netflix
forward-zone:
    name: "netflix.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "nflxvideo.net"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "nflxext.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# YouTube e Ecossistema Google Vídeo
forward-zone:
    name: "youtube.com"
   forward-addr: <IP_DNS_PRIMARIO>
   forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "googlevideo.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "ytimg.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# Amazon Prime Video
forward-zone:
    name: "primevideo.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "aiv-cdn.net"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# Twitch TV
forward-zone:
    name: "twitch.tv"
   forward-addr: <IP_DNS_PRIMARIO>
   forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "ttvnw.net"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# Disney+ e Star+
forward-zone:
    name: "disneyplus.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "bamgrid.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# ==========================================
# REPASSE PARA CDNs DE REDES SOCIAIS
# ==========================================

# Meta (Facebook, Instagram, WhatsApp)
forward-zone:
    name: "facebook.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "fbcdn.net"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "instagram.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "cdninstagram.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "whatsapp.net"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# TikTok
forward-zone:
    name: "tiktok.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "tiktokcdn.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "byteoversea.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>

# X (Antigo Twitter)
forward-zone:
    name: "x.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "twitter.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
forward-zone:
    name: "twimg.com"
    forward-addr: <IP_DNS_PRIMARIO>
    forward-addr: <IP_DNS_SECUNDARIO>
```

##

### 🛡️ Fase 4: Permissões e resolução local

O Unbound no Ubuntu LXC sofre concorrência direta na porta 53 com o systemd-resolved. Além disso, precisamos criar o usuário de serviço não privilegiado.

```bash
# 1. Cria o usuário do sistema sem login
useradd -r -s /bin/false unbound

# 2. Aplica as permissões restritas na pasta de configuração
chown -R unbound:unbound /etc/unbound
chmod -R 750 /etc/unbound

# 3. Libera o socket da porta 53 desabilitando o resolver nativo do Ubuntu
systemctl disable --now systemd-resolved
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

##

### 🚀 Fase 5: Serviço Systemd e Inicialização

Para que o Proxmox (via LXC) gerencie o ciclo de vida do daemon, precisamos declarar o serviço no Systemd de forma que ele inicie como root (para capturar a porta 53 protegida) e faça o rebaixamento de privilégio autônomo para o usuário unbound.

1. Crie o arquivo /etc/systemd/system/unbound.service:

```bash
Ini, TOML
[Unit]
Description=Unbound DNS Resolver (com Suporte DNSTAP)
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/sbin/unbound -d -c /etc/unbound/unbound.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

2. Recarregue os daemons e inicie o serviço:

```bash
systemctl daemon-reload
systemctl enable --now unbound
systemctl status unbound
```

##

### 🧩 Ajuste opcional:

Você pode acessar o terminal do container a qualquer momento para utilizar as ferramentas de rede pré-instaladas e monitorar o tráfego que está passando pelo DNS:

```bash
# Exemplos de uso interno:
# dnstop -l 3 eth0
# tcpdump -i eth0 port 53
# nload
```

### 💡 Dicas

* Sempre execute o validador nativo antes de dar restart no serviço após alterar o .conf:

```bash
/usr/sbin/unbound-checkconf /etc/unbound/unbound.conf
```

* Para confirmar se a compilação vinculou a biblioteca correta de telemetria, execute `unbound -V`. <br>
  O output deverá listar: `Linked libs: libevent [...] dnstap`.

* Se o contêiner não estabelecer o bind TCP com o collector, avalie os descartes de stream diretamente pelo log centralizado usando `journalctl -eu unbound.service`.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
