# Udemy — Docker & Kubernetes

Monorepo com material prático de três cursos da Udemy. Cada pasta é independente, com exercícios numerados e README próprio.

## Cursos

| Pasta | Foco | Descrição |
|-------|------|-----------|
| [`fundamentals/`](fundamentals/) | Docker + Kubernetes (intro) | Progressão do container simples até deploy completo com kind |
| [`docker/`](docker/) | Docker (aprofundado) | Chroot, builds, Compose, Swarm, segurança e documentação |
| [`kubernetes/`](kubernetes/) | Kubernetes (aprofundado) | Provisioning (kind/kubeadm), YAML e workloads _(em construção)_ |

## Ordem sugerida

```text
fundamentals/     → visão geral integrada (Docker → Compose → K8s básico)
       ↓
docker/           → aprofundamento em containers, orquestração Swarm e segurança
       ↓
kubernetes/       → cluster real, manifests e operação de workloads
```

Os cursos podem ser feitos de forma independente se você já dominar os pré-requisitos de cada um.

## Pré-requisitos gerais

| Ferramenta | Onde é usada |
|------------|--------------|
| [Docker Engine](https://docs.docker.com/get-docker/) | `fundamentals/`, `docker/` |
| [Docker Compose v2](https://docs.docker.com/compose/) | `fundamentals/`, `docker/` |
| [kind](https://kind.sigs.k8s.io/) + [kubectl](https://kubernetes.io/docs/tasks/tools/) | `fundamentals/06-kubernetes`, `kubernetes/` |
| [Vagrant](https://www.vagrantup.com/) + [VirtualBox](https://www.virtualbox.org/) | `docker/` (Swarm), `kubernetes/` (kubeadm) |

## Como navegar

```bash
# Curso introdutório — começar pelo módulo 01
cd fundamentals/01-application && cat README.md

# Curso de Docker — chroot e isolamento Linux
cd docker/01-chroot_scripts && cat README.md

# Curso de Kubernetes — provisionar cluster
cd kubernetes/01-provisioning/kubeadm && cat README.md
```

## Licença

Material de estudo pessoal — use livremente para aprendizado.
