
# 🛡️ SOP: Provisionamento de SSL (certbot) na OCI para o Zabbix Server

### 📝 Descrição e Escopo

Como a ideia é gerar um certificado para cada serviço que teremos nesse servidor (evitando um único certificado multi-domínio do tipo SAN - Subject Alternative Name), faremos invocações separadas do Certbot. 

O plugin do Apache fará o parsing dos arquivos que acabamos de criar, validará os domínios via HTTP-01 e reescreverá a configuração para habilitar a porta 443.

##

### 🌐 Fase 1: Instalação do Certbot e do plugin (se ainda não o tiver):

1. Para instalar, utilizamos o comando:

```bash
sudo apt update && sudo apt install certbot python3-certbot-apache -y
```

2. Para emitir um certificado do Zabbix Server isolado, rodamos o comando:

**Importante:** *O domínio aqui deve ser o mesmo configurado em `ServerName` na configuração do apache.*

```bash
sudo certbot --apache -d zabbix.seu-dominio.com
```

* *Durante a execução, o Certbot perguntará se você deseja redirecionar o tráfego HTTP para HTTPS (Redirect). Selecione Sim (Option 2). Isso implementará a segurança em Camada 7 automaticamente.*

##

### Fase 2: Automação e Gerência de Ciclo de Vida (MTTR)

No ecossistema Certbot instalado via pacote do SO, não precisamos configurar cron manualmente (como fizemos com o FreeIPA). O sistema já insere um systemd timer que roda autonomamente a cada 12 horas para verificar se os certificados estão a menos de 30 dias da expiração.

Para auditar o funcionamento dessa automação no OSS, você pode rodar o simulador de renovação:

```bash
sudo certbot renew --dry-run
```

Após essa estrutura, o tráfego chegará no IP público da OCI, o Apache validará a chave TLS respectiva ao subdomínio solicitado e entregará a camada gráfica de forma isolada, limpa e com alta interoperabilidade.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
