# 🎯 SOP: Coleta e Visualização de Logs DNS (LXC + go-dnscollector + Loki + Grafana)

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
apt update && apt upgrade -y
```

3. Instale dependências básicas:

```bash
apt install wget curl nano tar -y
``` 

##

### ⚙️ Fase 2: Instalação do go-dnscollector

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
Description=go-dnscollector
After=network.target

[Service]
ExecStart=/usr/local/bin/go-dnscollector -config /etc/dnscollector.yml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

4. Recarregue os daemons do sistema para reconhecer o novo serviço:

```bash
systemctl daemon-reload
``` 

##

### 🛠️ Fase 3: Configuração do Pipeline (Formato JSON)

Para que o Grafana consiga ler os campos nativamente (como IP de origem, domínio e status), precisamos forçar o coletor a enviar os dados em flat-json para o Loki.

1. Crie o arquivo de configuração:

```bash
nano /etc/dnscollector.yml
``` 

Adicione a configuração do pipeline. Neste exemplo, o coletor escuta logs DNS na porta 5000 (adapte a entrada conforme a exportação do seu Pi-hole/Adguard) e envia para o Loki:

```bash
pipelines:
  - name: dns_input
    dnstap:
      listen-ip: 0.0.0.0
      listen-port: 6000
    
    routing-policy:
      forward: [ loki_output ]

  - name: loki_output
    lokiclient:
      server-url: "http://<IP_DO_SEU_LOKI>:3100/loki/api/v1/push"
      mode: flat-json
```

2. Inicie e ative o serviço para iniciar junto com o boot do LXC:

```bash
systemctl enable --now go-dnscollector
systemctl status go-dnscollector
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
