# Clase 04 — Resolución de ejercicios y cierre de la fase introductoria

Objetivo: repasar y resolver los ejercicios propuestos en las tres primeras clases, extraer el feedback más relevante y cerrar la etapa introductoria con una hoja de ruta clara para seguir avanzando en GNU/Linux.

---

## 1. Resolución de ejercicios de Clase 01

Los ejercicios de Clase 01 sirven para fijar los comandos básicos de la terminal y el manejo de archivos.

1) Crear la carpeta `prueba_linux`, entrar en ella y crear tres archivos.

```bash
mkdir -p ~/prueba_linux
cd ~/prueba_linux
touch a.txt b.txt c.txt
ls -la
```

Salida esperada:

```text
drwxr-xr-x 2 usuario usuario 4096 ago 11 12:00 .
drwxr-xr-x 3 usuario usuario 4096 ago 11 12:00 ..
-rw-r--r-- 1 usuario usuario    0 ago 11 12:00 a.txt
-rw-r--r-- 1 usuario usuario    0 ago 11 12:00 b.txt
-rw-r--r-- 1 usuario usuario    0 ago 11 12:00 c.txt
```

2) Escribir texto en `a.txt` y mostrarlo por pantalla.

```bash
echo "Hola Linux" > a.txt
cat a.txt
```

Salida esperada:

```text
Hola Linux
```

3) Copiar `a.txt` a `d.txt`, renombrar `d.txt` a `e.txt` y borrar `b.txt`.

```bash
cp a.txt d.txt
mv d.txt e.txt
rm b.txt
ls -la
```

Salida esperada:

```text
-rw-r--r-- 1 usuario usuario  11 ago 11 12:00 a.txt
-rw-r--r-- 1 usuario usuario  11 ago 11 12:00 c.txt
-rw-r--r-- 1 usuario usuario  11 ago 11 12:00 e.txt
```

4) Cambiar permisos de `e.txt` para que sólo el propietario pueda leer y escribir.

```bash
chmod 600 e.txt
ls -l e.txt
```

Resultado esperado:

```text
-rw------- 1 usuario usuario 11 ago 11 12:00 e.txt
```

5) Practicar `man` y `--help`.

```bash
man ls
ls --help
```

La resolución consiste en leer la página de manual y comprobar las opciones que muestra el comando. Esto refuerza el hábito de consultar documentación local.

---

## 2. Resolución de ejercicios de Clase 02

Los ejercicios de Clase 02 son un paso hacia la automatización y la configuración del entorno de trabajo.

1) Script de backup comprimido con expiración de archivos antiguos.

Solución resumida:

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

Este script crea el backup de la carpeta `proyecto` e inmediatamente elimina los archivos `tar.gz` con más de 7 días de antigüedad.

2) Configurar alias `ll` y función `mkcd` en `~/.bashrc`.

Solución resumida:

```bash
cat >> ~/.bashrc <<'EOF'
alias ll='ls -alF'
mkcd() { mkdir -p "$1" && cd "$1"; }
EOF
source ~/.bashrc
```

Después de esto, `ll` lista en formato largo y `mkcd nombre` crea el directorio si no existe y entra en él.

3) Diagnóstico de un servicio que no arranca.

Pasos típicos:

```bash
sudo systemctl status miapp.service
sudo journalctl -u miapp.service -n 200 --no-pager
sudo ss -tunap | grep -E ':80|:443'
sudo ls -l /etc/miapp/
sudo cat /etc/miapp/miapp.conf
```

Si el servicio no arranca, el objetivo es identificar si hay:

- errores en la configuración.
- permisos incorrectos en archivos o carpetas.
- dependencias no disponibles.
- puertos ocupados.

4) Crear usuario `estudiante`, añadirlo a grupo sudo y permitir `systemctl` sin contraseña.

Solución resumida:

```bash
sudo adduser estudiante
sudo usermod -aG sudo estudiante   # o wheel según la distro
sudo visudo
```

Dentro de `visudo` añadir:

