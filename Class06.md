# Clase 06 — Mantenimiento del sistema, monitorización, seguridad y recuperación

Objetivo: llevar la administración de Linux un paso más allá de la creación de usuarios y la gestión de servicios. En esta clase veremos cómo vigilar el sistema, detectar problemas, protegerlo y mantenerlo sano sin depender solo de la intuición.

La idea no es “memorizar más comandos”, sino desarrollar una mirada de mantenimiento: saber qué mirar cuando el sistema parece lento, cuándo revisar logs, cómo protegerlo y cuándo hacer una copia antes de tocar algo importante.

---

## 1. El sistema no solo “funciona”: necesita vigilancia

Un sistema Linux no suele fallar de golpe sin previo aviso. Normalmente hay señales:

- consumo alto de memoria
- CPU saturada
- disco lleno
- servicios lentos o caídos
- errores en logs
- servicios que no arrancan al reiniciar

Por eso, administrar un sistema no es solo ejecutar comandos; también es observar.

### 1.1 Comandos esenciales para vigilar el sistema

Ver procesos activos:

```bash
ps aux
```

Monitorizar en tiempo real:

```bash
htop
```

Memoria disponible:

```bash
free -h
```

Espacio en disco:

```bash
df -h
```

Tamaño de carpetas:

```bash
du -sh /home/*
```

Tiempo de actividad del sistema:

```bash
uptime
```

### 1.2 ¿Qué significa cada valor?

- `CPU`: si está al 100%, algo está trabajando mucho o se está quedando bloqueado
- `Memoria`: si se llena, el sistema puede empezar a usar swap o a caer en lentitud
- `Disco`: si el disco está casi lleno, incluso los servicios pequeños pueden fallar
- `Procesos`: si hay demasiados procesos activos, normalmente hay algo mal configurado

### 1.3 Analogía útil

Si Linux fuera una vivienda, estos comandos son como mirar la factura, el termostato, la entrada de agua y el nivel de bolsas de basura.

No hace falta “sentir” el problema; basta con mirar los indicadores.

---

## 2. Procesos: qué corre y por qué

Un proceso es un programa en ejecución. En Linux, cada servicio, terminal, automatización y comando crea procesos.

### 2.1 Listar procesos

```bash
ps -ef
```

Buscar un proceso concreto:

```bash
ps aux | grep nginx
```

Matar un proceso:

```bash
kill PID
```

Forzar cierre:

```bash
kill -9 PID
```

### 2.2 Prioridades y recursos

A veces un proceso consume mucha CPU. Puedes revisarlo con `top` o `htop` y luego ajustar prioridad si es necesario.

Ejemplo:

```bash
nice -n 10 comando
```

`nice` ayuda a reducir la prioridad de un proceso, útil cuando quieres que un trabajo secundario no “bloquee” todo el sistema.

### 2.3 Ley importante

No todo proceso tiene que ser matado. A veces el problema real está en:

- un servicio mal configurado
- un proceso repetitivo
- un trabajo en loop
- un consumo excesivo de memoria

Antes de matar algo, conviene entender qué hace.

---

## 3. Logs: la memoria del sistema

Los logs son registros de eventos. Si el sistema falla, usually los logs dicen lo que pasó.

### 3.1 Directories comunes de logs

```bash
ls /var/log
```

Algunos archivos importantes:

- `/var/log/syslog`
- `/var/log/auth.log`
- `/var/log/dmesg`
- `/var/log/boot.log`

### 3.2 Ver logs en tiempo real

```bash
tail -f /var/log/syslog
```

### 3.3 `journalctl` con systemd

```bash
sudo journalctl -xe
```

Ver logs del último arranque:

```bash
sudo journalctl -b
```

Ver logs de un servicio concreto:

```bash
sudo journalctl -u nginx
```

### 3.4 ¿Por qué esto importa?

Porque el sistema no suele decir “está roto” de forma bonita. Normalmente da señales muy técnicas:

- “permission denied”
- “failed to start”
- “No such file or directory”
- “Address already in use”

Leer logs te da contexto, y con contexto puedes arreglar mejor.

---

## 4. `dmesg` y el kernel

El kernel es el corazón del sistema, y a veces difunde mensajes muy útiles sobre hardware, dispositivos, errores de disco o problemas de drivers.

```bash
dmesg | tail -n 50
```

También puedes filtrar mensajes de hardware y arranque:

```bash
dmesg --follow
```

Estos mensajes suelen ser muy útiles cuando:

- falla una USB
- el disco tiene errores
- el Wi‑Fi no conecta
- hay problemas con memoria o drivers

### 4.1 Regla práctica

Si el sistema “se comporta raro” sin explicación, revisa primero:

1. `top`/`htop`
2. `df -h`
3. `journalctl` o `dmesg`
4. `/var/log`

Eso te da una imagen real del problema.

---

## 5. Seguridad básica y mantenimiento preventivo

En Class05 ya trabajamos usuarios, permisos, sudo y servicios. Aquí la clave es reforzar la seguridad sin volvernos paranoicos.

### 5.1 Actualizaciones

Actualizar paquetes periódicamente:

```bash
sudo apt update
sudo apt upgrade
```

En distribuciones con `dnf` o `yum` sería similar, con el gestor correspondiente.

### 5.2 Configuración de SSH

La seguridad de acceso remoto suele depender de bien configuradas las claves SSH.

Ejemplo de generar pareja de claves:

```bash
ssh-keygen
```

Y luego copiar la clave pública a un servidor remoto:

```bash
ssh-copy-id usuario@servidor
```

### 5.3 UFW: firewall simple

Un firewall básico puede ayudar mucho:

```bash
sudo ufw status
sudo ufw allow ssh
sudo ufw enable
```

