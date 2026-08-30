# Joke API com FastAPI (Docker Compose)

Projeto inicial da série, demonstrando como containerizar uma API Python simples com FastAPI usando Docker e Docker Compose.

## Stack

- Python 3.10
- FastAPI
- Docker Compose

## Estrutura

```text
01-application/
├── docker-compose.yml
└── joke_api_python/
    ├── Dockerfile
    ├── requirements.txt
    └── src/
        └── main.py
```

## O que o projeto faz

- Sobe uma API FastAPI dentro de um container Docker.
- Expõe dois endpoints:
  - `GET /` — mensagem de boas-vindas
  - `GET /joke/` — retorna uma piada aleatória (lista fixa em memória)
- Usa um bind mount no diretório `src/` para hot-reload durante o desenvolvimento.

## Pré-requisitos

- Docker
- Docker Compose

## Como executar

### Build e subida do container

```bash
docker compose up --build
```

A API ficará disponível em: [http://localhost:8000](http://localhost:8000)

### Acessar os endpoints

```bash
# Endpoint raiz
curl http://localhost:8000/

# Endpoint de piadas
curl http://localhost:8000/joke/
```

### Documentação interativa (Swagger)

Acesse [http://localhost:8000/docs](http://localhost:8000/docs) no navegador.

### Parar o container

```bash
docker compose down
```

## Observações

- A flag `restart: unless-stopped` garante que o container suba automaticamente se o Docker reiniciar.
- O volume `./joke_api_python/src:/app` permite editar o código sem precisar rebuildar a imagem.
