# Clase 10 — Conceptos Avanzados: Namespaces, Cgroups y Virtualización

En las clases anteriores aprendimos los fundamentos de Linux: comandos, permisos, usuarios, servicios y daemons. Ahora vamos a explorar los conceptos avanzados que están detrás de tecnologías modernas como **contenedores** (Docker), **máquinas virtuales** y **aislamiento de procesos**. Estos no son temas "mágicos"—son construcciones que se basan en características muy concretas del kernel de Linux.

## El problema que resuelven

Imagina que quieres:

- ejecutar dos aplicaciones distintas sin que una interfiera con la otra,
- limitar cuánta memoria y CPU puede usar cada aplicación,
- crear ambientes aislados sin levantar máquinas virtuales completas,
- reproducir exactamente el mismo entorno en diferentes máquinas.

Hace 15 años, la única opción era usar máquinas virtuales pesadas. Hoy, Linux nos da herramientas más eficientes: **namespaces** y **cgroups**.

## Namespaces: aislar lo que los procesos ven

### La idea básica

Un namespace es como un "filtro de realidad" para un proceso. En lugar de ver todo lo que hay en el sistema, un proceso dentro de un namespace solo ve lo que le corresponde.

Piénsalo así: imaginemos que hay un edificio (el sistema Linux completo). Los namespaces crean "apartamentos virtuales" dentro del edificio. Cada proceso en su apartamento solo ve sus archivos, sus conexiones de red, sus usuarios, etc. No ve los apartamentos de otros procesos.

### Tipos de namespaces

Linux implementa varios tipos de namespaces:

#### 1. **PID namespace** — aislamiento de procesos

Cada namespace PID tiene su propio árbol de procesos. Un proceso en un namespace no ve los procesos de otro namespace.

Ejemplo sin containers:

```bash
$ ps aux  # ves TODOS los procesos del sistema
PID USER       COMMAND
1   root       /sbin/init
100 user       bash
101 user       curl https://example.com
...
```

Ejemplo dentro de un container con PID namespace:

```bash
# dentro del container
$ ps aux  # solo ves los procesos del container
PID USER       COMMAND
1   root       /bin/bash
5   root       /usr/sbin/nginx
...
```

El proceso bash dentro del container tiene PID 1 en su namespace, pero en realidad podría ser PID 5000 en el sistema completo.

#### 2. **Network namespace** — aislamiento de red

Cada namespace de red tiene su propia:

- interfaz de red,
- tabla de enrutamiento,
- firewall,
- conexiones TCP/UDP.

Sin network namespace:

```bash
$ ip addr
1: lo (loopback)
2: eth0 (conexión real)
3: wlan0 (wifi)
```

Con network namespace:

```bash
$ ip netns exec contenedor1 ip addr
1: lo (loopback dentro del contenedor)
2: eth0 (solo la que el contenedor ve)
```

Cada contenedor cree que tiene su propia red, pero comparte físicamente los recursos del host.

#### 3. **Mount namespace** — aislamiento del sistema de archivos

Cada namespace de montaje tiene su propia visión del sistema de archivos. Puedes montar o desmontar volúmenes sin afectar a otros procesos.

Ejemplo:

- el host ve `/home/user/datos` montado en `/mnt/datos`
- un contenedor solo ve `/data` como su raíz real
- no puede escapar a directorios fuera de su namespace

#### 4. **UTS namespace** — aislamiento de nombre de host

Cada namespace UTS puede tener su propio hostname y nombre de dominio.

```bash
# en el host
$ hostname
servidor-principal

# dentro del container
$ hostname
mi-aplicacion-1
```

Ambos son el mismo kernel, pero cada uno ve un nombre diferente.

#### 5. **User namespace** — aislamiento de usuarios

Un usuario dentro de un namespace puede tener UID 0 (root) sin ser realmente root en el sistema.

```bash
# dentro del container
$ id
uid=0(root)  # cree que es root

# pero el kernel sabe que realmente es UID 1000
```

Esto es muy importante para seguridad: un proceso puede creer que tiene privilegios sin realmente tenerlos.

#### 6. **IPC namespace** — aislamiento de comunicación interproceso

Memoria compartida, semáforos y colas de mensajes están aislados por namespace.

#### 7. **Cgroup namespace**

Aísla la vista de los límites de recursos (que veremos a continuación).

### Cómo se crean namespaces

En Linux bajo nivel, se usan syscalls:

```bash
# clone() crea un proceso nuevo en un namespace nuevo
# unshare() mueve el proceso actual a un namespace nuevo
$ unshare --pid --net bash  # abre bash en nuevo PID y network namespace
```

Docker y otros gestores de containers usan estas llamadas internamente.

