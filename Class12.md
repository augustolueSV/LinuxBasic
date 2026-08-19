# Clase 12 — Kubernetes: Orquestación y Automatización de Containers

En la Clase 11 aprendimos a construir y ejecutar containers con Docker. Funcionan bien en una máquina. Pero cuando tienes **docenas, cientos o miles de containers en producción**, Docker no es suficiente. Necesitas un orquestador: **Kubernetes**.

Si Docker es "cómo empaquetar una aplicación", Kubernetes es "cómo ejecutar esas aplicaciones a escala, de forma automática, confiable y resiliente".

## El problema que resuelve Kubernetes

Imagina que tienes 100 containers de tu aplicación web ejecutándose. Necesitas:

- **Programación**: decidir en qué máquina ejecutar cada container
- **Escalado automático**: si hay mucha carga, lanzar más containers
- **Recuperación**: si un container falla, lanzar uno nuevo
- **Actualizaciones**: cambiar de versión sin downtime
- **Balanceo de carga**: distribuir tráfico entre containers
- **Almacenamiento**: gestionar datos persistentes
- **Redes**: que los containers se comuniquen entre sí
- **Secretos**: manejar contraseñas, tokens, certificados
- **Monitoreo**: saber qué está pasando en cada momento

Hacer esto manualmente es **imposible**. Kubernetes lo automatiza.

## Arquitectura de Kubernetes

### Conceptos clave

Kubernetes organiza recursos en estos niveles:

```
Cluster (conjunto de máquinas)
├── Control Plane (cerebro del cluster)
│   ├── API Server (interfaz central)
│   ├── Scheduler (decide dónde ejecutar pods)
│   ├── Controller Manager (mantiene el estado deseado)
│   └── etcd (base de datos del cluster)
│
└── Nodes (máquinas de trabajo)
    ├── kubelet (agente en cada nodo)
    ├── Container Runtime (Docker, containerd, etc)
    └── Pods (unidad mínima de Kubernetes)
```

### Cluster

Un cluster Kubernetes es un conjunto de máquinas (nodos) que trabajan juntas. Un cluster puede tener 1 nodo (desarrollo) o cientos (producción).

### Control Plane

El cerebro del cluster. Toma decisiones sobre dónde ejecutar pods, cómo escalar, cómo recuperarse de fallos.

Componentes principales:

- **API Server**: expone la API de Kubernetes. Todo se comunica a través de ella.
- **Scheduler**: decide en qué nodo ejecutar un pod nuevo.
- **Controller Manager**: gestiona controladores (replicación, nodos, servicios, etc).
- **etcd**: base de datos clave-valor que almacena todo el estado del cluster.

### Nodes

Máquinas de trabajo donde se ejecutan los containers. Cada nodo tiene:

- **kubelet**: agente que se comunica con el control plane y maneja pods
- **Container Runtime**: Docker, containerd, o similar
- **kube-proxy**: maneja redes y reglas de firewall

### Pod

La unidad mínima en Kubernetes. Es un contenedor (o a veces varios) envuelto en una abstracción.

Características:

- Uno o más containers (usualmente uno).
- Comparten red: tienen la misma IP.
- Efímero: pueden crearse y destruirse frecuentemente.
- No deberías crear pods directamente: usar Deployments.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi_pod
spec:
  containers:
  - name: app
    image: mi_app:v1.0
    ports:
    - containerPort: 5000
```

## Objetos principales de Kubernetes

### Deployment

Define cómo correr una aplicación. Es lo que típicamente usarás.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mi_app
spec:
  replicas: 3              # ejecutar 3 copias
  selector:
    matchLabels:
      app: mi_app
  template:
    metadata:
      labels:
        app: mi_app
    spec:
      containers:
      - name: app
        image: mi_app:v1.0
        ports:
        - containerPort: 5000
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
```

Kubernetes automáticamente:

- Mantiene 3 pods ejecutándose
- Si uno falla, lanza uno nuevo
- Distribuye entre nodos disponibles

### Service

Expone un deployment al exterior o a otros servicios dentro del cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mi_app_service
spec:
  type: LoadBalancer          # exponer al exterior
  ports:
  - port: 80                  # puerto externo
    targetPort: 5000          # puerto del pod
  selector:
    app: mi_app               # se conecta a deployments con esta etiqueta
```

Tipos de servicios:

- **ClusterIP**: solo accesible dentro del cluster
- **NodePort**: accesible en un puerto de cada nodo
- **LoadBalancer**: expone con un load balancer externo (cloud)
- **ExternalName**: redirecciona a un servicio externo

### ConfigMap

Almacena configuración (no secretos) como variables de entorno o archivos.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app_config
data:
  LOG_LEVEL: "info"
  DATABASE_HOST: "postgres"
  config.yml: |
    server:
      port: 5000
      debug: false
```

