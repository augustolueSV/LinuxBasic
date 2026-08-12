# Clase 03 — Comandos esenciales para navegar y administrar GNU/Linux

Objetivo: continuar desde la Clase 01 y la Clase 02 y avanzar hacia la práctica diaria con la terminal. En esta clase veremos comandos frecuentes, cómo leer su salida, y cómo usar la línea de comandos para moverse, buscar, inspeccionar y automatizar tareas básicas.

---

## 1. Repaso rápido: lo que ya sabes

Antes de seguir, recordemos los conceptos base que ya hemos visto:

- GNU/Linux = kernel Linux + utilidades GNU + distribución (paquetes, configuraciones, repositorios).
- La terminal es una interfaz de texto para ejecutar comandos.
- Los directorios principales: `/`, `/home`, `/etc`, `/var`, `/usr`, `/bin`, `/dev`, `/tmp`.
- Los permisos `rwx` y comandos como `chmod`, `chown`.
- `ls`, `cd`, `cat`, `cp`, `mv`, `rm`, `find`, `grep`, `man`.
- Gestionar servicios con `systemctl` y administrar paquetes con `apt`, `dnf` o `pacman`.

Hoy vamos a convertir esos conceptos en práctica real con ejemplos de terminal y resultados simulados.

---

## 2. El comando `pwd` y el directorio actual

`pwd` significa “print working directory”. Te dice en qué carpeta estás trabajando.

```bash
$ pwd
/home/usuario
```

Si quieres ver también archivos ocultos y detalles:

```bash
$ ls -la
 total 16
 drwxr-xr-x  4 usuario usuario 4096 ago 11 12:00 .
 drwxr-xr-x  6 usuario usuario 4096 ago 11 11:45 ..
 -rw-r--r--  1 usuario usuario  220 ago 11 12:00 .bashrc
 -rw-r--r--  1 usuario usuario  123 ago 11 12:00 .profile
 drwxr-xr-x  2 usuario usuario 4096 ago 11 12:00 Documentos
 drwxr-xr-x  2 usuario usuario 4096 ago 11 12:00 Descargas
```

La opción `-a` muestra archivos ocultos (los que empiezan con `.`). `-l` muestra más detalle.

---

## 3. Crear y mover cosas: `mkdir`, `touch`, `cp`, `mv`, `rm`

### 3.1 Crear carpetas y archivos

```bash
$ mkdir proyecto_linux
$ cd proyecto_linux
$ pwd
/home/usuario/proyecto_linux

$ touch hola.txt
$ ls -l
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 hola.txt
```

`touch` crea un archivo vacío si no existe, o actualiza su fecha de modificación si sí existe.

### 3.2 Copiar archivos

```bash
$ cp hola.txt copia_hola.txt
$ ls -l
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 copia_hola.txt
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 hola.txt
```

### 3.3 Mover o renombrar

```bash
$ mv copia_hola.txt backup.txt
$ ls -l
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 backup.txt
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 hola.txt
```

### 3.4 Borrar archivos

```bash
$ rm backup.txt
$ ls -l
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 hola.txt
```

Importante: `rm` elimina archivos de forma permanente. Si quieres borrar carpetas, normalmente se usa `rm -r` o `rm -rf` si estás seguro, pero hay que tener cuidado.

---

## 4. Ver contenido de archivos: `cat`, `less`, `head`, `tail`

### 4.1 `cat`

Muestra el contenido completo del archivo.

```bash
$ echo "Hola desde Linux" > saludo.txt
$ cat saludo.txt
Hola desde Linux
```

### 4.2 `less`

Sirve para leer archivos largos sin saturar la pantalla. Se usa por páginas.

```bash
$ less /var/log/syslog
```

En `less`, puedes:

- usar `Espacio` para avanzar página
- usar `q` para salir

### 4.3 `head` y `tail`

`head` muestra las primeras líneas; `tail` muestra las últimas.

```bash
$ printf '%s\n' "L1" "L2" "L3" "L4" > ejemplo.txt
$ head -n 2 ejemplo.txt
L1
L2

$ tail -n 2 ejemplo.txt
L3
L4
```

