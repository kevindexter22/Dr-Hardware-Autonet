# 🎯 SOP: Túnel VPN IPsec (OCI ➔ CasaOS) para Grafana

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a configuração de um túnel VPN IPsec (IKEv2 com EAP-MSCHAPv2) utilizando o StrongSwan. O objetivo é interligar a nuvem (Instância OCI, a correr o Grafana) à rede local (CasaOS/Proxmox, a correr o Loki), permitindo que o Grafana consulte bases de dados internas de forma segura, sem a necessidade de expor portas para a internet pública.

##

### 🛡️ Fase 1: Configuração do Servidor VPN (CasaOS / Rede Local)

O servidor precisa de estar preparado para autenticar o cliente via certificado (para o servidor) e utilizador/palavra-passe (EAP) para o cliente.

1. Edite o ficheiro de segredos do StrongSwan no CasaOS:

```bash
sudo nano /etc/ipsec.secrets
```

2. Para evitar o erro EAP_MSCHAPv2 method failed e garantir que o servidor valide o cliente corretamente, utilize o formato %any para a associação EAP:

```bash
# Chave privada do certificado do servidor
: RSA "server-key.pem"

# Credenciais EAP para o cliente (OCI)
%any : EAP "sua_senha_segura"
```

3. Reinicie o serviço IPsec no CasaOS para aplicar as regras:

```bash
sudo ipsec restart
```

##

### ☁️ Fase 2: Instalação e Configuração do Cliente VPN (Oracle Cloud / Grafana)

A instância na OCI atuará como cliente, ligando-se à rede da sua casa para aceder ao IP interno do Loki.

1. Instalação do StrongSwan na OCI:

Antes de iniciar a configuração, precisamos de instalar o serviço IPsec e os plugins de autenticação (fundamentais para suportar o EAP-MSCHAPv2). No terminal da OCI (Ubuntu/Debian), execute:

```
sudo apt update
sudo apt install strongswan libcharon-extra-plugins -y
```

2. Configuração do IPsec (`ipsec.conf`):

Edite o ficheiro de configuração principal no cliente (OCI):

```bash
sudo nano /etc/ipsec.conf
```

Garanta que a ligação contenha a diretiva de identidade EAP exata (eap_identity) que coincidirá com o utilizador configurado no servidor:

```
conn vpn-lab
    # ... [As suas configurações de IP e certificados aqui] ...
    
    # Autenticação do servidor (remoto)
    rightauth=pubkey
    
    # Autenticação do cliente (local - OCI)
    leftauth=eap-mschapv2
    eap_identity="seu_usuario_novo"
    
    # Solicita um IP virtual da rede do CasaOS
    leftsourceip=%config
    auto=add
```

3. Autenticação (`ipsec.secrets`):

Edite o ficheiro de segredos na OCI para inserir a palavra-passe do túnel:

```bash
sudo nano /etc/ipsec.secrets
```

Adicione a credencial de autenticação:

```bash
seu_usuario_novo : EAP "sua_senha_segura"
```

4. Iniciar a Ligação VPN:

Derrube ligações presas e inicie o túnel recém-configurado:

```bash
sudo ipsec stop
sudo ipsec start
sudo ipsec up vpn-lab
```

*Se a ligação for bem-sucedida, o terminal retornará a mensagem connection 'vpn-lab' established successfully.*

##

📊 Fase 3: Ligação do Data Source no Grafana

Com o túnel estabelecido (`ESTABLISHED`), a OCI possui agora uma rota direta para a rede interna do seu laboratório.

1. Acesse o painel web do Grafana (hospedado na OCI).

2. Navegue até `Connections ➔ Data sources ➔ Add data source`.

3. Selecione a integração do Loki.

4. No campo URL, insira o endereço IP da rede local onde o Loki está rodando no LXC, seguido da porta 3100:

   * http://<IP_INTERNO_DO_LOKI>:3100 (Ex: http://192.168.1.50:3100)

5. Role até ao final e clique em `Save & Test`.

6. Se a VPN estiver encaminhando o tráfego corretamente, o Grafana retornará um alerta verde indicando ***"Data source successfully connected"***.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
