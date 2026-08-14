# Clase 09 — Daemons en Linux

En la clase anterior vimos el kernel, la capa central del sistema operativo. Ahora vamos a hablar de los daemons, procesos que viven en segundo plano y realizan tareas críticas del sistema sin intervención directa del usuario. En Linux, los daemons son la base de servicios como SSH, cron, HTTPD, systemd, DNS, impresión, sincronización de hora, gestión de redes y muchos otros.

## ¿Qué es un daemon?

Un daemon es un proceso que:

- se ejecuta en segundo plano,
- normalmente no tiene terminal asociada,
- permanece activo mientras el sistema está funcionando,
- ofrece servicios a otros procesos o al sistema en general,
- puede iniciarse al arranque o bajo demanda.

En Linux, la práctica tradicional era que cada servicio corriera como un proceso independiente, a veces con un script en /etc/init.d o similar. Hoy, la mayoría de distribuciones modernos usan systemd, que gestiona servicios y daemons de forma centralizada.

Ejemplos comunes:

- sshd: servicio SSH
- cron o crond: ejecuta tareas programadas
- nginx o apache2: servidor web
- cupsd: servicio de impresión
- NetworkManager: gestión de red
- dbus-daemon: sistema de mensajería entre procesos
- systemd: gestor de inicio del sistema

## Daemon vs proceso normal

Un proceso normal suele ejecutarse en primer plano desde una terminal. Un daemon normalmente:

- no depende de una sesión de usuario,
- no necesita interacción humana,
- queda ejecutándose en background,
- puede recibir señales del sistema o de init.

Ejemplo clásico:

- un usuario ejecuta `sleep 1000` en la terminal: proceso interactivo
- `sshd` escucha conexiones entrantes y atiende a clientes: daemon

## Cómo se inicia un daemon

Los daemons pueden iniciar de varias maneras:

1. Al arrancar el sistema, por ejemplo a través de systemd o SysV init
2. Cuando un usuario lo solicita, por ejemplo `sudo systemctl start nginx`
3. Tras un evento, como un socket activado por systemd
4. Mediante un crontab o un timer

## Init tradicional y systemd

### SysV init (sistema clásico)

En distribuciones antiguas, el proceso principal era init, y los servicios se activaban a través de scripts ubicados en:

- /etc/init.d/
- /etc/rc.d/
- /etc/rc.local

Ejemplo de un script de servicio:

- /etc/init.d/ssh
- /etc/init.d/nginx

Se usaban comandos como:

- service ssh start
- service ssh stop
- service ssh restart
- /etc/init.d/nginx status

### systemd

La mayoría de distribuciones modernas usan systemd como gestor de sistemas y servicios. Es más potente y más moderno que SysV init.

La unidad básica es un servicio (`.service`). systemd puede también gestionar:

- sockets (`.socket`)
- dispositivos (`.device`)
- montajes (`.mount`)
- targets (`.target`)
- timers (`.timer`)

#### Comandos principales de systemd

- systemctl status <servicio>
- systemctl start <servicio>
- systemctl stop <servicio>
- systemctl restart <servicio>
- systemctl enable <servicio>
- systemctl disable <servicio>
- systemctl is-active <servicio>
- systemctl list-units --type=service
- systemctl daemon-reload

Ejemplo:

```bash
$ sudo systemctl status ssh
$ sudo systemctl start ssh
$ sudo systemctl enable ssh
$ sudo systemctl restart nginx
```

## Archivos de configuración de servicios

Los daemons normalmente tienen archivos de configuración en directorios estándar:

