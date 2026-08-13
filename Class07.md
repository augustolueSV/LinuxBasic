# Clase 07 — Scripting en Bash para automatizar tareas

Objetivo: dar el siguiente paso en Linux y dejar de depender solo de comandos sueltos. En esta clase veremos cómo combinar comandos para crear pequeños programas en Bash, útiles para automatizar tareas repetitivas y dar orden a las operaciones del sistema.

La idea no es aprender “un montón de sintaxis” como si fuera un idioma extraño. La idea es entender que un script es simplemente una serie de comandos que se ejecutan en secuencia, como una receta: primero haces esto, luego aquello, compruebas si todo salió bien y finalmente terminas.

Si la clase anterior te hizo entender cómo se administra un sistema, esta te muestra cómo ahorrar tiempo y evitar errores repetitivos.

---

## 1. ¿Qué es un script?

Un script es un archivo de texto con comandos de Linux. Cuando lo ejecutas, el sistema lee ese archivo línea por línea y hace exactamente lo que le indicas.

Esto sirve para:

- automatizar tareas repetitivas
- crear backups
- preparar carpetas de trabajo
- revisar el estado del sistema
- instalar componentes de forma más rápida
- crear pequeños programas muy útiles para administración

### 1.1 Diferencia entre comando y script

Un comando como:

```bash
ls -la
```

se ejecuta directamente desde la terminal.

Un script es algo así:

```bash
#!/usr/bin/env bash

echo "Hola, soy un script"
ls -la
```

Y cuando lo ejecutas, hace todas esas acciones una detrás de otra.

### 1.2 Analogía útil

Si un comando individual es una sola tarea, un script es como una receta de cocina:

1. preparar ingredientes
2. cocinar
3. revisar si salió bien
4. guardar el resultado

En Linux, un script te permite repetir esa secuencia sin tener que pensar en cada paso cada vez.

---

## 2. Primer script: el clásico “Hola, Linux”

Crea un archivo llamado `hola.sh`:

```bash
nano hola.sh
```

Escribe esto:

```bash
#!/usr/bin/env bash

echo "Hola, Linux"
```

Guárdalo y luego hazlo ejecutable:

```bash
chmod +x hola.sh
./hola.sh
```

### Explicación

- `#!/usr/bin/env bash`: indica que este archivo debe ejecutarse con Bash.
- `echo`: imprime texto en pantalla.
- `chmod +x`: da permisos de ejecución al archivo.
- `./hola.sh`: ejecuta el script que está en la carpeta actual.

Si no pusieras `chmod +x`, el sistema no lo consideraría ejecutable.

### ¿Qué pasa si no funciona?

Si ves un error como "Permission denied", normalmente significa que no le has dado permiso de ejecución.

Prueba:

```bash
ls -l hola.sh
```

Y revisa los permisos.

---

## 3. Variables: guardar información para reutilizarla

Las variables son contenedores. Guardan valores que luego puedes usar varias veces.

Ejemplo:

```bash
#!/usr/bin/env bash

NOMBRE="Ana"
echo "Hola, $NOMBRE"
```

### Importante

En Bash, asignas una variable así:

```bash
NOMBRE="Ana"
```

y la usas así:

```bash
echo "$NOMBRE"
```

Nunca la olvides:

- `NOMBRE="Ana"` correcto
- `NOMBRE = "Ana"` incorrecto

### Ejemplo con fecha y usuario

```bash
#!/usr/bin/env bash

USUARIO=$(whoami)
FECHA=$(date)

echo "Usuario actual: $USUARIO"
echo "Fecha actual: $FECHA"
```

`$(...)` significa “ejecuta este comando y guarda su salida”.

Es decir, `$(date)` ejecuta la fecha y devuelve un valor que luego puedes mostrar.

---

## 4. Argumentos: hacer que el script reciba datos

Los scripts pueden recibir argumentos desde la terminal.

Ejemplo:

