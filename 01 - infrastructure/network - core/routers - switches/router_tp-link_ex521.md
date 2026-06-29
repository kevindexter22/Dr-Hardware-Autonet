<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/network - core/routers - switches/router_tp-link_ex521.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🖧 Edge Router: Roteador EX521 (Gateway Principal)

### 📝 Descrição do Ativo
Este equipamento atua como o roteador de borda (Gateway L3) do laboratório, responsável por autenticar com o provedor de internet (ISP), gerenciar o NAT (Network Address Translation) e segmentar a rede local inicial.

##

### 🛡️ Proteção de Borda e Firewall Ativo

O roteador atua como a primeira linha de defesa (*Perimeter Security*) contra tráfego malicioso originado da WAN.

* **Prevenção de DoS (Denial of Service):** Filtros ativados contra ataques de *Flood* (SYN/ICMP/UDP) e mitigação de *Port Scanning*.
* **Políticas de ACL (Access Control List):** Tráfego de entrada (*Inbound*) bloqueado por padrão (Default Deny), exceto para portas estritamente configuradas no *Port Forwarding*.

##

### 📡 Arquitetura Wireless (WLAN)

As redes sem fio estão segmentadas logicamente para isolar o tráfego de dispositivos de naturezas diferentes, reduzindo a superfície de movimentação lateral em caso de comprometimento.

| Finalidade | SSID (Oculto?) | Isolamento de Clientes (AP Isolation) |
| :--- | :--- | :--- |
| **Administração/Core** | Não | Ativado (Acesso à minha rede interna e internet, somente para meus dispositivos pessoais) |
| **IoT (Dispositivos Inteligentes)** | Não | Ativado (Sem acesso à rede administrativa) |
| **Guest (Visitantes)** | Não | Ativado (Apenas acesso à internet) |

##

### 📡 Gerenciamento de Provedor (TR-069 / TR-181)

O protocolo CWMP (TR-069/TR-181) é utilizado por ISPs para provisionamento remoto, atualizações de firmware e coleta de telemetria do roteador. Em nosso cenário utilizaremos para automações pontuais. 

* **Status:** `DESATIVADO`
* **Justificativa de SecOps:** A manutenção/desativação deste protocolo na rede é porque ainda estarei implementando meu serviço pessoal visando a criaão de automações para uso em minha rede.

##

### 🔒 Política de Acesso e Gestão

* Acesso administrativo via porta web (`TCP/<CUSTOM_ADMIN_PORT>`) restrito apenas para IPs da rede interna.
* Senhas de acesso e chaves WPA2/WPA3 mantidas offline no cofre de credenciais do laboratório.

##

### 🎮 Política de Gaming & NAT (UPnP)

Para garantir a melhor experiência em jogos online, o sistema permite a negociação dinâmica de portas (UPnP). 

* **Status:** Ativo (Restrito).
* **Justificativa:** Necessário para obtenção de NAT Aberto (Open NAT) nos consoles de videogame, garantindo latência mínima e   pareamento eficiente.
* **Política de Isolamento:** * O tráfego de entrada (*Inbound*) negociado via UPnP é inspecionado pelo Firewall de Host (UFW)   em cada servidor/dispositivo destino.
* **Mitigação de Riscos:**
    * O UPnP não possui permissão para negociar portas de gerenciamento dos servidores (`SSH`, `Web Admin`, `Database`).
    * Auditoria mensal de mapeamento de portas via logs do roteador.

##

### ⚙️ Considerações de Gerência em Mesh

Como os roteadores estão em Mesh, a configuração de firewall e TR-069 deve ser replicada ou sincronizada de forma consistente entre eles:

* **Consistência de Estado:** As ACLs de firewall configuradas no Controller são propagadas para o Satellite para garantir que   a política de segurança seja uniforme em todo o laboratório.
* **Sincronização TR-069:** Caso o protocolo TR-069 esteja ativo, ambos os nós reportarão telemetria a um servidor.

##

### 📂 Sobre os Arquivos de Configuração (Mesh-Ready)

Ao documentar as configurações, note que o arquivo de backup deve refletir a configuração de "nó" específica:

* **config-backup-controller-sanitized.bin:** Configuração contendo as regras de WAN/NAT.
* **config-backup-satellite-sanitized.bin:** Configuração focada em bridging e rádio.

⚠️ ***Observação:*** *Por questão de segurança esses arquivos ficam armazenados offline num storage de backup, uma vez que nos arquivos `.bin` pode contr senhas criptografadas e outras informações sensíveis.*

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
