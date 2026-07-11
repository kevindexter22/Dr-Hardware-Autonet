<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/unbound_dns_docker_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🎯 SOP: Compilação e Instalação do Unbound DNS + DNSTAP (Docker)

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a compilação e instalação de um servidor Unbound DNS containerizado, rodando nativamente sobre CasaOS em uma Raspberry Pi 4B (Arquitetura ARM).

O escopo inclui a compilação do módulo dnstap para exportação de logs de consultas DNS via TCP, configuração de bloqueios de URLs (Adblock/Malware), resolução de hosts locais, e repasse inteligente (Forwarding) de CDNs específicas de Streaming para os servidores do provedor de internet, otimizando a rota. Ferramentas de troubleshooting de rede (tcpdump, nload, dnstop, dig) foram embutidas na imagem.

##

### 🗂️ Fase 1: Estrutura de Diretórios e Root Hints

O Unbound precisa da lista oficial de servidores raiz da internet (Root Servers) para realizar a resolução autônoma.

1. Acesse o terminal da Raspberry Pi (via SSH) e crie a estrutura de pastas:

```bash
mkdir -p /DATA/AppData/unbound/unbound.conf.d
mkdir -p /DATA/AppData/unbound/build
```

2. Baixe o arquivo root.hints oficial da IANA:

```bash
curl -o /DATA/AppData/unbound/root.hints https://www.internic.net/domain/named.root
```

##

### 🐳 Fase 2: Construção da Imagem Docker (ARM)

Para habilitar o suporte ao dnstap e embutir as ferramentas de diagnóstico, vamos compilar o Unbound a partir do código-fonte em um container Alpine Linux.

1. Crie o arquivo /DATA/AppData/unbound/build/Dockerfile:

```bash
# Estágio de Compilação
FROM alpine:latest AS builder

RUN apk add --no-cache build-base wget openssl-dev libevent-dev expat-dev fstrm-dev protobuf-c-dev ca-certificates

ARG UNBOUND_VERSION=1.20.0

RUN wget https://nlnetlabs.nl/downloads/unbound/unbound-${UNBOUND_VERSION}.tar.gz && \
    tar -xzf unbound-${UNBOUND_VERSION}.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    ./configure \
      --prefix=/opt/unbound \
      --with-pthreads \
      --with-username=unbound \
      --with-libevent \
      --enable-dnstap \
      --with-conf-file=/opt/unbound/etc/unbound/unbound.conf && \
    make -j$(nproc) && \
    make install

# Estágio Final (Imagem Leve e Funcional)
FROM alpine:latest

# Instala dependências de execução e ferramentas de diagnóstico de rede
RUN apk add --no-cache openssl libevent expat fstrm protobuf-c ca-certificates shadow tzdata nload dnstop bind-tools tcpdump

# Cria o usuário unbound
RUN groupadd -g 1000 unbound && useradd -u 1000 -g 1000 -s /sbin/nologin unbound

# Traz os binários compilados do estágio anterior
COPY --from=builder /opt/unbound /opt/unbound

EXPOSE 53/tcp 53/udp

# Executa o Unbound em foreground com a config mapeada
CMD ["/opt/unbound/sbin/unbound", "-d", "-c", "/opt/unbound/etc/unbound/unbound.conf"]
```

##

### ⚙️ Fase 3: Configuração do Unbound

Crie os arquivos de configuração na pasta apropriada.

1. Arquivo Principal (`/DATA/AppData/unbound/unbound.conf`)

```bash
server:
    directory: "/opt/unbound/etc/unbound"
    chroot: ""
    username: "unbound"
    root-hints: "/opt/unbound/etc/unbound/root.hints"
    
    # Importa todas as configurações do diretório .d
    include: "/opt/unbound/etc/unbound/unbound.conf.d/*.conf"
```

