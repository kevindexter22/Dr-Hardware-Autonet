# 🔒 SOP: Provisionamento Zero-Touch de SSL no FreeIPA (Direct DDNS Mode)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a automação e gerência do ciclo de vida de certificados SSL/TLS (Let's Encrypt) no Control Plane de Identidade FreeIPA, utilizando exclusivamente um provedor de DNS Dinâmico gratuito (DuckDNS).

Por não utilizar um domínio customizado (TLD), a arquitetura dispensa a criação de Alias ou delegações CNAME. A validação do desafio DNS-01 ocorre de forma nativa e direta via API. O procedimento já contempla os contornos arquiteturais necessários para adequar os certificados modernos (Let's Encrypt RSA) ao rigoroso banco de dados criptográfico interno do FreeIPA (NSS/Dogtag).

##

### 🧹 Fase 1: Pré-requisitos e Saneamento (Control Plane)

Como o tráfego ocorrerá diretamente para o DNS dinâmico, garanta a resolução primária:

1. O subdomínio do DuckDNS (ex: seu-lab.duckdns.org) deve estar apontando (via cliente atualizador ou IP estático) para o IP público do seu laboratório.

2. Na rede interna (LAN), o seu servidor DNS local (ou arquivo /etc/hosts) deve resolver seu-lab.duckdns.org para o IP privado do servidor FreeIPA, garantindo o roteamento correto no domínio de broadcast.

##

## ⚙️ Fase 2: Instalação e Mediação do Orquestrador (acme.sh)

Acesse o terminal SSH do servidor FreeIPA (com privilégios de root):

1. Instalação do Core:

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
```

2. Engenharia de Confiabilidade (Downgrade de CA): O FreeIPA não possui as autoridades de novas CAs nativamente em seu sistema operacional base. Forçaremos o orquestrador a utilizar a Let's Encrypt como provedor padrão de confiança:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Fase 3: Emissão Direta e Extração Criptográfica

A emissão ocorrerá sem redirecionamentos lógicos, apontando os parâmetros de desafio para o próprio domínio.

1. Exporte o seu Token de integração:

```bash
export DuckDNS_Token="SEU_TOKEN"
```

2. Ordem de Emissão Direta (Point-to-Point):

Parametrizamos a chave para o formato tradicional RSA 2048, garantindo a retrocompatibilidade com a pilha do sistema.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d seu-lab.duckdns.org -k 2048
```

3. Staging Area (Área de Transição): Crie o diretório de custódia e fragmente a cadeia de certificados para isolar a Autoridade Certificadora (CA).

```bash
mkdir -p /etc/ssl/freeipa
/root/.acme.sh/acme.sh --install-cert -d seu-lab.duckdns.org \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--ca-file        /etc/ssl/freeipa/ca.cer
```

##

### 🔗 Fase 4: Sincronização da Cadeia de Confiança (Trust Chain)

O FreeIPA atua como Autoridade autônoma. Devemos injetar as chaves públicas da Let's Encrypt no banco de dados NSS para que ele reconheça a assinatura do seu novo certificado.

1. Download da Root CA Oficial (ISRG Root X1):
```bash
curl -L -o /etc/ssl/freeipa/isrgrootx1.pem https://letsencrypt.org/certs/isrgrootx1.pem
```

2. Injeção da Root CA (Chefe):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/isrgrootx1.pem
# (Forneça a senha do Directory Manager quando solicitado).
```

3. Injeção da Intermediate CA (Subordinada):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/ca.cer
```

4. Propagação Global (Sync): Atualize as bases internas do sistema para consolidar a hierarquia:

```bash
ipa-certupdate
```

##

### ✅ Fase 5: Integração e Automação de Lifecycle (Zero-Touch)

Diferente de servidores Web comuns, o FreeIPA não lê os certificados do diretório de forma dinâmica. 

Para garantir que a renovação automática a cada 60 dias seja aplicada sem intervenção humana, atrelamos um Hook (Gatilho) de reinicialização diretamente no orquestrador.

1. Deploy com Automação: Execute o comando abaixo substituindo SUA_SENHA_AQUI pela senha real do seu Directory Manager. 

O acme.sh instalará as chaves agora e memorizará este comando para executá-lo em segundo plano em todas as renovações futuras.

``` bash
/root/.acme.sh/acme.sh --install-cert -d seu-lab.duckdns.org \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--reloadcmd      "ipa-server-certinstall -w -d --dirman-password='SUA_SENHA_AQUI' --pin='' /etc/ssl/freeipa/ipa.key /etc/ssl/freeipa/ipa.cer && ipactl restart"
```

2. A partir da execução com sucesso, o painel de gerência do FreeIPA estará acessível de forma segura via HTTPS, e a infraestrutura operará com custo zero de manutenção operacional (OPEX) para a criptografia.

```text
https://seu-lab.duckdns.org
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
