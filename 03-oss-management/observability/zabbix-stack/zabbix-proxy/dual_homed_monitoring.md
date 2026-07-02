<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-proxy/dual_homed_monitoring.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🏗️ Solution Design: Monitoramento Isolado via Dual-Homing (Zabbix Proxy)

### 🚨 O Problema (Contexto)

Em cenários de infraestrutura distribuída, frequentemente nos deparamos com sub-redes isoladas (como redes Wi-Fi de convidados, IoT ou redes de gerência *Out-of-Band*) que não possuem roteamento direto para a LAN principal ou para a nuvem. 
O desafio arquitetural era: **Como extrair telemetria (monitorar) dispositivos nessa rede Wi-Fi isolada sem quebrar a segmentação de segurança (abrir portas no firewall) ou adquirir novo hardware?**

##

### 💡 A Solução Proposta

A solução adotada foi promover o Zabbix Proxy existente (Raspberry Pi - ARM64) a um nó **Dual-Homed** (conectado a duas redes simultaneamente).

Utilizando o rádio Wi-Fi nativo do hardware, o nó foi inserido fisicamente na segunda rede, atuando como uma ponte segura. Ele realiza o *polling* local na rede Wi-Fi isolada e utiliza sua interface cabeada (LAN) principal para escoar os dados agregados para o Zabbix Server.

##

### 🖧 Topologia Lógica e Fluxo de Dados

| Interface | Rede / VLAN | Função no Fluxo de Telemetria (FCAPS) |
| :--- | :--- | :--- |
| **`wlan0`** (Wi-Fi) | Rede Isolada / IoT | **Ingress (Coleta):** Ouve e requisita dados dos agentes Zabbix na rede sem fio. |
| **`eth0`** (Cabeada) | LAN Principal | **Egress (Escoamento):** Envia os dados processados para a nuvem de forma segura. |

##

### 🛡️ Considerações de Segurança (SecOps) e Roteamento

A implementação desta solução exige controles rigorosos para evitar que o nó de monitoramento se torne um vetor de ataque ou uma ponte de vazamento de dados (*Data Leakage*):

1. **Prevenção de Sequestro de Rota (Default Gateway Hijack):** A interface `wlan0` foi configurada de forma declarativa (via Netplan) para **ignorar** a rota padrão anunciada pelo DHCP da rede Wi-Fi (`dhcp4-overrides: use-routes: false`). Isso garante que todo o tráfego com destino à internet/nuvem saia exclusivamente pela rede cabeada (`eth0`).
2. **Isolamento de Tráfego (No IP Forwarding):** O repasse de pacotes IPv4 (`net.ipv4.ip_forward=0`) permanece desabilitado no nível do kernel (sysctl) do Linux. Isso garante que um dispositivo infectado na rede Wi-Fi não consiga utilizar o Zabbix Proxy como roteador para invadir a LAN principal.
3. **Criptografia na Borda:**
   Toda a comunicação consolidada que sai da interface `eth0` em direção à nuvem (Zabbix Server) permanece criptografada via TLS/PSK.

##

### ⚙️ Implementação Técnica (Referência)

A configuração declarativa responsável por habilitar esta topologia sem comprometer o roteamento foi aplicada no nível do Sistema Operacional:

```yaml
# Exemplo do bloqueio lógico da rota na interface secundária (Netplan)
wifis:
  wlan0:
    dhcp4: true
    dhcp4-overrides:
      use-routes: false  # Garante que a LAN principal (eth0) mantenha a Default Route
```

Caso prefira configurar um IP estático, ficará da seguinte forma:

```yaml
# Exemplo do bloqueio lógico da rota na interface secundária (Netplan)
wifis:
  wlan0:
    dhcp4: false
    addresses:
      - <IP_DA_REDE/CIDR>
    dhcp4-overrides:
      use-routes: false  # Garante que a LAN principal (eth0) mantenha a Default Route
```

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
