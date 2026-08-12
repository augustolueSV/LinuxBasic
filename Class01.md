# Clase 01 — Elementos básicos de GNU/Linux

Bienvenida: esta clase está pensada para personas que no saben nada de Linux. Explica los conceptos esenciales de manera clara y con ejemplos prácticos para que puedas seguirlos en una terminal.

---

## 1. ¿Qué es GNU/Linux?

GNU/Linux es el conjunto formado por el sistema operativo GNU (colección de utilidades y herramientas) y el kernel Linux (el núcleo que controla el hardware). Muchas personas dicen “Linux” para referirse al sistema completo, pero técnicamente el término correcto es GNU/Linux.

- Kernel (Linux): programa que gestiona el hardware (CPU, memoria, discos, redes) y servicios básicos.
- GNU: herramientas (gcc, bash, coreutils, ls, grep, etc.) que permiten usar y gestionar el sistema.

¿Por qué importa? Porque al aprender GNU/Linux verás comandos y herramientas que vienen del proyecto GNU y el comportamiento del kernel influye en cómo se administra el hardware.

## 2. ¿Qué son las distribuciones (distros)?

Una distribución es una compilación del kernel Linux más las utilidades GNU, bibliotecas y aplicaciones empaquetadas, además de un sistema de instalación y gestión (instalador, gestor de paquetes, configuraciones). Cada distro adapta GNU/Linux a distintos usos y preferencias.

Ejemplos populares:
- Ubuntu / Debian: fáciles para principiantes, amplias comunidades.
- Fedora: tecnologías más recientes, patrocinada por Red Hat.
- CentOS / Rocky / AlmaLinux: orientadas a servidores (estabilidad).
- Arch Linux: enfoque minimalista y learning-by-doing (documentación muy buena).
- Linux Mint: muy amigable para usuarios que vienen de Windows.

Cada distro puede usar un gestor de paquetes distinto (APT, DNF, Pacman) y configuraciones diferentes, pero los conceptos básicos son comunes.

---

## 3. Formas de usar GNU/Linux

- Instalado en tu equipo como sistema principal.
- En un arranque dual (con Windows u otro OS).
- En una máquina virtual (VirtualBox, VMware) — ideal para practicar.
- En contenedores (Docker) — para pruebas aisladas.
- En modo “Live” desde un USB (sin instalar): prueba rápida.

---

## 4. Primeros pasos en la terminal

La terminal (o consola) es la forma más directa y poderosa de usar GNU/Linux. Abre una terminal y prueba estos comandos básicos:

- pwd — muestra el directorio actual (print working directory)
  - Ejemplo: `pwd`
- ls — lista archivos y carpetas
  - `ls` (lista básica)
  - `ls -l` (lista detallada)
  - `ls -a` (incluye archivos ocultos)
- cd — cambiar de directorio
  - `cd /home/tu_usuario` o `cd ..` (subir un nivel)
  - `cd` sin argumentos va a tu home
- mkdir — crear carpetas
  - `mkdir proyecto`
- touch — crear archivos vacíos o actualizar tiempo de modificación
  - `touch archivo.txt`
- cp — copiar archivos o carpetas
  - `cp origen destino`
  - `cp -r carpeta_origen carpeta_destino` (recursivo)
- mv — mover o renombrar
  - `mv viejo.txt nuevo.txt`
- rm — borrar archivos y carpetas
  - `rm archivo.txt`
  - `rm -r carpeta` (peligroso: borrar recursivamente)
- cat, less, head, tail — ver contenido de archivos
  - `cat archivo.txt`
  - `less archivo.txt` (navegador de páginas)
  - `head -n 10 archivo.txt` (primeras 10 líneas)
  - `tail -f archivo.log` (seguir un archivo en tiempo real)

Consejos de seguridad: antes de usar `rm -r` o comandos con sudo, revisa dos veces la ruta. No copies comandos sin entenderlos.

---

## 5. Estructura básica del sistema de ficheros

El sistema de archivos en GNU/Linux sigue un esquema jerárquico. Algunos directorios importantes:

- / (root): raíz del sistema.
- /home: carpetas de usuarios (ej. /home/tu_usuario).
- /etc: archivos de configuración del sistema.
- /bin y /usr/bin: programas esenciales.
- /sbin y /usr/sbin: programas para administración del sistema.
- /var: datos variables (logs en /var/log, bases de datos, colas).
- /tmp: archivos temporales.
- /dev: archivos de dispositivos (discos, terminales).
- /mnt y /media: puntos de montaje para unidades externas.

Entender esta estructura ayuda a encontrar dónde están configuraciones, logs y programas.

---

## 6. Permisos y propietarios (muy importante)

Cada archivo y carpeta tiene permisos y un propietario. Usa `ls -l` para verlos.

Ejemplo de salida: `-rw-r--r-- 1 usuario grupo  1234 ago 11 12:00 archivo.txt`

Formato: `tipo | permisos usuario | enlace | propietario | grupo | tamaño | fecha | nombre`

Permisos: tres grupos (usuario, grupo, otros), cada uno con r (read), w (write), x (execute).

Cambiar permisos:
- `chmod 644 archivo.txt` (números: propietario, grupo, otros. 6=r+w, 4=r, 5=r+x)
- `chmod u+x script.sh` (añadir permiso de ejecución al propietario)

Cambiar propietario:
- `chown usuario:grupo archivo.txt` (requiere privilegios)

