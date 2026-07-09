# 🌐 Alta Disponibilidade do DNS

Este repositório contém a documentação e os manifestos necessários para implementar uma arquitetura de Alta Disponibilidade (HA) para resolução de DNS em ambientes HomeLab ou corporativos.

A solução utiliza Nginx (Módulo Stream L4) orquestrado pelo Keepalived (Protocolo VRRP) para garantir tolerância a falhas (MTTR < 2s) entre múltiplos nós, misturando ambientes Docker (CasaOS/Raspberry Pi) e LXC (Proxmox).

##

### 🏗️ Arquitetura Lógica

  * **Virtual IP (VIP):** IP 10.10.0.10 (Gateway DNS para toda a rede).

  * **Node 1 (MASTER):** Docker no CasaOS (Raspberry Pi). IP 10.10.0.11 e Prioridade VRRP: 100.

  * **Node 2 (BACKUP):** LXC no Proxmox. IP 10.10.0.12 e Prioridade VRRP: 90.

  * **Upstream 1 (DNS Primário):** Unbound no CasaOS ( IP 10.10.0.13 mapeado na porta 5353).

  * **Upstream 2 (DNS Secundário):** Servidor DNS Adicional (ex: Pi-hole em 10.10.0.14:53).

##

### ⚠️ Pré-requisitos e Preparação do Host

O IP Virtual (10.10.0.10) deve ser reservado fora do pool de DHCP do seu roteador principal.

Em ambos os nós (Host do CasaOS e dentro do LXC do Proxmox), o Kernel Linux precisa permitir que serviços escutem em IPs não-locais (VIP). Execute:

```bash
echo "net.ipv4.ip_nonlocal_bind=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```
***Prevenção de Conflito de Porta (CasaOS):*** *Se utiliza o Unbound em contêiner no mesmo host do Node 1, certifique-se de publicar as portas do Unbound como 5353:53 (TCP e UDP) no painel do CasaOS. O Nginx será o dono absoluto da porta 53 local.*

##

### 🚀 Fase 1: Deploy do Node 1 (MASTER - CasaOS)

1. Acesse a Raspberry Pi via SSH e crie a estrutura do projeto.

```bash
mkdir -p /DATA/AppData/ha-dns-proxy/nginx
cd /DATA/AppData/ha-dns-proxy
```

2. Configuração do Nginx (nginx/nginx.conf)

Crie o arquivo nginx/nginx.conf com as otimizações L4 para UDP (IPv4/IPv6 simultâneos) e TCP Keepalive:

```bash
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events { 
    worker_connections 1024; 
}

stream {
    upstream dns_servers {
        # DNS 1: Unbound local no CasaOS (na porta 5353 para evitar conflito)
        server 127.0.0.1:5353 max_fails=2 fail_timeout=5s; 
        
        # DNS 2: Outro servidor na rede (Ex: DNS 2)
        server 10.10.0.14:53 backup max_fails=2 fail_timeout=2s;   
    }

    # Proxy para DNS via UDP (Consultas Rápidas)
    server {
        listen 53 udp reuseport;
        proxy_pass dns_servers;
        proxy_timeout 2s;
    }

    # Proxy para DNS via TCP (Respostas Longas / Transferência de Zona)
    server {
        listen 53 so_keepalive=on;
        proxy_pass dns_servers;
        proxy_timeout 5s;
    }
}
```

3. Configuração do Keepalived (keepalived.conf)

Crie o arquivo keepalived.conf definindo este nó como MASTER:

```bash
global_defs {
    router_id NGINX_DNS_MASTER
}

vrrp_script chk_nginx {
    script "killall -0 nginx"
    interval 2
    weight -20
    fall 2
    rise 2
}

vrrp_instance VI_DNS {
    state MASTER
    interface eth0 
    virtual_router_id 53
    priority 100
    advert_int 1
    
    unicast_src_ip 10.10.0.11  # Substitua pelo IP físico da Raspberry Pi
    unicast_peer {
        10.10.0.12            # Substitua pelo IP físico do Node 2 (LXC Proxmox)
    }

    authentication {
        auth_type PASS
        auth_pass HA_DNS_SECURE
    }

    virtual_ipaddress {
        10.10.0.10/24 dev eth0 label eth0:vip
    }

    track_script {
        chk_nginx
    }
}
```

4. Manifesto Docker Compose (docker-compose.yml)

Crie o arquivo com suporte nativo à UI do CasaOS:

