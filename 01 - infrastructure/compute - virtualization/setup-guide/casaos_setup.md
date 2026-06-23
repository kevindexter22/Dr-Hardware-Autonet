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
*(Se o sistema pedir para reiniciar após atualizar o kernel, faça isso com `sudo reboot` e conecte-se novamente).*

2. O script de instalação do CasaOS precisa da ferramenta `curl` para baixar os arquivos. O Ubuntu geralmente já vem com ela, mas por garantia, execute o comando:
```bash
sudo apt install curl -y
```

##

### ⚙️ Fase 2: Instalando o CasaOS

A equipe responsável pelo CasaOS criou um script que automatiza a instalação.

Ele vai instalar o Docker (caso não esteja instalado), configurar as redes internas (bridges) e vai baixar os containeres do CasaOS.

Para utiliza-lo, execute o comando:
```bash
curl -fsSL https://get.casaos.io | sudo bash
```
*O que vai acontecer agora: O terminal vai mostrar uma tela de progresso. Esse processo pode levar de 2 a 10 minutos, dependendo da velocidade da sua internet e do modelo do seu Raspberry Pi, pois ele estará baixando a engine do Docker e as imagens do sistema.*

Assim que o script terminar, ele geralmente exibe no terminal o endereço de acesso. 

Se você não anotou ou passou rápido, descubra o IP local do seu Raspberry Pi utilizando o comando:
```bash
hostname -I
```
*Você verá um endereço no formato 192.168.x.x ou 10.x.x.x*

##

### 🖥️ Fase 3: Acessar o dashboard e criar conta de administrador

1. Abra o navegador no seu computador (ele precisa estar na mesma rede da Raspberry Pi) e digite o endereço que pegou na etapa anterior:
```bash
http://192.168.x.x
```

2. Na primeira vez que você acessar a página web, o CasaOS apresentará uma tela de boas-vindas pedindo para você criar a conta de administrador.

3. Clique em "GO" ou "Create Account".

4. Defina o nome de usuário e uma senha forte.

5. Pronto! Você estará no Dashboard principal e já pode começar a instalar os aplicativos pela "App Store" nativa deles ou carregar seus docker-compose.

<p align="center"><br>
<img src="https://github.com/user-attachments/assets/26740f42-99b4-4741-a320-99f2964b283c" alt="Dashboard" width="300"/>
</p>

##

### 💡 Dicas Pós-Instalação

- **IP estático:** como trata-se de um servidor e você usará acessando a interface web, defina um IP estático caso não tenha feito. Você pode fazer isso nas configurações do Ubuntu Server ou reservando um endereço IP dentro de seu roteador.
  
- **Armazenamento externo:** Se for plugar um HD externo ou SSD na USB do Raspberry Pi, o CasaOS possui um gerenciador de arquivos nativo. Formate o disco preferencialmente em ext4 (padrão Linux) ou ExFAT para melhor performance.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