Usar en un Deployment:

```yaml
spec:
  containers:
  - name: app
    image: mi_app:v1.0
    envFrom:
    - configMapRef:
        name: app_config
```

### Secret

Almacena datos sensibles (contraseñas, tokens, certificados) de forma segura.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db_credentials
type: Opaque
data:
  username: dXNlcm5hbWU=      # base64 de 'username'
  password: cGFzc3dvcmQ=      # base64 de 'password'
```

Usar en un Deployment:

```yaml
spec:
  containers:
  - name: app
    image: mi_app:v1.0
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db_credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db_credentials
          key: password
```

### StatefulSet

Similar a Deployment, pero para aplicaciones que necesitan identidad estable (bases de datos, colas, etc).

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

### Ingress

Enruta tráfico HTTP/HTTPS desde el exterior al cluster.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mi_ingress
spec:
  ingressClassName: nginx
  rules:
  - host: mi_app.ejemplo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mi_app_service
            port:
              number: 80
```

### PersistentVolume y PersistentVolumeClaim

Gestionan almacenamiento persistente.

```yaml
# PersistentVolume (oferta de almacenamiento)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv_datos
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.100
    path: "/export/datos"

---
# PersistentVolumeClaim (solicitud de almacenamiento)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc_datos
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

## Ciclo de vida de un Deployment

```
1. Crear Deployment (kubectl apply)
   ↓
2. Kubernetes crea Pods según especificación
   ↓
3. Pods se ejecutan en los nodos disponibles
   ↓
4. Si un Pod falla → Kubernetes lo reinicia
   ↓
5. Para actualizar → crear Deployment nuevo
   ↓
6. Rolling update: reemplaza pods gradualmente
   ↓
7. Versión nueva arranca, versión vieja se detiene
   ↓
8. Si hay problemas → rollback automático
```

## Kubectl: interfaz de Kubernetes

**kubectl** es la herramienta de línea de comandos para Kubernetes.

### Operaciones básicas

```bash
# Ver estado general
$ kubectl cluster-info
$ kubectl get nodes

# Crear objetos desde un archivo YAML
$ kubectl apply -f deployment.yaml

# Ver deployments
$ kubectl get deployments
$ kubectl get pods
$ kubectl get services

# Información detallada
$ kubectl describe deployment mi_app
$ kubectl describe pod mi_pod

# Logs de un pod
$ kubectl logs mi_pod
$ kubectl logs mi_pod -f            # seguimiento en vivo

# Ejecutar comando dentro de un pod
$ kubectl exec -it mi_pod -- bash

# Escalar manualmente
$ kubectl scale deployment mi_app --replicas=5

# Actualizar imagen
$ kubectl set image deployment/mi_app app=mi_app:v2.0

# Eliminar objetos
$ kubectl delete deployment mi_app
$ kubectl delete service mi_app_service
```

### Editar recursos en vivo

```bash
$ kubectl edit deployment mi_app    # abre editor
$ kubectl patch deployment mi_app --type='json' -p='[...]'
```

## Ejemplo completo: Aplicación web

Crearemos una aplicación con frontend, backend y base de datos.

### 1. ConfigMap para configuración

```yaml
# config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app_config
data:
  DATABASE_HOST: "postgres"
  DATABASE_PORT: "5432"
  DATABASE_NAME: "appdb"
  LOG_LEVEL: "info"
```

### 2. Secret para credenciales

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db_secret
type: Opaque
data:
  username: cG9zdGdyZXM=         # 'postgres' en base64
  password: c2VjdXJlX3Bhc3M=     # 'secure_pass' en base64
```

### 3. Base de datos (PostgreSQL)

```yaml
# database.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: "appdb"
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: db_secret
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db_secret
              key: password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
  - port: 5432
```

### 4. Backend (Flask)

```yaml
# backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: mi_backend:v1.0
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: app_config
        env:
        - name: DATABASE_USER
          valueFrom:
            secretKeyRef:
              name: db_secret
              key: username
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db_secret
              key: password
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 5000
```

### 5. Desplegar todo

```bash
# Crear namespace
$ kubectl create namespace mi_app

# Aplicar configuración y secretos
$ kubectl apply -f config.yaml -n mi_app
$ kubectl apply -f secret.yaml -n mi_app

# Desplegar servicios
$ kubectl apply -f database.yaml -n mi_app
$ kubectl apply -f backend.yaml -n mi_app

# Verificar estado
$ kubectl get pods -n mi_app
$ kubectl get services -n mi_app

# Ver logs del backend
$ kubectl logs deployment/backend -n mi_app -f
```

## Escalado automático

Kubernetes puede escalar automáticamente basándose en métricas.

