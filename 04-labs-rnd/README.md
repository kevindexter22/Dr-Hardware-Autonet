<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/04-labs-rnd/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🧪 Pesquisa e Desenvolvimento (Sandbox de P&D)

### 📝 Descrição do Escopo

Este repositório é o ambiente controlado de **Pesquisa e Desenvolvimento**. Sua função primária é servir como *Sandbox* para validação de novas topologias, testes de estresse em *workloads* e experimentação com novas tecnologias (PoCs) antes da implementação em ambientes produtivos.

##

### 🏗️ Estrutura de Domínios (Sandbox Logic)

O ambiente está segmentado para permitir testes isolados (abstração de camadas):

| Domínio | Objetivo Técnico | Ferramentas (Exemplos) |
| :--- | :--- | :--- |
| `network-simulations/` | Validação de topologias L2/L3 e cenários de roteamento. | EVE-NG, GNS3, PNETLab, Packet Tracer |
| `devops-sandboxes/` | Testes de esteiras CI/CD, orquestração e *deploy*. | Docker, K3s, Minikube, Jenkins |

##

### ⚙️ Ciclo de Vida de Experimentação

Para garantir a integridade do ambiente principal, toda experimentação deve seguir estas diretrizes:

1. **Isolamento de Recursos:** Testes que demandem alta carga ou manipulação de tabelas de roteamento devem ocorrer estritamente dentro da rede simulada (GNS3/EVE-NG).
2. **Reprodutibilidade:** Toda PoC deve ser documentada com arquivos de configuração (`.yaml`, `.sh`, `.py`) para que o experimento seja replicável.
3. **Limpeza de Estado:** Após a validação, recursos temporários (contêineres, instâncias de VMs, *snapshots*) devem ser removidos para evitar o consumo desnecessário de *compute* e *storage*.

##

### 🛡️ Governança e Compliance

* **Proibição em Produção:** Nenhum script ou configuração contida nestas subpastas possui garantia de estabilidade ou compatibilidade com a infraestrutura principal.
* **Segurança:** O tráfego gerado nos simuladores deve estar isolado da rede *Core* para evitar interferência em serviços produtivos de DNS, IAM ou Telecom.

##

### 🔄 Referências Cruzadas

* **Automação:** Para integrar o código validado aqui ao seu repositório de automação, consulte a seção `02-automation-iac`.
* **Políticas:** Para diretrizes de nomenclatura de ativos e padrões de segurança, consulte nosso **[Documento de Governança](#)**.

##

###### ℹ️ Ambiente de laboratório isolado - Parte do Dr. Hardware Autonet.
