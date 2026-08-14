# Clase 08 — El Kernel de Linux (detalle)

En esta clase se profundiza en una de las piezas más importantes de un sistema operativo: el kernel. Se explican sus responsabilidades, estructura, principales subsistemas de Linux, cómo interactúa con el hardware y con el espacio de usuario, y herramientas prácticas para inspeccionarlo y configurarlo.

## ¿Qué es el kernel?

El kernel es el núcleo del sistema operativo: la capa de software que controla el hardware y ofrece servicios básicos a los programas de usuario. Sus responsabilidades principales incluyen:

- Gestión de procesos (creación, planificación, terminación)
- Gestión de memoria (mapeo, paginación, intercambio)
- Gestión de dispositivos (drivers y controladores)
- Gestión del sistema de archivos
- Comunicación entre procesos y llamadas al sistema (syscalls)
- Seguridad y control de acceso

En Linux, el kernel es un programa monolítico que puede cargarse con módulos (compilado de forma modular), lo que le permite añadir o quitar controladores en tiempo de ejecución.

## Kernel space vs User space

El kernel se ejecuta en un modo privilegiado (kernel space) con acceso completo al hardware. Las aplicaciones de usuario se ejecutan en user space con privilegios restringidos. La interacción entre ambos se hace mediante llamadas al sistema (syscalls), interfaces virtuales como /proc y /sys, y mecanismos IPC.

Separar kernel/user protege la integridad del sistema: errores en una aplicación de usuario no deben corromper el kernel (aunque drivers bug pueden hacerlo).

## Tipos de kernels

- Monolítico: todo el código del kernel corre en el mismo espacio (Linux es monolítico con capacidad modular).
- Microkernel: funcionalidades mínimas en el kernel, servicios extra en espacio de usuario (ej: Minix). Linux no es microkernel, pero incorpora ideas modulares.

## El proceso de arranque (boot)

Pasos simplificados del arranque en sistemas modernos:

1. BIOS/UEFI inicializa hardware y busca un cargador de arranque.
2. GRUB (u otro bootloader) carga el kernel y un initramfs/initrd (si existe).
3. El kernel se inicia, detecta hardware, monta initramfs temporal.
4. El kernel arranca el proceso init (PID 1): en muchas distribuciones systemd, en otras sysvinit, runit, OpenRC, etc.
5. Init inicia servicios y cambia al sistema de archivos raíz final.

Comandos útiles para inspeccionar el arranque:

- uname -a           # versión del kernel
- dmesg              # mensajes del kernel (arranque y runtime)
- journalctl -k      # mensajes del kernel con systemd

Ejemplo:

$ uname -r
5.15.0-70-generic

$ sudo dmesg | less

## Módulos del kernel (loadable kernel modules)

Linux permite cargar controladores y otros componentes en tiempo de ejecución como módulos (.ko). Esto aporta flexibilidad y reduce el tamaño base del kernel.

Comandos:

- lsmod           # listar módulos cargados
- modinfo <mod>   # información de un módulo
- sudo modprobe <mod>  # carga un módulo y dependencias
- sudo rmmod <mod>     # descarga un módulo

Ejemplo:

$ lsmod | grep usb

Para ver información de módulos:

$ modinfo e1000e

## /proc y /sys: interfaces virtuales

/proc y /sys son pseudo-sistemas de archivos que exponen información del kernel y permiten cierta configuración.

- /proc: información de procesos (/proc/[pid]) y parámetros del kernel (/proc/cpuinfo, /proc/meminfo, /proc/sys/).
- /sys: interfaz sysfs para dispositivos y drivers (representa la jerarquía del kernel con atributos que pueden leerse/escribirse).

Ejemplos útiles:

$ cat /proc/cpuinfo
$ cat /proc/meminfo
$ ls /sys/class/net
$ cat /proc/sys/net/ipv4/ip_forward    # valor de forwarding

Para cambiar parámetros del kernel se puede usar sysctl o escribir en /proc/sys:

$ sudo sysctl -w net.ipv4.ip_forward=1
$ sudo sysctl -p   # recarga /etc/sysctl.conf

## Manejo de memoria

El kernel gestiona la memoria física y virtual. Conceptos clave:

- MMU (Memory Management Unit) maneja traducción de direcciones virtuales a físicas.
- Paginación: memoria dividida en páginas (p. ej. 4 KiB), con tablas de páginas por proceso.
- Swapping: mover páginas a disco cuando la RAM es insuficiente.
- Caches y buffers: el kernel usa caché de páginas y buffers para I/O eficiente.

Comandos para inspección:

$ free -h
$ cat /proc/meminfo
$ vmstat 1

## Planificación de procesos (scheduler)

El kernel decide qué proceso o hilo se ejecuta y por cuánto tiempo. Linux usa planificadores complejos:

- CFS (Completely Fair Scheduler): para cargas generales (procesos interactivos y de fondo).
- SCHED_FIFO, SCHED_RR (políticas en tiempo real)

Inspección y afinamiento:

- top, htop, ps
- chrt: manipular prioridades en tiempo real

Ejemplo: ver prioridades y nice

$ ps -eo pid,ppid,cmd,ni,pri,cls

## Llamadas al sistema (syscalls)

Las syscalls son la puerta entre user space y kernel space: open, read, write, fork, execve, ioctl, mmap, epoll, etc. Los wrappers en libc (ej: glibc) facilitan su uso.

Para inspeccionar llamadas del programa (trazas):

- strace program args   # captura llamadas al sistema
- ltrace program args   # captura llamadas a librerías

Ejemplo:

$ strace -o salida.txt ls

## Dispositivos y drivers

