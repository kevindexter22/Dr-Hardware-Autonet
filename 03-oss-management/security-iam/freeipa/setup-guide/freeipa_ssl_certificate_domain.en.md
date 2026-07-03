# 🛡️ SOP: Installing SSL (Let's Encrypt) on FreeIPA via DNS-01

### 📝 Description and Scope

This document shows the Standard Operating Procedure (SOP) to install valid SSL/TLS certificates on the FreeIPA Identity Control Plane.

FreeIPA has a strict internal database (NSS/Dogtag). Because of this, working directly with ACME providers requires careful management of the Trust Chain and using the RSA standard. This guide uses the acme.sh tool in DNS Delegation mode (Alias Mode). This helps check the domain without showing the LDAP/Web server to the public internet.

##

### 🌐 Phase 1: Routing and DNS Delegation

Prepare the settings on your public domain provider (for example: Hostinger).

1. Local Access (Layer 3): Create a record pointing to the internal IP of the FreeIPA server.

   * **Type:** A
   * **Name:** ipa.infra
   * **Target:** <LOCAL_STATIC_IP>

2. Security Delegation (ACME Challenge): Create a redirect pointing directly to the root of your backup DDNS.

   * **Type:** CNAME
   * **Name:** _acme-challenge.ipa.infra
   * **Target:** your-lab.duckdns.org

##

### ⚙️ Phase 2: Installing and Setting up the Tool

The acme.sh tool will connect to the DuckDNS API and the Certificate Authority. Open the FreeIPA server terminal (as root):

1. Installing the Core Program:

```bash
curl https://get.acme.sh | sh -s email=seu-email@dominio.com
```

2. Reliability (Provider Bypass): By default, acme.sh uses ZeroSSL. However, FreeIPA does not have this root certificate in its database. We will force it to use Let's Encrypt:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Phase 3: Getting and Extracting the Certificates

1. Save your DDNS provider API Token (DuckDNS):

```bash
export DuckDNS_Token="YOUR_TOKEN"
```

2. Order the Certificate: We will use the parameter -k 2048 to create a classic RSA key.

FreeIPA will block new ECC keys from Let's Encrypt because the system does not have the new Root CA.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d ipa.infra.seu-dominio.com --challenge-alias seu-lab.duckdns.org -k 2048
```

3. Staging Area (Deployment): Create a safe folder and copy the files to make a clean CA file.

```bash
mkdir -p /etc/ssl/freeipa
/root/.acme.sh/acme.sh --install-cert -d ipa.infra.seu-dominio.com \
--key-file       /etc/ssl/freeipa/ipa.key  \
--fullchain-file /etc/ssl/freeipa/ipa.cer \
--ca-file        /etc/ssl/freeipa/ca.cer
```

##

### 🔗 Phase 4: Syncing the Trust Chain

FreeIPA works as its own Certificate Authority. To make it accept the server SSL, we must teach it to trust the Let's Encrypt hierarchy from top to bottom.

1. Download the Official Root CA (ISRG Root X1):

```bash
curl -L -o /etc/ssl/freeipa/isrgrootx1.pem https://letsencrypt.org/certs/isrgrootx1.pem
```

2. Add the Root CA (Main):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/isrgrootx1.pem
# (You will need to type the Directory Manager password).
```

3. Add the Intermediate CA (Subordinate):

```bash
ipa-cacert-manage install /etc/ssl/freeipa/ca.cer
```

4. Global Sync: Update the NSS and LDAP databases to complete the trust setup:

```bash
ipa-certupdate
```

##

### ✅ Phase 5: Installing the Certificate and Handover

Now that the trust chain is ready, apply the keys to the FreeIPA services (Apache and Directory Server).

1. Installing the Server Certificate:

```bash
ipa-server-certinstall -w -d /etc/ssl/freeipa/ipa.key /etc/ssl/freeipa/ipa.cer
```

* ***Operational Note:*** *When the system asks for the "Directory Manager password", type your admin password.*

Next, it will ask for the "private key unlock password": just press ENTER with nothing typed, because Let's Encrypt keys do not have a local password.

2. Graceful Restart: Restart the control plane to apply the new settings:

```bash
ipactl restart
```

3. The web interface for FreeIPA will now use a valid TLS certificate (Green Lock). This protects your network credentials and keeps them safe.

To access it now, you can use this URL:

```text
https://ipa.infra.seu_dominio.com
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
