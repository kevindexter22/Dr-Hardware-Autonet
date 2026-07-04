# 🔌 SOP: Integração Grafana & Zabbix (Data Source)

### 📝 Descrição

Este documento estabelece o Procedimento Operacional Padrão (SOP) para conectar o **Grafana** (camada de visualização e dashboards) ao **Zabbix Server** (camada de telemetria e coleta de dados).

A integração é realizada através do plugin oficial e utiliza a API JSON-RPC do Zabbix. Como ambos os serviços operam na mesma instância, a comunicação é roteada internamente (`localhost`), o que elimina o tráfego externo, reduz a latência de consultas e aumenta a segurança da arquitetura.

##

### 🛠️ Passo 1: Instalação do Plugin (CLI)

Acesse o terminal do servidor via SSH e instale o conector diretamente pelo repositório do Grafana:

***Observação:*** *caso tenha feito a instalação seguindo o documento nesse repositório, a instalação já foi feita. Nesse caso basta pular para a próxima etapa.*

```bash
# Instala o plugin oficial do Zabbix (by Alexander Zobnin)
sudo grafana-cli plugins install alexanderzobnin-zabbix-app

# Reinicia o serviço para aplicar a instalação
sudo systemctl restart grafana-server
```

##

### 🌐 Passo 2: Ativação no Painel Web

Após a instalação no nível do sistema operacional, o módulo deve ser ativado na interface do Grafana:

1. Acesse o painel web do Grafana e faça o login administrativo.

2. No menu lateral esquerdo, navegue até Administration > Plugins and data > Plugins.

3. Na barra de pesquisa, digite `Zabbix` e clique no card correspondente.

4. Clique no botão azul Enable para habilitar o plugin no sistema.

##

### 🔗 Passo 3: Configuração do Data Source

Com o componente ativo, estabeleça a ponte de dados entre as duas plataformas:

1. No menu lateral do Grafana, vá em Connections > Data sources.

2. Clique no botão Add data source e selecione Zabbix.

3. Na configuração de HTTP, preencha o campo URL com o caminho da API local:
   * `http://localhost/zabbix/api_jsonrpc.php`

***Nota de Arquitetura:*** *O uso do protocolo HTTP via localhost ignora propositalmente o proxy reverso (Apache/SSL), evitando processamento criptográfico desnecessário para o tráfego interno da máquina.*

4. Role a página até encontrar a seção Zabbix API details.

5. Preencha as credenciais de acesso:
   * Username: Usuário com permissão de leitura no Zabbix (ex: Admin).
   * Password: Senha de acesso ou Token.

***Melhor prática de segurança:*** *Para ambientes de produção (Zabbix 7.0+), recomenda-se acessar o Zabbix em Users > API tokens e gerar um token de autenticação sem expiração exclusivo para o Grafana. Utilize este token em substituição à senha tradicional.*

6. Role até o rodapé da página e clique em Save & Test.

##

### ✅ Critério de Sucesso: 

Um prompt verde de notificação confirmará o sucesso da conexão informando a versão detectada da API (ex: Zabbix API version: 7.0.x). A partir deste momento, os dados já estão disponíveis para a construção de Dashboards.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
