# Curso Kubernetes — Udemy

Material prático de Kubernetes: provisionamento de clusters (kind e kubeadm), manifests YAML e workloads. _(Em construção — novos módulos serão adicionados conforme o curso avança.)_

> Parte do monorepo [Udemy — Docker & Kubernetes](../README.md). Para bases de Docker e um deploy introdutório com kind, veja [`fundamentals/`](../fundamentals/) (módulo 06).

## Pré-requisitos

| Requisito | Módulos |
|-----------|---------|
| [Docker Engine](https://docs.docker.com/engine/install/) | kind |
| [kind](https://kind.sigs.k8s.io/) + [kubectl](https://kubernetes.io/docs/tasks/tools/) | kind, kubeadm |
| [Vagrant](https://www.vagrantup.com/) + [VirtualBox](https://www.virtualbox.org/) (~6 GB RAM) | kubeadm |
| Conhecimento básico de Docker e YAML | todos |

## Estrutura do repositório

| Pasta | Tema | Documentação |
|-------|------|--------------|
| [`01-provisioning/kind`](01-provisioning/kind/) | Cluster local com kind (multi-node, port mappings) | config em `config.yaml` |
| [`01-provisioning/kubeadm`](01-provisioning/kubeadm/) | Cluster kubeadm com Vagrant (1 master + 2 workers, Flannel) | [README](01-provisioning/kubeadm/README.md) |
| [`02-yaml`](02-yaml/) | Manifests YAML básicos | `pod.yaml` |
| [`03-namespace`](03-namespace/) | Namespaces _(em construção)_ | — |
| [`04-pod`](04-pod/) | Pods em detalhe _(em construção)_ | — |

### Documentação

Diagramas de arquitetura em [`docs/assets/`](docs/assets/):

- `01-kubernetes-architecture.png` — visão geral da arquitetura
- `02-detailed-data-plane.png` — data plane detalhado

## Ordem sugerida

```text
01-provisioning/kind          → cluster rápido para testes locais
        ↓
01-provisioning/kubeadm       → cluster “de produção” com VMs
        ↓
02-yaml                       → manifests e recursos básicos
        ↓
03-namespace                  → isolamento lógico com Namespaces
        ↓
04-pod                        → Pods, containers e ciclo de vida
        ↓
(módulos futuros)             → Deployments, Services, Ingress, etc.
```

## Quick start — kind

```bash
kind create cluster --config kubernetes/01-provisioning/kind/config.yaml
kubectl cluster-info --context kind-kind
kubectl get nodes
```

## Quick start — kubeadm (Vagrant)

```bash
cd kubernetes/01-provisioning/kubeadm
vagrant up
vagrant ssh master-1
kubectl get nodes -o wide
```

→ Detalhes, troubleshooting e IPs fixos: [01-provisioning/kubeadm/README.md](01-provisioning/kubeadm/README.md)

## Relação com `fundamentals/06-kubernetes`

O módulo [`fundamentals/06-kubernetes`](../fundamentals/06-kubernetes/) aplica a Joke API (FastAPI + PostgreSQL) em um cluster kind com PV, Services e CronJob — um projeto integrado de ponta a ponta.

Este curso (`kubernetes/`) foca em conceitos e operação de cluster de forma mais ampla, com provisionamento real via kubeadm e exercícios incrementais de YAML.

## Licença

Material de estudo pessoal — use livremente para aprendizado.
