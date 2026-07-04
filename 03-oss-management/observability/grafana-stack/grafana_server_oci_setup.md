# 📊 SOP: Instalação do Grafana Server (Oracle Cloud - OCI)

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a instalação do Grafana Server (frontend no Apache) em uma instância Ubuntu 24.04 hospedada na Oracle Cloud Infrastructure (OCI).

Sendo o nó central (Core) da arquitetura de monitoramento, este servidor será responsável por abrigar as dashboards que faremos com os dados coletados pelo Zabbix.

##

### 🛠️ Fase 1: Deploy da Aplicação (Grafana OSS)

Instalaremos o Grafana isolando-o em sua porta padrão (TCP/3000), garantindo que não haja colisão com o frontend do Zabbix (que roda no PHP-FPM/Apache).

1. Importação da Chave Criptográfica e Repositório:

Garante a integridade dos pacotes da camada de software.

```bash
sudo apt install -y apt-transport-https software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```
2. Instalação e Orquestração do Serviço:

```bash
sudo apt update
sudo apt install grafana -y
```

3. Ativação no Control Plane (systemd):

Configure o daemon para iniciar autonomamente em caso de reboot da OCI (redução de MTTR).

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

##

🔀 Fase 2: Arquitetura Lógica de Roteamento (Proxy Reverso)

O Apache será instruído a atuar como um Gateway de Aplicação para o domínio do Grafana.

1. Validação de Módulos de Integração:

Certifique-se de que o motor de proxy do Apache está habilitado para realizar o encaminhamento de pacotes HTTP.

***Observação:*** caso tenha instalado o Zabbix Server na mesma instância seguindo a documentação desse repositório, essa habilitação já deve estar feita. Nesse caso basta pular para a próxima etapa.

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
```

###

2. Criação do Virtual Host (SNI):

Crie o arquivo de configuração de roteamento específico para o Grafana.

```bash
sudo nano /etc/apache2/sites-available/grafana.conf
```

3. Insira o bloco lógico abaixo (substitua grafana.seu-dominio.com pelo seu subdomínio real):

```bash
<VirtualHost *:80>
    ServerName grafana.seu-dominio.com

    # Preserva o cabeçalho original da requisição HTTP
    ProxyPreserveHost On

    # Encaminhamento do tráfego da Camada 7 para o socket local do Grafana
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    # Gerência de Falhas: Isolamento de Logs
    ErrorLog ${APACHE_LOG_DIR}/grafana_error.log
    CustomLog ${APACHE_LOG_DIR}/grafana_access.log combined
</VirtualHost>
```

4. Aplicação do Roteamento (Graceful Reload):

Ative o novo bloco e recarregue o Apache sem derrubar as sessões ativas do Zabbix.

```bash
sudo a2ensite grafana.conf
sudo systemctl reload apache2
```

##

# 🔒 Fase 3: Provisionamento Criptográfico (TLS/SSL)

Com o roteamento HTTP validado, aplicamos a camada de segurança para encriptar o tráfego da interface de gerência.

1. Emissão de Certificado Isolado:

Utilize o Certbot (já instalado na sua arquitetura) para invocar o desafio HTTP-01 e gerar o certificado exclusivamente para o subdomínio do Grafana.

```bash
sudo certbot --apache -d grafana.seu-dominio.com
```

* ***Nota:*** *Quando o assistente do Certbot perguntar se deseja redirecionar o tráfego (Redirect HTTP to HTTPS), opte por Yes.* <br>
  *Isso forçará a encriptação ponta-a-ponta.*

##

### 🧩 Fase 4: Integração de Sistemas (API Zabbix-Grafana)

Para que o Grafana consuma os dados de telemetria do seu Zabbix Server local, você precisará instalar o plugin oficial de mediação de dados.

1. Instalação do Plugin Alexander Zobnin:

```bash
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl restart grafana-server
```

* ***Post-Deployment Check:*** *Acesse `https://grafana.seu-dominio.com`, faça o login inicial (usuário: admin, senha: admin) e configure o Data Source apontando para a API local do seu Zabbix (http://localhost/zabbix/api_jsonrpc.php ou a URL interna configurada no seu ambiente).

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
