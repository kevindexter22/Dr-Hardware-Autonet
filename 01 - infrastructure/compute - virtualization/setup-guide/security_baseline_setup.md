<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/security_baseline_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛡️ SOP: OS Security Baseline & Hardening

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
   ***Nota Arquitetural:*** *Em ambientes de produção, recomenda-se alterar PasswordAuthentication para no, forçando o uso       exclusivo de chaves criptográficas (RSA/Ed25519).*<br>
3. Reinicie o serviço ssh para aplicar as alterações:
   ```bash
   sudo systemctl restart ssh
   ``` 
