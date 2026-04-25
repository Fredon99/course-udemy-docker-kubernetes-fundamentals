# Kubernetes Job — Request New Joke

---

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: job-request-joke
  namespace: jokeapi
spec:
  schedule: "* * * * *"
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: job-request-joke
            image: gabrielrichter/api_joke_request_to_postgres:1
            imagePullPolicy: IfNotPresent
            env:
            - name: POSTGRES_URL
              value: postgresql://admin123:admin123@joke-database-svc/prod
          restartPolicy: OnFailure
```

---

## O que é?

Esse arquivo define um **Job** no Kubernetes.

Jobs são usados para executar tarefas **pontuais** (batch), diferente de Deployments que ficam rodando continuamente.

---

## Estrutura explicada

### apiVersion
Define a versão da API usada para Jobs:

```yaml
apiVersion: batch/v1
```

---

### kind: Job
Indica que o recurso é um Job.

---

### metadata

Define informações como:

- nome do job
- namespace

---

### spec

Define como o Job vai rodar.

---

### template

Define o Pod que será executado pelo Job.

---

### containers

Aqui está o container que executa a tarefa.

Geralmente usado para:

- chamar uma API
- rodar script
- processar dados

---

### restartPolicy

```yaml
restartPolicy: Never
```

Significa:

- não reiniciar o container automaticamente
- se falhar, o Job falha

---

## Fluxo mental

```text
Job criado
   ↓
Kubernetes cria um Pod
   ↓
Container executa tarefa
   ↓
Finaliza (sucesso ou erro)
```

---

## Quando usar Job?

- Scripts únicos
- Migração de banco
- Batch processing
- Chamadas pontuais (ex: gerar nova piada 😄)

---

## Diferença vs Deployment

| Deployment | Job |
|----------|------|
| Sempre rodando | Executa e termina |
| Apps web | Tarefas batch |
| Escala contínua | Execução única |

---

## Comando

```bash
kubectl apply -f job_request_new_joke.yaml
```

---

## Ver execução

```bash
kubectl get jobs
kubectl get pods
kubectl logs <pod-do-job>
```
