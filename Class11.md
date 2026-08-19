# Clase 11 — Docker en Profundidad: Construcción y Optimización de Imágenes

En la Clase 10 aprendimos **cómo funcionan los containers internamente**: namespaces, cgroups, y el aislamiento de procesos. Ahora vamos a aprender **cómo construir containers útiles** con Docker, desde crear nuestras propias imágenes hasta optimizarlas para producción.

Si la Clase 10 fue "cómo funciona la máquina", esta clase es "cómo conducir la máquina eficientemente".

## ¿Qué es Docker realmente?

Docker es una plataforma que facilita:

1. **Empaquetar** una aplicación con todas sus dependencias en una imagen.
2. **Reproducir** ese entorno exacto en cualquier máquina (laptop, servidor, nube).
3. **Ejecutar** la aplicación en containers aislados con recursos controlados.
4. **Distribuir** imágenes fácilmente entre desarrolladores y entornos.

La idea central: "funciona en mi máquina" → "funciona en todas partes".

## Componentes principales de Docker

### Imagen

Una imagen es como una "fotografía" de un sistema operativo + aplicación + configuración. Es estática, inmutable.

Ejemplo: una imagen es como un ISO de Ubuntu con Python preinstalado y tu aplicación incluida.

Características:

- Se compone de **capas** (layers).
- Cada capa es un conjunto de cambios respecto a la anterior.
- Las capas se reutilizan (esto ahorra espacio).
- Se almacenan en local o en un registro (Docker Hub, registros privados).

### Container

Un container es una **instancia en ejecución** de una imagen. Es como arrancar una máquina virtual desde un ISO.

Características:

- Efímero: cuando se detiene, desaparece (a menos que guardes datos).
- Aislado: no interfiere con otros containers.
- Rápido: arranca en milisegundos.
- Controlado: recursos limitados por cgroups.

### Dockerfile

Un Dockerfile es una **receta de texto** que le dice a Docker cómo construir una imagen. Es como un script de instalación.

```dockerfile
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3
COPY ./app /app
WORKDIR /app
CMD ["python3", "app.py"]
```

### Registro

Un registro es un almacén central de imágenes. Ejemplos:

- **Docker Hub**: registro público oficial
- **GitHub Container Registry (GHCR)**: registry en GitHub
- **Registros privados**: Nexus, Harbor, registros propios

## El Dockerfile: receta de construcción

Un Dockerfile tiene instrucciones básicas:

### FROM

Define la imagen base. Todas las imágenes comienzan desde una imagen existente.

```dockerfile
FROM ubuntu:20.04        # imagen base: Ubuntu 20.04
FROM python:3.9-slim     # imagen base: Python 3.9
FROM alpine:3.14         # imagen base: Alpine (muy pequeño)
FROM scratch             # imagen vacía (casos especiales)
```

### RUN

Ejecuta comandos durante la construcción. Se usa para instalar paquetes, compilar, etc.

```dockerfile
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git
```

Nota: es importante combinar comandos con `&&` para reducir capas.

### COPY y ADD

Copia archivos desde el host a la imagen.

```dockerfile
COPY ./app /app           # copiar directorio local a /app
COPY requirements.txt /tmp/
ADD https://example.com/file.tar.gz /tmp/  # ADD descarga URLs
```

### WORKDIR

Define el directorio de trabajo por defecto.

```dockerfile
WORKDIR /app
RUN npm install
CMD npm start  # se ejecutará en /app
```

### ENV

Define variables de entorno.

```dockerfile
ENV NODE_ENV=production
ENV PORT=3000
```

### EXPOSE

Documenta qué puertos escucha la aplicación (no los abre automáticamente).

```dockerfile
EXPOSE 8080   # documentación, no activa el puerto
```

### CMD

Define el comando por defecto cuando arranque el container.

```dockerfile
CMD ["python3", "app.py"]
CMD ["/bin/bash"]
```

### ENTRYPOINT

Define el comando principal (más control que CMD).

```dockerfile
ENTRYPOINT ["/usr/local/bin/myapp"]
```

Diferencia:

- `CMD`: puede ser reemplazado fácilmente
- `ENTRYPOINT`: es más difícil de reemplazar

### USER

Define qué usuario ejecuta los comandos.

```dockerfile
USER appuser   # los comandos siguientes se ejecutan como 'appuser'
```

Buena práctica: **no correr containers como root**.

## Construyendo tu primera imagen

### Paso 1: Crear un Dockerfile

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY ./src .

EXPOSE 5000

