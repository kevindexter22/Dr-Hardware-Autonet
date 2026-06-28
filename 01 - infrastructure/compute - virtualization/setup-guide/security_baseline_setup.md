<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/security_baseline_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛡️ SOP: Base de Segurança e Endurecimento do SO

### 📝 Descrição e Escopo (SecOps)

Este Procedimento Operacional Padrão (SOP) define as diretrizes de endurecimento (*Hardening*) para o Sistema Operacional base (Ubuntu/Debian) dos nós de infraestrutura. 

O objetivo é reduzir a superfície de ataque, ofuscar portas padrão, aplicar políticas de *Default Deny* no firewall de host (UFW) e mitigar ataques de força bruta utilizando análise de logs (*Fail2ban*). Este baseline deve ser aplicado imediatamente após o *Bootstrap* inicial do servidor.

---

### 🔐 Fase 1: SSH Hardening (Ofuscação e Controle de Acesso)

A ofuscação da porta padrão (TCP/22) reduz drasticamente o ruído de *scanners* automatizados na rede.

1. Acesse o arquivo de configuração do *daemon* SSH:
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
   sudo ufw status verbose
   ```

##