Es una manera simple de bloquear acceso innecesario.

### 5.4 `fail2ban` y ataques repetitivos

En servidores reales, `fail2ban` puede bloquear IPs que repiten intentos fallidos de acceso. Es una capa extra de protección muy útil.

### 5.5 Buenas prácticas generales

- usa cuentas no privilegiadas para tareas normales
- no dejes usuarios sin uso activos
- usa permisos mínimos
- revisa cada servicio que está activo
- actualiza regularmente el sistema
- no abras puertos sin necesidad

---

## 6. Mantenimiento recurrente: no esperes a que falle algo

Si quieres mantener un sistema sano, es mejor hacer revisiones periódicas que reaccionar solo cuando hay un problema.

### 6.1 Checklist semanal

- `df -h`
- `free -h`
- `top` o `htop`
- `journalctl -xe`
- revisar espacios de trabajo y carpetas temporales
- revisar que no haya servicios sin uso

### 6.2 Limpieza de archivos temporales

```bash
sudo find /tmp -type f -atime +7 -delete
```

### 6.3 Comprobación de paquetes

```bash
dpkg -l | less
```

O con varias distribuciones, revisar paquetes instalados y no necesarios.

### 6.4 Backups periódicos

La regla es simple:

- si un archivo es importante, debe tener copia de seguridad
- si un servicio es crítico, debe tener un backup o una estrategia de restauración
- si vives de datos, no esperes a perderlos para empezar a protegerlos

---

## 7. Recuperación ante fallos: usar la información, no el pánico

A veces falla un servicio, el sistema se queda lento o una carpeta se vuelve inaccesible. La recuperación no consiste en “probar cosas al azar”, sino en diagnosticar.

### 7.1 Revisar disco y particiones

```bash
sudo fdisk -l
sudo lsblk
```

### 7.2 Verificar archivosystem

```bash
sudo fsck /dev/sda1
```

Esto debe hacerse con cuidado, muchas veces en modo de mantenimiento o desde un entorno de rescate.

### 7.3 Montaje de particiones

```bash
sudo mount
```

Para montar una partición concreta:

```bash
sudo mount /dev/sdb1 /mnt/backup
```

### 7.4 Entorno de rescate

Cuando el sistema no arranca, a veces el problema no es el software del usuario sino la configuración del boot o del sistema de archivos.

En esos casos, el administrador revisa:

- si la partición raíz está montada correctamente
- si el initramfs está bien generado
- si el grub o el bootloader está correcto
- si el servicio principal no inició por error de dependencia

### 7.5 Regla de recuperación

Antes de “arreglar” algo, haz esto:

1. identifica el problema
2. confirma la causa
3. haz una copia si el cambio es importante
4. aplica la corrección mínima
5. valida que el sistema responde

---

## 8. Automatización más allá de cron

Class05 puso énfasis en cron y scripts. Aquí vemos que la automatización puede ir un paso más allá.

### 8.1 Scripts más robustos

Ejemplo:

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/mi_backup.log"
BACKUP_DIR="/mnt/backup"
SOURCE_DIR="/home/usuario/proyecto"

mkdir -p "$BACKUP_DIR"
rsync -av "$SOURCE_DIR/" "$BACKUP_DIR/" >> "$LOG_FILE" 2>&1

echo "Backup completado: $(date)" >> "$LOG_FILE"
```

### 8.2 `systemd` timers

`cron` es muy útil, pero `systemd` también puede programar tareas de manera robusta y ordenada.

Ejemplo de idea general:

- un servicio para ejecutar la tarea
- un timer para activarlo según horario

Es una forma más moderna de automatizar tareas del sistema.

### 8.3 Automatización responsable

Las tareas automáticas deben:

- generar logs
- manejar errores
- ser idempotentes cuando sea posible
- tener rutas claras y configurables
- evitar destruir datos sin confirmación

---

## 9. Resumen de la clase

Esta clase cierra la idea de que Linux es solo “escribir comandos”. En realidad, la administración de sistemas combina:

- observación
- monitoreo
- logs
- permisos bien pensados
- servicios controlados
- copias de seguridad
- automatización y recuperación

Los administradores no solo saben qué comando ejecutan; saben qué mirar antes, qué signo indicates un problema y cómo comprobar si una corrección realmente funcionó.

---

## 10. Comandos clave para practicar

```bash
ps aux
htop
free -h
df -h
du -sh /home/*
journalctl -xe
sudo journalctl -u nginx
journalctl -b
ls /var/log
tail -f /var/log/syslog
sudo ufw status
ssh-keygen
sudo apt update
sudo apt upgrade
```

---

## 11. Ejercicios recomendados

1. Revisa `top` o `htop` y observa qué procesos consumen más CPU y memoria.
2. Muestra los logs del sistema con `journalctl` y localiza un evento reciente.
3. Comprueba el espacio en disco con `df -h` y el tamaño de carpetas con `du -sh`.
4. Genera una clave SSH y prueba el acceso remoto con una máquina de prueba.
5. Activa un firewall simple con `ufw` y revisa qué puertos están abiertos.
6. Crea un script de backup y ejecútalo manualmente antes de programarlo.
7. Haz una práctica de recuperación: revisa `lsblk`, `mount` y `dmesg` en un entorno de prueba.
8. Programa una tarea con cron o un timer de systemd y observa su registro.

---

## 12. Frase final

Linux no se trata solo de usarlo: se trata de mantenerlo vivo, ordenado y seguro. Cuando aprendes a observar, a leer logs, a proteger servicios y a automatizar tareas, dejas de ser un usuario que “ejecuta comandos” y te conviertes en alguien capaz de entender cómo funciona un sistema real.

Y esa diferencia es la que marca el paso entre usar Linux y administrarlo con criterio.
