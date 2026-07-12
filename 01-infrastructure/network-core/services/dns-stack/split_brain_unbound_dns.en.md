# 🛠️ SOP: Local Traffic Engineering via Split-Brain DNS (Unbound)

### 📝 Description and Scope

This document defines the Standard Operating Procedure (SOP) to configure Local Traffic Engineering (Split-DNS) using the Unbound DNS name resolver.

The goal is to let devices on the internal network access the NetBox interface using its public domain (with a valid SSL certificate). It resolves directly to the private IP (LAN). This avoids opening ports on the edge router (Zero Trust) and stops DNS Shadowing. It makes sure the rest of the root domain still points to the internet.

##

### ⚙️ Phase 1: Unbound Record Configuration

1. Access the terminal of the server where Unbound is running with superuser rights:

```bash
sudo su -
```

2. Create or edit the specific zone configuration file for NetBox:

```bash
nano /etc/unbound/unbound.conf.d/local-records.conf
```

3. Add the transparent zone directives and the static record (replace the domain and IP with your network data):

```bash
server:
    # Sets the zone as transparent so it does not break the main domain
    local-zone: "your-domain.com." transparent
    
    # Creates the static record only for NetBox
    local-data: "netbox.infra.your-domain.com. IN A 10.10.0.250"
```

* *Attention: The dot . after the domains is required in the Unbound syntax).*

4. Restart the Unbound service to apply the new routes in memory:

```bash
systemctl restart unbound
systemctl enable unbound
```
* ***Note:*** *If you are running it in Docker, you need to restart the container.*

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
