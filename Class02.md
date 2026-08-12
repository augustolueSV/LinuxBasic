# Clase 02 — Profundizando en GNU/Linux (continuación de Class01)

Objetivo: ampliar y consolidar los conceptos básicos presentados en la Clase 01 con explicaciones más profundas, buenas prácticas y ejercicios prácticos para adquirir fluidez en la administración y uso del sistema.

---

## 1. Repaso breve (puntos clave de Class01)

- GNU/Linux = kernel (Linux) + utilidades (GNU) + paquetes y configuraciones (distro).
- Terminal y comandos básicos: pwd, ls, cd, cp, mv, rm, cat, less, head, tail.
- Estructura de ficheros: /, /home, /etc, /var, /usr, /bin, /sbin, /dev, /mnt.
- Permisos básicos y chown/chmod; sudo para privilegios.
- Gestores de paquetes: apt, dnf, pacman.

Este material parte de esos supuestos y añade prácticas y herramientas usadas a diario.

---

## 2. La shell y el entorno: variables, historial y alias

La shell (habitualmente bash en muchas distros) tiene un entorno con variables que afectan el comportamiento de comandos y aplicaciones.

- Variables de entorno comunes:
  - PATH: lista de rutas donde la shell busca ejecutables.
    - `echo $PATH`
    - Añadir una ruta temporal: `export PATH="$HOME/bin:$PATH"`
  - HOME: directorio del usuario (`echo $HOME`).
  - USER, SHELL, LANG, TERM.
- Variables locales y de entorno: `VAR=valor` (local), `export VAR=valor` (expuesta a procesos hijos).

Historial de comandos:
- `history` muestra historial.
- Ejecutar comando por número: `!123`.
- Buscar en historial con Ctrl+R (reverse-i-search).

Aliases y funciones:
- Crear alias temporal: `alias ll='ls -alF'`.
- Alias permanente: añadir a `~/.bashrc` o `~/.bash_aliases`.
- Funciones shell para comportamientos complejos:
  - Ejemplo:
    ```bash
    mkcd() { mkdir -p "$1" && cd "$1"; }
    ```

---

## 3. Redirecciones y pipes (composición de comandos)

- Redirecciones de salida:
  - `>` sobrescribe (ej. `echo hola > saludo.txt`).
  - `>>` añade (ej. `echo otra >> saludo.txt`).
  - `2>` redirige stderr (errores). Ej. `comando 2> errores.log`.
  - `&>` redirige stdout y stderr juntos: `comando &> salida.log`.
- Pipes `|`: pasar la salida de un comando a otro.
  - Ej.: `ps aux | grep ssh | less`.
- Uso avanzado: combinar `tee` para ver y guardar: `cmd | tee archivo.txt`.

Consejo: probar comandos sin redirecciones primero para ver su salida antes de guardar o borrar.

---

## 4. Introducción al scripting (bash scripts)

Un script es un archivo de texto ejecutable con una serie de comandos. Permite automatizar tareas.

1. Crear un script sencillo `hola.sh`:
   ```bash
   #!/usr/bin/env bash
   # hola.sh - ejemplo básico
   set -euo pipefail   # opciones recomendadas: detenerse en errores

   nombre=${1:-"mundo"}
   echo "Hola, $nombre"
   ```

2. Hacerlo ejecutable:
   - `chmod +x hola.sh`
   - `./hola.sh` o `./hola.sh Augusto`

3. Buenas prácticas de scripting:
   - `set -euo pipefail` y `IFS=$'\n\t'` cuando corresponda.
   - Validar entradas y argumentos (usar `getopts` para opciones).
   - Comentar y documentar (uso, parámetros, ejemplos).
   - Evitar usar `sudo` dentro del script sin advertencia.