## Cgroups: limitar recursos

### La idea básica

Si los namespaces aislan "lo que ves", los **cgroups** (control groups) limitan "cuánto puedes usar".

Un cgroup es un mecanismo que te permite decir:

- "este proceso solo puede usar 2GB de RAM"
- "este proceso solo puede usar 50% de CPU"
- "este proceso solo puede hacer 100 operaciones de E/S por segundo"

Sin cgroups:

```bash
$ ./aplicacion_glotona
# consume toda la RAM disponible, bloquea todo el sistema
# otros procesos se ven afectados
```

Con cgroups:

```bash
$ cgcreate -g memory:/mi_app
$ echo "2G" > /sys/fs/cgroup/memory/mi_app/memory.limit_in_bytes
$ cgexec -g memory:/mi_app ./aplicacion_glotona
# consume máximo 2GB, otros procesos siguen funcionando
```

### Subsistemas de cgroups

Hay varios subsistemas que pueden limitarse:

| Subsistema | Qué limita |
|---|---|
| `cpu` | tiempo de CPU |
| `cpuset` | núcleos de CPU específicos |
| `memory` | memoria RAM |
| `blkio` | E/S de disco |
| `net_cls` | clase de tráfico de red |
| `pids` | número de procesos |
| `freezer` | pausar/reanudar procesos |

### Ejemplos prácticos de cgroups

#### Limitar memoria

```bash
# crear un cgroup para memoria
$ sudo cgcreate -g memory:/limite_bajo

# establecer límite de 500MB
$ echo "500M" | sudo tee /sys/fs/cgroup/memory/limite_bajo/memory.limit_in_bytes

# ejecutar un proceso en ese cgroup
$ sudo cgexec -g memory:/limite_bajo /ruta/a/aplicacion

# verificar el uso actual
$ cat /sys/fs/cgroup/memory/limite_bajo/memory.usage_in_bytes
```

#### Limitar CPU

```bash
# crear cgroup para CPU
$ sudo cgcreate -g cpu:/poco_cpu

# limitar a 50% de un core (100000 es 100% de un core)
$ echo "50000" | sudo tee /sys/fs/cgroup/cpu/poco_cpu/cpu.cfs_quota_us

# ejecutar proceso
$ sudo cgexec -g cpu:/poco_cpu ./mi_app
```

#### Ver límites actuales

```bash
# listar todos los cgroups
$ ls /sys/fs/cgroup/

# ver configuración de un cgroup específico
$ cat /sys/fs/cgroup/memory/mi_app/memory.limit_in_bytes
$ cat /sys/fs/cgroup/cpu/mi_app/cpu.shares
```

## Namespaces + Cgroups = Containers

### Cómo funciona Docker internamente

Docker no es "magia". Es una herramienta que:

1. crea un nuevo PID namespace,
2. crea un nuevo network namespace,
3. crea un nuevo mount namespace,
4. configura cgroups para limitar recursos,
5. monta un filesystem raíz específico (la imagen),
6. ejecuta el proceso principal en este entorno aislado.

Cuando ejecutas:

```bash
$ docker run -it --memory="512M" alpine /bin/sh
```

Docker está haciendo algo como:

```bash
# crear namespace
$ unshare --pid --net --mount --uts

# limitar memoria con cgroups
$ cgcreate -g memory:/docker_container
$ echo "512M" > /sys/fs/cgroup/memory/docker_container/memory.limit_in_bytes

# montar el filesystem de la imagen
$ mount -t overlay ...

# ejecutar el entrypoint
$ /bin/sh
```

### Ventajas sobre máquinas virtuales

Las máquinas virtuales (VM) usan un kernel completo y una capa de virtualización:

```
Host Linux
├── VM 1 (kernel Linux completo, 500MB RAM)
├── VM 2 (kernel Linux completo, 500MB RAM)
└── VM 3 (kernel Linux completo, 500MB RAM)
```

Los containers comparten el kernel del host:

```
Host Linux (kernel único)
├── Container 1 (solo aplicación, 50MB RAM)
├── Container 2 (solo aplicación, 50MB RAM)
└── Container 3 (solo aplicación, 50MB RAM)
```

Resultado: containers son más ligeros, más rápidos de arrancar y más eficientes en recursos.

## Copy-on-Write (CoW) y capas de imágenes

Docker usa **copy-on-write** para eficiencia de almacenamiento. Varias imágenes pueden compartir capas base sin duplicar datos.

Ejemplo:

