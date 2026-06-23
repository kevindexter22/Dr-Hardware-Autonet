<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/casaos_setup.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ (SOP) Instalando o CasaOS - Raspberry Pi

### 📝 Descrição e Escopo

O CasaOS não é um sistema operacional completo no sentido estrito, mas sim um orquestrador de containeres com uma interface de gerenciamento (UI/Dashboard) leve e baseada em ecossistema Docker, rodando tipicamente sobre uma distribuição Linux (como Debian ou Ubuntu) nativa da arquitetura ARM do Raspberry Pi.

A função dessa ferramenta no cenário proposto é rodar alguns serviços essenciais para o meu dia-a-dia, facilitando a manutenção e operação, uma vez que, além da interface web intuitiva ele possui uma loja com alguns docker-compose pré-configurados para a instalação e utilização em poucos cliques.

##

### ℹ️ Pré-requisitos

- Um Raspberry Pi (recomendado Raspberry Pi 4 ou 5 com no mínimo 4 GB de memória RAM para uma boa experiência).
- Ubuntu Server já instalado e conectado à internet.
- Acesso ao terminal (CLI) via SSH.

##