`tail -f` es muy útil para seguir un archivo mientras se crea o se actualiza, por ejemplo un log.

```bash
$ tail -f /var/log/syslog
```

---

## 5. Búsqueda y filtrado: `find` y `grep`

### 5.1 `find`

`find` busca archivos o carpetas por nombre, tamaño, fecha, etc.

```bash
$ find /home/usuario -name "*.txt" 2>/dev/null
/home/usuario/documentos/notas.txt
/home/usuario/proyecto_linux/hola.txt
/home/usuario/proyecto_linux/saludo.txt
```

Ejemplo con búsqueda en una ruta concreta:

```bash
$ find /etc -name "hosts" 2>/dev/null
/etc/hosts
```

### 5.2 `grep`

`grep` busca texto dentro de archivos.

```bash
$ grep "Linux" saludo.txt
Hola desde Linux
```

Buscando texto recursivamente en carpetas:

```bash
$ grep -R "TODO" /home/usuario/proyecto_linux
/home/usuario/proyecto_linux/script.sh:3: # TODO: mejorar este script
```

También puedes combinarlo con `|` para filtrar resultados:

```bash
$ ls -la | grep "txt$"
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 hola.txt
-rw-r--r-- 1 usuario usuario 0 ago 11 12:05 saludo.txt
```

Esto significa: “lista los archivos y luego muestra sólo los que terminan en `.txt`”.

---

## 6. Redirecciones y pipes: la base de la composición de comandos

### 6.1 Redirección `>` y `>>`

```bash
$ echo "Primera línea" > archivo.txt
$ echo "Segunda línea" >> archivo.txt
$ cat archivo.txt
Primera línea
Segunda línea
```

- `>` sobrescribe el archivo.
- `>>` añade contenido al final.

### 6.2 Pipes `|`

El pipe toma la salida de un comando y la usa como entrada de otro.

```bash
$ ps aux | grep bash
usuario   2334  0.0  0.1  ...  bash
```

Otro ejemplo:

```bash
$ ls -l /home/usuario | less
```

### 6.3 `tee`

`tee` permite ver la salida y guardar una copia a la vez.

```bash
$ echo "hola" | tee salida.txt
hola
$ cat salida.txt
hola
```

---

## 7. Permisos y archivos ejecutables

Recuerda que cada archivo tiene permisos con este formato:

```bash
-rwxr-xr-x 1 usuario usuario 1234 ago 11 12:00 script.sh
```

Desglose:

- `-` = tipo de archivo (regular)
- `rwx` = permisos del propietario
- `r-x` = permisos del grupo
- `r-x` = permisos para otros

### Cambiar permisos con `chmod`

```bash
$ chmod 755 script.sh
$ ls -l script.sh
-rwxr-xr-x 1 usuario usuario 1234 ago 11 12:00 script.sh
```

Interpretación:

- `7` = propietario: rwx (lectura, escritura, ejecución)
- `5` = grupo: r-x
- `5` = otros: r-x

También puedes hacer cambios más específicos:

```bash
$ chmod u+x script.sh
$ chmod go-r script.sh
```

Esto significa:

- `u+x` = añadir ejecución al propietario
- `go-r` = quitar lectura al grupo y a otros

---

## 8. `ls` y el formato típico de salida

`ls` es uno de los comandos más usados. Tiene muchas opciones útiles:

```bash
$ ls
Documentos  Descargas  proyecto_linux

$ ls -l
drwxr-xr-x 2 usuario usuario 4096 ago 11 12:00 Documentos
-rw-r--r-- 1 usuario usuario  123 ago 11 12:00 archivo.txt

$ ls -lh
-rw-r--r-- 1 usuario usuario 123 ago 11 12:00 archivo.txt
```

`-h` hace que el tamaño se muestre “humano”, por ejemplo `12K`, `1M` en vez de bytes exactos.

---

## 9. Procesos: `ps`, `top`, `kill`

### 9.1 Ver procesos activos

