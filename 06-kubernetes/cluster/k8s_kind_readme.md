# Kubernetes com Kind — Explicação dos arquivos YAML

Este documento explica a estrutura dos arquivos YAML usados para criar um cluster Kubernetes local com Kind e um namespace dentro do Kubernetes.

---

# 1. `config.yaml`

Arquivo usado pelo **Kind** para criar um cluster Kubernetes local.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
  extraMounts:
    - hostPath: /home/fred/Documents/workspace/course-udemy-docker-kubernetes-fundamentals/06-kubernetes/hostdir
      containerPath: /mnt/hostdir
- role: worker
  extraMounts:
    - hostPath: /home/fred/Documents/workspace/course-udemy-docker-kubernetes-fundamentals/06-kubernetes/hostdir
      containerPath: /mnt/hostdir
```

## Para que serve?

Esse arquivo configura um cluster Kind com:

- 1 node `control-plane`
- 2 nodes `worker`
- montagem de um diretório da sua máquina dentro dos workers

---

## Campos principais

### `kind: Cluster`
Define o tipo de recurso que o Kind vai criar.

---

### `apiVersion: kind.x-k8s.io/v1alpha4`
Define a versão da API usada pelo Kind para interpretar esse arquivo.

---

### `nodes`
Define quais máquinas/nodes existirão dentro do cluster.

---

### `role: control-plane`
Node principal do cluster (API Server, Scheduler, etc).

---

### `role: worker`
Nodes que executam os workloads.

---

### `extraMounts`
Permite montar um diretório da sua máquina dentro do node.

---

### `hostPath`
Caminho na sua máquina local.

---

### `containerPath`
Caminho dentro do node do Kind.

---

# 2. `create_namespace.yaml`

Arquivo usado para criar um namespace no Kubernetes.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jokeapi
  labels:
    name: jokeapi
```

---

## Para que serve?

Cria um namespace chamado `jokeapi`.

---

## Campos principais

### `apiVersion: v1`
Versão da API Kubernetes.

---

### `kind: Namespace`
Tipo do recurso.

---

### `metadata`
Informações do recurso.

---

### `metadata.name`
Nome do namespace.

---

### `metadata.labels`
Labels para organização e filtro.

---

# Fluxo

```bash
kind create cluster --config config.yaml
kubectl apply -f create_namespace.yaml
kubectl get ns
```

---

# Resumo

- `apiVersion` → versão da API
- `kind` → tipo do recurso
- `metadata` → identificação
- `spec` → configuração (quando aplicável)
