# 📄 SOP: Instalação Limpa do NetBox em LXC (Ubuntu 22.04 + PostgreSQL 16 + Python 3.12)


### 📋 Descrição do Processo

Este procedimento estabelece o padrão para implantação do NetBox como Fonte Única de Verdade (SSoT) num container LXC sob o Proxmox VE, utilizando uma stack atualizada e segura sob a premissa de Zero Trust (sem abertura de portas no router).

##

### 🛠️ Fase 1: Criação do Container (Proxmox VE)

Execute o provisionamento via CLI no nó do Proxmox para garantir a alocação exata de recursos e isolamento:

```bash
pct create 101 local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
  -cores 2 \
  -memory 1536 \
  -swap 1024 \
  -disk local-lvm:10 \
  -net0 name=eth0,bridge=vmbr0,ip=10.10.0.250/24,gw=10.10.0.1 \
  -ostype ubuntu \
  -unprivileged 1 \
  -start 1
```

##

### 📦 Fase 2: Atualização do SO e Repositórios Modernos

Acesse ao terminal do LXC como root. 

É necessário injetar os repositórios oficiais do PostgreSQL e do Python Core para instalar os pacotes atualizados no Ubuntu 22.04.

```bash
apt update && apt upgrade -y
apt install -y curl ca-certificates gnupg software-properties-common git nginx sudo redis-server build-essential libxml2-dev libxslt1-dev libffi-dev libssl-dev zlib1g-dev

# 1. Repositório Oficial PostgreSQL
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# 2. Repositório Python Atualizado (Deadsnakes)
add-apt-repository ppa:deadsnakes/ppa -y

# 3. Instalação da Stack Nativa
apt update
apt install -y postgresql-16 postgresql-client-16 libpq-dev python3.12 python3.12-venv python3.12-dev
```

##

### 🗄️ Fase 3: Camada de Dados 

Os templates LXC do Proxmox não possuem locale definido, forçando o Postgres a iniciar em modo ASCII. 

Mitigamos isto forçando a clonagem do template0 em UTF-8.

1. Acesse o prompt do postgresql

```bash
sudo -u postgres psql
```

2. Dentro do prompt postgres=#, execute:

```SQL
-- Força a codificação correta ignorando o template1 corrompido
CREATE DATABASE netbox ENCODING 'utf8' TEMPLATE template0;
CREATE USER netbox WITH PASSWORD 'SuaSenhaSeguraAqui';
ALTER DATABASE netbox OWNER TO netbox;
\q
```

3. Tuning de Memória do PostgreSQL 16

Ajuste os buffers para acomodar o limite de 1.5 GB de RAM do LXC:

```bash
nano /etc/postgresql/16/main/postgresql.conf
# Altere ou adicione a linha:
shared_buffers = 256MB
```

4. Salve o arquivo e reinicie o banco de dados

```bash
systemctl restart postgresql
```

##

### 🚀 Fase 4: Instalação e Configuração da Aplicação NetBox

1. Clonagem da Branch Estável

```bash
mkdir -p /opt/netbox/ && cd /opt/netbox/
git clone -b main --depth 1 https://github.com/netbox-community/netbox.git .

# Criação do usuário do sistema sem shell de login por segurança
useradd --system --shell /bin/bash --home /opt/netbox/ netbox
chown -R netbox:netbox /opt/netbox/
```

2. Configuração do Ambiente Django

```bash
cd /opt/netbox/netbox/netbox/
cp configuration_example.py configuration.py

# Gerar chave secreta única
python3.12 ../generate_secret_key.py
# Copie a chave gerada e cole em um bloco de notas para não perder
```

3. Edite o ficheiro nano configuration.py e configure estritamente as variáveis para evitar o erro HTTP 400 Bad Request:

```Python
# Permite o mapeamento do DNS interno sem rejeição do framework
ALLOWED_HOSTS = ['*']

DATABASE = {
    'NAME': 'netbox',
    'USER': 'netbox',
    'PASSWORD': 'SuaSenhaSeguraAqui',
    'HOST': 'localhost',
    'PORT': '',
    'CONN_MAX_AGE': 300,
}

REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'DATABASE': 0,
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'DATABASE': 1,
    }
}

SECRET_KEY = 'COLE_A_CHAVE_GERADA_AQUI'
```
Salve o arquivo.

4. Execução da Esteira de Build (Upgrade Script)

Forçar o script a utilizar o binário correto do Python 3.12 para erguer o ambiente virtual (venv):

```bash
cd /opt/netbox/
sudo PYTHON=/usr/bin/python3.12 ./upgrade.sh
```

5. Criação de Credenciais Administrativas

```bash
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox/
python3 manage.py createsuperuser
deactivate
```

##

### 🔄 Fase 5: Gestão de Serviços e Tuning do Gunicorn

Copie os ficheiros de unidade do systemd e ajuste os workers para não estourarem a memória RAM do LXC:

```bash
cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
nano /opt/netbox/gunicorn.py

# Altere para otimizar os recursos do container:
workers = 1
threads = 2
# Salve o arquivo de configuração

# Mapear os serviços no sistema
cp /opt/netbox/contrib/*.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now netbox netbox-rq
```

##

### 🔒 Fase 6: Camada Web e Criptografia SSL (Acme.sh)

Para evitar que o Nginx falhe na inicialização devido a ficheiros ausentes, geramos o certificado antes de ativar o bloco de rotas do servidor web.

**⚠️*Observação:*** *Caso tenha um dominio proprio e deseje utiliza-lo, siga o passo a passo documentado [netbox_ssl_certificate_domain](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/netbox-stack/netbox-server/netbox_ssl_certificate_domain.md)*

1. Desafio DNS-01 via acme.sh

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
source ~/.bashrc
mkdir -p /etc/ssl/netbox

# Execute o comando de emissão do seu provedor DNS (Ex: DuckDNS/Cloudflare)
export DuckDNS_Token="SEU_TOKEN"
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d seu-lab.duckdns.org -k 2048

# Após o sucesso da validação, instale as chaves estruturadas:
/root/.acme.sh/acme.sh --install-cert -d seu-lab.duckdns.org \
--key-file       /etc/ssl/netbox/netbox.key  \
--fullchain-file /etc/ssl/netbox/netbox.cer
--reloadcmd      "systemctl reload nginx"
```

2. Valide a automação para renovação do certificado

```bash
crontab -l
```
*Resultado: `15 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null`

3. Configuração do Proxy Reverso (Nginx)

```bash
cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
nano /etc/nginx/sites-available/netbox
```

4. Ajuste o bloco principal do servidor garantindo o casamento exato de nomes e caminhos:

```bash
server {
    listen [::]:443 ssl ipv6only=off;
    
    server_name seu-lab.duckdns.org;

    # Caminhos absolutos gerados pelo instalador do acme.sh
    ssl_certificate /etc/ssl/netbox/netbox.cer;
    ssl_certificate_key /etc/ssl/netbox/netbox.key;

    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header X-Forwarded-Host $http_host;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

```

Salve o arquivo e reinicie a stack web:

```bash
nginx -t
systemctl restart nginx
```

Para testar:

```bash
https://seu-lab.duckdns.org
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
