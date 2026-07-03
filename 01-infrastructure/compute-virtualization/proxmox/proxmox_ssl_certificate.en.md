<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/compute-virtualization/proxmox/proxmox_ssl_certificate.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🔒 SOP: Zero-Touch SSL Provisioning (DNS-01) - Proxmox VE (Direct DDNS Mode)

### 📝 Description and Scope

This document is the Standard Operating Procedure (SOP). It shows how to automate and manage SSL/TLS certificates (Let's Encrypt) in the Proxmox VE hypervisor using only a free Dynamic DNS provider (DuckDNS).

The goal is to create a secure edge architecture using the Direct DNS-01 challenge (Point-to-Point). Because we do not use a custom domain (TLD), this model has a simple topology. We do not need logical delegations (CNAME). Proxmox connects directly to DuckDNS via API to put the validation key and issue the certificate. This encrypts the management traffic without opening TCP ports (80/443) to the public internet.

##

### 📋 Prerequisite:

* You must go to the [duckdns](https://www.duckdns.org/) website. Log in with your Google or GitHub account and create a subdomain.
* After that, copy the ***Token*** at the top of the site. Then, follow the steps below.

##

### 🧹 Phase 1: Clean Up and Preparation (Control Plane)

Before we make the new architecture, we must ensure the cluster configuration database (PMXCFS) is clean. We need to delete old domains or Alias setups.

1. Open the Proxmox terminal (via SSH or Web Shell).

2. Remove Old State: Run the command below. It deletes the old domain to stop schema errors:

```bash
pvenode config set --delete acmedomain0
```

3. Make sure you have the DuckDNS alphanumeric Token and your active subdomain name (example: your-lab.duckdns.org).

##

### ⚙️ Phase 2: API Integration and Setup (Hypervisor)

Prepare the Proxmox ACME client to authenticate directly with the Dynamic DNS service.

1. In the Proxmox web interface, go to the Datacenter level (left panel) and click on ***ACME***.

2. Account Registration: In the ***Accounts section***, click Add. Add a new identity. Select the ***Let's Encrypt V2*** directory and put a valid email for alerts.

3. Accept the Terms of Service (TOS) and click Create.

4. Plugin Credentials: In the Challenge Plugins section, click Add to create the connection:

    - **Plugin ID:** duckdns
    - **DNS API:** DuckDNS
    - **API Data:** DuckDNS_Token=<YOUR_ALPHANUMERIC_TOKEN>
    - **Validation Delay:** 300 (This time is necessary to wait for the TXT record to spread to global DNS servers).

##

### 🚀 Phase 3: Orchestration and Issuing (Via CLI)

With the API ready, we configure the Node to link the domain directly to the plugin, without redirects.

1. Go back to the Proxmox Shell.

2. Put the new ACME configuration to link your subdomain to the plugin:

```bash
pvenode config set --acmedomain0 domain=your-lab.duckdns.org,plugin=duckdns
```

3. Run the manual provisioning command to validate the trust chain and get the certificate:

```bash
pvenode acme cert order
```

##

### ✅ Phase 4: Validation and Lifecycle Management

After you run the order, the terminal will show the logs: the DuckDNS API gets the TXT record, Proxmox sleeps for 300 seconds, and Let's Encrypt validates the challenge successfully.

* **Interface Handover:** The hypervisor HTTP service (pveproxy) downloads the keys (.pem and .key) and does a silent graceful reload. Now, you can access the management interface securely with encryption (Green Padlock) using only this URL: https://your-lab.duckdns.org:8006.
* **Zero-Touch Provisioning (Auto Renewal):** The infrastructure now works automatically. Exactly 30 days before the certificate expires (the total cycle is 90 days), the system service (pve-daily-update.service) will start Phase 3 in the background. It changes the keys without system downtime and without human work. This improves the operation's OPEX.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