```
ubuntu:20.04 (base)
├── Capa 1: binarios básicos (100MB)
├── Capa 2: herramientas comunes (50MB)

mi_app:v1 (basada en ubuntu:20.04)
├── (reutiliza capas 1 y 2)
├── Capa 3: mi aplicación (20MB)

otra_app:v1 (basada en ubuntu:20.04)
├── (reutiliza capas 1 y 2)
├── Capa 4: otra aplicación (15MB)
```

Almacenamiento:
- ubuntu:20.04: 150MB
- mi_app:v1: 20MB adicionales (no 170MB)
- otra_app:v1: 15MB adicionales (no 165MB)

Total: 185MB en lugar de 485MB.

## seccomp: limitar llamadas del sistema

**seccomp** (secure computing) permite restricciones adicionales. Puedes especificar qué syscalls un proceso puede ejecutar.

Ejemplo:

```bash
# bloquear acceso a la red
seccomp_profile.json:
{
  "defaultAction": "ALLOW",
  "defaultErrnoRet": 1,
  "rules": [
    {
      "name": "socket",
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
```

Un proceso con este perfil no podría crear sockets, aunque intentara.

## AppArmor y SELinux: control de acceso obligatorio

Estos son mecanismos de seguridad que van más allá de permisos POSIX:

- **AppArmor**: perfiles simples y flexibles (ubuntu/debian friendly)
- **SELinux**: políticas muy granulares (redhat/fedora standard)

Ambas pueden:

- limitar qué archivos puede leer/escribir un proceso,
- limitar qué recursos puede acceder,
- crear "jaulas" de seguridad.

Ejemplo AppArmor:

```bash
/usr/bin/mi_app {
  /etc/config/* r,
  /var/log/mi_app.log w,
  /proc/meminfo r,
}
```

El proceso solo puede:
- leer archivos en `/etc/config/`,
- escribir en `/var/log/mi_app.log`,
- leer `/proc/meminfo`,
- nada más.

## chroot: aislamiento simple del filesystem

**chroot** (change root) es el mecanismo más antiguo y simple. Cambia el directorio raíz de un proceso:

```bash
# crear un entorno minimal
$ mkdir -p /tmp/jail/bin /tmp/jail/lib

# copiar bash y librerías necesarias
$ cp /bin/bash /tmp/jail/bin/
$ ldd /bin/bash | grep "=>" | awk '{print $3}' | xargs -I {} cp {} /tmp/jail/lib/

# ejecutar bash dentro de la jaula
$ sudo chroot /tmp/jail /bin/bash

# dentro de chroot
$ pwd
/
$ ls
bin lib

# pero no puede acceder a archivos fuera
$ cat /etc/passwd  # error: archivo no encontrado
```

Nota: **chroot no es seguro** como forma de aislamiento, pero es útil para otros propósitos.

## Máquinas virtuales y KVM

Las máquinas virtuales usan un enfoque diferente: **emulación o virtualización de hardware**.

KVM (Kernel Virtual Machine) es un módulo del kernel Linux que:

- permite crear máquinas virtuales,
- comparte el kernel host con el guest,
- proporciona hardware virtual (CPU, RAM, disco, red).

Comparación:

| Aspecto | Containers | VMs |
|---|---|---|
| Arranque | milisegundos | segundos/minutos |
| Overhead | muy bajo | significativo |
| Aislamiento | bueno | excelente |
| Seguridad | depende de kernel | muy seguro |
| Caso uso | microservicios, desarrollo | ambientes completos, kernels distintos |

## Casos de uso reales

### 1. Desarrollo local con containers

```bash
$ docker run -v $(pwd):/app -it python:3.9 bash
# desarrollas con Python 3.9 sin instalar nada en tu máquina
```

### 2. Aislamiento de servicios

```
host:
├── container nginx (cgroup: 2 cores, 512MB)
├── container postgres (cgroup: 4 cores, 2GB)
└── container redis (cgroup: 1 core, 256MB)
```

Cada uno se limita a sus recursos sin afectar a otros.

### 3. Seguridad multi-tenant

```
seccomp + namespaces + apparmor:
- usuario1 puede ejecutar código en container1 (aislado)
- usuario2 puede ejecutar código en container2 (aislado)
- no pueden ver procesos ni archivos uno del otro
```

### 4. Reproducibilidad

```dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3
COPY ./app /app
WORKDIR /app
CMD ["python3", "app.py"]
```

Este Dockerfile genera exactamente el mismo entorno en tu máquina, en CI/CD y en producción.

## Riesgos de seguridad

Es importante entender que namespaces y cgroups NO son un sandbox impenetrable:

1. **Escape del kernel**: un usuario root en un container puede intentar explotar el kernel.
2. **Recursos compartidos**: el host y containers comparten el kernel, buses y drivers.
3. **Capas de aplicación**: la seguridad también depende de la aplicación misma.

