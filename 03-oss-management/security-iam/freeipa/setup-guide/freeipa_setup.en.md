<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>


# 🛠️ SOP: Installing FreeIPA - Proxmox LXC

### 📝 Description and Scope

This standard operating procedure (SOP) documents the setup and configuration of **FreeIPA**. It acts as the **Identity and Access Management (IAM) Plane** of the lab. 

In the OSS framework (FCAPS), this node is the primary core for **Security Management**. It is responsible for centralizing credential governance, audit, and Role-Based Access Control (RBAC).

* **Logical Architecture (Layer 7):** It acts as the *Single Source of Truth* (SSoT) of the infrastructure. It puts together **AuthN** (Authentication via Kerberos) and **AuthZ** (Authorization via LDAP) services. It also provides internal name resolution (DNS).
* **Infrastructure Architecture (Virtualization):** Hosted as an optimized Privileged LXC container in Proxmox (using AlmaLinux 8). This setup removes the overhead of a full virtual machine (KVM). It keeps direct access to Kernel *keyrings* needed for Kerberos encryption.
* **Interoperability and SRE:** It replaces decentralized management (static users in `/etc/passwd` of each machine) with a dynamic model connected via SSSD and PAM. This reduces operational MTTR, stops *Configuration Drift*, and allows instant access revocation (Zero Trust) across all servers (Ubuntu/Debian).

##

###  🗄️ Phase 1: Download and Install AlmaLinux 8 Template on Proxmox

For Proxmox to create the container, we need to make sure the official AlmaLinux 8 template is present in your storage.

1. Download the Template via Proxmox CLI
   
   Access the terminal of your Proxmox VE server (via SSH or WebUI shell). Run the command below to download the latest official template directly from the community repository (LinuxContainers):
   ```bash
   cd /var/lib/vz/template/cache/
   wget [https://images.linuxcontainers.org/images/almalinux/8/amd64/default/default.tar.xz](https://images.linuxcontainers.org/images/almalinux/8/amd64/default/default.tar.xz) -O almalinux-8-default_amd64.tar.xz
   ```
   *Note: If your template storage is different from the default /var/lib/vz, change the path in the cd command.*

2. Create LXC Container via CLI (Optimized)

   You can create the container using the Proxmox graphic interface, or you can run this command directly in the Proxmox shell. This creates it with the necessary privilege flags and sub-resources:
   ```bash
   pct create 100 /var/lib/vz/template/cache/almalinux-8-default_amd64.tar.xz \
   -cores 2 \
   -memory 2548 \
   -swap 512 \
   -hostname <YOUR_HOSTNAME.YOUR_DOMAIN.LOCAL> \
   -ostype almalinux \
   -storage local-lvm \
   -rootfs local-lvm:8 \
   -net0 name=eth0,bridge=vmbr0,ip=<SERVER_IP/CIDR>,gw=<GATEWAY_IP> \
   -unprivileged 0 \
   -features nesting=1
   ```
   * `unprivileged 0`: Sets the container as Privileged. FreeIPA on AlmaLinux 8 handles Kernel security keyrings that are blocked in unprivileged containers.
   * `features nesting=1`: Allows systemd to work correctly inside the LXC.

##

### 🐧 Phase 2: Operating System Preparation (Inside the Container)

Start the container in Proxmox, access its console, and configure network consistency:
```bash
# 1. Start and access (if done via Proxmox CLI)
pct start 100
pct enter 100

# 2. Fix the /etc/hosts file (Critical for FreeIPA)
nano /etc/hosts
```

Make sure the static IP line points directly to the FQDN before the short name. The file must look like this:
```bash
127.0.0.1   localhost localhost.localdomain
192.168.1.13 <YOUR_HOSTNAME.YOUR_DOMAIN.LOCAL> ipa
```

Update the AlmaLinux 8 repositories:
```bash
dnf update -y
```

##

### 🚀 Phase 3: FreeIPA Server Installation

On AlmaLinux 8, the FreeIPA packages are in a specific AppStream module called idm.

We need to enable this flow before installation:
```bash
# 1. Enable the Identity Management (IDM) module specific to AlmaLinux 8
dnf module enable idm:DL1 -y

# 2. Install the FreeIPA server with integrated DNS management
dnf install freeipa-server freeipa-server-dns -y
```

Now let's run the automatic installer.

Run the provisioning command without manual interactions:
```bash
ipa-server-install \
  --realm=<YOUR_DOMAIN.LOCAL> \ # Type in uppercase letters
  --domain=<YOUR_DOMAIN.LOCAL> \
  --hostname=<YOUR_HOSTNAME.YOUR_DOMAIN.LOCAL> \
  --setup-dns \
  --auto-forwarders \
  --allow-zone-overlap \
  -a "YourAdminPasswordHere" \
  -p "YourDirectoryManagerPasswordHere" \
  -U
```
*When finished, the FreeIPA Server will be running and controlling the .local domain.*

##

### 🐧 Phase 4: Client Configuration and Attachment (Ubuntu/Debian)

On your client server (any Ubuntu or Debian node), perform a preventive clean-up and a clean install to connect to the new AlmaLinux 8 server.
```bash
# 1. Purge previous configurations (if you never configured the FreeIPA client, ignore this part)
sudo ipa-client-install --uninstall -U
sudo rm -rf /var/lib/sss/db/*
sudo rm -f /etc/krb5.keytab

# 2. Install the client agent
sudo apt update
sudo apt install freeipa-client sssd-tools -y

# 3. Register to the new domain (.click)
sudo ipa-client-install \
  --server=<SERVER_HOSTNAME.YOUR_DOMAIN.LOCAL> \
  --domain=<YOUR_DOMAIN.LOCAL> \
  --realm=<YOUR_DOMAIN.LOCAL> \ # Type in uppercase letters
  --principal=admin \
  -w "YourAdminPasswordHere" \
  --mkhomedir \
  --unattended \
  --force-join \
  --fixed-primary \
  --no-ntp
```

Post-Installation Adjustments on the Client (SSH and PAM Guarantee)

To permanently fix token expiration errors on Ubuntu:
```bash
# Force SSSD injection into the Ubuntu PAM layers
sudo pam-auth-update --enable sss

# Make sure SSH accepts PAM intermediation
sudo sed -i 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Restart cache locks
sudo sss_cache -E
sudo systemctl restart sssd ssh
```

This structure based on AlmaLinux 8 as a central server running in a dedicated LXC mitigates port conflict failures. It delivers extremely fast and clean identity management for your Proxmox ecosystem.

##

### 💡 Tips

* **Important:** *If the configuration applied in /etc/ssh/sshd_config has the AllowUsers option and the added users are not the same as FreeIPA, it can block access via SSH for security.
  Therefore, comment out the AllowUsers option or add the users created in FreeIPA to this rule and restart the SSH service.*

##

#### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