2. Configuração Base e Otimização (`/DATA/AppData/unbound/unbound.conf.d/main.conf`)

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
    num-threads: 2
    
    # Tamanho do cache (ajustado para a Pi 4)
    msg-cache-size: 32m
    rrset-cache-size: 64m

    # Desliga a validação DNSSEC (usa apenas o iterador simples)
    # module-config: "iterator"
    # harden-dnssec-stripped: no
``` 

3. Controle de Acesso (`/DATA/AppData/unbound/unbound.conf.d/acl.conf`)

```bash
server:
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/8 allow
    access-control: 172.16.0.0/12 allow
    access-control: 192.168.0.0/16 allow
```

4. Resolução de Hosts Locais (`/DATA/AppData/unbound/unbound.conf.d/local-records.conf`)

```bash
server:
    # DEFINICAO DA ZONA AUTORITATIVA (Obrigatorio)
    # Isso diz ao Unbound: "Eu sou o dono deste dominio, nao procure na internet"
    local-zone: ".local." static
     
    # --- Apontamentos Diretos (A Records) ---
    local-data: "proxmox1.local. IN A <IP_Dispositivo>"
    local-data: "ipa.local. IN A <IP_Dispositivo>"
    local-data: "dnslog.local. IN A <IP_Dispositivo>"
    
    # --- Apontamentos Reversos (PTR Records) ---
    # Define a zona reversa da sua sub-rede (Lida de trás pra frente)
    # Se sua rede é 192.168.0.x, a zona é 0.168.192.in-addr.arpa.
    local-zone: "0.168.192.in-addr.arpa." static
```

5. Integração DNSTAP (`/DATA/AppData/unbound/unbound.conf.d/dnstap.conf`)

```bash
server:
    identity: "dns1"

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

6. Bloqueio de URLs (`/DATA/AppData/unbound/unbound.conf.d/blocklist.conf`)

```bash
server:
    # local-zone: "ads.exemplo.com" always_nxdomain
```

7. Rotas Estáticas de CDNs - Forwarding (`/DATA/AppData/unbound/unbound.conf.d/forward.conf`)

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

### 🛡️ Fase 4: Permissões de Segurança

O Unbound roda sob o UID 1000 por motivos de segurança. Aplique as permissões no diretório do host para que o container possa ler os arquivos:

```bash
sudo chown -R 1000:1000 /DATA/AppData/unbound
sudo chmod -R 755 /DATA/AppData/unbound
```

### 🚀 Fase 5: Orquestração e Inicialização

1. Crie o arquivo do Docker Compose (`/DATA/AppData/unbound/docker-compose.yml`). 

É obrigatório adicionar as capabilities de rede para que o Unbound funcione e para que as ferramentas de captura (tcpdump/dnstop) operem corretamente.

```YAML
version: '3.8'

services:
  unbound:
    build:
      context: /DATA/AppData/unbound/build
      dockerfile: Dockerfile
    container_name: unbound-dns
    hostname: dns1.seu_hostname.com
    restart: unless-stopped
    ports:
      - "5353:53/udp"
      - "5353:53/tcp"
    volumes:
      - /DATA/AppData/unbound:/opt/unbound/etc/unbound
    environment:
      - TZ=America/Sao_Paulo
    cap_add:
      - NET_ADMIN
      - NET_RAW
# Caso utilize o Casaos
x-casaos:
  architectures:
    - amd64
    - arm64
  main: unbound
  title:
    en_US: Unbound DNS
  icon: https://www.netdata.cloud/img/unbound.png
```

2. Para compilar a imagem e iniciar o serviço nativamente no plugin Docker V2 do CasaOS, execute:

```bash
cd /DATA/AppData/unbound
docker compose up -d --build
```

##

### 🧩 Ajuste opcional:

Você pode acessar o terminal do container a qualquer momento para utilizar as ferramentas de rede pré-instaladas e monitorar o tráfego que está passando pelo DNS:

```bash
docker exec -it unbound-dns sh
# Exemplos de uso interno:
# dnstop -l 3 eth0
# tcpdump -i eth0 port 53
# nload
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
