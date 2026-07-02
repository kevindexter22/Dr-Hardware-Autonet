# 🔒 SOP: Provisionamento Zero-Touch de SSL (DNS-01) - Proxmox VE

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a automação e gerência do ciclo de vida de certificados SSL/TLS (Let's Encrypt) no hypervisor Proxmox VE.

O objetivo é estabelecer uma arquitetura de segurança de borda utilizando o desafio DNS-01 em Alias Mode (Delegação CNAME). Este modelo permite emitir certificados para um domínio de topo customizado (ex: .click, gerenciado por terceiros, como a Hostinger), delegando a validação para um provedor DDNS secundário (DuckDNS) via integração de API. 

Isso garante a criptografia do tráfego de gerência e a interoperabilidade de sistemas sem a necessidade de expor portas de entrada (TCP/80 ou TCP/443) à internet pública.

##

### ⚠️ Pré-requisito:

* É necessário já ter acessado o site [duckdns](https://www.duckdns.org/) e já ter logado com sua conta google ou github e já ter cadastrado um subdomínio.
* Após feito isso basta copiar o ***Token*** que aparecerá na parte superior do site e continuar com os passos abaixo.

##

### 🌐 Fase 1: Roteamento e Delegação DNS

Como provedores de DNS genéricos frequentemente não possuem integração nativa com o cliente ACME do Proxmox, criamos um desvio lógico (Alias) instruindo a Autoridade Certificadora a buscar a chave de validação de forma delegada.

1. Acesse o painel de Gerenciamento de Zona DNS do seu domínio principal (ex: Hostinger).
2. Mapeamento de Acesso Local (Camada 3): Crie um registro apontando para o host físico.

   * **Tipo:** A
   * **Nome:** proxmox (ou o hostname correspondente ao nó)
   * **Aponta para:** <IP_ESTATICO_LOCAL>

3. Delegação de Segurança (Passo Crítico):

   * Crie um registro CNAME para redirecionar o tráfego de validação ACME estritamente para a raiz do seu subdomínio DuckDNS.
     * **Tipo:** CNAME
     * **Nome:** _acme-challenge.proxmox
     * **Aponta para:** seu-lab.duckdns.org

    **Nota Arquitetural:** O alvo do CNAME não deve conter prefixos adicionais (_acme-challenge). O apontamento direto (Point-to-Point) para a raiz do domínio DDNS previne loops de roteamento e erros do tipo SERVFAIL na propagação da cadeia de confiança (evitando falsos positivos em regras de wildcard).

##

### ⚙️ Fase 2: Integração de API (Hypervisor)

Preparação do cliente ACME no Proxmox para autenticação no serviço delegado (DuckDNS).

1. Na interface web do Proxmox, em nível de Datacenter, navegue até ***ACME***.
2. Registro de Account: Na seção ***Accounts***, adicione uma nova identidade selecionando o diretório ***Let's Encrypt V2*** e vinculando um e-mail válido para notificações operacionais.
3. Injeção de Credenciais (***Plugin***): Na seção ***Challenge Plugins***, crie o conector de mediação:

   * **Plugin ID:** duckdns
   * **DNS API:** DuckDNS
   * **API Data:** DuckDNS_Token=<SEU_TOKEN>
   * **Validation Delay:** 300 (Threshold necessário para garantir a convergência e dissipação de cache dos servidores globais de DNS antes do disparo da validação).

##

### 🚀 Fase 3: Orquestração e Emissão (Via CLI)

Para garantir a aplicação do parâmetro Alias (que resolve a disparidade lógica entre o domínio .click solicitado e a API do duckdns utilizada), a configuração do Nó é executada de forma atômica via Shell.

1. Acesse o terminal do Proxmox (via SSH ou Web Shell).
2. Injete o estado desejado de configuração ACME associando o domínio, o plugin e o alvo da delegação de uma só vez:
   ```bash
   pvenode config set --acmedomain0 domain=proxmox.seu-dominio.click,plugin=duckdns,alias=seu-lab.duckdns.org
   ```
3. Dispare o gatilho de provisionamento manual para validar a emissão inicial:
   ```bash
   pvenode acme cert order
   ```
##

### ✅ Fase 4: Validação e Gerênciamento do Ciclo de Vida

Uma vez executado o passo anterior, o output do terminal registrará a injeção do TXT Record na API, o tempo de latência aguardado (300s) e o sucesso do desafio criptográfico.

  * **Handover de Interface:** O serviço HTTP nativo (pveproxy) aplicará as novas chaves assimétricas (.pem e .key) e realizará um graceful reload automaticamente, sem gerar indisponibilidade nas Máquinas Virtuais. O acesso via https://proxmox.seu-dominio.click:8006 estará validado (Cadeado Verde).
  * **Zero-Touch Provisioning (Renovação Automática):** Não é necessária a criação de cron jobs ou rotinas sistêmicas customizadas. O serviço nativo pve-daily-update.service efetua a gerência de estado de forma autônoma. Faltando exatos 30 dias para a expiração, o Proxmox repetirá as Fases 2 e 3 silenciosamente em background, zerando o custo operacional (OPEX) de manutenção do ciclo de vida da criptografia.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