```bash
$ ps aux | head
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  ...  ... ?        Ss   ...  0:02 /sbin/init
usuario   2431  0.0  0.2  ...  ... tty1     S+   ...  0:00 bash
usuario   3204  0.0  0.0  ...  ... tty1     R+   ...  0:00 ps aux
```

### 9.2 `top`

```bash
$ top
```

Muestra un panel dinámico con:

- uso de CPU
- uso de memoria
- procesos activos
- carga del sistema

### 9.3 `kill`

Si un proceso se queda colgado, puedes terminarlo:

```bash
$ kill 3204
```

Si no responde, puede usarse `kill -9` como último recurso:

```bash
$ kill -9 3204
```

Aunque este último caso fuerza el cierre; se recomienda usarlo solo si es necesario.

---

## 10. Diagnóstico de red: `ping`, `curl`, `ip addr`, `ss`

### 10.1 `ping`

Comprueba si hay conectividad con otra máquina o host.

```bash
$ ping -c 3 google.com
PING google.com (172.217.10.14) 56(84) bytes of data.
64 bytes from mad41s14-in-f14.1e100.net (172.217.10.14): icmp_seq=1 ttl=118 time=12.3 ms
64 bytes from mad41s14-in-f14.1e100.net (172.217.10.14): icmp_seq=2 ttl=118 time=12.2 ms
64 bytes from mad41s14-in-f14.1e100.net (172.217.10.14): icmp_seq=3 ttl=118 time=11.9 ms
```

### 10.2 `curl`

Hace peticiones HTTP desde la terminal.

```bash
$ curl -I https://www.example.com
HTTP/2 200
accept-ranges: bytes
content-type: text/html; charset=UTF-8
```

### 10.3 `ip addr`

Muestra las interfaces de red y las direcciones IP.

```bash
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.25/24 brd 192.168.1.255 scope global dynamic eth0
```

### 10.4 `ss`

Muestra conexiones de red y puertos abiertos.

```bash
$ ss -tuln
State   Recv-Q  Send-Q   Local Address:Port   Peer Address:Port
LISTEN  0       128      0.0.0.0:22           0.0.0.0:*
LISTEN  0       128      127.0.0.1:3306       0.0.0.0:*
```

---

## 11. Comprimir y empaquetar: `tar`, `gzip`, `zip`

### 11.1 `tar`

`tar` crea o extrae archivos empaquetados.

```bash
$ tar -czvf backup.tar.gz proyecto_linux/
project_linux/
project_linux/hola.txt
project_linux/saludo.txt
```

Explicación:

- `-c` = crear
- `-z` = gzip
- `-v` = verbose
- `-f` = archivo

Extraer:

```bash
$ tar -xzvf backup.tar.gz
```

### 11.2 `zip`

```bash
$ zip -r proyecto.zip proyecto_linux/
  adding: proyecto_linux/ (stored 0%)
  adding: proyecto_linux/hola.txt (stored 0%)
  adding: proyecto_linux/saludo.txt (stored 0%)
```

Extraer:

```bash
$ unzip proyecto.zip
```

---

## 12. Trabajar con el historial y alias

El historial guarda comandos que ya ejecutaste.

```bash
$ history
  1  pwd
  2  ls -la
  3  mkdir proyecto_linux
  4  cd proyecto_linux
  5  touch hola.txt
```

Puedes repetir un comando con `!numero`.

```bash
$ !3
mkdir proyecto_linux
```

Crear un alias temporal:

```bash
$ alias ll='ls -alF'
$ ll
```

Alias permanente: se suele guardar en `~/.bashrc` o `~/.bash_aliases`.

```bash
echo "alias ll='ls -alF'" >> ~/.bashrc
source ~/.bashrc
```

---

## 13. Primeros scripts en bash

Los scripts permiten automatizar tareas repetitivas.

Crea un archivo llamado `hola.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

nombre=${1:-"mundo"}
echo "Hola, $nombre"
```

Hazlo ejecutable y pruébalo:

```bash
$ chmod +x hola.sh
$ ./hola.sh
Hola, mundo

$ ./hola.sh Augusto
Hola, Augusto
```

Esto es útil porque cuando aprendes a escribir scripts, puedes automatizar tareas como:

