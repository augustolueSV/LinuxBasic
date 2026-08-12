# Clase 05 — Administración de usuarios, permisos, servicios, respaldos y automatización

Objetivo: cerrar la etapa básica de Linux con una visión práctica de cómo un sistema se organiza como una comunidad: usuarios con roles, permisos con reglas, servicios que viven en segundo plano y tareas automáticas que se ejecutan sin que tú estés ahí.

La idea no es solo memorizar comandos, sino entender el “porqué” detrás de cada acción. Si lo imaginas como un edificio, cada usuario es alguien con una llave, cada grupo es un departamento, y el sistema es el encargado de decidir quién puede abrir qué puerta y cuándo.

---

## 1. Usuarios y grupos: la organización del sistema

En GNU/Linux, todo gira alrededor de dos ideas clave:

- usuarios: personas o procesos que interactúan con el sistema
- grupos: conjuntos de usuarios que comparten permisos o funciones

### 1.1 ¿Qué es un usuario?

Un usuario es una identidad dentro del sistema. Cada cuenta tiene:

- nombre de usuario
- identificador único (UID)
- grupo principal
- permisos sobre archivos y procesos

Puedes pensar en un usuario como una identidad con su propio acceso a un edificio.

- Un usuario normal no tiene la llave maestra del edificio.
- Un administrador tiene mayor nivel de acceso.
- El sistema usa esa identidad para decidir qué puede hacer cada persona.

### 1.2 ¿Qué es un grupo?

Un grupo es como un departamento dentro de la misma empresa.

Ejemplo:

- `developers` para programadores
- `sysadmin` para administradores
- `students` para alumnos o usuarios de pruebas

Cuando agregas a un usuario a un grupo, ese usuario comparte permisos o funciones con otros miembros del mismo grupo.

### 1.3 Comandos básicos

Crear un usuario:

```bash
sudo adduser nombre_usuario
```

Crear un usuario sin interacción (más técnico):

```bash
sudo useradd -m nombre_usuario
```

Ver información del usuario:

```bash
id nombre_usuario
```

Listar usuarios:

```bash
cat /etc/passwd
```

Listar grupos:

```bash
cat /etc/group
```

Añadir un usuario a un grupo:

```bash
sudo usermod -aG grupo nombre_usuario
```

Eliminar usuario:

```bash
sudo userdel -r nombre_usuario
```

Ver grupos de un usuario:

```bash
groups nombre_usuario
```

### 1.4 Analogía útil

Si el sistema fuera una empresa:

- cada persona es un usuario
- cada departamento es un grupo
- las carpetas y archivos son habitaciones o cajas
- los permisos son las reglas de acceso

Así, un usuario puede tener acceso a su carpeta personal, pero no a la carpeta de administración sin permiso.

---

## 2. Permisos avanzados: más allá de chmod básico

Ya vimos permisos básicos: `r`, `w` y `x` para propietario, grupo y otros. Ahora vamos a entender profundizar un poco más.

### 2.1 Propietario, grupo y otros

Cuando haces:

```bash
ls -l archivo.txt
```

puedes ver algo parecido a esto:

```bash
-rwxr-xr-- 1 usuario grupo 1024 ago 11 12:00 archivo.txt
```

Desglose:

- `-`: tipo de archivo
- `rwx`: permisos del propietario
- `r-x`: permisos del grupo
- `r--`: permisos para otros

### 2.2 Cambiar permisos

Permitir ejecución:

```bash
chmod +x script.sh
```

Establecer permisos exactos:

```bash
chmod 755 script.sh
```

Permisos más restrictivos:

```bash
chmod 600 archivo.txt
```

### 2.3 Cambiar propietario

```bash
sudo chown usuario:grupo archivo.txt
```

Esto significa: "este archivo ahora pertenece a ese usuario dentro de ese grupo".

### 2.4 Permisos avanzados: setuid, setgid y sticky bit

Estos son permisos especiales que aparecen en clases más avanzadas, pero vale la pena conocerlos.

#### setuid (s)

Se usa en ejecutables para que se ejecuten con los permisos del propietario del archivo.

Ejemplo clásico: `sudo`.

```bash
ls -l /usr/bin/sudo
```

Si ves una `s` en la posición del propietario, significa que el archivo tiene setuid.

Esto es útil, pero también puede ser peligroso si se usa mal.

#### setgid (s)

Cuando se aplica a un directorio, los archivos creados dentro heredarán el grupo del directorio.

```bash
chmod g+s directorio
```

