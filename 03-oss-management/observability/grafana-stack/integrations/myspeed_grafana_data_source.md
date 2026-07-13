<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/integrations/myspeed_grafana_data_source_integration.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🔌 SOP: Integração Grafana & MySpeed (Infinity Data Source)

### 📝 Descrição

Este documento estabelece o Procedimento Operacional Padrão (SOP) para integrar o **Grafana** (Camada de Apresentação) ao **MySpeed** (Motor de Testes de Desempenho e Capacidade).

A arquitetura utiliza o plugin **Infinity** para realizar o *polling* direto via REST API. Esta abordagem *serverless* elimina a necessidade de um Banco de Dados de Séries Temporais (TSDB) intermediário, reduzindo o *footprint* da infraestrutura e garantindo a auditoria de SLA (Acordo de Nível de Serviço) da operadora de forma eficiente.

##

### 🛠️ Passo 1: Instalação do Plugin

Como o MySpeed não possui um Data Source nativo, utilizamos o Infinity Data Source (desenvolvido pela comunidade) para consumir o JSON da API.

```bash
# Faz o download do plugin REST/JSON
sudo grafana cli plugins install yesoreyeram-infinity-datasource

# Reinicia o serviço da camada de apresentação
sudo systemctl restart grafana-server
```

##

### 🌐 Passo 2: Configuração do Data Source

Com o componente instalado, registre o mapeamento da API no Grafana:

  * No menu lateral do Grafana, navegue até `Connections > Data sources`.

  * Clique no botão `Add data source` e procure por Infinity.

  * Na configuração principal (`Authentication/Network`), a arquitetura do MySpeed permite conexão anônima para leitura. Não é necessário preencher credenciais ou Tokens.

  * Role até o rodapé e clique em `Save & Test`.

## 

### 🔗 Passo 3: Parametrização da Query (Dashboard)

A integração ocorre ativamente na criação dos painéis, onde o Grafana fará a requisição On-Demand ao banco interno (SQLite) do MySpeed.

Em um Dashboard, crie um novo Painel e selecione `Infinity` como Data Source.

Configure os parâmetros de extração lógica:

   * **Type:** `JSON`

   * **Parser:** `Default`

   * **Method:** `GET`

   * **URL:** `http://<IP_DO_MYSPEED>:<PORTA>/api/speedtests`

***Nota de Arquitetura (Integração L2/L3):*** *Se ambos os contêineres estiverem operando na mesma rede Docker bridge, substitua o IP pelo hostname interno da stack, ex: http://myspeed:5216/api/speedtests.*

Na aba de Parsing, mapeie as colunas extraídas do JSON para formatar a Série Temporal:

   * Coluna `timestamp` -> Tipo: DateTime

   * Colunas `download`, `upload`, `ping` -> Tipo: Number

***Melhor Prática de Gestão de Desempenho (FCAPS):*** *Recomenda-se ajustar a engine do MySpeed (Cron) para realizar testes estritamente em duas janelas diárias: Ociosidade (ex: 04:00) e Pico de Tráfego (ex: 16:00). No Grafana, utilize o visual de "Barras" ao invés de "Linhas", contrastando a entrega máxima nominal contra a entrega sob saturação.*

##

### ✅ Critério de Sucesso:

A integração será considerada validada quando o painel do Grafana renderizar os blocos do gráfico, atestando que o payload JSON foi recebido com status HTTP 200 OK e parseado corretamente na visualização, sem a ocorrência de erros de Timeout ou CORS.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