- /etc/systemd/system/
- /etc/systemd/system/*.service
- /etc/init.d/
- /etc/nginx/
- /etc/ssh/sshd_config
- /etc/cron.d/
- /etc/default/

Ejemplo:

```bash
$ ls /etc/systemd/system
$ ls /etc/init.d
$ ls /etc/ssh
```

## Cómo se ve un daemon en ejecución

Los daemons son procesos normales del sistema con un PID, pero se distinguen porque suelen correr sin terminal y con un usuario específico.

Comandos útiles:

- ps -ef | grep sshd
- ps aux
- pstree
- top
- htop
- pgrep -a nginx

Ejemplo:

```bash
$ ps -ef | grep cron
$ pstree -p | grep sshd
```

También podemos ver servicios activos con systemd:

```bash
$ systemctl list-units --type=service --all | head
```

## Señales de proceso y control de daemons

Los Linux daemons responden a señales del sistema. Algunas de las más importantes son:

- SIGTERM: termina de forma ordenada
- SIGINT: interrupción, normalmente usado en procesos interactivos
- SIGHUP: recarga configuración o reinicia servicio
- SIGKILL: termina inmediatamente, sin limpieza
- SIGUSR1/SIGUSR2: señales personalizadas

Ejemplos:

```bash
$ kill -TERM 1234
$ kill -HUP $(cat /run/nginx.pid)
$ kill -9 1234
```

Es importante notar que `SIGKILL` no puede ser capturado ni ignorado. Por eso se usa como última instancia cuando un daemon no responde.

## PID files y sockets

Muchos daemons crean archivos PID para guardar el identificador del proceso principal. Esto permite al sistema controlarlos y reusar información.

Ejemplos comunes:

- /run/nginx.pid
- /run/sshd.pid
- /var/run/mysql/mysqld.pid

Se usan para:

- conocer el PID del servicio,
- verificar si está activo,
- enviar señales de control.

Los sockets permiten que un daemon escuche conexiones entrantes sin necesidad de un proceso por cliente. Por ejemplo:

- socket TCP/UDP de un servidor web,
- socket de DBus,
- socket de sshd.

## Daemons y logs

Los daemons generan registros para diagnóstico. Los logs ayudan a saber:

- si el servicio arrancó bien,
- si hubo un error de configuración,
- si hubo veces de reinicio,
- si hay fallas de seguridad o de red.

Los sistemas utilizan varias herramientas para consultar logs:

- journalctl -u <servicio>
- journalctl -xe
- tail -f /var/log/syslog
- /var/log/auth.log
- /var/log/nginx/error.log

Ejemplo:

```bash
$ sudo journalctl -u nginx -n 50 --no-pager
$ sudo journalctl -u ssh --since "1 hour ago"
```

## Daemons en la práctica

### Ejemplo 1: servicio SSH

`sshd` escucha conexiones por el puerto 22 y autentica usuarios. Está diseñado para permanecer activo en segundo plano.

```bash
$ sudo systemctl status ssh
$ sudo systemctl restart ssh
$ sudo journalctl -u ssh -n 20
```

### Ejemplo 2: cron

`cron` o `crond` ejecuta tareas en horarios definidos. Las tareas se registran normalmente en:

- /etc/crontab
- /etc/cron.d/
- /var/spool/cron/

Ejemplo de tarea programada:

```bash
* * * * * root /usr/local/bin/backup.sh
```

### Ejemplo 3: servidor web

Nginx o Apache se ejecutan como daemons y escuchan en puertos HTTP/HTTPS. Permiten atender peticiones sin intervención interactiva del usuario.

```bash
$ sudo systemctl status nginx
$ sudo systemctl reload nginx
```

## Daemons y seguridad

Los daemons pueden ser una puerta de entrada para la seguridad del sistema. Por eso es importante:

- ejecutar el servicio con el usuario correcto,
- limitar permisos,
- usar firewalls,
- revisar los logs,
- mantener actualizados paquetes y dependencias,
- evitar abrir puertos innecesarios,
- usar sockets y servicios mínimos.

Ejemplo de buena práctica:

- `sshd` no debe estar activo si no se necesita SSH.
- `nginx` debe configurarse con permisos mínimos y redirecciones seguras.
- servicios que no se usan deben ser deshabilitados.

## Daemons y containers

Linux modernizó la forma de ejecutar servicios con contenedores. En un contenedor, un daemon puede correr dentro del contenedor como si fuera un proceso normal del sistema, pero con aislamiento de namespaces y cgroups.

Esto hace que:

- cada contenedor pueda tener su propio proceso init o servicio,
- los recursos se limiten con cgroups,
- el sistema sea más seguro y más ordenado.

## Cómo inspeccionar daemons en un sistema real

Algunos comandos muy útiles:

```bash
$ systemctl --type=service --state=running
$ systemctl --failed
$ ps -eo pid,ppid,comm,stat,user
$ ss -tulpn | grep LISTEN
$ lsof -i -P -n | grep LISTEN
```

Estos comandos te permiten ver:

- qué servicios están activos,
- qué puertos están escuchando,
- quién los está ejecutando,
- si hay fallas o servicios no habilitados.

## Buenas prácticas con daemons

- Usar systemd cuando es posible.
- Mantener los servicios con `systemctl status` y `journalctl`.
- Revisar configuraciones antes de reiniciar un daemon.
- No forzar `kill -9` si no es necesario.
- Mantener archivos PID y logs bien definidos.
- Evitar daemons sin necesidad.
- Seguir el principio de mínimo privilegio.

## Resumen

Un daemon es un proceso de Linux que corre en segundo plano para ofrecer servicios esenciales al sistema y a los usuarios. Se gestionan desde init o systemd, pueden escuchar sockets, generar logs, responder a señales y mantenerse activos durante el arranque y la operación normal del sistema.

Si el kernel es la base del sistema operativo, los daemons son los servicios que lo convierten en algo útil: red, usuarios, web, impresión, automatización, sincronización, almacenamiento y muchas otras funciones.

## Ejercicios prácticos

1. Ejecuta:

```bash
$ ps -ef | grep ssh
```

2. Revisa el estado de un servicio propio del sistema:

```bash
$ sudo systemctl status ssh
```

3. Lista los servicios activos:

```bash
$ systemctl list-units --type=service --state=running
```

4. Consulta logs de un servicio:

```bash
$ sudo journalctl -u ssh -n 20
```

5. Revisa los puertos en escucha:

```bash
$ ss -tulpn | head
```

6. Intenta averiguar qué daemon escucha el puerto 22 o 80. 

## Siguiente clase

La siguiente parte del curso puede enfocarse en el arranque del sistema, el proceso `init` o `systemd`, y cómo se inician los servicios al prender la máquina. También podríamos hablar de procesos, señales y la relación entre daemons y contenedores.
