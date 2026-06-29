<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03 - oss - management/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 👁️ Gerenciamento OSS (Operations Support Systems)

### 📝 Descrição do Domínio

Este diretório atua como o **Plano de Gerenciamento (Management Plane)** do laboratório. Baseado no framework global **FCAPS**, esta camada abriga todas as *stacks* e plataformas responsáveis por manter a saúde, a segurança e a visibilidade ativa de toda a infraestrutura física e virtual.

As ferramentas contidas aqui não são aplicações de consumo final (Workloads), mas sim os sistemas críticos que vigiam a fundação de rede e servidores (Network Core & Compute).

---

### 🏗️ Arquitetura de Domínios

#### 📊 1. Observability (F e P do FCAPS)
Responsável pela Gestão de Falhas (*Fault*) e Desempenho (*Performance*). Centraliza a coleta de métricas, telemetria L2-L7 e análise de logs do laboratório.
* **`myspeed/`**: Stack para monitoramento automatizado de qualidade de link (*throughput* e latência recorrentes).
* **`zabbix-stack/`**: Ecossistema principal de monitoramento via agentes e interrogadores (*Proxies*, *Agents* e *Templates*).

#### 🔐 2. Security & IAM (S do FCAPS)
Responsável pela Gestão de Segurança (*Security*). É o núcleo de Identidade e Controle de Acesso da rede.
* Abriga as stacks de *Identity and Access Management* (IAM), como provedores de *Single Sign-On* (SSO), diretórios de usuários (LDAP/Active Directory) e controle de autenticação de rede (RADIUS, FREEIPA).

#### 🚨 3. Alerts & Mediation
Responsável por orquestrar a inteligência de incidentes.
* Recebe os gatilhos brutos da camada de *Observability*, filtra ruídos e roteia alertas acionáveis para os canais de notificação corretos (Webhooks, Telegram, N8N, e-mail).

---

### 🛠️ Padrão de Organização (GitOps)

Cada ferramenta dentro destes subdiretórios é tratada como uma **Stack Coesa**. Seguindo as práticas de SRE, dentro da pasta de cada ferramenta (ex: `zabbix-stack`), você encontrará tudo o que pertence a ela:
* Manifestos Declarativos (`docker-compose.yaml`).
* Guias de Instalação Base e Manuais (SOPs).
* Arquivos de configuração específicos e *scripts* de manutenção.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
