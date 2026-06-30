<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/storage/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 💾 Storage Infrastructure (NAS/SAN)

### 📝 Descrição do Escopo

Este domínio gerencia a infraestrutura de armazenamento persistente. O foco reside na garantia da integridade dos dados (Fault Management), otimização de performance de I/O (Performance Management) e consistência na montagem de volumes (Configuration Management).

##

### 🏗️ Arquitetura de Armazenamento

A topologia de armazenamento está segmentada por funcionalidade e protocolo, garantindo o isolamento necessário para cada *workload*:

* **Storage Local (Proxmox/CasaOS):** Focado em persistência de bloco e volumes locais para contêineres e máquinas virtuais.
* **Storage de Rede (NAS/SMB):** Focado no compartilhamento de recursos para endpoints específicos (como o console PS2), utilizando o protocolo SMBv1 para compatibilidade legada.

##

### 📂 Estrutura de Diretórios (Workloads)

| Diretório | Protocolo | Função Lógica (FCAPS) |
| :--- | :--- | :--- |
| `casaos-local-storage/` | Mount (UUID) | Gerenciamento de montagens locais e persistência de blocos. |
| `opl-smb-storage/` | SMB (v1) | Compartilhamento de arquivos para endpoints (PS2/OPL) e automação de I/O. |

##

### ⚙️ Gestão de Configuração e Automação

A integridade do sistema de arquivos é mantida através de práticas de IaC e monitoramento proativo:

* **Gestão de UUIDs:** As montagens de discos rígidos em `casaos-local-storage` utilizam identificadores persistentes (UUIDs) para evitar *Configuration Drift* após eventos de reconfiguração de hardware ou *reboots*.
* **Monitoramento Ativo:** O diretório `opl-smb-storage` contém lógica de monitoramento de *endpoint* e rotinas de *shutdown* automatizadas. Estes scripts garantem a integridade dos dados antes da desconexão física do dispositivo (Mitigação de falhas/corrupção).

##

### 🛡️ Políticas de Segurança e Integridade

* **Access Control:** O acesso aos *shares* é restrito por endereçamento IP e credenciais de serviço, limitando a movimentação lateral de possíveis atacantes na rede local.
* **Integridade:** Rotinas de verificação de montagem (fstab/systemd mounts) são validadas para assegurar que não haja *race conditions* durante a inicialização do sistema.

##

### 🔄 Referências e Governança

Para detalhes sobre as políticas globais de nomenclatura e padrões de segurança, consulte a documentação oficial:
👉 **[Documento Central de Governança e Padrões (Standards & Policies)](#)**

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