```bash
version: '3.8'

services:
  nginx-proxy:
    image: nginx:alpine
    container_name: nginx-dns
    network_mode: "host"
    restart: unless-stopped
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro

  keepalived-ha:
    image: debian:bullseye-slim
    container_name: keepalived-dns
    network_mode: "host"
    pid: "host"
    cap_add:
      - NET_ADMIN
      - NET_BROADCAST
    restart: unless-stopped
    volumes:
      - ./keepalived.conf:/etc/keepalived/keepalived.conf:ro
    command: >
      /bin/bash -c "apt-get update && 
      apt-get install -y keepalived psmisc && 
      keepalived --dont-fork --log-console"

x-casaos:
  architectures:
    - amd64
    - arm64
  main: nginx-proxy
  title:
    en_US: DNS HA Proxy
  icon: [https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/nginx-proxy-manager.png](https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/nginx-proxy-manager.png)
``` 
***Suba a stack:*** *sudo docker compose up -d*

##

### 🛠️ Fase 2: Deploy do Node 2 (BACKUP - Proxmox LXC)

Crie um contêiner Ubuntu 22.04 unprivileged no Proxmox. Para otimização de recursos, este LXC pode operar com apenas 512MB de RAM.

1. Acesse o shell do LXC e instale os pacotes:

```bash
apt update -y && apt install nginx libnginx-mod-stream keepalived psmisc -y
```

2. Pare e desative o resolvedor nativo para libertar a porta 53:

```bash
mkdir -p /etc/systemd/resolved.conf.d
echo -e "[Resolve]\nDNSStubListener=no" > /etc/systemd/resolved.conf.d/disable-stub.conf
systemctl restart systemd-resolved
rm /etc/resolv.conf && echo "nameserver 10.10.0.14" > /etc/resolv.conf
``` 

3. Ajuste o arquivo `nginx.conf`

Abra o arquivo `/etc/nginx/nginx.conf` e adicione a linha `include /etc/nginx/stream.conf.d/*.conf;` no final do arquivo.

***Opcional:*** *Costumo deixar mais enxuto fazendo a limpeza do arquivo com o comando `echo > /etc/nginx/nginx.conf` e adicionando somente a linha `include /etc/nginx/stream.conf./*.conf;`.*

4. Crie o arquivo L4 do Nginx (/etc/nginx/stream.conf.d/dns.conf):

```bash
# Descomente se limpou o arquivo /etc/nginx/nginx.conf
# user www-data;
# worker_processes 1;
# error_log /var/log/nginx/error.log warn;
# pid /var/run/nginx.pid;
# include /etc/nginx/modules-enabled/*.conf;

# events {
#    worker_connections 1024;
#}

# Configuração geral
stream {
    upstream dns_servers {
        server 10.10.0.13:5353 max_fails=2 fail_timeout=5s;
        server 10.10.0.14:53 backup max_fails=2 fail_timeout=2s;
    }

    server {
        listen 53 udp reuseport;
        proxy_pass dns_servers;
        # proxy_responses 1;
        proxy_timeout 2s;
    }

    server {
        listen 53 so_keepalive=on;
        proxy_pass dns_servers;
        proxy_timeout 5s;
    }
}

```

3. Crie o arquivo `/etc/keepalived/keepalived.conf`:

```bash
global_defs {
    router_id NGINX_DNS_BACKUP
}

vrrp_script chk_nginx {
    script "killall -0 nginx"
    interval 2
    weight -20
    fall 2
    rise 2
}

vrrp_instance VI_DNS {
    state BACKUP              # Importante: Node Passivo
    interface eth0
    virtual_router_id 53
    priority 90               # Importante: Prioridade menor que o Master
    advert_int 1
    
    unicast_src_ip 10.10.0.12  # IP deste LXC
    unicast_peer {
        10.10.0.11              # IP da Raspberry Pi (CasaOS)
    }

    authentication {
        auth_type PASS
        auth_pass HA_DNS_SECURE
    }

    virtual_ipaddress {
        10.10.0.10/24 dev eth0 label eth0:vip
    }

    track_script {
        chk_nginx
    }
}
```

4. Habilite os serviços:

```bash
systemctl restart nginx keepalived
systemctl enable nginx keepalived
```

##

### 🧪 Validação e Produção (Go-Live)

1. Teste L4 e VIP: No terminal de qualquer PC da rede, valide a resolução dupla (IPv4/IPv6):

```bash
nslookup www.google.com 192.168.1.17
```

2. Teste de Failover (Chaos):

    2.1 - Deixe um ping 192.168.1.17 -t rodando.
    2.2 - Desligue o contêiner no CasaOS. Observe que o ping perderá no máximo 1 pacote e o Node 2 assumirá o tráfego instantaneamente.
    2.3 - Ligue o Master novamente e ele fará o preempt do VIP.

3. Teste Go-Live:

Acesse as configurações de DHCP da sua rede/roteador Wi-Fi e altere o DNS Primário para 192.168.1.17, deixando o secundário em branco ou adicionando u segundo dns de sua preferência.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
