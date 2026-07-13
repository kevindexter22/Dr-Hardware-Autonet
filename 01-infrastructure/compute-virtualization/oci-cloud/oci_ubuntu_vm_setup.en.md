<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/oci-cloud/oci_ubuntu_vm_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# ☁️ SOP: Provisioning an Ubuntu VM on Oracle Cloud (OCI)

### 📝 Scope Description

This Standard Operating Procedure (SOP) details how to create a compute infrastructure on Oracle Cloud Infrastructure (OCI). The scope covers everything from creating the virtual cloud network (VCN) to provisioning the virtual machine (VM) with Ubuntu Server, preparing the environment to host core services.

This node will act as the core of the cloud topology, receiving encrypted connections from the edge nodes (Proxies) of the local network.

##

### 🌐 Phase 1: Network Configuration (VCN and Subnet)

Before creating the server, we need to set up the logical network boundary.

1. Go to the OCI dashboard and navigate to **Networking** > **Virtual Cloud Networks (VCN)**.

2. Click on **Start VCN Wizard** and select **Create VCN with Internet Connectivity** (This will automatically create the Internet Gateway and the route table).

3. Fill in the basic information:
   * **VCN Name:** `<VCN_NAME>`
   * **VCN CIDR Block:** `10.0.0.0/16`
   * **Public Subnet CIDR Block:** `10.0.0.0/24`
   * **Private Subnet CIDR Block:** `10.0.1.0/24` (Optional for this lab, but created by default).

4. Review the topology and click **Create**.

##

### 🛡️ Phase 2: Security Configuration (Security Lists / SecOps)

By default, the OCI firewall blocks all incoming traffic (Ingress), except for port 22 (SSH). We need to open the necessary ports for our observability stack.

1. Inside your new VCN, click on **Security Lists** and open the `Default Security List for dr-hardware-cloud-vcn`.

2. Click on **Add Ingress Rules** and create the following rules:
   
   **Rule 1: Web Dashboard (HTTP/HTTPS)**
   * **Source CIDR:** `0.0.0.0/0`
   * **IP Protocol:** TCP
   * **Destination Port Range:** `80,443`
   * **Description:** Allow Web UI Access

##

### 💻 Phase 3: Instance Provisioning (Compute)

1. Navigate to **Compute** > **Instances** and click **Create Instance**.

2. **Instance Name:** `<HOSTNAME>`

3. **Image and Shape:**
   * **Image:** Change to **Ubuntu Server 24.04** (or the latest supported LTS).
   * **Shape:** Select your hardware. Oracle's *Always Free* tier allows you to use the AMD Micro shape or the powerful **Ampere A1 (ARM64)** with up to 2 OCPUs e 12 GB of RAM.

4. **Networking:**
   * Select the VCN created in Phase 1 (`VCN_NAME`).
   * Select the **Public Subnet**.
   * Make sure the option **Assign a public IPv4 address** is checked.

5. **Add SSH Keys (Security Access):**
   * **Option A (Generate new key):** Select **Generate a key pair for me**. You **must** click the *Save private key* button to download the `.key` file to your computer before continuing, because OCI will not store it.
   * **Option B (Use existing key):** Select **Paste public keys** or **Upload public key files** and enter your current public key (e.g., `id_ed25519.pub`).

6. Click **Create**. Wait for the status to change from *Provisioning* to *Running*.

##

### 🔑 Phase 4: Validation and First Access

After the instance is provisioned, note down the **Public IP Address** shown on the instance dashboard.

1. Open the terminal on your local computer and test the SSH connection:

```bash
ssh -i /path/to/your/private_key ubuntu@<OCI_PUBLIC_IP>
```

2. When you connect successfully, apply the initial security updates:

```bash
sudo apt update && sudo apt upgrade -y
```

* ***Next step:*** *See the [os-baseline](https://github.com/kevindexter22/Dr-Hardware-Autonet/tree/main/01-infrastructure/compute-virtualization/os-baseline) documentation to apply operating system hardening before installing applications).*

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
