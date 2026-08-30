# Docker & Kubernetes — Fundamentos

Curso introdutório com progressão prática: cada módulo evolui sobre o anterior, partindo de um container simples até uma implantação completa em Kubernetes com kind.

> Parte do monorepo [Udemy — Docker & Kubernetes](../README.md). Para aprofundamento, veja [`docker/`](../docker/) e [`kubernetes/`](../kubernetes/).

## Módulos

| # | Pasta | Tecnologias | Descrição |
|---|-------|-------------|-----------|
| 01 | [`01-application`](01-application/) | Docker, FastAPI | API de piadas containerizada com hot-reload |
| 02 | [`02-postgres-env`](02-postgres-env/) | Docker, PostgreSQL | Variáveis de ambiente: hardcoded vs arquivo `.env` |
| 03 | [`03-postgres-volumes`](03-postgres-volumes/) | Docker, PostgreSQL | Persistência: volume absoluto vs bind mount |
| 04 | [`04-application-db`](04-application-db/) | Docker Compose, FastAPI, PostgreSQL | API integrada ao banco com seed e scripts de reset |
| 05 | [`05-distributed-systems`](05-distributed-systems/) | Docker Compose, ScyllaDB, Python, Streamlit | Sistema distribuído com dashboard em tempo real |
| 06 | [`06-kubernetes`](06-kubernetes/) | Kubernetes (kind), FastAPI, PostgreSQL | Deploy completo com PV, CronJob e Services |

## Evolução dos conceitos

```text
[01] Container simples
        ↓
[02] Configuração via variáveis de ambiente
        ↓
[03] Persistência com volumes Docker
        ↓
[04] Multi-container com Docker Compose + banco de dados
        ↓
[05] Sistema distribuído multi-serviço
        ↓
[06] Orquestração com Kubernetes (local — kind)
```

## Detalhes de cada módulo

### 01 — Joke API com FastAPI

API REST simples que retorna piadas aleatórias de uma lista em memória. Foco em: Dockerfile, build de imagem, Docker Compose com bind mount para hot-reload.

→ [README](01-application/README.md)

### 02 — PostgreSQL com Variáveis de Ambiente

Dois compose files mostrando a diferença entre declarar variáveis diretamente no YAML (`sem-env`) versus carregá-las de um arquivo `.env` (`com-env`).

→ [README](02-postgres-env/README.md)

### 03 — PostgreSQL com Volumes

Dois cenários de persistência: volume absoluto (pasta local) e volume nomeado com bind (`driver_opts`). Inclui scripts `start`/`stop` com limpeza de dados.

→ [README](03-postgres-volumes/README.md)

### 04 — Joke API com Banco de Dados

Versão evoluída da API com FastAPI + PostgreSQL via Docker Compose. Seed SQL na inicialização e scripts para reset completo do ambiente.

→ [README](04-application-db/README.md)

### 05 — Sistema Distribuído (Minecraft Event Tracking)

Rastreamento de sessões de jogadores em tempo real com ScyllaDB (cluster 2 nós), gerador de eventos Python e dashboard Streamlit.

→ [README](05-distributed-systems/README.md)

### 06 — Kubernetes (kind)

Deploy completo da Joke API no Kubernetes local. Namespace, Deployments, Services, PV/PVC com `hostPath` e CronJob que busca piadas externas a cada minuto.

→ [README](06-kubernetes/README.md)

## Pré-requisitos

| Ferramenta | Módulos |
|------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | 01–06 |
| [Docker Compose](https://docs.docker.com/compose/) | 01–05 |
| [kind](https://kind.sigs.k8s.io/) | 06 |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 06 |

## Como navegar

Cada pasta possui seu próprio `README.md` com instruções detalhadas. Recomenda-se seguir a ordem numérica.

```bash
cd fundamentals/01-application && cat README.md
```