Ejemplo con argumentos y opciones:
```bash
#!/usr/bin/env bash
usage() { echo "Uso: $0 -n NOMBRE"; exit 1; }
while getopts ":n:h" opt; do
  case "$opt" in
    n) nombre="$OPTARG" ;; 
    h) usage ;; 
    *) usage ;; 
  esac
done
: "${nombre:?Necesito -n NOMBRE}"
echo "Hola, $nombre"
```

---

## 5. Usuarios, grupos y sudoers

- Crear usuario: `sudo adduser nombre_usuario` (interactivo) o `sudo useradd -m nombre_usuario` (más control).
- Añadir a grupo: `sudo usermod -aG grupo usuario`.
- Ver grupos de un usuario: `groups usuario`.

Sudoers (control de privilegios):
- Archivo: `/etc/sudoers` (no editar directo; usar `visudo`).
- Ejemplo de línea en sudoers: `usuario ALL=(ALL) NOPASSWD: /usr/bin/systemctl`.
- Recomendación: otorgar permisos mínimos necesarios (principio de menor privilegio).

---

## 6. Gestión de servicios con systemd

systemd es el sistema de arranque y gestor de servicios en muchas distros.

Operaciones comunes:
- `systemctl status nombre.service` — ver estado, logs recientes y si está habilitado
- `sudo systemctl start nombre.service` — iniciar ahora
- `sudo systemctl stop nombre.service` — detener
- `sudo systemctl restart nombre.service` — reiniciar
- `sudo systemctl enable nombre.service` — arrancar al inicio
- `sudo systemctl disable nombre.service` — no arrancar al inicio

Ver logs con journalctl:
- `sudo journalctl -u nombre.service` (logs de un servicio)
- `sudo journalctl -b` (logs del arranque actual)
- `sudo journalctl -f` (seguir en tiempo real)

---

## 7. Administración de paquetes avanzada

- APT (Debian/Ubuntu):
  - `sudo apt update` — actualizar índices
  - `sudo apt upgrade` — actualizar paquetes instalados
  - `sudo apt install pkg` — instalar
  - `sudo apt-cache policy pkg` — ver versión candidata/instalada
  - `apt autoremove` — limpiar dependencias no usadas
- DNF (Fedora): `sudo dnf install pkg` y `sudo dnf upgrade`.
- Pacman (Arch): `sudo pacman -Syu`.

Qué mirar antes de actualizar:
- Revisar notas de la distro, PPA/u otra fuente externa.
- Hacer backups de configuraciones críticas (`/etc`) antes de grandes upgrades.

---

## 8. Logs y diagnóstico del sistema

- Archivos de logs tradicionales en `/var/log` (ej. `/var/log/syslog`, `/var/log/auth.log`).
- journalctl para sistemas con systemd.
- Comandos útiles:
  - `dmesg` — mensajes del kernel (arranque y hardware).
  - `tail -f /var/log/syslog` — seguir logs en tiempo real.
  - `sudo journalctl -xe` — eventos críticos recientes.

Consejo: cuando algo falla, buscar en logs con `grep` o `journalctl -u servicio` antes de cambiar configuraciones radicales.

---

## 9. Redes y SSH

- Ver interfaces y direcciones: `ip addr`, `ip route`.
- Comprobar conectividad: `ping`, `traceroute` (`traceroute` puede necesitar instalarse).
- Conexiones y puertos abiertos: `ss -tuln`, `ss -tunap` (requiere privilegios), `lsof -i`.

SSH (acceso remoto seguro):
- Conectar: `ssh usuario@host`.
- Autenticación con claves:
  - `ssh-keygen -t ed25519 -C "tu_email"`
  - `ssh-copy-id usuario@host` (copiar la clave pública)
- Archivo de configuración del cliente: `~/.ssh/config` para atajos y opciones.
- Buenas prácticas:
  - Deshabilitar autenticación por contraseña en el servidor (`PasswordAuthentication no` en /etc/ssh/sshd_config).
  - Usar `ssh-agent` para cargar claves.