- crear estructura de carpetas
- hacer respaldos
- revisar logs
- ejecutar tareas periódicas

---

## 14. Ejemplo práctico: crear una estructura de trabajo y listar archivos

Veamos un ejemplo completo y realista:

```bash
$ mkdir -p ~/mis_proyectos/webapp/logs
$ touch ~/mis_proyectos/webapp/app.py
$ touch ~/mis_proyectos/webapp/logs/error.log
$ ls -R ~/mis_proyectos/webapp
/home/usuario/mis_proyectos/webapp:
app.py
logs

/home/usuario/mis_proyectos/webapp/logs:
error.log
```

Resultado: hemos creado una estructura útil para un proyecto sencillo.

---

### Ejercicio guiado 01 — mini gestor de tareas con interfaz CLI

Para practicar de forma controlada, vamos a crear un pequeño programa en bash que gestione tareas desde la terminal. La intención es que tenga un comportamiento claro, una interfaz sencilla y que al mismo tiempo sea útil en la vida real.

Archivo: `./ejercicios/ejercicio01_cli.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="${HOME}/.linux_practice_tasks"

ensure_storage() {
  if [[ ! -f "$DATA_FILE" ]]; then
    : > "$DATA_FILE"
  fi
}

show_banner() {
  printf '\n'
  printf '====================================================\n'
  printf '  Linux Practice CLI - Ejercicio 01\n'
  printf '  Gestor simple de tareas\n'
  printf '====================================================\n'
}

show_menu() {
  cat <<'EOF_MENU'
  [1] Añadir tarea
  [2] Listar tareas
  [3] Marcar como hecha
  [4] Eliminar tarea
  [5] Salir
EOF_MENU
}

list_tasks() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas registradas. Añade la primera con la opción 1."
    return
  fi

  echo "Tareas actuales:"
  local index=1
  while IFS='|' read -r title status; do
    [[ -z "${title:-}" ]] && continue
    if [[ "$status" == "done" ]]; then
      printf '  [%02d] %s  [COMPLETADA]\n' "$index" "$title"
    else
      printf '  [%02d] %s  [PENDIENTE]\n' "$index" "$title"
    fi
    ((index++))
  done < "$DATA_FILE"
}

add_task() {
  local title=""
  if [[ $# -gt 0 ]]; then
    title="$1"
  else
    read -r -p "Nombre de la tarea: " title
  fi

  if [[ -z "$title" ]]; then
    echo "La tarea no puede estar vacía."
    return
  fi

  printf '%s|pending\n' "$title" >> "$DATA_FILE"
  echo "Tarea añadida: $title"
}

main() {
  ensure_storage

  while true; do
    show_banner
    show_menu
    echo
    read -r -p "Elige una opción [1-5]: " option || exit 0

    case "$option" in
      1) add_task ;;
      2) list_tasks ;;
      3) echo "Opción de completar tarea" ;;
      4) echo "Opción de borrar tarea" ;;
      5) echo "Saliendo del gestor de tareas."; exit 0 ;;
      *) echo "Opción no válida." ;;
    esac

    echo
    read -r -p "Pulsa Enter para continuar..." _
  done
}

main "$@"
```

Ejecutarlo:

```bash
$ chmod +x ./ejercicios/ejercicio01_cli.sh
$ ./ejercicios/ejercicio01_cli.sh
```

Salida esperada (simulada):

```text
====================================================
  Linux Practice CLI - Ejercicio 01
  Gestor simple de tareas
====================================================
  [1] Añadir tarea
  [2] Listar tareas
  [3] Marcar como hecha
  [4] Eliminar tarea
  [5] Salir

Elige una opción [1-5]: 1
Nombre de la tarea: Revisar logs del sistema
Tarea añadida: Revisar logs del sistema

====================================================
  Linux Practice CLI - Ejercicio 01
  Gestor simple de tareas
====================================================
  [1] Añadir tarea
  [2] Listar tareas
  [3] Marcar como hecha
  [4] Eliminar tarea
  [5] Salir

Elige una opción [1-5]: 2
Tareas actuales:
  [01] Revisar logs del sistema  [PENDIENTE]
```

