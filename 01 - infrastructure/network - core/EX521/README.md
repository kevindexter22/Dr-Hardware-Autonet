<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/network - core/EX521/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🖧 Edge Router: Roteador EX521 (Gateway Principal)

### 📝 Descrição do Ativo
Este equipamento atua como o roteador de borda (Gateway L3) do laboratório, responsável por receber o link físico do provedor de internet (ISP), gerenciar o NAT (Network Address Translation) e segmentar a rede local inicial.

##

### ⚙️ Papéis e Serviços Ativos
* **Serviço de Borda:** Recebe IP estático/PPPoE do provedor na interface `WAN`.
* **Roteamento Interno:** Roteia o tráfego da subnet principal `<LAN_SUBNET_CIDR>`.
* **Port Forwarding:** Regras ativas para direcionamento de tráfego HTTPS e túneis VPN para o nó de virtualização interno.

##

### 🔒 Política de Acesso (SecOps)
* Acesso administrativo via porta web (`TCP/<CUSTOM_ADMIN_PORT>`) restrito apenas para IPs da rede de gerência.
* Broadcast de SSID do Wi-Fi Administrativo configurado como oculto (Hidden SSID).

##

### 📂 Sobre os Arquivos de Configuração
O arquivo `config-backup-sanitized.txt` contém a extração da configuração do roteador com dados sensíveis mascarados. Para restauração em caso de falha física, substitua as tags `< >` pelos valores reais documentados no cofre de senhas *offline* do laboratório.

##
