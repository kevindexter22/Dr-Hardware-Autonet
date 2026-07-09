<h6 align="right">Read this page in <a href="./README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🖧 Routers & Switches (Network Infrastructure)

### 📝 Descrição da Arquitetura

Este diretório centraliza a documentação, padrões de configuração (*golden configs*), topologia física e gestão de ciclo de vida dos equipamentos de comutação e roteamento que compõem a camada de acesso e borda da rede.

O objetivo desta documentação é garantir a padronização do ambiente físico (Plano de Dados) e do acesso administrativo (Plano de Controle), fornecendo um repositório único de informações (Single Source of Truth) para *troubleshooting*, atualização de *firmwares* e substituição rápida de *hardware* (RMA).

##

### 🏗️ Alinhamento Operacional (FCAPS)

A gestão dos ativos de rede segue as melhores práticas de operações estruturadas:

* **F (Fault Management):** Estabelecimento de referências para o monitoramento físico via *polling* (quando suportado pelo *hardware*) ou análise indireta de conectividade. O objetivo é isolar rapidamente falhas de cabeamento, negociação de portas ou *hardware degradation*, reduzindo o MTTR (Tempo Médio de Recuperação).
* **C (Configuration Management):** Controle rigoroso de versões de *firmware* homologadas e retenção das configurações base. Para equipamentos não-gerenciáveis (Layer 2 burros), documenta-se a topologia física esperada (o que conecta onde) para evitar *loops* ou conexões indevidas.
* **P (Performance Management):** Controle da capacidade de comutação de rede, garantindo que portas operem em *Full-Duplex* com a velocidade nominal esperada (ex: Gigabit Ethernet) e prevenindo o descarte de pacotes por saturação de *buffers* físicos.

##

### 🖧 Topologia Lógica (OSI Layer 1-3)

Os equipamentos mapeados neste diretório operam nas camadas inferiores do modelo OSI, fornecendo o transporte físico e lógico fundamental para as camadas de aplicação:

| Camada OSI | Componente Físico | Função Lógica | Padrões e Protocolos |
| :--- | :--- | :--- | :--- |
| **Layer 3 (Network)** | Roteadores/Gateways | Roteamento, NAT, DHCP, Encaminhamento de Pacotes | IPv4/IPv6, ICMP |
| **Layer 2 (Data Link)** | Switches | Comutação de quadros, Segmentação Física/VLANs | 802.3 (Ethernet), 802.1Q*, STP* |
| **Layer 1 (Physical)** | Portas/Cabeamento | Transmissão de sinal, Autonegociação | 1000BASE-T, Auto-MDI/MDIX |

*(Nota: O suporte a protocolos complexos de L2 como 802.1Q e STP varia conforme a classificação do switch em gerenciável ou não-gerenciável).*

##

### 🛡️ Requisitos de Segurança e Rede (SecOps)

Para garantir a integridade da infraestrutura física e lógica:

1.  **Isolamento do Plano de Gerência (OAM):** Para equipamentos gerenciáveis, o acesso às interfaces administrativas (Web/CLI) deve ocorrer através de redes ou VLANs dedicadas à operação de TI, estritamente bloqueadas para tráfego de usuários comuns ou redes *Guest*.
2.  **Segurança Física (Layer 1):** Proteção do ambiente físico para evitar manipulação de cabos, inserção de dispositivos não autorizados (ex: servidores DHCP desonestos) ou a criação de *loops* físicos (fechamento de portas no mesmo switch).
3.  **Controle de Atualizações:** Nenhuma atualização de *firmware* deve ser aplicada sem testes prévios de compatibilidade e *backup* da configuração vigente.

##

### 🛠️ Hardware Homologado e Documentação Específica

Para detalhes de arquitetura, configurações específicas, limitações de *hardware* e topologia de cada equipamento, consulte os subdiretórios correspondentes:

* 📁 **[`tp-link_ex521`](./tp-link_ex521/)**: Documentação do Roteador/Gateway (Wi-Fi 6).
* 📁 **[`tp-link_ls1008g`](./tp-link_ls1008g/)**: Documentação do Switch Desktop Não-Gerenciável (Layer 2).

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