Objetivos del ejercicio:

- practicar lectura y escritura de archivos desde bash
- usar `case` para un menú interactivo
- separar lógica en funciones
- manejar entradas del usuario y validación simple
- guardar datos persistentes en un archivo local

Ejercicios de ampliación:

- añadir una opción para marcar una tarea como completada
- guardar también la fecha de creación de cada tarea
- filtrar tareas pendientes y completadas
- mejorar la interfaz con colores y mensajes más claros

Este ejercicio está pensado para alguien que ya tiene soltura con Linux, pero todavía quiere reforzar la lógica de shell y la composición de comandos.

---

## 15. Ejercicios prácticos

### Ejercicio 1: crear un archivo y buscar texto

```bash
$ mkdir -p ~/ejercicios/linux
$ cd ~/ejercicios/linux
$ echo "Linux es divertido" > ejemplo.txt
$ grep "divertido" ejemplo.txt
Linux es divertido
```

### Ejercicio 2: listar y filtrar archivos

```bash
$ ls -l ~/ejercicios/linux | grep "txt"
-rw-r--r-- 1 usuario usuario 22 ago 11 12:00 ejemplo.txt
```

### Ejercicio 3: crear un script básico

```bash
$ cat > saluda.sh <<'EOF'
#!/usr/bin/env bash
echo "Bienvenido a GNU/Linux"
EOF
$ chmod +x saluda.sh
$ ./saluda.sh
Bienvenido a GNU/Linux
```

### Ejercicio 4: seguir un log en tiempo real

```bash
$ tail -f /var/log/syslog
```

Observa cómo la salida va apareciendo mientras el sistema genera eventos.

---

## 16. Errores comunes y cómo interpretarlos

A medida que practiques, verás mensajes como estos:

```bash
$ ls /ruta/que/no/existe
ls: cannot access '/ruta/que/no/existe': No such file or directory
```

Esto significa que la ruta no existe.

```bash
$ chmod 700 archivo.txt
chmod: cannot access 'archivo.txt': No such file or directory
```

No existe el archivo que quieres cambiar de permisos.

```bash
$ rm archivo.txt
rm: cannot remove 'archivo.txt': No such file or directory
```

La solución suele ser simple: verificar la ruta, `pwd`, `ls` antes de usar comandos destructivos.

---

## 17. Buenas prácticas para seguir avanzando

- Prueba los comandos primero sin guardar resultados en archivos importantes.
- Usa `ls`, `pwd` y `man` antes de ejecutar un comando complicado.
- No uses `rm -rf` sin revisar la ruta exacta.
- Guarda tus scripts en una carpeta clara, por ejemplo `~/scripts`.
- Revisa `--help` y `man` cuando no recuerdes una opción.

Ejemplos:

```bash
$ ls --help
$ man ls
```

---

## 18. Resumen

En esta clase hemos visto cómo:

- navegar por el sistema de archivos con `pwd`, `cd`, `ls`
- crear y manipular archivos con `mkdir`, `touch`, `cp`, `mv`, `rm`
- ver contenido con `cat`, `head`, `tail`, `less`
- buscar texto con `grep` y archivos con `find`
- filtrar y combinar comandos con pipes y redirecciones
- revisar procesos con `ps` y `top`
- comprobar conectividad con `ping` y `curl`
- crear scripts sencillos con bash

Estos comandos son la base de la administración diaria en GNU/Linux. Practicarlos de forma repetida te dará confianza y te ayudará a avanzar a temas más avanzados como servicio, seguridad, SSH, automatización y administración de servidores.

---

## 19. Siguiente paso

La siguiente clase puede enfocarse en:

- administración de usuarios y grupos
- `sudo`, `visudo` y permisos avanzados
- `systemctl` y servicios del sistema
- backups con `rsync` y `tar`
- automatización con bash y tareas programadas (`cron`)

Si quieres, en la próxima clase puedo continuar con una “Clase 04” más orientada a administración de sistemas y automatización.

---

¡Buen trabajo! La terminal ya no es un misterio: con práctica, cada comando se vuelve una herramienta útil para resolver problemas reales.
