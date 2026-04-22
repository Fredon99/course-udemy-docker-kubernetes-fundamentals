# Docker & Kubernetes Fundamentals

Repositório do curso prático de Docker e Kubernetes. Cada pasta é um projeto independente que evolui sobre os conceitos do anterior, partindo de um container simples até uma implantação completa em Kubernetes.

## Projetos

| # | Pasta | Tecnologias | Descrição |
|---|---|---|---|
| 01 | `01-application` | Docker, FastAPI | API de piadas containerizada com hot-reload |
| 02 | `02-postgres-env` | Docker, PostgreSQL | Variáveis de ambiente: hardcoded vs arquivo `.env` |
| 03 | `03-postgres-volumes` | Docker, PostgreSQL | Persistência de dados: volume absoluto vs bind mount |
| 04 | `04-application-db` | Docker Compose, FastAPI, PostgreSQL | API integrada ao banco com seed e scripts de reset |
| 05 | `05-distributed-systems` | Docker Compose, ScyllaDB, Python, Streamlit | Sistema distribuído com ScyllaDB e dashboard em tempo real |
| 06 | `06-kubernetes` | Kubernetes (kind), FastAPI, PostgreSQL | Deploy completo no Kubernetes com PV, CronJob e Services |
| 07 | `07-kubernetes_AWS` | Kubernetes, AWS | Deploy em cluster Kubernetes na AWS _(em construção)_ |

---

## Evolução dos conceitos

```
[01] Container simples
        │
        ▼
[02] Configuração via variáveis de ambiente
        │
        ▼
[03] Persistência com volumes Docker
        │
        ▼
[04] Multi-container com Docker Compose + banco de dados
        │
        ▼
[05] Sistema distribuído multi-serviço
        │
        ▼
[06] Orquestração com Kubernetes (local - kind)
        │
        ▼
[07] Kubernetes na nuvem (AWS)
```

---

## Detalhes de cada projeto

### 01 — Joke API com FastAPI

API REST simples que retorna piadas aleatórias de uma lista em memória. Foco em: Dockerfile, build de imagem, Docker Compose com bind mount para hot-reload.

→ [README](01-application/README.md)

---

### 02 — PostgreSQL com Variáveis de Ambiente

Dois compose files mostrando a diferença entre declarar variáveis de ambiente diretamente no YAML (`sem-env`) versus carregá-las de um arquivo `.env` (`com-env`).

→ [README](02-postgres-env/README.md)

---

### 03 — PostgreSQL com Volumes

Dois cenários de persistência para o PostgreSQL:
- **Volume absoluto**: pasta local mapeada diretamente
- **Volume nomeado com bind**: volume Docker com `driver_opts`

Inclui scripts `start` e `stop` com limpeza de dados para facilitar testes.

→ [README](03-postgres-volumes/README.md)

---

### 04 — Joke API com Banco de Dados

Versão evoluída da API com FastAPI + PostgreSQL via Docker Compose. O banco é inicializado com um seed SQL e a API lê as piadas do banco. Inclui scripts para reset completo do ambiente.

→ [README](04-application-db/README.md)

---

### 05 — Sistema Distribuído (Minecraft Event Tracking)

Sistema de rastreamento de sessões de jogadores de Minecraft em tempo real:
- **ScyllaDB** (cluster de 2 nós) como banco de dados de alta performance
- **python_data_writer**: gerador de eventos sintéticos com 3 threads concorrentes
- **Streamlit**: dashboard ao vivo com métricas atualizadas a cada 5 segundos

→ [README](05-distributed-systems/README.md)

---

### 06 — Kubernetes (kind)

Deploy completo da Joke API no Kubernetes local com kind. Demonstra:
- Criação de cluster multi-node com `extraMounts`
- Namespace, Deployments, Services (NodePort e ClusterIP)
- PersistentVolume + PersistentVolumeClaim com `hostPath`
- CronJob que busca piadas externas e grava no banco a cada minuto

→ [README](06-kubernetes/README.md)

---

### 07 — Kubernetes na AWS _(em construção)_

Extensão do projeto Kubernetes para um cluster gerenciado na AWS (EKS ou similar).

---

## Pré-requisitos gerais

| Ferramenta | Projetos |
|---|---|
| [Docker](https://docs.docker.com/get-docker/) | 01 ao 06 |
| [Docker Compose](https://docs.docker.com/compose/) | 01 ao 05 |
| [kind](https://kind.sigs.k8s.io/) | 06 |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 06 |

## Como navegar

Cada pasta possui seu próprio `README.md` com instruções detalhadas de como executar o projeto. Recomenda-se seguir a ordem numérica para acompanhar a progressão dos conceitos.

```bash
cd 01-application && cat README.md
```
