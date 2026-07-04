<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/maintenance/grafana_server_upgrade.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🔄 SOP: Atualização do Grafana Server e Módulos

### 📝 Descrição

Este documento estabelece o Procedimento Operacional Padrão (SOP) para a atualização do **Grafana Server** e gerenciamento de seus plugins de integração (Data Sources).

A partir das versões estáveis recentes, a ferramenta de linha de comando legada `grafana-cli` foi depreciada. Este guia padroniza a nova sintaxe de execução do utilitário (`grafana cli`) e define as etapas necessárias para preservar as diretivas de proxy reverso e SSL configuradas no arquivo de parametrização global.

##

### 🛡️ Passo 1: Salvaguarda de Dados (Pre-Upgrade)

Realize a cópia dos arquivos de configuração e da base interna baseada em SQLite3 antes de prosseguir:

```bash
# 1. Backup do arquivo de parametrização de rede e segurança
sudo cp -a /etc/grafana/grafana.ini /etc/grafana/grafana.ini.backup_$(date +%F)

# 2. Backup do banco de dados interno de Dashboards e Usuários
sudo cp -a /var/lib/grafana/grafana.db /var/lib/grafana/grafana.db.backup_$(date +%F)
```

##

### 🛑 Passo 2: Paralisação do Processo

Interrompa a execução do servidor web do Grafana:

```bash
sudo systemctl stop grafana-server
```

##

### 🚀 Passo 3: Atualização do Core e Regras de Escopo

Execute a atualização pontual do binário do Grafana através do gerenciador de pacotes do sistema:

```bash
# Sincroniza os repositórios
sudo apt update

# Atualiza exclusivamente o pacote do Grafana
sudo apt install --only-upgrade grafana
```

**⚠️ Aviso Importante:** Durante a instalação, o sistema operacional poderá questionar sobre a substituição do arquivo `/etc/grafana/grafana.ini`. É mandatório responder `N (ou Keep your currently-installed version)` para manter as diretivas ativas de root_url e domain ajustadas para o Proxy Reverso com SSL.

##

### 🔌 Passo 4: Atualização de Plugins via Nova CLI

Caso os menus suspensos ou o mapeamento de hosts de integração apresentem falhas de renderização após o upgrade do Core, reinstale ou atualize o plugin utilizando a sintaxe atualizada (sem hífen):

```bash
# Utiliza a nova CLI para forçar a instalação do conector atualizado
sudo grafana cli plugins install alexanderzobnin-zabbix-app
```

##

### 🔄 Passo 5: Restabelecimento do Serviço

Inicie o Grafana e confirme a integridade operacional da aplicação:

```bash
# Reinicia o serviço no sistema
sudo systemctl start grafana-server

# Valida se o status retornou para active (running)
sudo systemctl status grafana-server
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