El kernel abstrae hardware mediante drivers. Los subsistemas de I/O incluyen controladores para bloques (discos), caracteres (puertos serie), y redes.

- /dev contiene nodos de dispositivo gestionados por el kernel y udev.
- udev crea nodos dinámicamente según eventos del kernel.

Inspección:

$ ls -l /dev/sda*
$ lspci -k   # muestra drivers asociados (requiere paquete pciutils)

## Seguridad en el kernel

Linux incorpora múltiples mecanismos de seguridad:

- DAC (Discretionary Access Control): permisos Unix tradicionales.
- MAC (Mandatory Access Control): SELinux, AppArmor.
- Capabilities: particionar privilegios en lugar de UID 0.
- Seccomp: filtrar syscalls permitidas por un proceso.
- namespaces y cgroups: aislamiento y control de recursos (base de contenedores).

Verificación:

$ sestatus    # si SELinux está instalado
$ aa-status   # AppArmor

## Namespaces y cgroups (containers)

Namespaces aíslan recursos (PID, mount, network, IPC, UTS, user). cgroups limitan y contabilizan recursos (CPU, memoria, I/O).

Herramientas relacionadas:

- systemd-cgls, systemd-cgtop
- cgcreate, cgexec (paquetes cgroup-tools)
- docker/podman usan namespaces + cgroups

## Debugging y profiling del kernel

Herramientas comunes:

- dmesg / journalctl -k: logs del kernel
- perf: profiling de CPU y eventos del kernel/user
- ftrace: trazado básico integrado en el kernel
- BPF (eBPF): trazado y observabilidad moderna
- SystemTap, kdump, crash: análisis post-mortem y tracing

Ejemplo simple (perf):

$ sudo perf top
$ sudo perf record -o perf.data -- sleep 5 && sudo perf report

## Compilar y configurar el kernel

Pasos generales:

1. Obtener el código fuente (kernel.org o paquete de distribución).
2. Configurar: make menuconfig / xconfig / oldconfig.
3. Compilar: make -j$(nproc) bzImage modules
4. Instalar módulos y kernel: make modules_install && make install (o copiar manualmente).
5. Actualizar bootloader (grub) si es necesario y reiniciar.

Ejemplo de ver la versión actual:

$ uname -srvm
Linux 5.15.0-70-generic x86_64

Nota: compilar kernels requiere espacio y tiempo; usar máquinas virtuales para pruebas.

## Ajustes y parámetros del kernel

- sysctl: gestionar parámetros expuestos en /proc/sys.
- Kernel command line: parámetros pasados por el bootloader (p. ej., isolcpus, quiet, noapic).
- /etc/sysctl.conf y archivos en /etc/sysctl.d/ para persistencia.

Ejemplos:

$ sudo sysctl -w vm.swappiness=10
$ echo 10 | sudo tee /proc/sys/vm/swappiness

## Logs y diagnóstico

- dmesg muestra buffer del kernel (útil tras insertar hardware o detectar errores de drivers).
- journalctl -k muestra registros del kernel integrados con systemd.
- /var/log/kern.log en sistemas sin journal.

Ejemplo: buscar errores relacionados con un driver

$ sudo dmesg | grep -i error

## Versiones y soporte

- Stable: versiones de desarrollo regular.
- LTS (Long Term Support): versiones con soporte extendido (recomendadas para servidores).

Consultar https://kernel.org para calendario de versiones.

## Buenas prácticas y seguridad

- Mantener kernels LTS en sistemas de producción.
- Revisar dmesg después de cambios de hardware y actualizaciones.
- Limitar módulos cargados a los necesarios.
- Aplicar controles de acceso (SELinux/AppArmor) y mantener actualizaciones.

## Ejercicios propuestos

1. Inspeccionar el kernel actual:
   - uname -a
   - cat /proc/version
   - lsmod | head
   - dmesg | head -n 50

2. Investigar /proc y /sys:
   - Explorar /proc/[PID] de un proceso propio (por ejemplo, tu editor) y describir qué contiene cada archivo importante.
   - Listar interfaces en /sys/class y explicar qué representan.

3. Cambiar un parámetro del kernel con sysctl (temporal y persistente):
   - sudo sysctl -w vm.swappiness=20
   - Añadir vm.swappiness = 20 a /etc/sysctl.d/99-local.conf y recargar con sudo sysctl --system.

4. Cargar/descargar un módulo seguro (p. ej., módulo para memoria virtual o pseudo-driver si tu sistema lo permite):
   - lsmod | grep <mod>
   - sudo modprobe <mod>
   - sudo rmmod <mod>

5. Traza básica de llamadas de sistema para un comando:
   - strace -o /tmp/ls-strace.txt ls -l
   - Analizar las primeras 20 llamadas al sistema.

6. Revisar logs del arranque y localizar mensajes de hardware relevantes:
   - sudo journalctl -b | grep -i usb

7. (Avanzado) Configurar un kernel virtualizado y compilar una configuración mínima en una VM. Arrancar con el kernel compilado y observar dmesg.

## Recursos y lecturas recomendadas

- https://www.kernel.org/
- Documentación del kernel: Documentation/ en el árbol de código fuente
- "Linux Kernel Development" — Robert Love (libro)
- "Understanding the Linux Kernel" — Bovet & Cesati (más antiguo pero útil)
- Blogs sobre eBPF, tracing y profiling (Brendan Gregg, perf, bpftrace)

---

Fin de la Clase 08. En la próxima clase se pueden revisar ejercicios prácticos: 1) trazas y 2) manipulación segura de módulos y parámetros del kernel. Si se desea, preparar un laboratorio para compilar un kernel en una VM paso a paso.
