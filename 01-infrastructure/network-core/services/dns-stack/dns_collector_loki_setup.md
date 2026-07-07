# 🎯 SOP: Coleta de Logs DNS (go-dnscollector + Loki) em LXC

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha o fluxo completo (de ponta a ponta) para a coleta e estruturação de logs de consultas DNS na rede. 

O processo abrange desde a criação do container LXC no Proxmox, a instalação do go-dnscollector como serviço, a configuração de exportação em JSON para o Loki.

Sendo um componente crítico para a observabilidade da rede, isso permite auditar requisições, identificar com precisão domínios bloqueados e visualizar a resposta real dos servidores separando-as do tráfego legítimo.

##

### 📦 Fase 1: Preparação do Ambiente (Proxmox LXC)

Recomenda-se o uso de um container LXC leve (Debian ou Ubuntu) para hospedar o coletor, evitando o consumo desnecessário de recursos de uma VM completa.

1. No Proxmox, crie um novo container LXC (ex: CT ID 200, Hostname dns-collector, Template debian-12 ou ubuntu-24.04).

2. Acesse o console do LXC e atualize os pacotes do sistema:

```bash
apt update; apt upgrade -y
```

3. Instale dependências básicas:

```bash
apt install wget curl nano tar -y
``` 

##

### ⚙️ Instalando e Configurando o Loki

Acesse o terminal do seu novo LXC. A forma mais leve de rodar o Loki (sem docker) é baixando o binário direto.

1. Baixe o Loki:

```bash
apt update; apt install unzip wget -y
wget https://github.com/grafana/loki/releases/download/v3.0.0/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
chmod +x loki-linux-amd64
mv loki-linux-amd64 /usr/local/bin/loki
```

2. Crie a configuração (/etc/loki-config.yaml):

Crie um arquivo básico apenas para receber logs localmente e sem autenticação complexa (já que ficará na rede interna).

```YAML
4. cole as configurações abaixo:
auth_enabled: false

server:
  http_listen_port: 3100

common:
  path_prefix: /opt/loki
  storage:
    filesystem:
      chunks_directory: /opt/loki/chunks
      rules_directory: /opt/loki/rules
  replication_factor: 1
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h
```

3. Inicie o serviço:

Você pode criar um serviço no systemd para o Loki rodar em background apontando para essa configuração (loki -config.file=/etc/loki-config.yaml).

```bash
# Crie o arquivo de configuração:
nano /etc/systemd/system/loki.service

# Cole as configurações abaixo:
[Unit]
Description=Loki Log Aggregation System
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/loki -config.file=/etc/loki-config.yaml
Restart=always
RestartSec=5

# Opcional: Se quiser limitar o uso do sistema, descomente as linhas abaixo
# LimitNOFILE=65536
# LimitNPROC=4096

[Install]
WantedBy=multi-user.target
```

4. Ative o serviço:

```bash
# Recarrega a lista de serviços do systemd
systemctl daemon-reload

# Faz o Loki iniciar automaticamente no boot do LXC
systemctl enable loki

# Inicia o Loki agora
systemctl start loki
```

##

### ⚙️ Fase 3: Instalação do go-dnscollector

1. Vamos baixar o binário oficial do go-dnscollector e configurá-locomo um serviço do sistema para rodar em background.

Baixe a última versão do binário (verifique no repositório oficial do Github por versões mais recentes, se necessário):

```bash
wget [https://github.com/dmachard/go-dnscollector/releases/latest/download/go-dnscollector_linux_amd64.tar.gz](https://github.com/dmachard/go-dnscollector/releases/latest/download/go-dnscollector_linux_amd64.tar.gz)
``` 

2. Extraia e mova o binário para a pasta de executáveis do sistema:

```bash
tar -zxvf go-dnscollector_linux_amd64.tar.gz
mv go-dnscollector /usr/local/bin/
chmod +x /usr/local/bin/go-dnscollector
```

3. Crie o arquivo de serviço do Systemd (`/etc/systemd/system/go-dnscollector.service`):

```bash
[Unit]
Description=DNS-collector (Log Shipper para Loki)
# Configurado para iniciar só depois que a rede e o Loki estiverem de pé
After=network.target loki.service

[Service]
Type=simple
ExecStart=/usr/local/bin/go-dnscollector -config /etc/dnscollector.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

4. Recarregue os daemons do sistema para reconhecer o novo serviço:

```bash
systemctl daemon-reload
``` 

##

### 🛠️ Fase 4: Configuração do Pipeline (Formato JSON)

Para que o Grafana consiga ler os campos nativamente (como IP de origem, domínio e status), precisamos forçar o coletor a enviar os dados em flat-json para o Loki.

1. Crie o arquivo de configuração:

```bash
nano /etc/dnscollector.yml
``` 

Adicione a configuração do pipeline. Neste exemplo, o coletor escuta logs DNS na porta 5000 (adapte a entrada conforme a exportação do seu Pi-hole/Adguard) e envia para o Loki:

```bash
global:
  trace:
    verbose: true

pipelines:
  # Recebe os logs do Docker via TCP (usando o protocolo dnstap)
  - name: dns_input
    dnstap:
      listen-ip: 0.0.0.0
      listen-port: 6000
    routing-policy:
      forward: [ loki_output ]

# Envia os dados estruturados para o Loki local
  - name: loki_output
    lokiclient:
      server-url: "http://127.0.0.1:3100/loki/api/v1/push"
      job-name: "dns-logs"
      mode: flat-json
```

2. Inicie e ative o serviço para iniciar junto com o boot do LXC:

```bash
systemctl enable --now go-dnscollector
systemctl status go-dnscollector
```

##

**🧩 Integração:**

Agora podemos integrar o loki com o Grafana e gerar uma *dashboard* para visualização das requisições. 

## 

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
