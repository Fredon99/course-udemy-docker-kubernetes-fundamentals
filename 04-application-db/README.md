# Joke API com FastAPI e PostgreSQL

Projeto de exemplo com uma API em FastAPI que busca uma piada aleatoria no PostgreSQL usando Docker Compose.

## Stack

- Python 3.10
- FastAPI
- SQLAlchemy
- PostgreSQL 17
- Docker Compose

## Estrutura

```text
.
├── .env
├── docker-compose.yaml
├── postgres_init/
│   └── 01-init.sql
├── postgres_volume/
├── joke_api_python/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       └── main.py
└── run.sh
└── stop.sh
```

## O que o projeto faz

- Sobe um container PostgreSQL.
- Inicializa a tabela `jokes` e insere dados seed na primeira subida do banco.
- Sobe uma API FastAPI conectada ao banco.
- Expõe um endpoint para retornar uma piada aleatoria.

## Pre-requisitos

- Docker
- Docker Compose
- `curl`

## Variaveis de ambiente

As variaveis ficam no arquivo `.env`:

```env
POSTGRES_USER=teste
POSTGRES_PASSWORD=teste123
POSTGRES_DB=container_db
POSTGRES_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
```

## Como executar

### Subida normal

```bash
./run.sh
```

Esse script:

- sobe o PostgreSQL e a API
- recria o diretorio `postgres_volume/` se ele nao existir
- aguarda a API responder
- imprime a resposta do endpoint `/joke/`

### Reset completo do banco

```bash
./run.sh --reset-db
```

Use esse modo quando quiser:

- remover os dados persistidos do PostgreSQL
- recriar o banco do zero
- reaplicar o seed definido em `postgres_init/01-init.sql`

### Parar tudo e remover o volume do banco

```bash
./stop.sh
```

Esse script:

- derruba os containers e a rede do Compose
- remove o volume `postgres_volume_04`
- remove o diretorio `postgres_volume/` no host para garantir um banco vazio na proxima subida

## Seed do banco

O seed e executado pelo proprio container do PostgreSQL via `docker-entrypoint-initdb.d`.

Arquivo responsavel:

- `postgres_init/01-init.sql`

Esse SQL:

- cria a tabela `jokes`
- insere 3 piadas iniciais

Importante: esse seed automatico so roda quando o diretorio de dados do PostgreSQL esta vazio.

## Endpoints

### `GET /`

Retorna uma mensagem simples com a rota principal da API.

Exemplo:

```json
{
  "message": "Endpoint de piadas: /jokes/"
}
```

### `GET /joke/`

Retorna uma piada aleatoria vinda da tabela `jokes`.

Exemplo:

```json
{
  "joke": "O que o pato falou para a pata? Vem qua."
}
```

## Portas

- API: `http://localhost:8000`
- PostgreSQL no host: `localhost:5435`

## Observacoes tecnicas

- O servico `joke-api-python` espera o PostgreSQL ficar saudavel antes de iniciar.
- A conexao com o banco e aberta por requisicao no endpoint `/joke/`.
- O codigo trata cenarios como tabela ausente, banco indisponivel e tabela vazia.

## Comandos uteis

### Ver logs

```bash
docker compose logs -f
```

### Ver logs so da API

```bash
docker compose logs -f joke-api-python
```

### Ver logs so do banco

```bash
docker compose logs -f postgres
```

### Derrubar os containers

```bash
docker compose down
```

### Parar tudo e remover o volume do banco

```bash
./stop.sh
```

## Possiveis problemas

### Seed nao foi reaplicado

Se o banco ja tinha dados persistidos, o script de inicializacao do PostgreSQL nao roda de novo. Nesse caso, use:

```bash
./run.sh --reset-db
```

### API subiu, mas o endpoint ainda falhou na primeira tentativa

O `run.sh` faz retry automatico do `curl` durante a validacao inicial. Isso cobre o pequeno intervalo em que a API terminou de subir, mas ainda nao estava pronta para responder a primeira conexao.