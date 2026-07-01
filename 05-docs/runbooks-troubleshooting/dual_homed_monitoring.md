

# 📘 Runbook & Arquitetura: Monitoramento Isolado via Dual-Homing

### 🚨 O Problema (Contexto)

Em cenários de rede, frequentemente temos sub-redes isoladas (como Wi-Fi de convidados ou IoT) que não possuem roteamento para a rede principal. O desafio era: **Como monitorar os dispositivos nessa rede Wi-Fi isolada sem abrir portas no firewall ou comprar outro hardware?**

##

### 💡 A Solução (Design)

A solução adotada foi promover o Zabbix Proxy existente (Raspberry Pi) a um nó **Dual-Homed** (conectado a duas redes ao mesmo tempo). Ele usa o Wi-Fi para acessar a rede isolada e o cabo de rede para enviar os dados para o Zabbix Server.

| Interface | Rede / VLAN | Função no Fluxo (FCAPS) |
| :--- | :--- | :--- |
| **`wlan0`** (Wi-Fi) | Rede Isolada / IoT | **Ingress (Coleta):** Coleta métricas dos agentes na rede sem fio. |
| **`eth0`** (Cabeada) | LAN Principal | **Egress (Escoamento):** Envia os dados para a nuvem de forma segura. |

##

### 🛡️ Segurança e Roteamento (SecOps)

Para garantir que o Proxy não se torne uma ponte insegura entre as redes:

1. **Sem Sequestro de Rota (Default Gateway Hijack):** A interface Wi-Fi (`wlan0`) foi configurada no Netplan com `use-routes: false`. Isso garante que a internet continue saindo pelo cabo (`eth0`).
2. **Isolamento (No IP Forwarding):** O repasse de pacotes (`net.ipv4.ip_forward=0`) está desativado no Linux. Ninguém na rede Wi-Fi consegue usar o Proxy como roteador para invadir a rede principal.

##

### 🔧 Troubleshooting (O que fazer se quebrar)

Se o monitoramento da rede Wi-Fi parar ou o Proxy perder conexão com a nuvem, siga estes passos:

1. **Verifique a Rota Padrão (Crítico):**
   Execute `ip route`. A linha que começa com `default via` **deve** apontar para a interface `eth0`. Se estiver apontando        para `wlan0`, o tráfego está indo para o lugar errado.
   * *Correção:* Revise o arquivo `/etc/netplan/*.yaml` e aplique `sudo netplan apply`.
2. **Verifique a Conexão Wi-Fi:**
   Execute `ip a show wlan0`. Verifique se a interface pegou um endereço IP. Se não tiver IP, o rádio pode estar desconectado.
   * *Correção:* Verifique as credenciais no Netplan e rode `sudo wpa_cli status`.
3. **Teste o Isolamento:**
   Tente fazer um ping da rede Wi-Fi para um IP da rede principal usando o Proxy. O ping deve **falhar**, garantindo que o        isolamento de segurança está ativo.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
