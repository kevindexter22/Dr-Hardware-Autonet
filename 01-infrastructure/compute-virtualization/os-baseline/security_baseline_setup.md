<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/os-baseline/security_baseline_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛡️ SOP: Base de Segurança e Endurecimento do SO

### 📝 Descrição e Escopo (SecOps)

Este Procedimento Operacional Padrão (SOP) define as diretrizes de endurecimento (*Hardening*) para o Sistema Operacional base (Ubuntu/Debian) dos nós de infraestrutura. 

O objetivo é reduzir a superfície de ataque, ofuscar portas padrão, aplicar políticas de *Default Deny* no firewall de host (UFW) e mitigar ataques de força bruta utilizando análise de logs (*Fail2ban*). Este baseline deve ser aplicado imediatamente após o *Bootstrap* inicial do servidor.

##

### 🔐 Fase 1: SSH Hardening (Ofuscação e Controle de Acesso)

A ofuscação da porta padrão (TCP/22) reduz drasticamente o ruído de *scanners* automatizados na rede.

1. Acesse o servidor via ssh e abra o arquivo de configuração do *daemon* SSH:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Modifique as seguintes diretivas (descomentando se necessário):
   ```bash
   Port <CUSTOM_PORT_SSH>
   PermitRootLogin no
   PubkeyAuthentication yes
   ```
   ***Nota Arquitetural:*** *Em ambientes de produção, recomenda-se alterar PasswordAuthentication para no, forçando o uso       exclusivo de chaves criptográficas (RSA/Ed25519).*
3. Reinicie o serviço ssh para aplicar as alterações:
   ```bash
   sudo systemctl restart ssh
   ```

##

### 🧱 Fase 2: Host Firewall (UFW - Uncomplicated Firewall)

A política de segurança L3/L4 adota o princípio de *Zero Trust* local (Default Deny), ou seja, o tráfego de entrada só é permitido se declarado.

1. Primeiramente garanta que o UFW está devidamente instalado:
   ```bash
   sudo apt update; sudo apt install ufw -y
   ```
2. Defina as políticas padrão (Bloqueia entrada, permite saída):
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```
3. **CRÍTICO:** Libere a nova porta SSH antes de ativar o firewall para evitar lockout:
   ```bash
   sudo ufw allow <CUSTOM_SSH_PORT>/tcp
   ```
4. Libere as portas dos serviços que estão rodando nesse host (ex. web, samba, etc.):
   ```bash
   # Portas TCP
   sudo ufw allow <SERVICE_PORT>/tcp comment "Serviço que a porta atende"
   # Portas UDP
   sudo ufw allow <SERVICE_PORT>/udp comment "Serviço que a porta atende"
   # Portas tanto TCP como UDP
   sudo ufw allow <SERVICE_PORT> comment "Serviço que a porta atende"
   ```
5. Ative o firewall:
   ```bash
   sudo ufw enable
   ```
6. Valide a tabela de regras:
   ```bash
   sudo ufw status
   ```

##

### 🚨 Fase 3: IPS Local e Prevenção de Intrusão (Fail2ban)

O Fail2ban atua como um IPS (Intrusion Prevention System) baseado em host, monitorando os logs do sistema e injetando regras dinâmicas no iptables/UFW para banir IPs maliciosos.

1. Instale o pacote utilizando o comando:
   ```bash
   sudo apt update; sudo apt install fail2ban -y
   ```
2. Crie uma cópia local do arquivo de configuração (evita sobreposição em atualizações de pacote):
   ```bash
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   ```
3. Edite o arquivo local para configurar a Jail do SSH:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```
4. Localize a seção [sshd] e altere a porta para coincidir com o ajuste feito na Fase 1, ativando a regra:
   ```bash
   [sshd]
   enabled = true
   port    = <CUSTOM_SSH_PORT>
   logpath = %(sshd_log)s
   backend = %(sshd_backend)s
   maxretry = 3
   bantime = 3600
   ```
   - `maxretry` = 3: Bane o IP após 3 tentativas falhas.
   - `bantime` = 3600: Tempo de banimento (em segundos, ex: 1 hora).
5. Iniciando o serviço:
   ```bash
   sudo systemctl enable fail2ban
   systemctl restart fail2ban
   ```

##

### 🛡️ Configuração do Banner de Segurança (SSH)

Como parte das nossas políticas de SecOps e conformidade (Compliance), todos os servidores devem exibir um aviso legal antes da autenticação SSH, desencorajando acessos não autorizados.

1. Edite o arquivo de mensagens de rede do sistema:
   ```bash
   sudo nano /etc/issue.net
   ```
2. Insira o banner padrão da sua empresa/rede:
   ```bash
   ***************************************************************************
                              A V I S O

   Este e um sistema privado pertencente ao lab Dr. Hardware Autonet.
   O acesso e restrito a usuarios autorizados. Todas as conexoes sao 
   registradas e monitoradas (Auditadas). O acesso nao autorizado
   resultara em desconexao imediata e possiveis sancoes.

   ***************************************************************************
   ```
3. Configure o daemon do SSH para exibir o arquivo:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
4. Procure pela diretiva Banner (ou adicione-a no final do arquivo):
   ```bash
   Banner /etc/issue.net
   ```
5. Reinicie o serviço SSH para aplicar a política:
   ```bash
   sudo systemctl restart ssh
   ```

##

### ✅ Fase 4: Validação Operacional (Anti-Lockout)

Agora vamos garantir que não haverá bloqueio do acesso via SSH após aplicar as configurações.

**Observação:** Não feche o terminal atual onde você executou estas configurações, para não perder o acesso caso os ajustes não tenham sido devidamente aplicados.

1. Abra um segundo terminal na sua máquina local.
2. Tente estabelecer uma nova conexão SSH utilizando a porta customizada:
   ```bash
   ssh <SEU_USUÁRIO>@<IP_DO_SERVIDOR> -p <cCUSTOM_SSH_PORT>
   ``` 
3. Valide se o Fail2ban está operando corretamente e monitorando o SSH:
   ```bash
   sudo fail2ban-client status sshd
   ```
4. Se o acesso na janela 2 for bem-sucedido, o *Baseline* de Segurança foi implementado com êxito e a janela 1 pode ser encerrada.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
