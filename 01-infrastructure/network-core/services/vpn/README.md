
# 🛡️ VPN Stack (IPsec/IKEv2 & strongSwan)

### 📝 Descrição da Arquitetura
Este diretório documenta a arquitetura, o provisionamento e as políticas de operação do gateway de **VPN de Acesso Remoto (Client-to-Site)**. O serviço foi desenhado para prover acesso seguro, criptografado e autenticado à infraestrutura e redes de gerência para colaboradores remotos.

O núcleo criptográfico e de negociação de chaves é provido pelo **strongSwan**, um *daemon* IPsec robusto e de código aberto. A topologia utiliza o protocolo **IKEv2** (Internet Key Exchange version 2) para o estabelecimento do túnel, combinado com **EAP-MSCHAPv2** para a autenticação de usuários. Esta escolha arquitetural garante alta segurança e interoperabilidade máxima, permitindo que *endpoints* (Windows, macOS, Android) conectem-se nativamente sem a instalação de aplicativos/softwares clientes adicionais.

##

### 🏗️ Alinhamento Operacional (FCAPS)

A operação deste gateway VPN consolida as seguintes estratégias de gerência:

* **F (Fault Management):** O daemon `charon` do strongSwan fornece *logs* detalhados das máquinas de estado IKE. O monitoramento contínuo das falhas de negociação (Fase 1/Fase 2) ou de autenticação EAP permite que a equipe de suporte isole rapidamente se um incidente é causado por credenciais inválidas, bloqueio de portas em redes de operadoras ou *timeout* criptográfico, reduzindo o MTTR.

* **C (Configuration Management):** Padronização dos parâmetros de criptografia (*Cipher Suites*), políticas de roteamento e *split-tunneling*. A configuração é mantida como código, facilitando a auditoria e a recuperação rápida do serviço em caso de desastre.
  
* **P (Performance Management):** Otimização de MSS (*Maximum Segment Size*) e MTU (*Maximum Transmission Unit*) via *ufw/iptables/nftables* para evitar fragmentação de pacotes e quedas de conexão. Uso de extensões de *hardware* (AES-NI) no host físico/virtual para acelerar o processamento criptográfico, evitando gargalos de CPU.

* **S (Security Management):** Autenticação robusta baseada em certificados mútuos (para o Gateway) e credenciais (para os clientes). Implementação de *Perfect Forward Secrecy* (PFS) para garantir que chaves de sessão comprometidas no futuro não decriptem o tráfego passado. 

##

### 🖧 Topologia Lógica (OSI Layer 3-7)

| Componente / Protocolo | Função Lógica | Comunicação | Protocolos / Camada OSI |
| :--- | :--- | :--- | :--- |
| **IKEv2 (strongSwan)** | Negociação de Chaves e SAs | `Client <-> VPN Gateway` | UDP 500 / UDP 4500 (Layer 7) |
| **EAP-MSCHAPv2** | Autenticação de Usuários | `Client <-> VPN Gateway` | EAP via IKEv2 (Layer 7) |
| **IPsec (ESP)** | Encapsulamento Criptográfico | `Client <-> VPN Gateway` | IP Protocol 50 (Layer 3) |
| **NAT-T (NAT Traversal)** | Tunelamento UDP sobre NAT | `Client -> NAT -> Gateway` | UDP 4500 (Layer 4) |

##

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Para garantir a operação correta do túnel e proteger o perímetro da rede:

1.  **Firewall de Entrada:** O *host* que roda o strongSwan deve estar acessível externamente (WAN) estritamente nas portas `UDP 500` (IKE) e `UDP 4500` (NAT-T), além de permitir o tráfego do protocolo IP `50` (ESP).

2.  **Roteamento e Encaminhamento (Forwarding):** O *kernel* Linux do servidor VPN deve ter o repasse de pacotes ativado (`net.ipv4.ip_forward=1`). O *firewall* local deve realizar masquerading/NAT do bloco de IPs virtuais atribuídos aos clientes VPN para que estes alcancem a rede interna (LAN/OAM).

3.  **Isolamento de Acesso:** Políticas de controle de acesso (ACLs) devem ser aplicadas na interface interna do servidor VPN, restringindo quais servidores e serviços (SSH, Web Admin, RDP) os clientes VPN estão autorizados a alcançar.

4.  **Gestão de Identidade:** Recomenda-se a futura integração do backend de autenticação (atualmente arquivos locais/secrets) com um servidor RADIUS/Active Directory para centralizar a governança de identidades (IAM).

##

### 🛠️ Procedimentos Operacionais (Runbooks)

Para o provisionamento de novos servidores VPN, criação de usuários ou revogação de acessos, consulte os procedimentos documentados abaixo:

* 👉 **[SOP: Instalação e Configuração do VPN Server (IPsec/IKEv2 strongSwan)](./vpn_server_setup.md)**

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
