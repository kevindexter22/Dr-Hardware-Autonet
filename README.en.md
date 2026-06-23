<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🏡 Welcome to Dr. Hardware Autonet

💡 The idea of this project is to create a homelab to improve my home infrastructure. At the same time, I want to show my technology skills. It brings learning, experience, and better solutions for my daily life.

🔁 I will share every step here. I will show things I really use in my lab or technologies I test in virtual labs. I will explain the reasons, the challenges, and how I solved the problems (easy or difficult).

🗂️ To make it easy to understand, this repository uses this organization:

```text
Dr-Hardware-Autonet/
├── 🏠 01-infrastructure/               # PHYSICAL AND LOGICAL INFRASTRUCTURE (Home Lab)
│   ├── compute-virtualization/         # Hypervisors (Proxmox, ESXi) and Containers (K8s, Docker)
│   ├── network-core/                   # Routing, Switching and Base Services (DHCP, DNS, BGP, OSPF)
│   └── storage/                        # NAS, SAN, Ceph, etc.
│
├── ⚙️ 02-automation-iac/               # CONFIGURATION MANAGEMENT AND AUTOMATION (MTTR Reduction)
│   ├── ansible/                        # Playbooks for setup and configuration management
│   ├── terraform/                      # IaC for resource setup
│   └── python-scripts/                 # Custom scripts (Netmiko, NAPALM, REST APIs/ETL)
│
├── 👁️ 03-oss-management/               # OPERATION SUPPORT SYSTEMS (FCAPS)
│   ├── observability/                  # Metrics (Prometheus, Grafana), Logs (ELK/Loki) and Tracing
│   ├── security-iam/                   # Authentication, Authorization (Radius, TACACS+, Vault)
│   └── alerts-mediation/               # Alert rules, webhooks and data mediation
│
├── 🧪 04-labs-rnd/                     # RESEARCH AND DEVELOPMENT (Simulators and PoCs)
│   ├── network-simulations/            # EVE-NG, GNS3, PNETLab, Packet Tracer
│   └── devops-sandboxes/               # Isolated tests for orchestration and CI/CD
│
├── 📖 docs/                            # OFFICIAL DOCUMENTATION AND ENGINEERING
│   ├── architecture-diagrams/          # Topologies (L2/L3), API flows and logical diagrams
│   ├── runbooks-troubleshooting/       # Guides to fix problems (SOPs)
│   └── standards-policies.md           # IPAM policies, VLANs and naming rules
│
├── .gitignore                          # Ignore sensitive files (.env, tfstate, etc.)
├── LICENSE                             # Project license
├── README.md                           # Main Control Panel (Portuguese)
└── README.en.md                        # Main Control Panel (English)
```

😉 "I hope my journey helps and inspires you to have new ideas and build your own projects. Let's grow together!"

##

###### ℹ️ This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