Es muy útil en carpetas compartidas por un equipo.

#### sticky bit (t)

Se usa para evitar que usuarios borren archivos ajenos dentro de un directorio compartido.

```bash
chmod +t directorio
```

Es típico en `/tmp`.

### 2.5 ¿Por qué esto importa?

Porque Linux no trata los permisos como vagos. Los permisos son reglas de seguridad reales.

- un usuario no debe entrar donde no tiene que entrar
- un proceso no debe escribir en lugares que no le corresponden
- un servicio debe tener el mínimo acceso necesario

Es como una oficina:

- cada empleado tiene una puerta a su despacho
- algunos pueden entrar a salas compartidas
- pocos tienen acceso a la caja fuerte

---

## 3. `sudo`, `visudo` y el principio del mínimo privilegio

### 3.1 ¿Qué es `sudo`?

`sudo` significa "superuser do".

Permite ejecutar un comando como administrador o root de forma controlada.

Ejemplo:

```bash
sudo apt update
sudo systemctl restart nginx
```

### 3.2 ¿Por qué no usamos root siempre?

Porque root puede hacer casi todo. Si usas root todo el tiempo, puedes:

- borrar archivos importantes
- romper configuraciones
- modificar servicios sin querer
- abrir huecos de seguridad

Linux favorece el principio del mínimo privilegio: "dame solo lo que haga falta".

### 3.3 ¿Qué hace `visudo`?

`visudo` es el editor seguro para editar el archivo `/etc/sudoers`.

Este archivo define quién puede usar `sudo` y qué comandos puede ejecutar.

Ejemplo de línea:

```bash
usuario ALL=(ALL) ALL
```

Esto significa: "este usuario puede ejecutar comandos como administrador".

Otro ejemplo más restringido:

```bash
usuario ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

Aquí le permites ejecutar solo un comando concreto sin preguntar contraseña.

### 3.4 Analogía

Imagina una oficina con un jefe que tiene la llave maestra. Si todos pudieran usarla sin control, el caos sería enorme.

`sudo` no es una llave perpetua: es una autorización puntual.

`visudo` es como la hoja oficial de reglas de acceso:

- quién puede abrir la caja fuerte
- qué puede tocar
- cuándo puede hacerlo

### 3.5 Buenas prácticas

- usa una cuenta normal para todo lo cotidiano
- usa `sudo` solo cuando haga falta
- no edites `/etc/sudoers` a mano
- usa `visudo` para validar sintaxis
- limita a usuarios y comandos estrictamente necesarios

Ejemplo de verificación:

```bash
sudo visudo -c
```

Esto valida la sintaxis del archivo de sudoers.

---

## 4. `systemctl` y servicios del sistema

### 4.1 ¿Qué es un servicio?

Un servicio es un programa que corre en segundo plano y realiza tareas del sistema.

Ejemplos comunes:

- SSH
- NGINX
- PostgreSQL
- cron
- Apache
- Docker

### 4.2 ¿Qué es `systemd`?

`systemd` es el sistema de inicialización y gestión de servicios en la mayoría de distribuciones modernas.

Es como el director de orquesta del sistema: coordina qué empieza, qué se queda detenido y en qué orden se arranca todo.

### 4.3 Comandos clave

Ver estado de un servicio:

```bash
systemctl status nginx
```

Iniciar un servicio:

```bash
sudo systemctl start nginx
```

Detener un servicio:

```bash
sudo systemctl stop nginx
```

Reiniciar un servicio:

```bash
sudo systemctl restart nginx
```

Habilitar un servicio al inicio:

```bash
sudo systemctl enable nginx
```

Deshabilitarlo:

```bash
sudo systemctl disable nginx
```

Ver todos los servicios activos:

```bash
systemctl list-units --type=service --state=running
```

### 4.4 Logs con `journalctl`

Cuando un servicio falla, a veces lo más útil no es adivinar, sino comprobar los registros.

Ver logs de un servicio:

```bash
sudo journalctl -u nginx
```

Seguir logs en tiempo real:

```bash
sudo journalctl -f
```

Ver logs del arranque actual:

```bash
sudo journalctl -b
```

### 4.5 Analogía

`systemctl` es como el portero o encargado del edificio.

- decide cuál servicio “entra”
- arranca o detiene tareas según la necesidad
- mantiene en funcionamiento cosas que no vemos a simple vista

Si un servicio falla, los logs son como el cuaderno de incidencias del edificio: dicen qué pasó, cuándo y qué falló.

---

## 5. Backups: Resguardar el trabajo antes de tocar nada

Los backups son copias de seguridad. En Linux, existen varias maneras de hacerlos. Dos de las más útiles y comunes son `tar` y `rsync`.

### 5.1 `tar`: empaquetar y comprimir

`tar` sirve para crear un archivo que contiene directorios y archivos.

Crear un backup comprimido:

```bash
tar -czvf respaldo.tar.gz /home/usuario/proyecto
```

- `c`: crear
- `z`: gzip
- `v`: verbose
- `f`: nombre del archivo

Extraer un backup:

```bash
tar -xzvf respaldo.tar.gz
```

### 5.2 `rsync`: sincronizar y copiar eficientemente

`rsync` es ideal para respaldar carpetas y mantenerlas sincronizadas.

Ejemplo simple:

```bash
rsync -av /home/usuario/proyecto/ /backup/proyecto/
```

Opciones útiles:

- `-a`: modo archivado, preserva permisos y metadatos
- `-v`: verbose
- `--delete`: elimina archivos que ya no existen en origen

Ejemplo de backup realista:

```bash
rsync -av --delete /home/usuario/ /mnt/backup/usuario/
```

### 5.3 ¿Por qué hacer backups?

Porque la práctica de administradores y usuarios avanzados es:

- hacer backups antes de cambios grandes
- guardar versiones importantes
- probar que la restauración funciona
- no confiar solo en la memoria del sistema

### 5.4 Analogía

Imagina que tu proyecto es un cuarto lleno de documentos importantes.

- `tar` es como guardar todo en una caja grande y cerrada
- `rsync` es como hacer una copia idéntica del cuarto en otra habitación sin dejar que se descoordine

Si un día el sistema falla, el backup te salva.

### 5.5 Buenas prácticas

- haz respaldo de archivos críticos antes de un cambio grande
- guarda copias en otra partición, disco o equipo
- usa fechas en los nombres de archivo
- prueba la restauración de vez en cuando

Ejemplo con fecha:

```bash
tar -czvf /backups/proyecto-$(date +%F).tar.gz /home/usuario/proyecto
```

---

## 6. Automatización con Bash y tareas programadas (`cron`)

Automatizar significa que una tarea se ejecute sola, sin que tú la pulses manualmente cada vez.

### 6.1 Bash scripting: pequeñas rutinas que hacen trabajo repetitivo

Un script en Bash puede ayudarte a:

- crear backups
- limpiar archivos temporales
- revisar discos
- enviar alertas
- reenviar registros

Ejemplo básico:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Iniciando limpieza de temporales..."
rm -rf /tmp/*
echo "Limpieza completa."
```