Transferir archivos:
- `scp archivo usuario@host:/ruta/destino`
- `rsync -avz origen/ usuario@host:/ruta/destino/` — sincronización eficiente (recomendado para backups)

---

## 10. Copias de seguridad y estrategias de recuperación

Buenas prácticas:
- Hacer backups regulares y automatizados (rsync, Borg, Restic, duplicity).
- Mantener backups fuera del host (otro servidor, disco externo, nube).
- Probar restauraciones periódicas (un backup que no se puede restaurar no sirve).

Ejemplo simple con rsync (backup local incremental):
- `rsync -av --delete /home/usuario/ /media/backup/usuario/`.

Ejemplo con tar para snapshot: `tar -czvf /media/backup/home-$(date +%F).tar.gz /home/usuario`

---

## 11. Permisos avanzados: setuid, setgid y sticky bit

- setuid (s): si se aplica a un ejecutable, se ejecuta con permisos del propietario del archivo.
  - Ejemplo clásico: `/usr/bin/sudo` con setuid para ejecutar con privilegios root.
  - Ver con `ls -l`: `-rwsr-xr-x` (s en la posición de ejecución del propietario).
- setgid (g): archivos ejecutables se ejecutan con el grupo del archivo; aplicado a directorios hace que nuevos archivos hereden el grupo del directorio.
  - `chmod g+s directorio` — útil en carpetas compartidas de equipo.
- sticky bit (t): en un directorio evita que usuarios borren archivos de otros usuarios (ej. `/tmp` tiene sticky bit).
  - `drwxrwxrwt` indica sticky bit.

Cuidado: no otorgar setuid a scripts sin entender riesgos (puede implicar vulnerabilidades).

---

## 12. Seguridad básica: firewall y hardening

- Firewalls:
  - ufw (Ubuntu amigable): `sudo ufw enable`, `sudo ufw allow 22/tcp`, `sudo ufw status verbose`.
  - iptables/nftables para control más fino (nftables es el sucesor moderno).
- Actualizar el sistema regularmente.
- Deshabilitar servicios innecesarios.
- Revisar usuarios y grupos, cuentas sin contraseña, shells asignados.
- SELinux (Red Hat) o AppArmor (Ubuntu) proporcionan control de acceso obligatorio — son más avanzados y requieren aprendizaje gradual.

---

## 13. Herramientas de depuración y diagnóstico

- strace: seguir llamadas al sistema de un proceso: `strace -f -o traza.txt comando`.
- lsof: ver archivos abiertos por procesos `lsof -p PID` o `lsof -i :80`.
- ss/netstat: ver conexiones y puertos.
- top/htop: ver uso de CPU/memoria y matar procesos.
- tcpdump: capturar tráfico de red (requerirá privilegios): `sudo tcpdump -i eth0 port 80`.

Usar estas herramientas para entender qué hace un proceso y por qué falla.

---

## 14. Cron y tareas programadas

- Cron ejecuta tareas periódicas. Editar crontab con `crontab -e` (para el usuario) y ver con `crontab -l`.
- Formato básico: `m h dom mon dow comando` (minuto, hora, día del mes, mes, día de la semana).
  - Ejemplo: `0 3 * * * /usr/bin/rsync -a /home/usuario/ /media/backup/usuario/` (backup diario a las 3:00)
- Tareas del sistema: `/etc/cron.daily`, `/etc/cron.hourly`, etc.

Consejo: redirigir salida de cron a un log o usar `MAILTO` en crontab para recibir errores.

---

## 15. Control de versiones y colaboración

- Git es la herramienta estándar: instalar y configurar (`git config --global user.name "Tu Nombre"`).
- Buenas prácticas: commits pequeños y descriptivos, usar ramas para funciones y PR/MR para revisiones.

---

## 16. Diagnóstico paso a paso (ejemplo práctico)

Escenario: un servicio web `miapp.service` no responde.

