# LinuxBasic: guía para principiantes, curiosos y amantes del terminal

Bienvenido a este repositorio. Aquí no solo encontrarás apuntes y ejercicios de Linux, sino una forma de aprenderlo con calma, practicando desde la terminal y entendiendo cómo funciona la herramienta que más usamos cuando queremos controlar un sistema con precisión.

Si estás empezando, no te preocupes: Linux se entiende mejor cuando lo usas, no cuando lo miras solo en teoría. Este proyecto está pensado para ayudarte a dar los primeros pasos, construir confianza y empezar a sentir que la terminal ya no es un monstruo, sino una aliada.

---

## ¿Qué es este repositorio?

Este proyecto reúne una serie de clases y ejercicios introductorios sobre GNU/Linux, con enfoque práctico y claro para quienes empiezan desde cero.

Incluye:

- fundamentos del sistema operativo GNU/Linux
- estructura del sistema de archivos
- permisos y propietarios
- comandos básicos para navegar y administrar archivos
- uso de la terminal y shell
- gestión de paquetes
- servicios y procesos
- scripting básico en Bash
- diagnóstico de problemas con logs y red
- ejercicios prácticos para poner todo en acción

El objetivo principal es aprender Linux como alguien que quiere usarlo, entenderlo y disfrutarlo, no solo memorizar comandos.

---

## Mi filosofía de aprendizaje

Linux no se trata de "saber todos los comandos" de memoria. Se trata de:

- entender qué hace cada cosa
- probar con seguridad
- leer la documentación
- usar la terminal con intención
- aprender de los errores
- sentirse cómodo en un entorno sin miedo

Esto es importante: en Linux, muchas veces la mejor forma de aprender es ejecutar un comando, observar la salida, entender el resultado, y repetirlo hasta que tenga sentido.

---

## Estructura del proyecto

```text
LinuxBasic/
├── README.md
├── Class01.md
├── Class02.md
├── Class03.md
├── Class04.md
├── Class05.md
└── ejercicios/
    └── ejercicio01_cli.sh
```

### Descripción rápida

- Class01.md: conceptos básicos de GNU/Linux, distribuciones, terminal, directorios y permisos.
- Class02.md: entorno de shell, scripting, variables, alias, usuarios, servicios y seguridad básica.
- Class03.md: comandos esenciales, redirecciones, pipes, grep, find y más práctica real.
- Class04.md: resolución de ejercicios y cierre de la etapa introductoria.
- Class05.md: administración de usuarios y grupos, sudo, permisos avanzados, systemd, backups y automatización con cron.
- ejercicios/ejercicio01_cli.sh: mini gestor de tareas escrito en Bash para practicar scripting y lógica.

---

## Ruta de aprendizaje recomendada

Si eres principiante, te recomiendo seguir este orden:

### 1. Empieza por lo esencial

Aprende a moverte por el sistema:

- `pwd`
- `ls`
- `cd`
- `mkdir`
- `touch`
- `cp`
- `mv`
- `rm`
- `cat`
- `head`
- `tail`

Estos comandos son la base para cualquier trabajo en Linux.

### 2. Entiende la estructura del sistema

Conocer directorios como:

- `/`
- `/home`
- `/etc`
- `/var`
- `/tmp`
- `/usr`
- `/bin`
- `/dev`

te ayuda a no perderte cuando algo no funciona o quieres buscar configuraciones.

### 3. Domina permisos

Los permisos son clave en Linux. Aprender a leer esto:

```bash
-rw-r--r--
```

y entender `r`, `w` y `x` cambia mucho la forma en que interactúas con el sistema.

### 4. Practica con la terminal, no solo leyendo

Ejemplo:

```bash
mkdir ~/prueba_linux
cd ~/prueba_linux
touch a.txt b.txt c.txt
ls -la
```

Esto te enseña más que muchas páginas de teoría.

### 5. Avanza a scripting básico