Darle permisos de ejecución:

```bash
chmod +x limpiar_tmp.sh
```

Ejecutarlo:

```bash
./limpiar_tmp.sh
```

### 6.2 ¿Qué es `cron`?

`cron` es el programador de tareas de Linux.

Es como un reloj automático que ejecuta tareas a horarios definidos.

Abre el editor de cron:

```bash
crontab -e
```

Ejemplo de una línea en cron:

```bash
0 2 * * * /home/usuario/scripts/backup.sh
```

Esto significa:

- a las 02:00 cada día
- ejecutar el script `/home/usuario/scripts/backup.sh`

### 6.3 Ejemplos de expresiones cron

Cada campo tiene este orden:

```bash
minuto hora día-del-mes mes día-de-la-semana comando
```

Ejemplos:

```bash
0 * * * * echo "Cada hora" >> /tmp/hora.log
15 8 * * 1 echo "Cada lunes a las 08:15" >> /tmp/semana.log
0 0 * * * /usr/local/bin/backup.sh
```

### 6.4 Ver jobs activos

```bash
crontab -l
```

Eliminar cron del usuario:

```bash
crontab -r
```

### 6.5 Analogía

`cron` es como un despertador muy serio para el sistema.

No necesita que tú estés presente. Solo necesita que le digas:

- qué hacer
- a qué hora
- con qué frecuencia

Es una forma muy práctica de dejar que el sistema "trabaje solo" cuando ya sabes lo que debe hacer.

### 6.6 Buenas prácticas

- guarda scripts en una carpeta clara, por ejemplo `~/scripts`
- registra logs para saber si la tarea se ejecutó bien
- prueba la tarea manualmente antes de programarla
- evita órdenes peligrosas en cron sin verificar primero

Ejemplo con log:

```bash
0 2 * * * /home/usuario/scripts/backup.sh >> /home/usuario/logs/backup.log 2>&1
```

