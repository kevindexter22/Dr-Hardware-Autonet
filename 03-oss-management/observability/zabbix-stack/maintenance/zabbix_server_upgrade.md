# 🔄 SOP: Atualização do Zabbix Server

### 📝 Descrição

Este documento estabelece o Procedimento Operacional Padrão (SOP) para realizar a atualização de pacotes e versões do **Zabbix Server** corporativo provisionado em ambiente de nuvem (ARM64). 

O objetivo deste procedimento é garantir a aplicação de correções de segurança e melhorias de performance na ramificação estável (ex: 7.0.x LTS) sem causar corrupção no banco de dados relacional ou sobrescrever arquivos de configuração customizados.

##

### 🛡️ Passo 1: Backup de Segurança (Pre-Upgrade)

Antes de iniciar qualquer alteração de pacotes, é obrigatório realizar o backup estrutural do serviço e dos dados históricos:

```bash
# 1. Backup do diretório de configuração do Zabbix
sudo cp -a /etc/zabbix /etc/zabbix_backup_$(date +%F)

# 2. Backup do banco de dados relacional (MySQL/MariaDB)
# Substitua 'root' pelo usuário correspondente, se necessário
mysqldump -u root -p zabbix > ~/zabbix_db_backup_$(date +%F).sql
```

##

### 🛑 Passo 2: Interrupção do Serviço

Para evitar a gravação de dados parciais ou inconsistências durante a substituição dos binários, pare o processo principal:

```bash
sudo systemctl stop zabbix-server
```

##

### 🚀 Passo 3: Atualização Seletiva de Pacotes

Para mitigar riscos, a atualização deve ser direcionada exclusivamente aos componentes do ecossistema Zabbix, evitando atualizações generalizadas do sistema operacional nesta janela:

```bash
# Atualiza os índices dos repositórios
sudo apt update

# Força o upgrade apenas dos pacotes do Zabbix
sudo apt install --only-upgrade zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent
```

**⚠️ Aviso de Configuração (Prompt do APT):** 
Se o gerenciador de pacotes perguntar se você deseja substituir o arquivo `/etc/zabbix/zabbix_server.conf` por uma nova versão do mantenedor, selecione `N` (Manter a versão atualmente instalada).

##

### 🔄 Passo 4: Inicialização e Homologação

Após a conclusão do download e instalação, reative o serviço e valide o comportamento dos logs:

```bash
# Inicia o processo core do Zabbix Server
sudo systemctl start zabbix-server

# Valida o status do serviço no systemd
sudo systemctl status zabbix-server

# Inspeciona as últimas 50 linhas do log à procura de erros de banco ou conexões
sudo tail -n 50 /var/log/zabbix/zabbix_server.log
```

***Nota de Análise:*** *Após atualizações, o painel web pode levar alguns instantes para sincronizar. Se necessário, limpe o cache do navegador (Ctrl + F5) e reinicie o servidor web com sudo systemctl restart apache2.*

##

### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
