<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/Infrastructure/Virtualization%20and%20Workloads/setup-guide/raspberry-pi-setup_en.md" target="_blank" rel="noopener noreferrer">🇬🇧 Inglês</a></h6>

# <img width="50" height="50" alt="image" src="https://github.com/user-attachments/assets/135b24c8-25c5-4e75-8eb3-24f175094478" /> Raspberry Pi

### 

### 📝 Descrição

Nesta etapa vamos instalar o sistema operacional de base.

Ele vai servir tanto para instalarmos os serviços diretamente no sistema deixando o Raspberry Pi dedicado como se optarmos por utilizar o Docker (seja instalando o serviço e orquestrando com o Docker Swarm ou utilizando o CasaOS que possui uma interface web para gerenciamento dos containers).

O Raspberry Pi possui diversas distribuições linux otimizadas para ele, tais como: Raspberry Pi OS (que é basicamente o debian), Ubuntu, Rocky Linux, Alpine, entre outros.

Aqui focarei na instalação das mais comuns para o uso como servidor (Raspberry Pi OS Lite, Rock Linux e Ubuntu Server), porém utilizarei o Ubuntu Server em meus projetos.

Em relação a sistemas operacionais a própria Raspberry Pi Foundation disponibiliza uma ferramenta chamada Raspberry Pi Imager que nos permite gravar/instalar os sistemas embarcados de forma simples e intuitiva.

Sendo assim vamos instalar o sistema utilizando esse método.

##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/d94a1bcc-23ae-43cf-9e33-d8bbb48ec709" /> Preparando o Cartão Micro-SD para a Instalação via RPI Imager

#### 1. Iniciando o Aplicativo
Com o Micro-SD já inserido no computador, abra o **Raspberry Pi Imager**. A interface principal permite selecionar o hardware, o SO e o destino da gravação.

<p align="center">
  <img src="https://github.com/user-attachments/assets/db0d5c09-a11d-4fe9-9f42-4c7a8181327c" width="450" alt="Interface RPI Imager" />
  <br><em>Interface inicial para seleção de dispositivo e sistema.</em>
</p>

> [!TIP]
> Vamos formatar o cartão diretamente por este aplicativo, para evitar erros de partição comuns em outros métodos.

#### 2. Formatação (Erase)
Para limpar o cartão antes da instalação:
1. Clique em **CHOOSE DEVICE** e selecione o seu modelo (ex: Raspberry Pi 3B).
2. Em **OPERATING SYSTEM**, role até o final e escolha a opção **ERASE** (MS-DOS FAT32).
3. Selecione o seu cartão em **CHOOSE STORAGE**.
4. Feito isso clique em **NEXT**, ele trará uma mensagem confirmando se deseja mesmo formatar o cartão então confirme em **YES**.
5. Aguarde a formatação ser concluída.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f28cb4e-450e-4235-8563-23947dd24357" width="300" />
  <img src="https://github.com/user-attachments/assets/f7b0d48e-96ef-4998-937b-7725c7a10362" width="300" />
  <img src="https://github.com/user-attachments/assets/e7333177-5124-4592-985b-43d2de2c97f3" width="300" />
  <img src="https://github.com/user-attachments/assets/6533c7e6-5f65-49b4-8913-ad1ace5e42fc" width="300" />
  <img src="https://github.com/user-attachments/assets/1a6b810c-f452-4228-9923-3ba136c301a7" width="300" />
  <img src="https://github.com/user-attachments/assets/c05c33d1-0a00-46f4-8179-b8a2c69766d9" width="300" />
</p>

6. Após finalizado basta clicar em **CONTINUE**, ejetar e reinserir o Cartão Micro-SD e estamos prontos para a instalação do sistema operacional.

<p align="center">
   <img src="https://github.com/user-attachments/assets/93c0fa24-f915-4f9d-a918-316df4f84b6b" width="300" />
   <img src="https://github.com/user-attachments/assets/3e0edead-6622-40c4-ab25-291e30e4022c" width="300" />
</p>

##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/b64bbe84-d2a5-438c-bbb3-1e5b2eca6e47" /> Instalando e Configurando o Raspberry Pi OS

#### 1. Instalando o Raspberry Pi OS

O processo de instalação pelo aplicativo é tão intuitivo quando a formatação que fizemos anteriormente.

Para fazer a instalação abrimos o aplicativo.

<p align="center">
  <img src="https://github.com/user-attachments/assets/db0d5c09-a11d-4fe9-9f42-4c7a8181327c" width="450" alt="Interface RPI Imager" />
</p>

##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/5c0caa8d-9f10-4a62-a0f9-ea5f937e0cb8" /> Instalando e Configurando o Ubuntu Server

##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/0f91be5f-a8b7-4774-a1a4-614aba390e87" /> Instalando e Configurando o Rocky Linux

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