Esto ayuda a revisar si hubo errores.

---

## 7. Cómo se ve esto en la práctica

Un administrador básico suele hacer esto:

1. crear usuarios y grupos para cada tipo de trabajo
2. asignar permisos mínimos
3. configurar `sudo` con reglas claras
4. revisar servicios con `systemctl`
5. crear respaldos con `tar` o `rsync`
6. automatizar tareas con Bash y cron

Ejemplo realista:

```bash
sudo adduser desarrollador
sudo usermod -aG sudo desarrollador
sudo systemctl status ssh
sudo rsync -av /home/usuario/proyecto/ /mnt/backup/proyecto/
crontab -e
```

Todo junto suena complejo, pero en realidad es una estructura elegante:

- permisos para proteger
- servicios para mantener todo funcionando
- backups para recuperar
- automatización para ahorrar trabajo

---

## 8. Errores comunes al empezar

### 8.1 Dar permisos demasiado abiertos

```bash
chmod 777 archivo.txt
```

Esto permite a cualquiera leer, escribir y ejecutar. Es útil solo en entornos temporales y nunca es una buena práctica en sistemas reales.

### 8.2 Ejecutar `sudo` sin pensar

Es una de las mejores formas de romper algo en segundos.

Antes de hacer cualquier cambio importante:

- revisa la ruta
- revisa el file
- revisa la lógica
- confirma el comando

### 8.3 Olvidar hacer backup

No importa qué tan pequeño sea el cambio. Si vas a tocar un servicio o una carpeta importante, lo sano es hacer una copia.

### 8.4 Crear un cron sin probarlo primero

Si una tarea no se probó en ejecución directa, puede fallar en el horario programado y tú ni enterarte.

---

## 9. Regla de oro de administración básica

Si quieres pensar como alguien que realmente maneja Linux, recuerda esto:

- usuarios tienen identidades
- grupos organizan permisos
- permisos controlan acceso
- `sudo` restringe la autoridad
- `systemctl` controla servicios
- backups protegen datos
- scripts y cron automatizan tareas

Es decir: Linux no es solo “comandos”; es un sistema de reglas, responsabilidades y flujo de trabajo.

---

## 10. Resumen rápido

### Usuarios y grupos

```bash
sudo adduser usuario
sudo usermod -aG sudo usuario
id usuario
groups usuario
```

### Permisos y propietario

```bash
ls -l archivo.txt
chmod 755 script.sh
sudo chown usuario:grupo archivo.txt
```

### sudo y visudo

```bash
sudo apt update
sudo visudo
```

### systemctl

```bash
sudo systemctl status servicio
sudo systemctl start servicio
sudo systemctl enable servicio
sudo journalctl -u servicio
```

### Backups

```bash
tar -czvf backup.tar.gz /ruta/archivo
rsync -av /origen/ /destino/
```

### Automatización con cron

```bash
crontab -e
0 2 * * * /ruta/script.sh >> /ruta/logs/script.log 2>&1
```

---

## 11. Cierre

Esta clase sintetiza la parte más “de administración” del sistema. No se trata solo de escribir comandos, sino de construir buenas costumbres:

- usuarios bien definidos
- permisos mínimos
- servicios controlados
- backups confiables
- automatización segura

Todas esas piezas hacen que GNU/Linux se sienta como un sistema ordenado, responsable y potente.

Y aquí es donde empieza a verse la diferencia entre simplemente “usar Linux” y “administrarlo con criterio”.

---

## 12. Recomendaciones para practicar

1. Crea un usuario nuevo en tu entorno de prueba.
2. Añádelo a un grupo y revisa `id` y `groups`.
3. Cambia permisos en una carpeta simple y observa `ls -l`.
4. Usa `sudo` con un comando básico y luego revisa `/etc/sudoers` con `visudo`.
5. Prueba `systemctl status` en un servicio local.
6. Haz un backup con `tar` y compara con `rsync`.
7. Crea un script simple y prográmalo con `cron`.

Lo importante no es la cantidad de comandos, sino la lógica detrás de cada uno.

---

## 13. Frase final

Linux no es solo un sistema operativo: es una forma de pensar en el control, la seguridad y la organización. Cada usuario, cada permiso, cada servicio y cada tarea automática son piezas de un mismo mecanismo.

Aprender esto te da más que “capacidad técnica”: te da conciencia de cómo funcionan los sistemas reales.

Y eso es lo que convierte a una persona en alguien capaz de administrarlos, no solo de usarlos.
