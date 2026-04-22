# PostgreSQL com Variáveis de Ambiente (Docker Compose)

Projeto demonstrando as duas formas de passar variáveis de ambiente para um container PostgreSQL com Docker Compose: hardcoded diretamente no arquivo e via arquivo `.env`.

## Stack

- PostgreSQL 17
- Docker Compose

## Estrutura

```text
02-postgres-env/
├── docker-compose-postgres-com-env.yaml   # Variáveis carregadas de arquivo .env
└── docker-compose-postgres-sem-env.yaml   # Variáveis definidas diretamente no compose
```

## Cenários

### Sem `.env` — variáveis hardcoded

O arquivo `docker-compose-postgres-sem-env.yaml` define as variáveis diretamente:

```yaml
environment:
  POSTGRES_USER: teste
  POSTGRES_PASSWORD: teste123
  POSTGRES_DB: container_db
```

Porta exposta: `5434`

### Com `.env` — variáveis externas

O arquivo `docker-compose-postgres-com-env.yaml` lê as variáveis de um arquivo `.env` na mesma pasta:

```yaml
environment:
  POSTGRES_USER: ${POSTGRES_USER}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  POSTGRES_DB: ${POSTGRES_DB}
```

Porta exposta: `5433`

Crie um arquivo `.env` com o seguinte conteúdo:

```env
POSTGRES_USER=teste
POSTGRES_PASSWORD=teste123
POSTGRES_DB=container_db
```

## Pré-requisitos

- Docker
- Docker Compose

## Como executar

### Cenário sem .env (variáveis hardcoded)

```bash
docker compose -f docker-compose-postgres-sem-env.yaml up -d
```

### Cenário com .env

```bash
docker compose -f docker-compose-postgres-com-env.yaml up -d
```

### Conectar ao banco

```bash
# Sem env (porta 5434)
psql -h localhost -p 5434 -U teste -d container_db

# Com env (porta 5433)
psql -h localhost -p 5433 -U teste -d container_db
```

### Parar os containers

```bash
docker compose -f docker-compose-postgres-sem-env.yaml down
docker compose -f docker-compose-postgres-com-env.yaml down
```

## Observações

- Usar um arquivo `.env` é a abordagem recomendada: evita expor credenciais no código e facilita trocar configurações por ambiente (dev, staging, prod).
- Nunca commite o arquivo `.env` com credenciais reais em repositórios públicos.
