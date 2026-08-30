# Kubernetes Database Setup — Explicação dos YAMLs

Este documento explica os arquivos relacionados ao banco PostgreSQL no Kubernetes.

---

# 1. database_deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: jokeapi
  name: joke-database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: joke-database
  template:
    metadata:
      labels:
        app: joke-database
    spec:
      volumes:
      - name: joke-pv-data
        persistentVolumeClaim:
          claimName: postgres-pvc
      containers:
        - name: postgres
          image: 'postgres:16'
          imagePullPolicy: IfNotPresent
          env:
          - name: POSTGRES_USER
            value: admin123
          - name: POSTGRES_PASSWORD
            value: admin123
          - name: POSTGRES_DB
            value: prod
          ports:
            - containerPort: 5432
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: joke-pv-data
```

## O que é?

Um **Deployment** gerencia Pods e garante que eles estejam sempre rodando.

---

## Pontos principais

### apiVersion: apps/v1
Usado para recursos de alto nível como Deployment.

### kind: Deployment
Define que queremos gerenciar Pods com replicação.

### metadata.namespace
Define onde será criado (`jokeapi`).

### spec.replicas
Quantidade de Pods:

```yaml
replicas: 1
```

---

### selector + labels

```yaml
selector:
  matchLabels:
    app: joke-database
```

Conecta Deployment com os Pods.

---

### template

Define o Pod que será criado.

---

### containers

```yaml
image: postgres:16
```

Container PostgreSQL.

---

### env

Variáveis de ambiente do banco:

- POSTGRES_USER
- POSTGRES_PASSWORD
- POSTGRES_DB

---

### volumes + volumeMounts

Conecta armazenamento persistente ao container:

```text
PVC → Volume → Container
```

---

# 2. database_pv_pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: jokeapi
  name: postgres-pv
  labels:
    type: local
    app: joke-database
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /mnt/hostdir/postgresql

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: jokeapi
  name: postgres-pvc
  labels:
    app: joke-database
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

## O que é?

Define armazenamento persistente.

---

## PersistentVolume (PV)

Representa o disco físico.

### hostPath

```yaml
path: /mnt/hostdir/postgresql
```

Diretório na máquina local (Kind).

---

### capacity

```yaml
storage: 1Gi
```

---

### accessModes

```yaml
ReadWriteMany
```

Permite múltiplos Pods acessarem.

---

## PersistentVolumeClaim (PVC)

É o pedido de armazenamento.

```text
Pod → PVC → PV
```

---

# 3. database_service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: jokeapi
  name: joke-database-svc
  labels:
    app: joke-database
spec:
  type: NodePort
  ports:
    - port: 5432
  selector:
    app: joke-database
```

## O que é?

Expõe o banco dentro/fora do cluster.

---

## type: NodePort

Permite acessar via porta do node.

---

## selector

```yaml
app: joke-database
```

Liga o Service ao Pod.

---

## ports

```yaml
port: 5432
```

Porta do PostgreSQL.

---

# Fluxo completo

```text
Deployment → cria Pod
Pod → usa PVC
PVC → conecta no PV
Service → expõe o Pod
```

---

# Resumo mental

- Deployment → cria containers
- PV → disco
- PVC → pedido de disco
- Service → acesso ao Pod
