<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/vpn/vpn_server_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🎯 SOP: Instalação e Configuração de VPN Server strongSwan (IKEv2 + MSCHAPv2 via ipsec.conf)

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a implementação de um servidor de VPN baseado no pacote clássico do strongSwan utilizando o backend tradicional (`ipsec.conf`). 

O escopo inclui a criação de uma Infraestrutura de Chaves Públicas (PKI) interna para emissão do certificado do servidor, autenticação de clientes via IKEv2 com EAP-MSCHAPv2 (Usuário e Senha), e provisionamento de rede virtual (Pool de IPs) com Full Tunneling.

---

### 🗂️ Fase 1: Estrutura de Diretórios e Infraestrutura de Chaves Públicas (PKI)

Para garantir a segurança do Plano de Controle (IKEv2), o servidor precisa de um certificado digital para que os clientes validem sua identidade. Os usuários utilizarão apenas usuário/senha, necessitando apenas confiar na CA Raiz.

1. Acesse o terminal e crie a estrutura temporária para a geração das chaves:

```bash
mkdir -p ~/pki/{cacerts,certs,private}
chmod 700 ~/pki
```

2. Gere a Autoridade Certificadora (Root CA) interna:

```bash
pki --gen --type ed25519 --outform pem > ~/pki/private/ca-key.pem
pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
    --type ed25519 --dn "C=BR, O=SuaEmpresa, CN=SuaEmpresa Root CA" \
    --outform pem > ~/pki/cacerts/ca-cert.pem
```

3. Gere o Certificado do Servidor VPN (Substitua vpn.seudominio.com.br pelo seu FQDN ou IP público):

```bash
pki --gen --type ed25519 --outform pem > ~/pki/private/server-key.pem
pki --issue --lifetime 1825 --cacert ~/pki/cacerts/ca-cert.pem \
    --cakey ~/pki/private/ca-key.pem --in ~/pki/private/server-key.pem \
    --type ed25519 --dn "C=BR, O=suavpn, CN=vpn.seudominio.com.br" \
    --san vpn.seudominio.com.br --flag serverAuth --flag ikeIntermediate \
    --outform pem > ~/pki/certs/server-cert.pem
```

##

### 🐧 Fase 2: Preparação do SO e Instalação de Pacotes

Instale o strongSwan e as dependências necessárias para a autenticação extauth/EAP. Em seguida, mova os certificados gerados para a estrutura oficial do daemon ipsec.

```bash
# 1. Atualização da base e instalação dos pacotes estáveis
apt update && apt upgrade -y
apt install -y strongswan strongswan-pki \
    libcharon-extra-plugins libcharon-extauth-plugins

# 2. Implantação dos certificados nos diretórios de produção do ipsec
cp ~/pki/cacerts/ca-cert.pem /etc/ipsec.d/cacerts/
cp ~/pki/certs/server-cert.pem /etc/ipsec.d/certs/
cp ~/pki/private/server-key.pem /etc/ipsec.d/private/
```

##

### ⚙️ Fase 3: Configuração do strongSwan (ipsec.conf e ipsec.secrets)

Configure o daemon de criptografia, as diretrizes de conexões e as credenciais.

1. Arquivo de Configuração Principal (`/etc/ipsec.conf`)

Faça backup do arquivo original e crie um novo:

```bash
mv /etc/ipsec.conf /etc/ipsec.conf.bkp
nano /etc/ipsec.conf
```

Insira as configurações abaixo:

```bash
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=never

conn %default
    keyexchange=ikev2
    # Ciphersuites modernas
    ike=aes256gcm16-prfsha256-ecp256,aes256-sha256-modp2048!
    esp=aes256gcm16-ecp256,aes256-sha256!
    dpdaction=clear
    dpddelay=300s
    rekey=no
    
    # Configurações do Lado Servidor (Left)
    left=%any
    leftid=@vpn.suaempresa.com.br
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0 # Full Tunnel
    
    # Configurações do Lado Cliente (Right)
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=1.1.1.1,8.8.8.8
    rightsendcert=never
    eap_identity=%identity

conn ikev2-vpn
    auto=add
```

2. Arquivo de Credenciais (`/etc/ipsec.secrets`)

Este arquivo mapeia a chave privada do servidor e centraliza os usuários/senhas do MSCHAPv2.

```bash
# Chave privada do servidor VPN
: Ed25519 server-key.pem

# Usuários Road Warrior (EAP-MSCHAPv2)
joao.silva : EAP "SenhaForteDoJoao123!"
maria.souza : EAP "SenhaForteDaMaria456!"
```

##

### 🛡️ Fase 4: Permissões, Roteamento e Regras de Firewall

O sistema operacional precisa encaminhar pacotes da subnet virtual da VPN para a interface física e permitir as portas de negociação IPsec.

```bash
# 1. Ativação do Encaminhamento de Pacotes IPv4 (IP Forwarding)
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 2. Configuração do Masquerade (NAT) e liberação de portas (Supondo eth0 como WAN)
nano /etc/ufw/before.rules

# Insira o bloco abaixo no topo do arquivo, logo após os comentários de cabeçalho, mas antes da linha *filter:
# ==========================================
# REGRAS NAT - ROTEAMENTO DA VPN
# ==========================================
*nat
:POSTROUTING ACCEPT [0:0]
# Faça o Masquerade da subnet da VPN saindo pela interface WAN (eth0)
-A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
COMMIT

# Liberação do IKE (Internet Key Exchange)
ufw allow 500/udp

# Liberação do NAT-T (NAT Traversal)
ufw allow 4500/udp

# Liberação do tráfego encapsulado ESP (Protocolo IP 50)
ufw allow proto esp

# Desativa e ativa para garantir o flush correto das tabelas iptables subjacentes
ufw disable
ufw enable

# Verifique o status para confirmar
ufw status
```

Dessa forma, a configuração fica persistente (resistente a reboots), declarativa e aderente ao framework de gerência de configuração que o UFW impõe ao sistema operacional base.

##

### 🚀 Fase 5: Serviço Systemd e Gestão de Conexões

Como estamos utilizando a estrutura clássica, o gerenciamento do daemon é feito diretamente pelo comando ipsec.

1. Reinicie o serviço para carregar os certificados, segredos e conexões:

```bash
systemctl restart ipsec
systemctl enable ipsec
systemctl status ipsec
```
2. Monitoramento de Sessões via CLI:

Você pode validar os túneis ativos e os logs de conexão diretamente do console do servidor:

```bash
# Exibe o status geral da VPN e sessões ativas (SAs)
ipsec statusall

# Para verificar falhas ou logs de negociação IKE
tail -f /var/log/syslog | grep charon

# Monitorar tráfego IPsec em tempo real na interface física
tcpdump -lnni eth0 udp port 500 or udp port 4500 or esp
```

##

### 💡 Dicas

  * **Recarregando Credenciais:** Se você adicionar novos usuários no arquivo `ipsec.secrets`, não é necessário reiniciar toda a VPN. Basta rodar o comando `ipsec rereadsecrets`.

  * **Entrega ao Usuário:** Forneça apenas o arquivo `ca-cert.pem` gerado na Fase 1 para os usuários instalarem em seus dispositivos (Windows/iOS/Android) no repositório de Autoridades de Certificação Raiz Confiáveis. O tipo de conexão deve ser configurado como IKEv2 por Usuário/Senha.

  * **Troubleshooting:** Caso usuários de Windows enfrentem falhas de conexão relacionadas a fragmentação, pode ser necessário ativar a fragmentação IKEv2 adicionando `fragmentation=yes` no arquivo `ipsec.conf`.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
