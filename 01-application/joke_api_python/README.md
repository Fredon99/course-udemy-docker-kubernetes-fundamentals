# Joke API Python

API simples de piadas com FastAPI, pronta para subir com Docker Compose na porta 8000.

## Requisitos

- Docker
- Docker Compose

## Como executar

No diretório do projeto, rode:

```bash
docker compose up --build
```

Esse comando faz o build (se necessário) e já sobe o container, sem precisar rodar `docker build` e `docker run` separadamente.

A API ficará disponível em:

- http://localhost:8000/
- http://localhost:8000/joke/

## Rodar em segundo plano

```bash
docker compose up --build -d
```

## Parar a aplicação

```bash
docker compose down
```

## Observação

O volume ./src:/app já está configurado no docker-compose.yml, junto com o comando fastapi dev. Assim, alterações no código em src/main.py são recarregadas automaticamente, sem rebuild da imagem.
