# Kubernetes API Setup — Explicação dos YAMLs

Este documento explica os arquivos da API da aplicação.

---

# 1. api_deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: jokeapi
  name: joke-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: joke-api
  template:
    metadata:
      labels:
        app: joke-api
    spec:
      containers:
        - name: joke-api
          image: gabrielrichter/joke_api_python:2
          imagePullPolicy: IfNotPresent
          env:
          - name: POSTGRES_URL
            value: postgresql://admin123:admin123@joke-database-svc/prod
          ports:
            - containerPort: 8000
```

## O que é?

Um Deployment que sobe sua API dentro do cluster.

---

## Pontos principais

### apiVersion: apps/v1
Usado para Deployments.

### kind: Deployment
Gerencia Pods e réplicas.

---

### metadata

Define nome e namespace.

---

### spec.replicas

Quantidade de instâncias da API.

---

### selector + labels

Conectam Deployment com Pods.

---

### template

Define como o Pod será criado.

---

### containers

Define o container da API:

- image → imagem Docker da aplicação
- ports → porta exposta
- env → variáveis de ambiente

---

# 2. api_service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: jokeapi
  name: joke-api-svc
  labels:
    app: joke-api
spec:
  type: NodePort
  ports:
    - port: 8000
  selector:
    app: joke-api
```

## O que é?

Um Service que expõe sua API.

---

## Pontos principais

### kind: Service
Permite comunicação com Pods.

---

### type

Pode ser:

- ClusterIP (interno)
- NodePort (externo via node)
- LoadBalancer (cloud)

---

### selector

Liga o Service aos Pods da API.

---

### ports

Define como acessar a API.

---

# Fluxo completo

```text
Deployment → cria Pods da API
Service → expõe a API
Cliente → acessa via Service
```

---

# Integração com banco

```text
API Pod → Service DB → Pod PostgreSQL → PV (disco)
```

---

# Resumo mental

- Deployment → sobe API
- Service → expõe API
- Labels → conectam tudo
