<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/split_brain_unbound_dns.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 🛠️ SOP: Engenharia de Tráfego Local via Split-Brain DNS (Unbound)

### 📝 Descrição e Escopo

Este documento define o Procedimento Operacional Padrão (SOP) para a configuração de Engenharia de Tráfego Local (Split-DNS) utilizando o resolvedor de nomes Unbound DNS.

O objetivo é permitir que dispositivos na rede interna acessem a interface do NetBox através do seu domínio público (com certificado SSL válido), resolvendo diretamente para o IP privado (LAN). Isso evita a necessidade de abrir portas no roteador de borda (Zero Trust) e impede o DNS Shadowing, garantindo que o restante do domínio raiz continue apontando para a internet.

##

### ⚙️ Fase 1: Configuração do Apontamento no Unbound

1. Acesse o terminal do servidor onde o Unbound está rodando com privilégios de superusuário:

```bash
sudo su -
```

2. Crie ou edite o arquivo de configuração de zona específico para o NetBox:

```bash
nano /etc/unbound/unbound.conf.d/local-records.conf
```

3. Adicione as diretivas de zona transparente e o apontamento estático (substitua o domínio e IP pelos dados correspondentes da sua rede):

```bash
server:
    # Define a zona como transparente para não quebrar o domínio principal
    local-zone: "seu-dominio.com." transparent
    
    # Cria o apontamento estático exclusivamente para o NetBox
    local-data: "netbox.infra.seu-dominio.com. IN A <IP DO SERVIDOR>"
``` 
* *Atenção: O ponto final . após os domínios é obrigatório na sintaxe do Unbound).*

4. Reinicie o serviço do Unbound para aplicar as novas rotas em memória:

```bash
systemctl restart unbound
systemctl enable unbound
```
***Observação:*** *Se estiver rodando no docker precisa reiniciar o container.*

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
