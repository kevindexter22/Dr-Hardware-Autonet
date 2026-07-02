# 🔒 SOP: Provisionamento Zero-Touch de SSL (DNS-01) - Proxmox VE (Direct DDNS Mode)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a automação e gerência do ciclo de vida de certificados SSL/TLS (Let's Encrypt) no hypervisor Proxmox VE utilizando exclusivamente um provedor de DNS Dinâmico gratuito (DuckDNS).

O objetivo é estabelecer uma arquitetura de segurança de borda utilizando o desafio DNS-01 Direto (Point-to-Point). Por não utilizar um domínio customizado (TLD), este modelo possui uma topologia simplificada, eliminando a necessidade de delegações lógicas (CNAME). O Proxmox integra-se diretamente via API com o DuckDNS para injetar a chave de validação e emitir o certificado, garantindo a criptografia do tráfego de gerência sem a necessidade de expor portas TCP (80/443) à internet pública.

##

### 📋 Pré-requisito:

* É necessário já ter acessado o site [duckdns](https://www.duckdns.org/) e já ter logado com sua conta google ou github e já ter cadastrado um subdomínio.
* Após feito isso basta copiar o ***Token*** que aparecerá na parte superior do site e continuar com os passos abaixo.

##

### 🧹 Fase 1: Saneamento e Preparação (Control Plane)

Antes de estabelecer a nova arquitetura, é imperativo garantir a integridade do banco de dados de configuração do cluster (PMXCFS), expurgando quaisquer configurações de domínios anteriores ou tentativas de apontamentos Alias.

1. Acesse o terminal do Proxmox (via SSH ou Web Shell).
2. Remoção de Estado Anterior: Execute o comando abaixo para deletar o escopo do domínio antigo e evitar conflitos de schema:
   ```bash
   pvenode config delete acmedomain0
   ```
3. Garanta que você possui o Token alfanumérico fornecido no painel do DuckDNS e o nome do seu subdomínio ativo (ex: seu-lab.duckdns.org).

##

### ⚙️ Fase 2: Integração de API e Mediação (Hypervisor)

Preparação do cliente ACME nativo no Proxmox para autenticação direta no serviço de DNS Dinâmico.

1. Na interface web do Proxmox, em nível de Datacenter (painel esquerdo), navegue até ***ACME***.
2. Registro de Account: Na seção ***Accounts***, clique em Add. Adicione uma nova identidade selecionando o diretório ***Let's Encrypt V2*** e vinculando um e-mail válido para notificações operacionais.
3. Aceite os termos (TOS) e clique em ***create***.
4. Injeção de Credenciais (Plugin): Na seção ***Challenge Plugins***, clique em Add para criar o conector:
   * **Plugin ID:** duckdns
   * **DNS API:** DuckDNS
   * **API Data:** DuckDNS_Token=<SEU_TOKEN_ALFANUMERICO>
   * **Validation Delay:** 300 (Threshold necessário para garantir a propagação do registro TXT nos servidores autoritativos globais).

##

### 🚀 Fase 3: Orquestração e Emissão (Via CLI)

Com o conector de API estabelecido, parametrizamos o Nó para associar o domínio diretamente ao plugin, sem o uso de redirecionamentos.

1. Retorne ao Shell do Proxmox.
2. Injete o estado desejado de configuração ACME associando o seu subdomínio ao plugin de forma atômica:
   ```bash
   pvenode config set --acmedomain0 domain=seu-lab.duckdns.org,plugin=duckdns
   ```
3. Dispare o gatilho de provisionamento manual para validar a cadeia de confiança e emitir o certificado:
   ```bash
   pvenode acme cert order
   ```
##

### ✅ Fase 4: Validação e Gerênciamento do Ciclo de Vida

Após a execução do order, o terminal exibirá o log de orquestração: a API do DuckDNS receberá o registro TXT, o Proxmox entrará em sleep por 300 segundos, e a Let's Encrypt validará o desafio com sucesso.

   * **Handover de Interface:** O serviço HTTP do hypervisor (pveproxy) fará o download das chaves (.pem e .key) e executará um graceful reload silencioso. O acesso de gerência passará a ser feito de forma segura e criptografada (Cadeado Verde) exclusivamente pela URL: https://seu-lab.duckdns.org:8006.
   * **Zero-Touch Provisioning (Renovação Automática):** A infraestrutura passa a operar de forma autônoma. Faltando exatos 30 dias para a expiração (o ciclo total é de 90 dias), o daemon nativo do sistema operativo (pve-daily-update.service) acionará as rotinas da Fase 3 em background. As chaves serão rotacionadas sem causar indisponibilidade (Zero Downtime) e sem qualquer intervenção humana, otimizando o OPEX da operação.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
