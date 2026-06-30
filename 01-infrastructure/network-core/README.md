<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🌐 Core de Rede e Serviços

### 📝 Descrição do Domínio

Esta seção documenta a fundação lógica e física da rede do laboratório (Camadas 2 e 3 do Modelo OSI). Aqui residem as configurações de roteamento, comutação (*switching*) e os serviços essenciais (*Core Services*) necessários para que a infraestrutura se comunique com a internet e para que os nós internos se descubram mutuamente.

##

### 🗺️ Topologia e IPAM (IP Address Management)

Visão geral da segmentação lógica e roteamento. Os endereços exatos são mantidos no cofre offline do laboratório por políticas de segurança.

* **Rede LAN Principal:** `<LAN_SUBNET_CIDR>` (Gateway: `<LAN_GATEWAY_IP>`)
* **Serviço de DNS Interno:** `<INTERNAL_DNS_IP_1>` / `<INTERNAL_DNS_IP_2>`
* **Túnel VPN (Acesso Remoto):** `<VPN_SUBNET_CIDR>` (Protocolo Roteado L3)

> **Nota:** Para o detalhamento de arquitetura de políticas de atribuição, consulte o documento oficial de padrões em `05-docs/standards-policies.md`.

##

### ⚙️ Serviços e Ativos de Rede

Inventário dos componentes que formam o núcleo de conectividade:

* **Roteadores de Borda (Edge):** Equipamentos físicos responsáveis pelo NAT, Firewall L3 (ACLs) e saída para o ISP.
* **Resolução de Nomes (DNS/DHCP):** Serviços de bloqueio de telemetria a nível de rede (ex: Pi-hole / Unbound) e resolução de     domínios TLD locais.
* **Acesso Remoto Seguro (VPN):** Túneis criptografados para acesso ao *Management Plane* do laboratório a partir de redes         externas não confiáveis.

##

### 📂 Estrutura do Diretório

```text
01-infrastructure/network-core/
├── 📄 README.md                 # Visão Geral da Topologia de Rede (português)
├── 📄 README.en.md              # Visão Geral da Topologia de Rede (inglês)
├── 📂 routers-switches/         # Configurações extraídas e sanitizadas de hardware físico
└── 📂 services/                 # Procedimentos manuais (SOPs) de implementação de VPN, DNS, etc.
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
