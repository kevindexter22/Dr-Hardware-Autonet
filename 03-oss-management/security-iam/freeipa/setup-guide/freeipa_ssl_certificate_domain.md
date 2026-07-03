<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_ssl_certificate_domain.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛡️ SOP: Provisionamento de SSL (Let's Encrypt) no FreeIPA via DNS-01

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a injeção de certificados SSL/TLS válidos no Control Plane de Identidade FreeIPA.

Devido à arquitetura rigorosa do banco de dados criptográfico interno do FreeIPA (NSS/Dogtag), a integração direta com provedores ACME exige o tratamento estrito da Cadeia de Confiança (Trust Chain) e a adoção do padrão criptográfico RSA. Este guia utiliza o orquestrador acme.sh em modo de Delegação DNS (Alias Mode) para validar o domínio sem expor o servidor LDAP/Web à internet pública.

##

### 🌐 Fase 1: Roteamento e Delegação DNS

Preparação da camada lógica no seu provedor de domínio público (ex: Hostinger).

1. Acesso Local (Camada 3): Crie um registro apontando para o IP interno do FreeIPA.

   * **Tipo:** A
   * **Nome:** ipa.infra
   * **Alvo:** <IP_ESTATICO_LOCAL>

2. Delegação de Segurança (ACME Challenge): Crie o redirecionamento apontando estritamente para a raiz do seu DDNS de apoio.

   * **Tipo:** CNAME
   * **Nome:** _acme-challenge.ipa.infra
   * **Alvo:** seu-lab.duckdns.org

##

### ⚙️ Fase 2: Instalação e Parametrização do Orquestrador

O acme.sh mediará a comunicação com a API do DuckDNS e a Autoridade Certificadora. Acesse o terminal do servidor FreeIPA (como root):

1. Instalação do Core:

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
```

2. Engenharia de Confiabilidade (Bypass de Fornecedor): Por padrão, o acme.sh utiliza a ZeroSSL, porém, o FreeIPA não possui essa raiz em seu banco de dados nativo. Forçaremos a utilização da Let's Encrypt:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Fase 3: Emissão e Extração Criptográfica

1. Exporte o seu Token de API do provedor DDNS (DuckDNS):

```bash
export DuckDNS_Token="SEU_TOKEN"
```

2. Ordem de Emissão (Bypass de Criptografia): Forçaremos o parâmetro -k 2048 para emitir uma chave RSA Clássica.<br>
O FreeIPA rejeitará chaves modernas do tipo ECC (Curvas Elípticas) da Let's Encrypt devido à falta da nova Root CA no sistema base.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d ipa.infra.seu-dominio.com --challenge-alias seu-lab.duckdns.org -k 2048
```

3. Staging Area (Deployment): Crie um diretório de custódia seguro e extraia os arquivos quebrando a cadeia (Fullchain) para gerar um arquivo CA purificado.

```bash
mkdir -p /etc/ssl/freeipa
/root/.acme.sh/acme.sh --install-cert -d ipa.infra.seu-dominio.com \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--ca-file        /etc/ssl/freeipa/ca.cer
```

##

### 🔗 Fase 4: Sincronização da Cadeia de Confiança (Trust Chain)

O FreeIPA atua como sua própria Autoridade Certificadora. Para que ele aceite o SSL do servidor, precisamos ensiná-lo a confiar na hierarquia da Let's Encrypt de cima para baixo.

1. Download da Root CA Oficial (ISRG Root X1):

```bash
curl -L -o /etc/ssl/freeipa/isrgrootx1.pem https://letsencrypt.org/certs/isrgrootx1.pem
```

2. Injeção da Root CA (Chefe):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/isrgrootx1.pem
# (Será solicitada a senha do Directory Manager).
```

3. Injeção da Intermediate CA (Subordinada):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/ca.cer
```

4. Propagação Global (Sync): Atualize os bancos de dados NSS e LDAP para consolidar a confiança:

```bash
ipa-certupdate
```

##

### ✅ Fase 5: Injeção do Certificado e Handover

Com a cadeia de confiança resolvida, aplique as chaves aos serviços de borda do FreeIPA (Apache e Directory Server).

1. Instalação do Certificado de Servidor:

```bash
ipa-server-certinstall -w -d /etc/ssl/freeipa/ipa.key /etc/ssl/freeipa/ipa.cer
```

* ***Nota Operacional:*** *Quando o prompt solicitar a Directory Manager password, insira sua senha administrativa.<br>
Em seguida, ele solicitará a private key unlock password: pressione ENTER em branco, pois as chaves do Let's Encrypt não possuem senha local.*

2. Graceful Restart: Reinicie o plano de controle para aplicar a nova topologia:

```bash
ipactl restart
```

* *O acesso web ao painel do FreeIPA agora estará operando sob criptografia TLS válida (Cadeado Verde), garantindo a integridade e confidencialidade das credenciais de rede.*

3. Para acessar agora, podemos fazer da seguinte forma:
```text
https://ipa.infra.seu_dominio.com
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
