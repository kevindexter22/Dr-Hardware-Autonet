# 📘 Runbook & Architecture: Local Traffic Engineering via Split-Brain DNS (Unbound)

### 🚨 The Problem (Context)

In local networks (Home Labs or company networks), we often use a Zero Trust model (no open Inbound ports like 80 or 443 on the edge router).

The challenge comes when we use public domains (e.g., `.com` on Hostinger or `.duckdns.org` on DuckDNS) with valid Let's Encrypt SSL certificates: How can internal devices access NetBox using the public domain without opening ports on the router and without the traffic going to the internet? 

If we try direct access, the traffic stops at the router firewall because there is no Hairpin NAT. If we create a full local DNS zone for the public domain, we cause DNS Shadowing. This breaks access to the main website or emails hosted outside the local network.

##

### 💡 The Solution (Design)

The solution is to use the Split-Brain DNS concept with the Unbound DNS name resolver. We configure a [zone declared as `transparent`](#).

Unbound intercepts only the NetBox request and gives the private IP. It sends any other request for the root domain to the public DNS servers on the internet.

| Component | Configuration / Directive | Flow Function (Traffic Engineering) |
| :--- | :--- | :--- |
| **`local-zone`** | `"your-domain.com." transparent` | **Zone Bypass:** Allows intercepting local subdomains without breaking the main domain on Hostinger. |
| **`local-data`** | `"netbox.infra... IN A 10.10.0.250"` | **Route Injection:** Answers immediately with the local LXC IP, keeping traffic inside the LAN. |

**Note:** For full details on installing the base app, PostgreSQL 16 database, and Gunicorn, see the SOP for Clean NetBox Install in LXC.

##

### 🛡️ Security and Encryption (SecOps)

To ensure packet delivery integrity and data privacy:

1. **Native SSL/TLS Validation:** Because the browser still accesses the official address (`netbox.infra.your-domain.com`), Nginx can deliver the valid certificate generated via `acme.sh` (DNS-01 Challenge). This completely removes the "Unsafe Site" alerts.

2. **Traffic Privacy (Zero Leak):** No asset management or network inventory requests leave through the WAN cables. Traffic stays in Layer 2/3 strictly locally. This stops external sniffers or interceptions.

##

### 🔧 Troubleshooting (What to do if it breaks)

If you type the domain and the browser shows errors like `ERR_CONNECTION_REFUSED`, `ERR_CONNECTION_TIMED_OUT`, or invalid certificate warnings, follow these diagnostic steps:

1. Check Unbound Syntax (Critical):

Before any restart, check if there are no punctuation or quote errors in the internal configuration file.

```bash
unbound-checkconf
```
* **Fix:** If there are errors, edit the `/etc/unbound/unbound.conf.d/netbox.conf` file. Make sure to use the dot . after the domain zones in the syntax.

2. Check Local Name Resolution:

In the terminal of your personal computer (network client), run a DNS query test for NetBox:

```bash
nslookup netbox.infra.your-domain.com
```

* **Expected Result:** The return must be strictly the private IP of the LXC container (10.10.0.250). If it returns your public internet IP, Unbound is not intercepting the request.

* **Fix:** Force the service restart with systemctl restart unbound. Check if the client machine is really using Unbound as the primary DNS server.

3. Test Root Domain Isolation:

Run a DNS query for the main domain or other subdomains in the cloud:

```bash
nslookup your-domain.com
```

* **Expected Result:** The return must be the public IP of the hosting server. If it returns an error or the NetBox IP, the `transparent` directive is missing or typed wrong, causing the DNS Shadowing effect.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.

ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
