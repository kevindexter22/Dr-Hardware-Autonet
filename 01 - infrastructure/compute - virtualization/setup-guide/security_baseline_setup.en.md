<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01 - infrastructure/compute - virtualization/setup-guide/security_baseline_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

## 🛡️ SOP: Security Base and OS Hardening

### 📝 Description and Scope (SecOps)

This Standard Operating Procedure (SOP) gives the rules for base Operating System (Ubuntu/Debian) hardening on infrastructure nodes.

The goal is to reduce the attack surface, hide standard ports, use Default Deny rules on the host firewall (UFW), and stop brute force attacks using log analysis (Fail2ban). You must apply this baseline right after the first server boot.

##

### 🔐 Phase 1: SSH Hardening (Hiding and Access Control)

Hiding the standard port (TCP/22) stops a lot of noise from automatic network scanners.

1. Access the server via SSH and open the SSH configuration file:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Change these lines (remove the comment symbol if necessary):
   ```bash
   Port <CUSTOM_PORT_SSH>
   PermitRootLogin no
   PubkeyAuthentication yes
   ```
   ***Architectural Note:*** *In production, it is good to change PasswordAuthentication to no. This forces the use of              cryptographic keys only (RSA/Ed25519).*

3. Restart the SSH service to apply the changes:
   ```bash
   sudo systemctl restart ssh
   ```

## 

### 🧱 Phase 2: Host Firewall (UFW - Uncomplicated Firewall)

The L3/L4 security policy uses local Zero Trust (Default Deny). This means incoming traffic is only allowed if you declare it.

1. First, make sure UFW is installed:
   ```bash
   sudo apt update; sudo apt install ufw -y
   ```
2. Set the default rules (Block incoming, allow outgoing):
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```
3. **CRITICAL:** Allow the new SSH port before you turn on the firewall. This prevents a lockout:
   ```bash
   sudo ufw allow <CUSTOM_SSH_PORT>/tcp
   ```
4. Allow the ports for the services running on this host (e.g., web, samba, etc.):
   ```bash
   # TCP Ports
   sudo ufw allow <SERVICE_PORT>/tcp comment "Service name for this port"
   # UDP Ports
   sudo ufw allow <SERVICE_PORT>/udp comment "Service name for this port"
   # TCP and UDP Ports
   sudo ufw allow <SERVICE_PORT> comment "Service name for this port"
   ``` 
5. Turn on the firewall:
   ```bash
   sudo ufw enable
   ```
6. Check the rule table:
   ```bash
   sudo ufw status
   ```

##

### 🚨 Phase 3: Local IPS and Intrusion Prevention (Fail2ban)

Fail2ban works as a host-based IPS (Intrusion Prevention System). It reads system logs and adds dynamic rules to iptables/UFW to ban bad IPs.

1. Install the package with this command:
   ```bash
   sudo apt update; sudo apt install fail2ban -y
   ``` 
2. Make a local copy of the config file (this stops overwrites during package updates):
   ```bash
   sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
   ```
3. Edit the local file to configure the SSH Jail:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ``` 
4. Find the [sshd] section. Change the port to match Phase 1, and turn on the rule:
   ```bash
   [sshd]
   enabled = true
   port    = <CUSTOM_SSH_PORT>
   logpath = %(sshd_log)s
   backend = %(sshd_backend)s
   maxretry = 3
   bantime = 3600
   ``` 
   - `maxretry` = 3: Bans the IP after 3 failed tries.
   - `bantime` = 3600: Ban time (in seconds, e.g., 1 hour).
5. Start the service:
   ```bash
   sudo systemctl enable fail2ban
   systemctl restart fail2ban
   ```

##

### ✅ Phase 4: Operational Check (Anti-Lockout)

Now, we need to make sure you do not lose SSH access after these changes.

**Note:** Do not close your current terminal. If the settings are wrong, you will lose access if you close it.

1. Open a second terminal on your local machine.
2. Try to make a new SSH connection using the custom port:
   ```bash
   ssh <YOUR_USER>@<SERVER_IP> -p <CUSTOM_SSH_PORT>
   ``` 
3. Check if Fail2ban is working well and watching SSH:
   ```bash
   sudo fail2ban-client status sshd
   ``` 
4. If the connection in window 2 works, the Security Baseline is a success. You can now close window 1.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
