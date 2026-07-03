# 🔒 SOP: Zero-Touch SSL Provisioning (DNS-01) - Proxmox VE

### 📝 Description and Scope

This document is the Standard Operating Procedure (SOP). It shows how to automate and manage SSL/TLS certificates (Let's Encrypt) in the Proxmox VE hypervisor.

The goal is to make a secure edge architecture. It uses the DNS-01 challenge in Alias Mode (CNAME Delegation). This model lets you get certificates for a custom top domain (example: .click, managed by a third party like Hostinger). It gives the validation task to a second DDNS provider (DuckDNS) using an API. 

This encrypts the management traffic and connects the systems. You do not need to open TCP ports (80/443) to the public internet.

##

### 📋 Prerequisite:

* You must go to the [duckdns](https://www.duckdns.org/) website. Log in with your Google or GitHub account and create a subdomain.
* After this, copy the ***Token*** at the top of the site. Then, follow the steps below.

##

### 🌐 Phase 1: DNS Routing and Delegation

General DNS providers often do not connect directly to the Proxmox ACME client. So, we create a logical redirect (Alias). This tells the Certificate Authority to find the validation key in another place.

1. Go to the DNS Zone Management panel for your main domain (example: Hostinger).

2. Local Access Mapping (Layer 3): Create a record pointing to the physical host.
   * **Type:** A
   * **Name:** proxmox (or your node hostname)
   * **Points to:** <LOCAL_STATIC_IP>

3. Security Delegation (Critical Step):
* Create a CNAME record to redirect the ACME validation traffic only to the root of your DuckDNS subdomain.
     * **Type:** CNAME
     * **Name:** _acme-challenge.proxmox
     * **Points to:** your-lab.duckdns.org

**Architectural Note:** The CNAME target must not have extra prefixes (_acme-challenge). The direct link (Point-to-Point) to the DDNS root domain prevents routing loops and SERVFAIL errors in the trust chain (this avoids false positives in wildcard rules).

##

### ⚙️ Phase 2: API Integration (Hypervisor)

Prepare the Proxmox ACME client to authenticate with the delegated service (DuckDNS).

1. In the Proxmox web interface, go to the Datacenter level and click on ***ACME***.

2. Account Registration: In the ***Accounts*** section, add a new identity. Select the ***Let's Encrypt V2*** directory and link a valid email for alerts.

3. Plugin Credentials: In the ***Challenge Plugins*** section, create the connector:
   * **Plugin ID:** duckdns
   * **DNS API:** DuckDNS
   * **API Data:** DuckDNS_Token=<YOUR_TOKEN>
   * **Validation Delay:** 300 (This time is necessary to wait for the global DNS servers to update before validation).

##

### 🚀 Phase 3: Orchestration and Issuing (Via CLI)

We must use the Alias parameter to fix the difference between the requested .click domain and the DuckDNS API. To do this, we configure the Node directly via Shell.

1. Open the Proxmox terminal (via SSH or Web Shell).

2. Put the new ACME configuration to link the domain, the plugin, and the alias target all at once:

```bash
pvenode config set --acmedomain0 domain=proxmox.your-domain.click,plugin=duckdns,alias=your-lab.duckdns.org
