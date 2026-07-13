# 🛡️ VPN Stack (IPsec/IKEv2 & strongSwan)

### 📝 Architecture Description
This folder documents the architecture, setup, and operation policies of the **Remote Access VPN (Client-to-Site)** gateway. We designed this service to give remote workers safe, encrypted, and authenticated access to the infrastructure and management networks.

The core for cryptography and key negotiation is **strongSwan**, a strong, open-source IPsec *daemon*. The topology uses the **IKEv2** (Internet Key Exchange version 2) protocol to build the tunnel. It uses **EAP-MSCHAPv2** to authenticate users. This choice guarantees high security and maximum compatibility. It allows *endpoints* (Windows, macOS, Android) to connect natively, without installing extra client apps or software.

##

### 🏗️ Operational Alignment (FCAPS)

The operation of this VPN gateway follows these management strategies:

* **F (Fault Management):** The strongSwan `charon` daemon gives detailed *logs* of the IKE state machines. Continuous monitoring of negotiation errors (Phase 1/Phase 2) or EAP authentication helps the support team. They can quickly find if the problem is bad credentials, blocked ports by ISPs, or a cryptographic *timeout*. This reduces the MTTR.

* **C (Configuration Management):** Standardization of cryptography parameters (*Cipher Suites*), routing policies, and *split-tunneling*. We keep the configuration as code. This makes auditing easy and allows fast service recovery in a disaster.
  
* **P (Performance Management):** We optimize the MSS (*Maximum Segment Size*) and MTU (*Maximum Transmission Unit*) using *ufw/iptables/nftables*. This stops packet fragmentation and connection drops. We use *hardware* extensions (AES-NI) on the physical/virtual host to make cryptography processing faster and avoid CPU bottlenecks.

* **S (Security Management):** Strong authentication using mutual certificates (for the Gateway) and credentials (for the clients). We use *Perfect Forward Secrecy* (PFS). This guarantees that compromised session keys in the future cannot decrypt past traffic. 

##

### 🖧 Logical Topology (OSI Layer 3-7)

| Component / Protocol | Logical Function | Communication | Protocols / OSI Layer |
| :--- | :--- | :--- | :--- |
| **IKEv2 (strongSwan)** | Key and SA Negotiation | `Client <-> VPN Gateway` | UDP 500 / UDP 4500 (Layer 7) |
| **EAP-MSCHAPv2** | User Authentication | `Client <-> VPN Gateway` | EAP via IKEv2 (Layer 7) |
| **IPsec (ESP)** | Cryptographic Encapsulation | `Client <-> VPN Gateway` | IP Protocol 50 (Layer 3) |
| **NAT-T (NAT Traversal)** | UDP Tunneling over NAT | `Client -> NAT -> Gateway` | UDP 4500 (Layer 4) |

##

### 🛡️ Security and Network Requirements (SecOps)

To guarantee the correct tunnel operation and protect the network perimeter:

1.  **Ingress Firewall:** The *host* running strongSwan must be accessible from the outside (WAN) only on ports `UDP 500` (IKE) and `UDP 4500` (NAT-T). It must also allow IP protocol `50` (ESP) traffic.

2.  **Routing and Forwarding:** The VPN server's Linux *kernel* must have packet forwarding enabled (`net.ipv4.ip_forward=1`). The local *firewall* must do masquerading/NAT for the virtual IP block assigned to VPN clients. This lets them reach the internal network (LAN/OAM).

3.  **Access Isolation:** Access Control Lists (ACLs) must be active on the VPN server's internal interface. This limits which servers and services (SSH, Web Admin, RDP) the VPN clients can reach.

4.  **Identity Management:** We recommend future integration of the authentication backend (currently local files/secrets) with a RADIUS/Active Directory server. This will centralize identity management (IAM).

##

### 🛠️ Operational Procedures (Runbooks)

To set up new VPN servers, create users, or remove access, see the documented procedures below:

* 👉 **[SOP: VPN Server Installation and Configuration (IPsec/IKEv2 strongSwan)](./vpn_server_setup.en.md)**

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