CMD ["python", "app.py"]
```

### Paso 2: Crear la aplicación

```bash
$ mkdir mi_app && cd mi_app
$ echo "Flask==2.0.0" > requirements.txt
$ mkdir src && cat > src/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "¡Hola desde Docker!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF
```

### Paso 3: Construir la imagen

```bash
$ docker build -t mi_app:v1.0 .
```

Salida esperada:

```
Sending build context to Docker daemon  2.048kB
Step 1/6 : FROM python:3.9-slim
3.9-slim: Pulling from library/python
...
Step 6/6 : CMD ["python", "app.py"]
---> Using cache
---> a1b2c3d4e5f6
Successfully built a1b2c3d4e5f6
Successfully tagged mi_app:v1.0
```

### Paso 4: Ejecutar el container

```bash
$ docker run -d -p 8000:5000 --name mi_contenedor mi_app:v1.0
$ curl http://localhost:8000
¡Hola desde Docker!
```

## Capas y caché

Cada línea en un Dockerfile crea una capa. Docker cachea capas para acelerar reconstrucciones.

Ejemplo:

```dockerfile
FROM ubuntu:20.04           # Capa 1
RUN apt-get update          # Capa 2
RUN apt-get install -y git  # Capa 3
COPY ./app /app             # Capa 4
RUN cd /app && npm install  # Capa 5
```

Si cambias solo el código (Capa 4), Docker reutiliza capas 1-3 del caché. Muy eficiente.

**Buena práctica**: ordena instrucciones de menos a más probable que cambien.

```dockerfile
# ❌ MALO: npm install se repite siempre que cambia el código
FROM node:16
COPY . /app
RUN npm install

# ✅ BUENO: npm install se cachea mientras package.json no cambie
FROM node:16
COPY package.json /app/
RUN npm install
COPY . /app
```

## Optimización de imágenes

Las imágenes grandes son lentas de transferir y ejecutar. Aquí hay técnicas para optimizar:

### 1. Usa imágenes base pequeñas

```dockerfile
# ❌ PESADO: 1.2GB
FROM ubuntu:20.04

# ✅ LIGERO: 150MB
FROM python:3.9-slim

# ✅ MUY LIGERO: 5MB
FROM alpine:3.14
```

Alpine es Linux mínimo. Perfecto para microservicios.

### 2. Multi-stage builds

Construye la aplicación en un stage y copia solo lo necesario en otro.

```dockerfile
# Stage 1: compilar
FROM golang:1.16 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

# Stage 2: ejecutar (solo necesita el binario)
FROM alpine:3.14
COPY --from=builder /app/myapp /usr/local/bin/
ENTRYPOINT ["myapp"]
```

Resultado: la imagen final solo contiene el binario, no el compilador. Pasamos de 500MB a 20MB.

### 3. Minimiza layers

Combina comandos:

```dockerfile
# ❌ MUCHAS CAPAS
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y pip
RUN apt-get clean

# ✅ UNA CAPA
RUN apt-get update && apt-get install -y \
    python3 \
    pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
```

### 4. Excluye archivos innecesarios

Crea un `.dockerignore` (como `.gitignore`):

```
.git
.gitignore
node_modules
.env
*.log
```

## Redes en Docker

Los containers necesitan comunicarse. Docker proporciona varios modos de red:

### Bridge (red por defecto)

Cada container obtiene una dirección IP en una red privada. Los containers en la misma red se ven entre sí.

```bash
# Crear una red
$ docker network create mi_red

# Ejecutar containers en la red
$ docker run -d --name db --network mi_red postgres:13
$ docker run -d --name app --network mi_red -p 8000:5000 mi_app:v1.0

# La app puede conectarse a db usando el hostname 'db'
```

### Host

El container comparte la red del host. Muy rápido pero menos aislado.

```bash
$ docker run --network host mi_app:v1.0
```

### None

El container no tiene red (útil para procesos que no necesitan red).

```bash
$ docker run --network none mi_app:v1.0
```

## Volúmenes y persistencia

Los containers son efímeros. Para datos persistentes, usa volúmenes.

### Volumen nombrado

Docker gestiona el almacenamiento.

```bash
# Crear volumen
$ docker volume create mi_datos

# Usar en container
$ docker run -v mi_datos:/data mi_app:v1.0

# Verificar
$ docker volume ls
$ docker volume inspect mi_datos
```

### Bind mount

Monta un directorio del host en el container.

```bash
$ docker run -v $(pwd)/mi_datos:/data mi_app:v1.0

# Los cambios en /data dentro del container afectan $(pwd)/mi_datos en el host
```

### Tmpfs

Almacenamiento temporal en memoria.

```bash
$ docker run --tmpfs /tmp:size=100m mi_app:v1.0
```

## Variables de entorno

Las aplicaciones se configuran mediante variables de entorno.

En el Dockerfile:

```dockerfile
ENV DATABASE_URL=postgres://localhost/db
ENV LOG_LEVEL=info
```

Al ejecutar:

```bash
$ docker run -e DATABASE_URL=postgres://prod.db/db \
             -e LOG_LEVEL=debug \
             mi_app:v1.0
```

## Limitación de recursos

Con Docker podemos limitar CPU, memoria y E/S.

```bash
# Limitar memoria a 256MB
$ docker run --memory 256m mi_app:v1.0