```text
estudiante ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

Esto mantiene el principio de privilegios mínimos, permitiendo sólo un comando concreto sin contraseña.

---

## 3. Resolución de ejercicios de Clase 03

Los ejercicios de Clase 03 aplican los comandos esenciales en ejemplos prácticos.

### Ejercicio 1: crear un archivo y buscar texto

```bash
mkdir -p ~/ejercicios/linux
cd ~/ejercicios/linux
echo "Linux es divertido" > ejemplo.txt
grep "divertido" ejemplo.txt
```

Salida esperada:

```text
Linux es divertido
```

### Ejercicio 2: listar y filtrar archivos

```bash
ls -l ~/ejercicios/linux | grep "txt"
```

Salida esperada:

```text
-rw-r--r-- 1 usuario usuario 22 ago 11 12:00 ejemplo.txt
```

### Ejercicio 3: crear un script básico

```bash
cat > saluda.sh <<'EOF'
#!/usr/bin/env bash
echo "Bienvenido a GNU/Linux"
EOF
chmod +x saluda.sh
./saluda.sh
```

Salida esperada:

```text
Bienvenido a GNU/Linux
```

### Ejercicio 4: seguir un log en tiempo real

```bash
tail -f /var/log/syslog
```

Este comando permite observar cómo el sistema genera nuevos eventos.

### Ejercicio guiado 01: mini gestor de tareas en bash

El archivo `./ejercicios/ejercicio01_cli.sh` ya contiene la base de la solución. El menú es correcto y las funciones principales están divididas claramente.

Resolución completa:

- `ensure_storage`: crea el archivo de datos si no existe.
- `show_menu`: muestra las opciones.
- `list_tasks`: lee el archivo y muestra tareas pendientes y completadas.
- `add_task`: guarda nuevas tareas con estado `pending`.
- `main`: controla el bucle de interacción.

Para completar el ejercicio, hay que implementar las opciones restantes:

```bash
mark_done() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas para completar."
    return
  fi

  list_tasks
  read -r -p "Número de la tarea a marcar como hecha: " index
  if ! [[ "$index" =~ ^[0-9]+$ ]]; then
    echo "Entrada no válida. Usa un número."
    return
  fi

  local tmp
  tmp=$(mktemp)
  local i=1
  while IFS='|' read -r title status; do
    if [[ -z "${title:-}" ]]; then
      continue
    fi
    if [[ "$i" -eq "$index" ]]; then
      printf '%s|done\n' "$title" >> "$tmp"
    else
      printf '%s|%s\n' "$title" "$status" >> "$tmp"
    fi
    ((i++))
  done < "$DATA_FILE"
  mv "$tmp" "$DATA_FILE"
  echo "Tarea marcada como hecha."
}

remove_task() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas para eliminar."
    return
  fi

  list_tasks
  read -r -p "Número de la tarea a eliminar: " index
  if ! [[ "$index" =~ ^[0-9]+$ ]]; then
    echo "Entrada no válida. Usa un número."
    return
  fi

  local tmp
  tmp=$(mktemp)
  local i=1
  while IFS='|' read -r title status; do
    if [[ -z "${title:-}" ]]; then
      continue
    fi
    if [[ "$i" -ne "$index" ]]; then
      printf '%s|%s\n' "$title" "$status" >> "$tmp"
    fi
    ((i++))
  done < "$DATA_FILE"
  mv "$tmp" "$DATA_FILE"
  echo "Tarea eliminada si existía."
}
```

Esto completa la experiencia de un gestor de tareas simple: añadir, listar, marcar y eliminar.

---

## 4. Feedback de las últimas tres clases

Estas tres clases construyen una progresión lógica:

- Clase 01: fundamentos. Presenta el entorno GNU/Linux, la terminal, la estructura de directorios, permisos y comandos básicos.
- Clase 02: entorno y automatización. Añade variables, alias, scripting, servicios, usuarios, gestión de paquetes y diagnóstico.
- Clase 03: aplicación práctica. Convierte los conceptos en ejemplos concretos, comandos útiles, lectura de salida, redirección, búsqueda y un ejercicio interactivo.

Qué funciona bien:

- Aprender con ejemplos concretos ayuda a retener la sintaxis y a ver para qué sirve cada comando.
- Dividir entre conceptos básicos y práctica concreta facilita el avance sin saturarse.
- El uso de scripts simples y ejercicios prácticos hace el aprendizaje activo en lugar de solo teórico.

Qué conviene mejorar a partir de aquí:

- Consolidar la práctica diaria con un ambiente seguro (máquina virtual o contenedor) para evitar errores en el sistema real.
- Escribir pequeños scripts propios en lugar de copiar, porque así se entiende mejor la lógica de shell.
- Revisar siempre los errores con `man`, `--help`, `journalctl` y `ls -l` antes de actuar.

---

## 5. Fin de lo introductorio y qué sigue

Con esta Clase 04 cerramos la fase introductoria. Ya tienes:

- una base sólida de comandos esenciales.
- una idea clara de la estructura de archivos y permisos.
- experiencia práctica con scripts y tareas automatizadas.
- la capacidad de diagnosticar problemas básicos en servicios, paquetes y red.

A partir de ahora, el camino sigue hacia temas más específicos y avanzados:

- administración de usuarios y seguridad de sistema.
- servicios y servidores (`systemctl`, NGINX, Apache, bases de datos).
- redes y acceso remoto seguro (SSH, firewall, VPN).
- automatización real con `cron`, `systemd timers`, `rsync` y scripts.
- contenedores y virtualización.

---

## 6. Recomendaciones finales

1. Practica un pequeño truco nuevo cada día. Repite un comando varias veces hasta sentir que lo entiendes.
2. Mantén tus scripts en `~/scripts` y añade comentarios breves.
3. Usa siempre una cuenta normal y `sudo` solo cuando haga falta.
4. Cuando no entiendas un comando, detente y lee su manual: `man comando`.
5. Lleva un registro de tus ejercicios en un repositorio Git si quieres volver a consultarlos.

¡Buen trabajo! Esta clase cierra la etapa introductoria y te deja listo para avanzar hacia la administración real de sistemas GNU/Linux.