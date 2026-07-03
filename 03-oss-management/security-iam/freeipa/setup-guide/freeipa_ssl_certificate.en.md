<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/security-iam/freeipa/setup-guide/freeipa_ssl_certificate.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🔒 SOP: Zero-Touch SSL Provisioning on FreeIPA (Direct DDNS Mode)

### 📝 Description and Scope

This document shows the Standard Operating Procedure (SOP) to automate and manage the life cycle of SSL/TLS certificates (Let's Encrypt) on the FreeIPA Identity Control Plane. This guide uses only a free Dynamic DNS provider (DuckDNS).

We do not use a custom domain name. Because of this, the setup does not need Alias or CNAME configuration. The system checks the domain directly using the DNS-01 challenge via API. This guide includes the steps needed to make modern certificates (Let's Encrypt RSA) work with the strict internal database of FreeIPA (NSS/Dogtag).

##

### 🧹 Phase 1: Requirements and Setup (Control Plane)

The internet traffic goes directly to the dynamic DNS. Because of this, you must check the main settings:

1. Your DuckDNS subdomain (for example: your-lab.duckdns.org) must point to the public IP of your lab. You can use an update client or a static IP.

 2. Inside your local network (LAN), your local DNS server (or the /etc/hosts file) must point your-lab.duckdns.org to the private IP of the FreeIPA server. This makes the local routing work correctly.

##

### ⚙️ Phase 2: Installing and Setting up the Tool (acme.sh)

Open the FreeIPA server terminal (as root):

1. Installing the Core Program:

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
```

2. Reliability (Downgrade CA): FreeIPA does not have new Certificate Authorities in its base operating system. We will force the tool to use Let's Encrypt as the default provider:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Phase 3: Direct Issuance and Extracting Certificates

The certificate generation will happen directly, pointing the challenge parameters to your own domain.

1. Save your integration Token:

```bash
export DuckDNS_Token="YOUR_TOKEN"
```

2. Order the Certificate Directly: We will configure the key to the classic RSA 2048 format. This makes it work perfectly with the old system parts.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d seu-lab.duckdns.org -k 2048
```

3. Staging Area: Create a safe folder and copy the files to separate the Certificate Authority (CA) files.

```bash
mkdir -p /etc/ssl/freeipa
/root/.acme.sh/acme.sh --install-cert -d seu-lab.duckdns.org \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--ca-file        /etc/ssl/freeipa/ca.cer
```

##

### 🔗 Phase 4: Syncing the Trust Chain

FreeIPA works as its own Certificate Authority. We must add the public keys from Let's Encrypt into the NSS database. This helps the server recognize your new certificate.

1. Download the Official Root CA (ISRG Root X1):

```bash
curl -L -o /etc/ssl/freeipa/isrgrootx1.pem https://letsencrypt.org/certs/isrgrootx1.pem
```

2. Add the Root CA (Main):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/isrgrootx1.pem
# (Type your Directory Manager password when the system asks for it).
```

3. Add the Intermediate CA (Subordinate):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/ca.cer
```

4. Global Sync: Update the internal system files to finish the configuration:

```bash
ipa-certupdate
```

##

### ✅ Phase 5: Integration and Automated Lifecycle (Zero-Touch)

Normal web servers can read certificates dynamically, but FreeIPA cannot.

The certificate needs to renew automatically every 60 days without human help. To do this, we connect a restart command (Hook) directly to the main tool.

1. Deploy with Automation: Run the command below. Replace SUA_SENHA_AQUI with your real Directory Manager password.

The acme.sh tool will install the keys now. It will also remember this command to run it in the background for all future renewals.

```bash
/root/.acme.sh/acme.sh --install-cert -d seu-lab.duckdns.org \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--reloadcmd      "ipa-server-certinstall -w -d --dirman-password='SUA_SENHA_AQUI' --pin='' /etc/ssl/freeipa/ipa.key /etc/ssl/freeipa/ipa.cer && ipactl restart"
```

2. After this command runs successfully, you can access the FreeIPA admin web page safely via HTTPS. The system will work with zero maintenance cost for encryption.

```text
https://seu-lab.duckdns.org
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
