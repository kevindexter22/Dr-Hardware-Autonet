<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/05-docs/runbooks-troubleshooting/split_brain_unbound_dns.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 📘 Runbook & Arquitetura: Engenharia de Tráfego Local via Split-Brain DNS (Unbound)

### 🚨 O Problema (Contexto)

Em infraestruturas locais (*Home Labs* ou redes corporativas), frequentemente adotamos uma postura de **Zero Trust** (não abrir portas *Inbound* como 80 ou 443 no roteador de borda). 

O desafio surge ao utilizarmos domínios públicos (ex: `.com` na Hostinger ou `.duckdns.org` no DuckDNS) com certificados SSL válidos da Let's Encrypt: **Como os dispositivos internos podem acessar o NetBox usando o domínio público sem abrir portas no roteador e sem que o tráfego saia para a internet?** 

Se tentarmos o acesso direto, o tráfego morre no firewall do roteador devido à falta de *Hairpin NAT*. Se criarmos uma zona DNS local inteira para o domínio público, causamos o **DNS Shadowing** (Sombreamento), quebrando o acesso ao site principal ou e-mails hospedados fora da rede local.

##

### 💡 A Solução (Design)

A solução adotada foi implementar o conceito de **Split-Brain DNS (DNS de Horizonte Dividido)** utilizando o resolvedor de nomes **Unbound DNS**. Configuramos uma [zona declarada como `transparent`](https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/dns-stack/split_brain_unbound_dns.md). 

O Unbound intercepta apenas a requisição do servidor local (ex. netbox) e entrega o IP privado, enquanto encaminha qualquer outra requisição do domínio raiz para os servidores DNS públicos da internet.

| Componente | Configuração / Diretiva | Função no Fluxo (Engenharia de Tráfego) |
| :--- | :--- | :--- |
| **`local-zone`** | `"seu-dominio.com." transparent` | **Bypass de Zona:** Permite interceptar subdomínios locais sem quebrar o domínio principal na Hostinger. |
| **`local-data`** | `"netbox.infra... IN A 10.10.0.250"` | **Injeção de Rota:** Responde imediatamente com o IP local do LXC, mantendo o tráfego dentro da LAN. |

##

### 🛡️ Segurança e Criptografia (SecOps)

Para garantir a integridade da entrega dos pacotes e a privacidade dos dados:

1. **Validação Nativa SSL/TLS:** Como o navegador continua acessando o endereço oficial (`netbox.infra.seu-dominio.com`), o Nginx consegue entregar o certificado válido gerado via `acme.sh` (Desafio DNS-01). Isso elimina completamente os alertas de "Site Inseguro".

2. **Privacidade de Tráfego (Zero Leak):** Nenhuma requisição de gerenciamento de ativos ou inventário de rede sai pelos cabos de WAN. O tráfego permanece em Camada 2/3 de forma estritamente local, neutralizando sniffers ou interceptações externas.

##

### 🔧 Troubleshooting (O que fazer se quebrar)

Se ao digitar o domínio o navegador exibir erros como `ERR_CONNECTION_REFUSED`, `ERR_CONNECTION_TIMED_OUT` ou avisos de certificado inválido, siga estes passos de diagnóstico:

1. Verifique a Sintaxe do Unbound (Crítico):

Antes de qualquer reinício, valide se não há erros de pontuação ou aspas no arquivo de configuração interna.
```bash
unbound-checkconf
```

* **Correção:** Se houver erros, edite o arquivo `/etc/unbound/unbound.conf.d/netbox.conf` e certifique-se de usar o ponto final . após as zonas de domínio na sintaxe.

2. Verifique a Resolução de Nomes Local:

No terminal do seu computador pessoal (cliente da rede), execute um teste de query DNS para o NetBox:

```bash
nslookup netbox.infra.seu-dominio.com
```

* **Resultado Esperado:** O retorno deve ser estritamente o IP privado do container LXC (10.10.0.250). Se retornar o IP público da sua internet, o Unbound não está interceptando a requisição.

* **Correção:** Force o reinício do serviço com systemctl restart unbound e verifique se a máquina cliente está realmente usando o Unbound como servidor DNS primário.

3. Teste o Isolamento do Domínio Raiz:

Execute uma consulta DNS para o domínio principal ou outros subdomínios que estão na nuvem:

```bash
nslookup seu-dominio.com
```

* **Resultado Esperado:** O retorno deve ser o IP público do servidor de hospedagem. Se retornar erro ou o IP do NetBox, a diretiva transparent foi omitida ou digitada incorretamente, gerando o efeito de DNS Shadowing.

##

###### ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
