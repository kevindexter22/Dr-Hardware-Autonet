# 🔗 SOP: Zabbix Server - Habilitação do proxy para apache2

### 📝 Descrição do Escopo

Este Procedimento Operacional Padrão (SOP) detalha a configuração do apache2 no servidor do ***Zabbix Server 7.0 LTS*** para a instalação e integração com o ****Grafana*** que será responsáveis pelas *dashboards* da nossa infraestrutura.

##

### ⭐ Fase 1: Habilitação de Módulos (Camada de Integração)

O Apache precisa dos módulos de proxy e tráfego HTTPS ativados para conseguir ler as requisições que chegam e roteá-las internamente.

No terminal da sua instância OCI, execute:

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
```

* ***Nota:*** *Os comandos acima utilizam o padrão Debian/Ubuntu. Se você estiver usando Oracle Linux/RHEL, os módulos são habilitados no arquivo httpd.conf*

##

### 🗄️ Fase 2: Arquitetura Lógica de Virtual Hosts (SNI)

Vamos criar dois blocos lógicos separados. O Apache interceptará a requisição na porta 80 (e futuramente na 443) e fará o direcionamento com base no cabeçalho Host da requisição HTTP.

1. Configuração do Zabbix (Servidor Nativo)

Crie um arquivo para o Zabbix (ex. `/etc/apache2/sites-available/zabbix.conf`). <br>
Verifique o `DocumentRoot` exato da sua instalação (geralmente é /usr/share/zabbix).

```bash
<VirtualHost *:80>
    ServerName zabbix.seu-dominio.com
    DocumentRoot /usr/share/zabbix

    <Directory "/usr/share/zabbix">
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/zabbix_error.log
    CustomLog ${APACHE_LOG_DIR}/zabbix_access.log combined
</VirtualHost>
```

* ***Observação:*** Caso não possua um dominio, adicione o IP Público da instância na opção `ServerName`. 

2. Ative o novo site e recarregue o serviço:

```bash
sudo a2ensite zabbix.conf
sudo systemctl reload apache2
```

##

**☢️ Alerta de Segurança:**

* Realize a configuração de um [certificado SSL](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-server/zabbix_server_oci_ssl_certificate.md) para o apache.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.