```bash
#!/usr/bin/env bash

echo "Primer argumento: $1"
echo "Segundo argumento: $2"
echo "Todos los argumentos: $@"
```

Y lo ejecutas así:

```bash
./script.sh hola 123
```

Salida:

```bash
Primer argumento: hola
Segundo argumento: 123
Todos los argumentos: hola 123
```

### Variables especiales de Bash

- `$0`: nombre del script
- `$1`: primer argumento
- `$2`: segundo argumento
- `$#`: número de argumentos
- `$@`: todos los argumentos
- `$?`: código de salida del último comando

### Ejemplo práctico

```bash
#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
    echo "Uso: $0 <nombre>"
    exit 1
fi

echo "Hola, $1"
```

Esto hace que el script valide si se le pasó un nombre.

---

## 5. Condiciones: tomar decisiones

Uno de los mayores poderes del scripting es decidir qué hacer según ciertas condiciones.

### 5.1 Estructura `if`

```bash
#!/usr/bin/env bash

if [ "$1" = "hola" ]; then
    echo "Has dicho hola"
else
    echo "No has dicho hola"
fi
```

### 5.2 Operadores de comparación

- `=`: compara cadenas
- `-eq`: igual a número
- `-ne`: distinto
- `-lt`: menor que
- `-gt`: mayor que
- `-d`: existe y es un directorio
- `-f`: existe y es un archivo
- `-e`: existe

### 5.3 Ejemplos sencillos

Comprobar si un archivo existe:

```bash
#!/usr/bin/env bash

if [ -f "/etc/passwd" ]; then
    echo "El archivo existe"
else
    echo "No existe"
fi
```

Comprobar si un directorio existe:

```bash
#!/usr/bin/env bash

if [ -d "$HOME/mi_carpeta" ]; then
    echo "La carpeta ya existe"
else
    mkdir -p "$HOME/mi_carpeta"
    echo "He creado la carpeta"
fi
```

Este tipo de script es muy útil para automatizar tareas sin duplicar trabajo.

---

## 6. Bucles: repetir tareas

Los bucles sirven para hacer la misma acción varias veces sin escribirla muchas veces.

### 6.1 Bucle `for`

```bash
#!/usr/bin/env bash

for i in 1 2 3 4 5; do
    echo "Número: $i"
done
```

Salida:

```bash
Número: 1
Número: 2
Número: 3
Número: 4
Número: 5
```

### 6.2 Recorrer archivos

```bash
#!/usr/bin/env bash

for archivo in *.txt; do
    echo "Archivo encontrado: $archivo"
done
```

Esto recorre todos los `.txt` del directorio actual.

### 6.3 Bucle `while`

```bash
#!/usr/bin/env bash

CONTADOR=1

while [ "$CONTADOR" -le 3 ]; do
    echo "Iteración $CONTADOR"
    CONTADOR=$((CONTADOR + 1))
done
```

`$((...))` se usa para hacer operaciones matemáticas dentro del script.

---

## 7. Leer entrada del usuario: `read`

A veces un script necesita preguntar algo al usuario.

```bash
#!/usr/bin/env bash

read -p "¿Cómo te llamas? " NOMBRE

echo "Hola, $NOMBRE"
```

### Ejemplo con confirmación

```bash
#!/usr/bin/env bash

read -p "¿Quieres continuar? [s/N]: " RESPUESTA

if [ "$RESPUESTA" = "s" ] || [ "$RESPUESTA" = "S" ]; then
    echo "Continuamos"
else
    echo "Se cancela la operación"
fi
```

Esto es muy útil cuando quieres evitar acciones peligrosas.

---

## 8. `set -euo pipefail`: seguridad en scripts

Cuando escribes scripts más serios, hay una línea muy útil:

```bash
set -euo pipefail
```

### Significado

- `-e`: si un comando falla, el script se detiene
- `-u`: si usas una variable no definida, falla
- `-o pipefail`: si una tubería falla, también falla el script