```yaml
# autoscaling.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend_autoscaler
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80      # escalar si CPU > 80%
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 85      # escalar si memoria > 85%
```

## Estrategias de actualización

### Rolling Update (por defecto)

Reemplaza pods gradualmente. Cero downtime.

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1         # máximo 1 pod extra durante update
      maxUnavailable: 0   # siempre disponible
```

### Blue-Green

Dos versiones completas, cambio instantáneo.

```bash
# versión blue (actual)
$ kubectl set selector service/mi_app version=blue

# versión green (nueva)
$ kubectl apply -f deployment_v2.yaml -l version=green

# cambiar tráfico a green
$ kubectl set selector service/mi_app version=green
```

### Canary

Envía pequeño porcentaje a versión nueva.

```bash
# 90% a versión old, 10% a versión new
$ kubectl apply -f canary.yaml  # tiene 10% de pods nuevos
```

## Health checks

Kubernetes verifica que los pods estén sanos.

```yaml
spec:
  containers:
  - name: app
    image: mi_app:v1.0
    # ¿La aplicación está lista para recibir tráfico?
    readinessProbe:
      httpGet:
        path: /ready
        port: 5000
      initialDelaySeconds: 10
      periodSeconds: 5
    # ¿La aplicación está viva?
    livenessProbe:
      httpGet:
        path: /health
        port: 5000
      initialDelaySeconds: 30
      periodSeconds: 10
    # ¿Está lista para requerir tráfico? (solo al arrancar)
    startupProbe:
      httpGet:
        path: /startup
        port: 5000
      failureThreshold: 30
      periodSeconds: 10
```

Si los probes fallan, Kubernetes reinicia el pod automáticamente.

## Namespaces

Namespaces aíslan recursos dentro del mismo cluster.

```bash
# Crear namespace
$ kubectl create namespace produccion

# Usar namespace
$ kubectl apply -f deployment.yaml -n produccion

# Ver recursos en un namespace
$ kubectl get pods -n produccion

# Cambiar namespace por defecto
$ kubectl config set-context --current --namespace=produccion
```

## Ejercicios prácticos

### Ejercicio 1: Minikube local

```bash
# Instalar minikube (Kubernetes en una máquina local)
$ minikube start

# Verificar
$ kubectl cluster-info
$ kubectl get nodes

# Dashboard
$ minikube dashboard
```

### Ejercicio 2: Deployment simple

```bash
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80

# Aplicar
$ kubectl apply -f deployment.yaml

# Ver pods
$ kubectl get pods

# Acceder a un pod
$ kubectl exec -it nginx-xxxx -- bash
```

### Ejercicio 3: Service y Ingress

```bash
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    nodePort: 30000

# Aplicar y acceder
$ kubectl apply -f service.yaml
$ kubectl get service nginx-service
$ curl http://localhost:30000
```

### Ejercicio 4: Scalin automático

```bash
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx_hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 2
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

# Aplicar
$ kubectl apply -f hpa.yaml

# Ver HPA
$ kubectl get hpa
```

### Ejercicio 5: Actualización y Rollback

```bash
# Actualizar imagen
$ kubectl set image deployment/nginx nginx=nginx:1.22

# Ver rollout
$ kubectl rollout status deployment/nginx

# Historial de deployments
$ kubectl rollout history deployment/nginx

# Rollback a versión anterior
$ kubectl rollout undo deployment/nginx
```

## Resumen

Kubernetes es el orquestador de containers más poderoso del mercado. Proporciona:

- **Automatización**: programación, escalado, recuperación
- **Reliability**: alta disponibilidad, self-healing
- **Flexibility**: soporta cualquier aplicación, cualquier cloud
- **Escalabilidad**: desde 1 nodo a miles
- **Ecosistema**: miles de herramientas y extensiones

Los conceptos clave son:

- **Cluster**: conjunto de nodos
- **Pod**: unidad mínima (container(s))
- **Deployment**: cómo ejecutar aplicaciones
- **Service**: cómo exponerlas
- **Ingress**: enrutamiento HTTP/HTTPS
- **StatefulSet**: aplicaciones con estado
- **ConfigMap y Secret**: configuración y secretos

## Siguiente nivel

Después de Kubernetes, el camino natural es:

- **Helm**: empaquetar aplicaciones Kubernetes (como brew/apt pero para K8s)
- **Service Mesh**: Istio, Linkerd (control avanzado de tráfico)
- **GitOps**: Flux, ArgoCD (sincronizar estado del cluster con git)
- **Operadores**: automatizar aplicaciones stateful complejas
- **Observabilidad**: Prometheus, Grafana, ELK (métricas, logs, trazas)

Kubernetes es amplio. Cada uno de estos temas puede ser una especialización completa. El viaje recién comienza.