1. Ver estado del servicio: `sudo systemctl status miapp.service` — revisar salida y sugerencias.
2. Ver logs del servicio: `sudo journalctl -u miapp.service -n 200 --no-pager`.
3. Ver puertos: `ss -tuln | grep :80` o `ss -tunap | grep miapp`.
4. Probar la aplicación localmente: `curl -v http://localhost:80/` — observar errores HTTP y tiempos.
5. Revisar archivos de configuración en `/etc/miapp/` y permisos.
6. Usar `strace -f -o /tmp/miapp.trace -p PID` si está congelado para ver llamadas al sistema.

Documentar cada paso y revertir cambios si algo empeora.

---

## 17. Ejercicios prácticos (con soluciones resumidas)

1) Crear un script que haga backup comprimido de `~/proyecto` en `/media/backup/` con nombre que incluya fecha y borre backups antiguos mayores a 7 días.

Solución (resumen):
```bash
#!/usr/bin/env bash
set -euo pipefail
src="$HOME/proyecto"
dst="/media/backup"
fecha=$(date +%F)
archivo="$dst/proyecto-$fecha.tar.gz"
tar -czf "$archivo" -C "$HOME" proyecto
find "$dst" -name "proyecto-*.tar.gz" -mtime +7 -delete
```

2) Configurar un alias `ll` permanente y una función `mkcd` en `~/.bashrc`.

Solución (resumen): añadir al final de `~/.bashrc`:
```bash
alias ll='ls -alF'
mkcd() { mkdir -p "$1" && cd "$1"; }
```
Luego `source ~/.bashrc`.

3) Investigar un servicio que no arranca: listar pasos y comandos que usarías.

Solución (resumen): `systemctl status`, `journalctl -u`, `systemctl start --no-block`, comprobar dependencias y permisos, probar ejecución manual del binario, verificar variables de entorno y archivos de configuración.

4) Crear una cuenta de usuario `estudiante`, añadirlo a grupo `sudo` (o `wheel`) y configurar sudo sin contraseña para un comando específico `/usr/bin/systemctl`.

Solución (resumen):
```bash
sudo adduser estudiante
sudo usermod -aG sudo estudiante   # o wheel en algunas distros
sudo visudo   # añadir: estudiante ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

---

## 18. Recursos y referencias avanzadas (en español e inglés)

- `man` y `info` para documentación local (`man bash`, `man systemctl`).
- The Linux Documentation Project: https://tldp.org/
- Arch Wiki (excelente referencia aunque sea de Arch): https://wiki.archlinux.org/ (muy recomendable)
- Documentación de systemd: https://www.freedesktop.org/wiki/Software/systemd/
- Libros: "The Linux Command Line" (William Shotts), "Linux Pocket Guide" (Daniel J. Barrett).

---

## 19. Buenas prácticas para seguir aprendiendo

- Practicar diariamente con pequeños retos (automatizar tareas personales).
- Leer logs y entender errores en lugar de aplicar soluciones sin contexto.
- Mantener un entorno de pruebas (VM o contenedor) para experimentar.
- Contribuir a la documentación (por ejemplo, con notas propias en `~/.notes` o en un repo Git).

---

## 20. Resumen y siguientes pasos

Esta clase profundiza en herramientas esenciales: shell scripting, gestión de usuarios y servicios, depuración, redes y seguridad básica. Siguiente sugerencia: crear una pequeña máquina virtual con una distro (Ubuntu Server o Debian) y practicar los ejercicios aquí propuestos. Si se desea, preparar una Clase 03 enfocada en:
- Administración de servidores (NGINX/Apache, bases de datos).
- Contenedores y Docker.
- Seguridad avanzada (SELinux/AppArmor, auditoría).

---

¡Buen trabajo! Si quieres, adapto esta clase a una presentación de 45 minutos, un conjunto de diapositivas, o genero ejercicios con soluciones detalladas paso a paso.

