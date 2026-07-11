# 🛡️ SOP: Provisionamento de SSL (Let's Encrypt) no NetBox via DNS-01 (Alias Mode)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a injeção de certificados SSL/TLS válidos no Proxy Reverso (Nginx) que protege a interface do NetBox (Single Source of Truth).

Devido à arquitetura de rede Zero Trust (sem abertura de portas Inbound no roteador) implementada no laboratório, a integração direta via HTTP-01 é impossível. Este guia utiliza o orquestrador acme.sh em modo de Delegação DNS (Alias Mode) para validar o domínio personalizado (ex: .click) sem expor o servidor web à internet pública, terceirizando o desafio criptográfico para um DDNS de apoio (DuckDNS).

##

### 🌐 Fase 1: Roteamento e Delegação DNS

Preparação da camada lógica no seu provedor de domínio público (ex: Hostinger).

Acesso Local (Split-DNS): No seu servidor de DNS interno (ex: Unbound), crie o apontamento estático para o IP do LXC, evitando que o tráfego saia para a internet.

Tipo: A / Local-Data

Nome: netbox.infra.seu-dominio.com

Alvo: 10.10.0.250

Delegação de Segurança (ACME Challenge): No painel público da Hostinger (Zona DNS), crie o redirecionamento apontando estritamente para a raiz do seu DDNS de apoio para automatizar o desafio.

Tipo: CNAME

Nome: _acme-challenge.netbox

Alvo: seu-lab.duckdns.org

##

### ⚙️ Fase 2: Instalação e Parametrização do Orquestrador

O acme.sh mediará a comunicação com a API do DuckDNS e a Autoridade Certificadora. Acesse o terminal do servidor LXC do NetBox (como root):

1. Instalação do Core:

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
source ~/.bashrc
```

2. Engenharia de Confiabilidade (Bypass de Fornecedor): Por padrão, o acme.sh utiliza a ZeroSSL. 

Para mantermos a padronização Open Source do laboratório, forçaremos a utilização da Let's Encrypt como CA primária:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Fase 3: Emissão e Extração Criptográfica

1. Exporte o seu Token de API do provedor DDNS (DuckDNS):

```bash
export DuckDNS_Token="SEU_TOKEN_AQUI"
```

2. Ordem de Emissão (Delegação Criptográfica): Solicitaremos o certificado para o domínio .com, mas instruiremos a Let's Encrypt a procurar a resposta do desafio no domínio do DuckDNS.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d netbox.infra.seu-dominio.com --challenge-alias seu-lab.duckdns.org
```

3. Staging Area (Deployment e Automação): Crie um diretório de custódia seguro e instale os arquivos. 

Adicionaremos o Hook de recarregamento (--reloadcmd) para garantir que o certificado seja renovado sozinho a cada 60 dias sem intervenção humana.

```bash
mkdir -p /etc/ssl/netbox
/root/.acme.sh/acme.sh --install-cert -d netbox.infra.seu-dominio.com \
--key-file       /etc/ssl/netbox/netbox.key  \
--fullchain-file /etc/ssl/netbox/netbox.cer \
--reloadcmd      "systemctl reload nginx"
```

4. Valide a automação para renovação do certificado

```bash
crontab -l
```
*Resultado: `15 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null`

##

### 🔗 Fase 4: Integração da Cadeia de Confiança no Proxy (Nginx)

O NetBox delega a terminação SSL para o web server (Nginx). 

Precisamos apontar as diretivas do servidor para o cofre de chaves recém-criado.

Edite o arquivo de rotas do NetBox:

```bash
nano /etc/nginx/sites-available/netbox
```

Ajuste o bloco server para refletir o domínio exato e os caminhos absolutos:

```bash
server {
    listen [::]:443 ssl ipv6only=off;
    
    # Nome oficial de acesso
    server_name netbox.infra.seu-dominio.com;

    # Apontamento da Cadeia Completa (Fullchain) e Chave Privada
    ssl_certificate /etc/ssl/netbox/netbox.cer;
    ssl_certificate_key /etc/ssl/netbox/netbox.key;
    
    client_max_body_size 25m;
    
    # ... (manter as locations do Gunicorn abaixo)
}
```

##

### ✅ Fase 5: Injeção do Certificado e Handover

Com a cadeia de confiança resolvida na configuração, faça a validação sintática para evitar a queda do serviço web:

```bash
nginx -t
```

Graceful Restart: Se o comando retornar syntax is ok, reinicie o proxy reverso para aplicar a nova topologia na memória RAM:

``` bash
systemctl restart nginx
```

O acesso web ao painel do NetBox agora estará operando sob criptografia TLS válida e reconhecida globalmente (Cadeado Verde), sem disparar alertas de segurança.

Para acessar a interface, utilize a seguinte URL no seu navegador:
```bash
https://netbox.infra.seu-dominio.com
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
