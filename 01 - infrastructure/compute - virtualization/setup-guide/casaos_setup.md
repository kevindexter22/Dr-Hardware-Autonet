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

### 🐧 Fase 1: Preparação do sistema

1. Antes de instalar qualquer serviço é preciso garantir que a base do sistema operacional está atualizada com os patches de segurança e os repositórios mais recentes.

Para isso utilizamos o seguinte comando:
```bash
sudo apt update; sudo apt upgrade -y
```
**(Se o sistema pedir para reiniciar após atualizar o kernel, faça isso com `sudo reboot` e conecte-se novamente).**

2. O script de instalação do CasaOS precisa da ferramenta `curl` para baixar os arquivos. O Ubuntu geralmente já vem com ela, mas por garantia, execute o comando:
```bash
sudo apt install curl -y
```

---

### ⚙️ Instalando o CasaOS

A equipe responsável pelo CasaOS criou um script que automatiza a instalação.

Ele vai instalar o Docker (caso não esteja instalado), configurar as redes internas (bridges) e vai baixar os containeres do CasaOS.

Para utiliza-lo, execute o comando:
```bash
curl -fsSL https://get.casaos.io | sudo bash
```
**O que vai acontecer agora: O terminal vai mostrar uma tela de progresso. Esse processo pode levar de 2 a 10 minutos, dependendo da velocidade da sua internet e do modelo do seu Raspberry Pi, pois ele estará baixando a engine do Docker e as imagens do sistema.**