Ejemplo:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Empieza el script"
mkdir -p /tmp/mi_directorio
ls /tmp/mi_directorio
```

Esto evita que un script siga adelante cuando algo va mal.

### ¿Por qué es importante?

Porque en administración de sistemas, a veces un fallo pequeño puede convertirse en un problema grande si el script sigue ejecutando comandos aunque ya hubo un error.

---

## 9. Script práctico: backup simple

Vamos a crear un script que haga una copia de seguridad de una carpeta a otra.

```bash
#!/usr/bin/env bash
set -euo pipefail

ORIGEN="${1:-$HOME/proyecto}"
DESTINO="${2:-$HOME/backups}"
FECHA=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "$DESTINO"

cp -r "$ORIGEN" "$DESTINO/proyecto_$FECHA"

echo "Backup creado en: $DESTINO/proyecto_$FECHA"
```

### ¿Cómo se ejecuta?

```bash
chmod +x backup.sh
./backup.sh
```

Si quieres cambiar la ruta:

```bash
./backup.sh /home/usuario/proyecto /tmp/backup
```

### ¿Qué hace?

- toma la carpeta origen
- crea la carpeta de destino si no existe
- hace una copia de la carpeta con una fecha incluida
- imprime un mensaje final

Este tipo de scripts son muy útiles para tareas del día a día.

---

## 10. Scripts con funciones

Las funciones permiten agrupar bloques de código reutilizables.

```bash
#!/usr/bin/env bash

saludar() {
    echo "Hola, $1"
}

saludar "Ana"
saludar "Luis"
```

Salida:

```bash
Hola, Ana
Hola, Luis
```

### ¿Para qué sirven?

Porque te evitan repetir código. Si tienes varias tareas similares, puedes ponerlas en una función y llamarlas desde el script.

Ejemplo más útil:

```bash
#!/usr/bin/env bash
set -euo pipefail

crear_carpeta() {
    local nombre="$1"
    mkdir -p "$nombre"
    echo "Carpeta creada: $nombre"
}

crear_carpeta "/tmp/prueba1"
crear_carpeta "/tmp/prueba2"
```

`local` hace que la variable solo exista dentro de la función.

---

## 11. Redirecciones y tuberías dentro de scripts

Ya vimos que en Linux puedes combinar comandos con redirecciones y `|`.

### 11.1 Redirección

```bash
ls > salida.txt
```

Esto guarda la salida de `ls` en un archivo.

### 11.2 Añadir contenido a un archivo

```bash
echo "Nueva línea" >> salida.txt
```

### 11.3 Tuberías

```bash
ps aux | grep bash
```

Esto toma la salida de un comando y la pasa a otro.

### 11.4 Ejemplo en script

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Revisando procesos..."
ps aux | grep ssh > /tmp/ssh_processes.txt

echo "Resultado guardado en /tmp/ssh_processes.txt"
```

Esto es útil para automatizar inspecciones o auditorías rápidas.

---

## 12. Detección de errores y mensajes útiles

Un buen script no solo hace cosas; también comunica qué está haciendo.

Ejemplo:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Comenzando backup..."
mkdir -p /tmp/backup
cp -r /etc /tmp/backup/etc_backup

echo "[OK] Backup finalizado"
```

### ¿Por qué es útil?

Porque cuando el script falla en producción, puedes ver exactamente dónde se detuvo.

Puedes incluso añadir mensajes de error manuales:

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$1" ]; then
    echo "[ERROR] El directorio $1 no existe" >&2
    exit 1
fi

echo "[INFO] Todo está bien"
```

`>&2` significa: “envía este mensaje a la salida de errores”, no a la salida normal.

---

## 13. Automatización con cron

Una vez que tienes un script útil, puedes ejecutarlo automáticamente con `cron`.

### 13.1 Editar cron

```bash
crontab -e
```

### 13.2 Ejemplo de tarea cada 5 minutos

```bash
*/5 * * * * /home/usuario/backup.sh >> /tmp/backup.log 2>&1
```

Esto significa:

