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

O processo de instalação pelo aplicativo é tão intuitivo quando a formatação que fizemos anteriormente.

Para fazer a instalação abrimos o aplicativo.

<p align="center">
  <img src="https://github.com/user-attachments/assets/db0d5c09-a11d-4fe9-9f42-4c7a8181327c" width="450" alt="Interface RPI Imager" />
</p>

#### 1. Instalação do Sistema Operacional

O procedimento aqui é muito similar ao anterior:

1. Clique em **CHOOSE DEVICE** e selecione o seu modelo (ex: Raspberry Pi 3B).
2. Em **OPERATING SYSTEM**, selecione a categoria (ex: Raspberry Pi OS (other).
3. Em seguida escolha o sistema operacional que deseja instalar (ex: Raspberry Pi OS Lite (64-bit)).
4. Selecione o seu cartão em **CHOOSE STORAGE**.
5. Feito isso clique em **NEXT**, ele trará uma mensagem perguntanto se deseja personalizar a instalação, se clicarmos em **NO, CLEAR SETTINGS** ele continuará a instalação de forma "limpa", ou seja, com todas as configurações pré-definidas.
<br>A opção **YES** aplica as configurações já feitas em instalações anteriores.
<br>A opção **NO** continuará sem aplicar as configurações personalizadas também.
<br>Como vamos personalizar a instalação após o sistema estar no Cartão Micro-SD, vamos clicar em **NO, CLEAR SETTINGS**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/5a615bb1-6b5f-4e4d-a3e4-9ed8e5cdb891" width="300" />
  <img src="https://github.com/user-attachments/assets/cd4151a6-98af-452b-94bc-72618ea7bde1" width="300" />
  <img src="https://github.com/user-attachments/assets/463a69df-a971-4837-a818-85494226246f" width="300" />
  <img src="https://github.com/user-attachments/assets/3207b67f-536e-44c3-b0f0-d7ba3d3489d8" width="300" />
  <img src="https://github.com/user-attachments/assets/209995ee-7c0e-4e31-a003-416f140be6bc" width="300" />
  <img src="https://github.com/user-attachments/assets/42ed04fa-a5b6-4864-a7c6-aca4b2f19791" width="300" />
</p>

6. Na próxima janela, confirme a formatação do cartão clicando em **YES** novamente e aguarde o término da instalação.

<p align="center">
   <img src="https://github.com/user-attachments/assets/dd6b37f0-181a-4f18-a4af-4c3720e5fb73" width="225" />
   <img src="https://github.com/user-attachments/assets/3264e183-996d-4df7-b15c-ca1862f0f62e" width="225" />
   <img src="https://github.com/user-attachments/assets/ef8800d2-8898-432b-bd2a-fb7ff80c6bec" width="225" />
</p>

7. Após finalizar a instalação, basta clicar em **CONTINUE**.

<p align="center">
  <img src="https://github.com/user-attachments/assets/b9b80956-8b90-409b-b6eb-00992eae5093" width="300" />
</p>

#### 2. Configurações Pós Instalação
Agora antes de colocar o Micro-SD no dispositivo, vamos fazer algumas configurações diretamente nos arquivos de boot do sistema.

Ao ejetar e inserir novamente o cartão no leitor, ele montará duas partições: **bootfs** (partição de inicialização e onde fica as configurações que carregarão ao iniciar o sistema) e **rootfs** (a partição raiz (/) do sistema.

A que vamos acessar para configurar alguns arquivos é a bootfs.

<p align="center">
  <img src="https://github.com/user-attachments/assets/d4297081-a371-408d-8c65-576b2248ffc7" width="300" />
  <br><em>Partições montadas no computador.</em>
</p>

#### Configurando **IP Estático** e **Wifi** *(se nescessário)*

Ao entrar na partição **bootfs** vamos abrir o arquivo **network-config** para fazermos as configurações da interface de rede:

<p align="center">
  <img src="https://github.com/user-attachments/assets/389a2377-15d0-481e-a325-6f23e8bfbd49" width="300" />
  <img src="https://github.com/user-attachments/assets/01ddfd5c-7d98-4002-b8e9-fda69072aeb3" width="300" />
</p>

Descendo um pouco vemos que existe nesse arquivo a opção de configuração tando da interface de rede cabeada como da interface sem fio e vemos que nesse documento é possível também realizar as configurações de rede wireless.

<p align="center">
  <img src="https://github.com/user-attachments/assets/0b13c186-c11a-4541-bb17-9e76fd035173" width="300" />
</p>

Nessa etapa vamos configurar um endereço IP estático para que ele inicie com esse IP sempre.

Isso facilitará nosso acesso SSH ao servidor, assim como, manterá os serviços que utilizaremos sempre nesse mesmo IP.

No documento encontre a parte da configuração da interface que deseja configurar, no nosso caso será a interface **WLAN0**.

Descomente as linhas e faça a configuração conforme abaixo, utilizando as informações de IP de sua rede.

<p align="center">
  <img src="https://github.com/user-attachments/assets/242187c5-5651-4171-85d5-efe24e809576" width="300" />
</p>

Obs.: Caso vá utilizar uma conexão cabeada, configure na parte referente a interface **eth0**.

Para configurar o SSID e a senha de sua rede wifi (se for utilizar a rede sem fio), basta descomentar e preencher os campos na parte de  **access-points** conforme exemplo abaixo:

<p align="center">
  <img src="https://github.com/user-attachments/assets/b5462ebd-8043-45d9-9d07-da834699b140" width="300" />
</p>

Após fazer isso, basta salvar o arquivo.

#### Configurando o SSH para acesso remoto seguro

Agora vamos habilitar o ssh e configurar o usuário e senha para acesso.

1. Crie o arquivo ssh na partição bootfs do micro SD, caso utilize linux, pode fazer utilizando o comando abaixo no terminal.

```sh
touch /media/<seu_usuário>/bootfs/ssh
```
Obs.: No windows basta acessar a partição e criar o arquivo ssh sem nenhuma extenção.

2. Agora como as novas versões do sistema não vem com um usuário pré-definido precisamos criar um arquivo que contenha e crie essas informações ao iniciar o sistema.

Para isso, criamos um arquivo chamado `userconf.txt` na partição bootfs. Esse arquivo vai conter `usuário:senha_criptografada`.

```sh
# criar o arquivo userconf.txt via terminal no linux
touch /media/<seu_usuário>/bootfs/userconf.txt
```
Obs.: No windows basta criar um novo arquivo de texto nessa partição.

Agora precisamos gerar a senha criptografada para adicionar no arquivo.

No linux utilizamos o utilitário `openssl` e digitamos o seguinte comando no terminal:
```sh
echo 'sua_senha' | openssl passwd -6 -stdin
```
- O que o comando faz: o parâmetro -6 utiliza o algoritmo SHA512, que é o padrão recomendado.
-  Resultado: Ele retornará algo como $6$rounds=656000$.... Copie todo esse código, pois iremos inseri-lo no arquivo de configuração.

No windows ele não possui uma forma nativa de gerar utilizando o openssl, mas podemos fazer isso utilizando o WSL (ubuntu,debian,etc).

Na distribuição do WSL que utiliza, basta ter o utilitário `openssl` ativo e digitar o comando abaixo:
```sh
echo "sua_senha" | openssl passwd -6 -stdin
```

Após esse procedimento feito, basta abrir o arquivo `userconf.txt` e adicionar a configuração conforme abaixo:
```
usuário:código_gerado

## Exemplo:
pi:$6$dU2DKSj1d8KE57Uy$Q.5BPFHoWNzupp7YQWbteJMt8/ANu
```

> [!TIP]
> Para ver que está tudo certo, basta no terminal ou CMD (se usar windows) digitar o comando ping `seu_ip` e ver se ao iniciar
> ele comunica com o IP configurado no arquivo.



##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/5c0caa8d-9f10-4a62-a0f9-ea5f937e0cb8" /> Instalando e Configurando o Ubuntu Server

##

### <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/0f91be5f-a8b7-4774-a1a4-614aba390e87" /> Instalando e Configurando o Rocky Linux

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
