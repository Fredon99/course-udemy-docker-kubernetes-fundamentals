# Postgres com Volumes (Docker Compose)

Este diretório possui dois cenários de persistência para Postgres:

1. **Volume absoluto (bind em pasta local)**
2. **Volume nomeado com bind (`driver_opts`)**

## Pré-requisitos

- Docker e Docker Compose instalados
- Arquivo `.env` configurado (já existe neste projeto)

## Arquivos criados

- `start-absoluto.sh`
- `stop-absoluto.sh`
- `start-bind.sh`
- `stop-bind.sh`

## Como usar

No diretório deste projeto, execute:

### Cenário 1: Volume absoluto

Subir ambiente:

```bash
./start-absoluto.sh
```

Parar ambiente e remover volume (pasta `./psql_db`):

```bash
./stop-absoluto.sh
```

### Cenário 2: Volume nomeado + bind

Subir ambiente:

```bash
./start-bind.sh
```

Parar ambiente e remover volume Docker + pasta do bind (`./postgres_volume`):

```bash
./stop-bind.sh
```

## Observações

- No cenário bind, o `docker compose up` cria um volume `postgres_volume_03`, evitando conflito com outros diretórios.
- Os scripts de stop removem os dados persistidos para facilitar testes do zero.
- Se quiser manter os dados, remova as linhas de `rm -rf` dos scripts de stop.
