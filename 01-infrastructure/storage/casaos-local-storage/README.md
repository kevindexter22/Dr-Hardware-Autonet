<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/storage/casaos-local-storage/README.en.md" target="_blank" rel="noopener noreferrer">🇬🇧 English</a></h6>

# 💾 CasaOS Local Storage: Watchdog de Montagem de Disco

### 📝 Descrição do Escopo
Este diretório abriga o *script* garantidor de estado (State Enforcer) para mídias de armazenamento externo no CasaOS (Raspberry Pi). 

Sistemas operacionais desktop e interfaces web frequentemente "sequestram" HDDs externos montando-os em caminhos dinâmicos (como `/media/root/`), o que quebra os volumes persistentes (`bind mounts`) dos contêineres Docker. O objetivo deste *script* é atuar como um *Watchdog*, validando se o disco está montado no local exato estipulado pela infraestrutura e corrigindo automaticamente caso não esteja.

##

### ⚙️ Lógica de Funcionamento (State Enforcement)

O script `mount-external-disk.sh` não altera configurações do host; ele faz a leitura do estado atual e aplica ações corretivas:

1. **Validação de Hardware:** Utiliza `blkid` para confirmar se o UUID mapeado está fisicamente conectado ao barramento USB.
2. **Leitura da Fonte da Verdade:** Consulta o `/etc/fstab` para descobrir qual é o *Mountpoint* oficial daquele disco.
3. **Auditoria de Estado:** Cruza os dados com o `lsblk`. Se o disco estiver montado no lugar errado pelo automounter do SO, o script executa um `umount` forçado.
4. **Aplicação de Estado:** Remonta o disco no caminho correto utilizando a regra oficial do sistema (`mount <MOUNTPOINT>`).
5. **Observabilidade (Syslog):** Todas as ações, sucessos ou falhas são injetadas nativamente no log do sistema utilizando a tag `HDD_Mount`, permitindo rastreabilidade via `journalctl`.

##

### 📋 Pré-requisitos
Para que o *script* funcione, o disco já deve possuir uma entrada válida pré-configurada no `/etc/fstab` da máquina. 

Exemplo de entrada FSTAB esperada:
```text
UUID=F0B8596AB8592FF8 /mnt/storage_externo auto defaults,nofail 0 2
```
* **Nota:** *A flag nofail garante que a Raspberry Pi não trave durante o boot caso o HD seja desconectado fisicamente.*

##

### 🚀 Execução e Teste Manual

Para rodar a verificação de estado e acompanhar os logs de execução:
```bash
chmod +x mount-external-disk.sh
sudo ./mount-external-disk.sh

# Para visualizar os logs gerados pelo script:
sudo journalctl -t HDD_Mount
```

##

ℹ️ Parte do projeto Dr. Hardware Autonet - Licenciado sob a licença MIT.