# Limitar CPU a 0.5 cores
$ docker run --cpus 0.5 mi_app:v1.0

# Limitar E/S de lectura a 1MB/s
$ docker run --device-read-bps /dev/sda:1mb mi_app:v1.0
```

## Ejemplo: Aplicación web multicontenedor

### Estructura

```
mi_proyecto/
├── Dockerfile              # imagen de la app
├── docker-compose.yml      # orquestación local
├── src/
│   └── app.py
└── requirements.txt
```

### Dockerfile (aplicación Flask)

```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/ .
EXPOSE 5000
CMD ["python", "app.py"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:5000"
    environment:
      DATABASE_URL: postgresql://postgres:pass@db:5432/appdb
    depends_on:
      - db
    networks:
      - app_network

  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: appdb
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app_network

volumes:
  db_data:

networks:
  app_network:
```

### Ejecutar todo

```bash
$ docker-compose up -d    # arranca todos los servicios
$ docker-compose logs -f  # ver logs en vivo
$ docker-compose down     # detener todo
```

## Buenas prácticas en Dockerfiles

1. **No corras como root**

```dockerfile
RUN useradd -m appuser
USER appuser
```

2. **Minimiza capas**

Combina `RUN` con `&&`.

3. **Ordena instrucciones inteligentemente**

De menos a más probable que cambien.

4. **Limpia después de instalar**

```dockerfile
RUN apt-get update && apt-get install -y git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
```

5. **Usa health checks**

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD curl -f http://localhost:5000/health || exit 1
```

6. **Documenta los puertos**

```dockerfile
EXPOSE 8080
```

7. **Usa `.dockerignore`**

Excluye archivos innecesarios como `.git`, `node_modules`, etc.

## Debugging y inspección

```bash
# Ver logs de un container
$ docker logs CONTAINER_ID
$ docker logs -f CONTAINER_ID  # seguimiento en tiempo real

# Ejecutar comando dentro de un container
$ docker exec -it CONTAINER_ID bash

# Inspeccionar configuración
$ docker inspect CONTAINER_ID

# Ver cómo se construyó
$ docker history IMAGEN:TAG

# Ver tamaño de la imagen
$ docker images --no-trunc mi_app:v1.0

# Estadísticas de recursos
$ docker stats
```

## Ejercicios prácticos

### Ejercicio 1: Tu primer Dockerfile

Crea una imagen simple que imprima un mensaje:

```dockerfile
FROM alpine:3.14
RUN echo "¡Hola desde Docker!"
CMD ["echo", "El container se ejecutó correctamente"]
```

Construye y ejecuta:

```bash
$ docker build -t hola:v1 .
$ docker run hola:v1
```

### Ejercicio 2: Aplicación Node.js

Crea una aplicación Express y dockeriza:

```bash
$ mkdir express_app && cd express_app
$ npm init -y
$ npm install express
$ cat > app.js << 'EOF'
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('¡Hola desde Express en Docker!');
});

app.listen(3000, () => {
  console.log('Servidor escuchando en puerto 3000');
});
EOF

# Dockerfile
$ cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
EOF

# Construir y ejecutar
$ docker build -t express_app:v1 .
$ docker run -p 8000:3000 express_app:v1
```

### Ejercicio 3: Multi-stage build

Crea una aplicación Go compilada:

```dockerfile
# Stage 1: compilar
FROM golang:1.16 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp .

# Stage 2: ejecutar
FROM alpine:3.14
COPY --from=builder /app/myapp /usr/local/bin/myapp
ENTRYPOINT ["myapp"]
```

### Ejercicio 4: Optimizar imagen

Toma un Dockerfile existente y optimiza su tamaño:

```bash
# Medir tamaño original
$ docker build -t app:v1 .
$ docker images app:v1

# Optimizar y comparar
$ docker build -t app:v2 -f Dockerfile.optimized .
$ docker images | grep "app:"
```

### Ejercicio 5: Docker Compose

Crea un `docker-compose.yml` con múltiples servicios y experimenta con:

```bash
$ docker-compose up -d
$ docker-compose ps
$ docker-compose logs
$ docker-compose exec web bash  # entrar en un container
$ docker-compose down
```

## Resumen

Docker permite:

- **Empaquetar** aplicaciones con todas sus dependencias
- **Reproducir** entornos exactos en cualquier lugar
- **Optimizar** imágenes para producción
- **Orquestar** múltiples containers con docker-compose
- **Aislar** procesos sin overhead de máquinas virtuales

Las imágenes Docker son el estándar moderno para distribuir software. Entender cómo construirlas, optimizarlas y ejecutarlas es fundamental en el desarrollo moderno.

## Siguiente: Kubernetes

Cuando tienes muchos containers en producción, necesitas orquestación automática: programación inteligente, escalado, recuperación ante fallos, actualizaciones sin downtime. Para eso existe Kubernetes, el tema de la próxima clase.