Uso de sudo: `sudo` ejecuta un comando con privilegios de administrador. Ejemplo: `sudo apt update`.

No uses sudo a ciegas: es poderoso y puede cambiar o romper el sistema.

---

## 7. Gestión de paquetes (instalar programas)

Cada distro tiene su gestor de paquetes:
- Debian/Ubuntu: apt
  - `sudo apt update` (actualizar lista de paquetes)
  - `sudo apt install nombre_paquete` (instalar)
  - `sudo apt remove nombre_paquete` (desinstalar)
- Fedora: dnf
  - `sudo dnf install nombre_paquete`
- Arch Linux: pacman
  - `sudo pacman -Syu` (actualizar todo)

Los comandos cambian entre distros, pero la idea es la misma: descargar e instalar paquetes desde repositorios.

---

## 8. Procesos y servicios

- `ps aux` muestra procesos en ejecución.
- `top` o `htop` (si está instalado) muestran procesos en tiempo real y uso de CPU/memoria.
- `kill PID` envía señal para terminar proceso (usar `kill -9 PID` como último recurso).

systemd (la mayoría de distros modernas) maneja servicios:
- `systemctl status nombre.service` — ver estado
- `sudo systemctl start nombre.service` — iniciar
- `sudo systemctl stop nombre.service` — detener
- `sudo systemctl enable nombre.service` — activar al arrancar

---

## 9. Red, IP y conectividad básica

- `ip addr` — ver interfaces y direcciones IP
- `ping ejemplo.com` — comprobar conectividad
- `ss -tuln` o `netstat -tuln` — ver puertos escuchando
- `curl http://ejemplo.com` — hacer peticiones HTTP desde la terminal

---

## 10. Búsqueda y filtrado

- `find` — buscar archivos por nombre, fecha, tamaño
  - `find /home -name "*.txt"`  (buscar .txt en /home)
- `grep` — buscar texto dentro de archivos
  - `grep "palabra" archivo.txt`
  - `grep -R "funcion" /ruta` (recursivo)
- Tubos (pipes) y redirecciones:
  - `comando1 | comando2` (usar salida de uno como entrada de otro)
  - `ls -l | grep ".txt$"`
  - `comando > archivo` (sobrescribir)
  - `comando >> archivo` (añadir al final)

---

## 11. Comprimir y empaquetar

- `tar -czvf archivo.tar.gz carpeta/` — crear archivo comprimido (gzip)
- `tar -xzvf archivo.tar.gz` — extraer
- `zip` y `unzip` también son comunes

---

## 12. Editores de texto básicos

- nano — sencillo e intuitivo (ideal para principiantes)
  - Abrir: `nano archivo.txt`
  - Guardar: Ctrl+O, salir: Ctrl+X
- vim — potente pero con curva de aprendizaje (opcional)
- Visual editors: VS Code, etc. para interfaz gráfica

---

## 13. Buenas prácticas y seguridad

- Aprende a usar la terminal con una cuenta normal. Usa `sudo` sólo cuando sea necesario.
- Haz copias de seguridad antes de modificar archivos importantes en /etc.
- Lee la documentación: `man comando` (p. ej. `man ls`) y `--help` (p. ej. `ls --help`).
- No pegues comandos de internet sin entenderlos.

---

## 14. Glosario rápido

- Terminal / Shell: interfaz de texto para ejecutar comandos (bash es un shell común).
- Kernel: núcleo del sistema operativo (Linux).
- Distro: distribución (paquetes + instalador + configuración).
- Root: usuario administrador (superusuario).
- Paquete: unidad de software instalable (programa + metadatos).

---

## 15. Ejercicios sugeridos (práctica)

1. Abrir la terminal y comprobar tu directorio actual:
   - `pwd` y `ls -la`
2. Crear una carpeta `prueba_linux`, entrar en ella, y crear tres archivos:
   - `mkdir prueba_linux && cd prueba_linux && touch a.txt b.txt c.txt && ls -la`
3. Escribir texto en `a.txt` y mostrarlo por pantalla:
   - `echo "Hola Linux" > a.txt` y `cat a.txt`
4. Copiar `a.txt` a `d.txt`, renombrar `d.txt` a `e.txt` y borrar `b.txt`:
   - `cp a.txt d.txt; mv d.txt e.txt; rm b.txt`
5. Cambiar permisos de `e.txt` para que sólo el propietario lo pueda leer y escribir:
   - `chmod 600 e.txt` y verificar con `ls -l`
6. Practicar con `man` y `--help`: `man ls`, `ls --help`.

Soluciones: realizar cada comando en la terminal y comprobar la salida; si algo falla, leer el mensaje de error y usar `man`.

---

## 16. Recursos recomendados (en español)

- Documentación de Ubuntu: https://help.ubuntu.com/
- Documentación de Debian: https://www.debian.org/doc/
- The Linux Documentation Project: https://tldp.org/
- Curso y guía de Bash en línea: busca "Guía de Bash" y "tutorial de comandos Linux".
- Libro: "Introducción a Unix y Linux" (varias ediciones y autores)

---

## 17. Resumen

GNU/Linux es un sistema poderoso y flexible. Empezar por la terminal, entender la estructura de ficheros, permisos y gestores de paquetes te permitirá administrar y usar el sistema con confianza. Practica los ejercicios y consulta `man` cuando tengas dudas.

¡Felicidades por dar el primer paso! Continua practicando y preguntando cuando algo no quede claro.