Por eso se recomiendan capas de seguridad:

- usar **user namespaces** (root dentro del container no es root real),
- usar **seccomp** para bloquear syscalls peligrosas,
- usar **AppArmor/SELinux** para control de acceso adicional,
- ejecutar containers como usuarios no privilegiados,
- usar registro privado para imágenes,
- mantener kernel y paquetes actualizados.

## Monitoreo de containers

Comandos útiles para inspeccionar containers:

```bash
# ver cgroups de un proceso
$ cat /proc/PID/cgroup

# ver namespaces de un proceso
$ ls -la /proc/PID/ns/

# ver límites de memoria aplicados
$ cat /sys/fs/cgroup/memory/docker/PID/memory.limit_in_bytes

# ver uso actual de memoria
$ cat /sys/fs/cgroup/memory/docker/PID/memory.usage_in_bytes

# ver estadísticas de CPU
$ cat /sys/fs/cgroup/cpu/docker/PID/cpuacct.usage
```

Con Docker:

```bash
$ docker stats  # vista en tiempo real de recursos
$ docker exec CONTAINER_ID ps aux  # ver procesos
$ docker logs CONTAINER_ID  # ver salida del proceso
$ docker inspect CONTAINER_ID | grep -A 10 "HostConfig"  # ver configuración
```

## Herramientas modernas

Hoy en día hay muchas herramientas que usan namespaces y cgroups:

- **Docker**: containers de aplicaciones
- **Kubernetes**: orquestación de containers
- **Podman**: alternativa sin daemon a Docker
- **LXC/LXD**: containers más "orientados a sistemas"
- **systemd-nspawn**: crear namespaces desde systemd
- **Firecracker**: microvms ultra-livianas (AWS)

## Ejercicios prácticos

### Ejercicio 1: Explorar namespaces de un proceso

```bash
# abre una terminal y nota el PID de bash
$ echo $$
12345

# en otra terminal, mira los namespaces
$ ls -la /proc/12345/ns/
```

Verás enlaces simbólicos a los namespaces: pid, net, ipc, uts, user, mnt, etc.

### Ejercicio 2: Crear un namespace simple

```bash
# crear un nuevo namespace PID y Network
$ sudo unshare --pid --net --mount bash

# dentro del namespace
$ ps aux  # solo ves procesos del namespace
$ id     # verifica tu usuario
$ exit
```

### Ejercicio 3: Explorar cgroups (si tienes acceso)

```bash
# ver estructura de cgroups
$ ls /sys/fs/cgroup/

# si tienes Docker, inspecciona un container en ejecución
$ docker ps
$ docker inspect CONTAINER_ID | grep -i "cgroup"
$ cat /sys/fs/cgroup/memory/docker/CONTAINER_ID/memory.limit_in_bytes
```

### Ejercicio 4: Entender layers con Docker

```bash
# descarga dos imágenes basadas en ubuntu
$ docker pull ubuntu:20.04
$ docker pull ubuntu:22.04

# verifica que comparten capas
$ docker images --tree  # si está disponible
$ docker system df  # ver uso de almacenamiento
```

### Ejercicio 5: Limitar recursos de un container

```bash
# ejecutar nginx limitado a 256MB
$ docker run -d --name web --memory="256M" nginx

# ver uso actual
$ docker stats web

# ver límites en cgroups
$ docker inspect web | grep -i memory
```

## Resumen

Los conceptos avanzados de Linux—namespaces, cgroups, seccomp, chroot—no son "magia de containers". Son mecanismos concretos del kernel que permiten:

- **aislar procesos** (namespaces),
- **limitar recursos** (cgroups),
- **restringir syscalls** (seccomp),
- **controlar acceso** (AppArmor/SELinux).

Cuando juntas todo esto, obtienes containers: aplicaciones aisladas, reproducibles y eficientes.

Entender estos conceptos te hace:

- más capaz de depurar problemas en containers,
- mejor preparado para administración de sistemas,
- más consciente de los trade-offs de seguridad,
- listo para explorar orquestación (Kubernetes) y más tecnologías modernas.

## Siguiente nivel

Ahora que entiendes cómo funcionan los containers, los siguientes pasos naturales son:

- **Docker en profundidad**: escribir Dockerfiles, optimizar imágenes, redes Docker.
- **Kubernetes**: orquestación de containers a escala.
- **Networking avanzado**: VLANs, overlays, service mesh.
- **Seguridad en profundidad**: scanning de vulnerabilidades, policies, RBAC.
- **Observabilidad**: logging centralizado, métricas, trazas distribuidas.

El camino es cada vez más especializado y poderoso. ¡Sigue aprendiendo!