Cuando ya entiendas comandos simples, llega el momento de automatizar tareas con Bash.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Hola, Linux"
```

Esto abre la puerta a scripts útiles, automatización y administración básica.

### 6. Diagnóstico y seguridad

Cuando algo falla, la clave es revisar:

- logs
- estado de servicios
- permisos
- redes
- configuración

Comandos frecuentes:

- `systemctl status`
- `journalctl`
- `ip addr`
- `ping`
- `ss -tuln`
- `grep`
- `find`

---

## Comandos esenciales que debes ir dominando

### Navegación y archivos

```bash
pwd
ls -la
cd /ruta/del/directorio
mkdir nombre
touch archivo.txt
cp origen destino
mv origen destino
rm archivo.txt
```

### Ver contenido

```bash
cat archivo.txt
less archivo.txt
head -n 20 archivo.txt
tail -n 20 archivo.txt
tail -f /var/log/syslog
```

### Búsqueda

```bash
find /ruta -name "*.txt"
grep "texto" archivo.txt
grep -R "texto" /ruta
ls -l /ruta | grep "txt$"
```

### Permisos

```bash
ls -l archivo.txt
chmod 644 archivo.txt
chmod +x script.sh
chown usuario:grupo archivo.txt
sudo apt update
```

### Sistema y servicios

```bash
ps aux
top
htop
systemctl status servicio
sudo systemctl start servicio
sudo systemctl stop servicio
sudo systemctl enable servicio
```

### Red

```bash
ip addr
ping ejemplo.com
curl https://example.com
ss -tuln
```

---

## Ejercicio práctico incluido

El repositorio incluye un script de ejemplo demostrativo:

```bash
./ejercicios/ejercicio01_cli.sh
```

Este script implementa un pequeño gestor de tareas desde la terminal con estas funciones:

- añadir tareas
- listar tareas
- marcar tareas como hechas
- eliminar tareas
- salir del menú

Es una excelente forma de practicar:

- lectura de entrada del usuario
- validación simple
- uso de archivos para persistencia
- estructuras de control en Bash
- lógica de estado (pending/done)

---

## Consejos para no frustrarte al aprender Linux

### 1. Haz pruebas en un entorno seguro

Si eres principiante, mejor usa:

- una máquina virtual
- un contenedor
- un entorno de prueba
- un usuario no privilegiado para la mayoría de tareas

### 2. No uses `sudo` a la ligera

`sudo` es poderoso. Es útil, pero no debes ejecutarlo sin pensar. Antes de borrar, mover o modificar archivos importantes, revisa dos veces la ruta.

### 3. Lee la documentación local

Cuando tengas duda, usa:

```bash
man ls
ls --help
man grep
```

La documentación en Linux es una de sus mayores fortalezas.

### 4. La terminal es una herramienta, no un castigo

Al principio parece "mucha letra y poco sentido". Pero con la práctica, la terminal se vuelve más intuitiva y rápida que un entorno gráfico para muchas tareas.

### 5. Repite, repite y repite

No hace falta hacer todo a la vez. Un comando por día, bien entendido, vale más que cien copiados sin comprender.

---

## Qué vas a aprender con este proyecto

Al finalizar esta etapa, deberías sentirte cómodo con:

- usar la terminal con confianza
- moverte entre archivos y carpetas
- crear, copiar, renombrar y borrar elementos
- comprender permisos y propietarios
- usar `grep`, `find`, `head`, `tail`, `ls`, `cd`, `cp`, etc.
- administrar paquetes
- revisar servicios y logs
- crear scripts sencillos en Bash
- reconocer patrones comunes de diagnóstico

Este es el inicio de una ruta mucho más grande dentro de Linux: administración del sistema, automatización, redes, servidores, seguridad y más.

---

## Siguiente nivel

Cuando termines la fase introductoria, los siguientes temas que suelen abrir mucho camino son:

- usuarios y grupos
- `sudo` y sudoers
- `systemctl` y servicios
- SSH y acceso remoto
- firewall (`ufw`, `nftables`)
- copias de seguridad con `rsync` y `tar`
- automatización con `cron` y scripts
- contenedores con Docker
- virtualización con VirtualBox o QEMU

---

## Frase final

Linux no está hecho para que lo "domines de golpe". Está hecho para que lo aprendas con paciencia, práctica y curiosidad. Cada comando que entiendes suma una capa de control, y cada error te enseña algo útil.

Si te gusta explorar, construir, reparar y automatizar, Linux acaba convirtiéndose en una herramienta muy poderosa y muy gratificante.

¡Bienvenido a la terminal, al sistema y a la libertad de aprender con ella!

---

## Referencias rápidas del proyecto

- Clase 01: fundamentos básicos
- Clase 02: shell, usuarios, servicios y scripting
- Clase 03: comandos esenciales y redirecciones
- Clase 04: resolución de ejercicios y cierre de la etapa introductoria
- Ejercicio 01: mini gestor de tareas en Bash

Si quieres continuar el aprendizaje, lo mejor es practicar un poco cada día con comandos reales y convertir cada error en una lección.
