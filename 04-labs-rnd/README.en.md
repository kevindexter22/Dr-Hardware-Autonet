<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/04-labs-rnd/README.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🧪 Research and Development (R&D Sandbox)

### 📝 Scope Description

This repository is the controlled **Research and Development** environment. Its primary function is to serve as a *Sandbox* for validating new topologies, stress testing *workloads*, and experimenting with new technologies (PoCs) before implementation in production environments.

##

### 🏗️ Domain Structure (Sandbox Logic)

The environment is segmented to allow isolated testing (layer abstraction):

| Domain | Technical Objective | Tools (Examples) |
| :--- | :--- | :--- |
| `network-simulations/` | Validation of L2/L3 topologies and routing scenarios. | EVE-NG, GNS3, PNETLab, Packet Tracer |
| `devops-sandboxes/` | Testing CI/CD pipelines, orchestration, and *deploy*. | Docker, K3s, Minikube, Jenkins |

##

### ⚙️ Experimentation Lifecycle

To ensure the integrity of the main environment, all experimentation must follow these guidelines:

1. **Resource Isolation:** Tests that require high load or manipulation of routing tables must take place strictly within the simulated network (GNS3/EVE-NG).
2. **Reproducibility:** Every PoC must be documented with configuration files (`.yaml`, `.sh`, `.py`) so that the experiment is replicable.
3. **State Cleanup:** After validation, temporary resources (containers, VM instances, *snapshots*) must be removed to avoid unnecessary consumption of *compute* and *storage*.

##

### 🛡️ Governance and Compliance

* **Prohibition in Production:** No script or configuration contained in these subfolders has a guarantee of stability or compatibility with the main infrastructure.
* **Security:** Traffic generated in the simulators must be isolated from the *Core* network to avoid interference with production DNS, IAM, or Telecom services.

##

### 🔄 Cross-References

* **Automation:** To integrate the code validated here into your automation repository, see the `02-automation-iac` section.
* **Policies:** For asset naming guidelines and security standards, see our **[Governance Document](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/05-docs/standards-policies.en.md)**.

##

###### ℹ️ Isolated lab environment - Part of Dr. Hardware Autonet.
