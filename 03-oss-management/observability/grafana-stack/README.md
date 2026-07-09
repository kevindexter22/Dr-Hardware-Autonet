# 📊 Grafana Stack

### 📝 Descrição do Escopo

Bem-vindo ao diretório da Grafana Stack do projeto.

Este ambiente é a camada visual (Frontend) da nossa arquitetura de observabilidade. 

O objetivo principal do Grafana aqui é centralizar, cruzar e exibir os dados brutos coletados pela nossa infraestrutura, transformando-os em dashboards acionáveis.

##

### 🗂️ Estrutura do Diretório

A organização desta stack foi dividida nas seguintes subpastas para facilitar a manutenção e evolução do ambiente:

* 📁 `/grafana-server`: Contém os Procedimentos Operacionais Padrão (SOPs) para provisionamento, instalação e configuração do servidor Grafana (hospedado na Oracle Cloud - OCI), além das configurações de túnel VPN para acesso à rede local.

* 📁 `/integrations:` Guias de conexão com nossas fontes de dados (Data Sources), instalação de plugins e mapeamento de métricas.

* 📁 `/maintenance:` Scripts de backup, rotinas de atualização, exportação de dashboards como código (JSON) e troubleshooting geral.

##

### 🔌 Fontes de Dados (Data Sources)

Nesse cenário o Grafana atua como um painel de vidro único (single pane of glass) consumindo dados de dois motores principais:

1. **Zabbix (Métricas e Alertas):**

    * **Função:** Monitoramento ativo de saúde da infraestrutura (CPU, RAM, tráfego de rede, status de serviços, ICMP ping).

    * **Integração:** Realizada via plugin oficial do Zabbix (Zabbix API).

2. **Loki (Agregação de Logs):**

   * **Função:** Recebimento e indexação de logs de rede e aplicações (ex: logs de consultas DNS do Pi-hole/AdGuard coletados via go-dnscollector).

   * **Integração:** Realizada via consulta direta LogQL através de túnel VPN seguro (IPsec).

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
