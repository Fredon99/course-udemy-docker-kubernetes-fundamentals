# Documentação

Material de apoio ao [curso Docker](../README.md). Os exercícios práticos ficam nas pastas numeradas na raiz do repositório; aqui ficam os conceitos transversais e recursos de referência.

## Fundamentos

Base teórica sobre como containers funcionam no Linux:

| Documento | Conteúdo |
|-----------|----------|
| [containers-linux.md](fundamentos/containers-linux.md) | Namespaces, cgroups, chroot vs container, relação com Kubernetes |
| [redes-linux-docker.md](fundamentos/redes-linux-docker.md) | veth, docker0, NAT, inspeção de rede, comunicação entre containers |

## Guias práticos

| Documento | Relacionado a |
|-----------|---------------|
| [healthcheck.md](guias/healthcheck.md) | [05-build-node-healthcheck](../05-build-node-healthcheck/), [06-build-python-healthcheck](../06-build-python-healthcheck/), [10-docker-compose-ghost](../10-docker-compose-ghost/) |
| [swarm-cluster-setup.md](guias/swarm-cluster-setup.md) | [11-docker-swarm](../11-docker-swarm/), [12-docker-swarm-ha-proxy](../12-docker-swarm-ha-proxy/), [13-docker-swarm-dns](../13-docker-swarm-dns/) |

## Documentação nos módulos

Alguns tópicos ficam junto do código que os demonstra:

| Módulo | Documento |
|--------|-----------|
| [04-build-node-entrypoint](../04-build-node-entrypoint/) | CMD, ENTRYPOINT e histórico de comandos Docker |
| [08-restart-policies](../08-restart-policies/) | Restart policies — guia completo com exemplos |
| [09-docker-compose](../09-docker-compose/) | Compose básico — múltiplos serviços |
| [10-docker-compose-ghost](../10-docker-compose-ghost/) | Ghost + MySQL — healthcheck e `service_healthy` |
| [11-docker-swarm](../11-docker-swarm/) | Swarm com Vagrant — arquitetura, portas e `DOCKER_HOST` |
| [12-docker-swarm-ha-proxy](../12-docker-swarm-ha-proxy/) | VIP vs DNSRR, HAProxy global e balanceamento |
| [13-docker-swarm-dns](../13-docker-swarm-dns/) | BIND9, DNS round robin e nginx via routing mesh |

## Recursos

| Arquivo | Descrição |
|---------|-----------|
| [docker_annotations.pdf](recursos/docker_annotations.pdf) | Anotações do curso em PDF |
| [Docker.xopp](recursos/Docker.xopp) | Mapa mental / anotações no Xournal++ |