- cada 5 minutos
- ejecuta `backup.sh`
- guarda la salida y los errores en `backup.log`

### 13.3 Ejemplo de tarea diaria

```bash
0 2 * * * /home/usuario/backup.sh >> /tmp/backup.log 2>&1
```

Esto ejecuta el script a las 2:00 AM todos los días.

### 13.4 Importante

No todo lo que se automatiza debe ejecutarse sin supervisión. Un script útil debe:

- tener logs
- fallar con mensajes claros
- evitar sobrescribir cosas sin confirmación
- usar rutas bien definidas

---

## 14. Mini proyecto: script de diagnóstico simple

Vamos a crear un script que revisa algunos elementos del sistema y los muestra en pantalla.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== Estado del sistema ==="

echo "- Usuario actual: $(whoami)"
echo "- Fecha: $(date)"
echo "- Espacio en disco:"
df -h | head

echo "- Procesos activos:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
```

### ¿Qué hace?

- muestra el usuario actual
- imprime la fecha
- revisa el espacio en disco
- lista los procesos más pesados

Esto te sirve para practicar la unión de comandos en un solo flujo.

---

## 15. Recomendaciones para escribir scripts sin frustrarte

Cuando empiezas, esto ayuda mucho:

- escribe scripts pequeños
- prueba cada parte por separado
- usa `echo` para comprobar variables
- haz que el script falle con mensajes claros
- no intentes automatizar todo de golpe
- empieza con tareas simples y luego agrégales condiciones

### Recomendación clave

Si un script parece difícil, divídelo en pasos:

1. comprobar si existe la carpeta
2. crear la carpeta si no existe
3. guardar un archivo de log
4. mostrar mensaje final

Eso es mucho más fácil que intentar hacer todo en una sola línea enorme.

---

## 16. Resumen de la clase

En esta clase hemos visto que Linux no solo se usa con comandos aislados, sino que también se puede automatizar con scripts.

Los conceptos clave fueron:

- qué es un script
- cómo crear un archivo ejecutable
- cómo usar variables
- cómo recibir argumentos
- cómo decidir con `if`
- cómo repetir con `for` y `while`
- cómo leer entrada del usuario
- cómo manejar errores con `set -euo pipefail`
- cómo programar tareas con `cron`

Esto no hace que te conviertas en “experto de Bash” de la noche a la mañana, pero sí te da la base para empezar a automatizar tareas reales con confianza.

---

## 17. Comandos clave para practicar

```bash
chmod +x script.sh
./script.sh

VARIABLE="valor"
echo "$VARIABLE"

if [ -d "/tmp" ]; then
    echo "Existe"
fi

for i in 1 2 3; do
    echo "$i"
done

read -p "Nombre: " NOMBRE

echo "Hola, $NOMBRE"

ps aux | grep bash
crontab -e
```

---

## 18. Ejercicios recomendados

1. Crea un script que diga “Hola, tu nombre” usando un argumento.
2. Haz un script que compruebe si una carpeta existe y la cree si no existe.
3. Escribe un script que recorra archivos `.txt` y los muestre en pantalla.
4. Crea un backup simple de una carpeta en otra ubicación.
5. Añade `set -euo pipefail` a un script y prueba qué pasa cuando falla algo.
6. Programa una tarea con `crontab` y observa la salida en un archivo de log.
7. Haz un script que muestre la fecha, el usuario actual y el espacio libre del disco.
8. Practica con `if`, `for` y `read` en un mismo script para familiarizarte con el flujo.

---

## 19. Frase final

Si en la clase anterior aprendiste a mirar el sistema, en esta aprendiste a hablar con él. Bash no es magia: es una forma de decirle al sistema “haz esto, luego esto, y si pasa eso, haz lo otro”.

Eso es lo que convierte a un usuario principiante en alguien capaz de automatizar tareas, ahorrar tiempo y entender mejor cómo funciona Linux en la práctica.

Y no hace falta saberlo todo desde el principio. Solo hace falta practicar, probar y volver a probar.
