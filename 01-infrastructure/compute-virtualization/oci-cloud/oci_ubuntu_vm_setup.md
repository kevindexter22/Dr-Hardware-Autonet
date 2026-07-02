
# ☁️ SOP: Provisionamento de VM Ubuntu na Oracle Cloud (OCI)

### 📝 Descrição e Escopo

Este Procedimento Operacional Padrão (SOP) detalha a criação de uma infraestrutura de computação na Oracle Cloud Infrastructure (OCI). O escopo abrange desde a criação da rede virtual (VCN) até o provisionamento da máquina virtual (VM) com Ubuntu Server, preparando o terreno para hospedar serviços centrais (como o Zabbix Server).

Este nó atuará como o núcleo (*Core*) da topologia em nuvem, recebendo conexões criptografadas dos nós de borda (Edge/Proxies) da rede local.

---

### 🌐 Fase 1: Configuração de Redes (VCN e Sub-rede)

Antes de criar o servidor, precisamos estabelecer o perímetro lógico de rede.

1. Acesse o painel da OCI e navegue até **Networking** > **Virtual Cloud Networks (VCN)**.
2. Clique em **Start VCN Wizard** e selecione **Create VCN with Internet Connectivity** (Isso criará automaticamente o Internet Gateway e a tabela de rotas).
3. Preencha os dados básicos:
   * **VCN Name:** `<NOME_DA_VCN`>`
   * **VCN CIDR Block:** `10.0.0.0/16`
   * **Public Subnet CIDR Block:** `10.0.0.0/24`
   * **Private Subnet CIDR Block:** `10.0.1.0/24` (Opcional para este laboratório, mas criado por padrão).
4. Revise a topologia e clique em **Create**.

---

### 🛡️ Fase 2: Configuração de Segurança (Security Lists / SecOps)

Por padrão, o firewall da OCI bloqueia todo o tráfego de entrada (*Ingress*), exceto a porta 22 (SSH). Precisamos liberar as portas necessárias para a nossa stack de observabilidade.

1. Dentro da sua nova VCN, clique em **Security Lists** e abra a `Default Security List for dr-hardware-cloud-vcn`.
2. Clique em **Add Ingress Rules** e crie as seguintes regras:
   
   **Regra 1: Painel Web (HTTP/HTTPS)**
   * **Source CIDR:** `0.0.0.0/0`
   * **IP Protocol:** TCP
   * **Destination Port Range:** `80,443`
   * **Description:** Allow Web UI Access

---

### 💻 Fase 3: Provisionamento da Instância (Compute)

1. Navegue até **Compute** > **Instances** e clique em **Create Instance**.
2. **Nome da Instância:** `<HOSTNAME>`
3. **Image and Shape:**
   * **Image:** Altere para **Ubuntu Server 24.04** (ou a LTS mais recente suportada).
   * **Shape:** Selecione o hardware desejado. O *Always Free* da Oracle permite usar o shape AMD Micro ou o poderoso **Ampere A1 (ARM64)** com até 4 OCPUs e 24GB de RAM.
4. **Networking:**
   * Selecione a VCN criada na Fase 1 (`NOME_DA_VCN`).
   * Selecione a **Public Subnet**.
   * Certifique-se de que a opção **Assign a public IPv4 address** está marcada.
5. **Add SSH Keys (Acesso de Segurança):**
   * **Opção A (Gerar nova chave):** Selecione **Generate a key pair for me**. É **obrigatório** clicar no botão *Save private key* para baixar o arquivo `.key` para o seu computador antes de prosseguir, pois a OCI não o armazenará.
   * **Opção B (Usar chave existente):** Selecione **Paste public keys** ou **Upload public key files** e insira a sua chave pública atual (ex: `id_ed25519.pub`).
6. Clique em **Create**. Aguarde o status mudar de *Provisioning* para *Running*.

---

### 🔑 Fase 4: Validação e Primeiro Acesso

Após a instância ser provisionada, anote o **Public IP Address** exibido no painel da instância.

1. Abra o terminal na sua máquina local e teste a conexão SSH:
   ```bash
   ssh -i /caminho/para/sua/chave_privada ubuntu@<IP_PUBLICO_DA_OCI>
   ```
2. Ao conectar com sucesso, aplique as atualizações de segurança iniciais:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
   * ***Próximo passo:*** *Consulte a documentação de [os-baseline](https://github.com/kevindexter22/Dr-Hardware-Autonet/tree/main/01-infrastructure/compute-virtualization/os-baseline) para aplicar o hardening do sistema operacional antes de instalar as aplicações).*

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
