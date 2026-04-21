#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$ROOT_DIR"

if [[ "${1:-}" == "--reset-db" ]]; then
  echo "Resetando containers e limpando dados do Postgres..."
  docker compose down
  mkdir -p "$ROOT_DIR/postgres_volume"
  docker run --rm \
    -v "$ROOT_DIR/postgres_volume:/target" \
    alpine:3.20 \
    sh -c 'rm -rf /target/* /target/.[!.]* /target/..?*'
fi

mkdir -p "$ROOT_DIR/postgres_volume"

echo "Subindo Postgres e API..."
docker compose up --build -d

echo "Servicos iniciados."
echo "API: http://localhost:8000/joke/"
echo "Validando endpoint..."

for attempt in {1..20}; do
  if response="$(curl -fsS http://localhost:8000/joke/)"; then
    echo "Resposta da API: $response"
    break
  fi

  if [[ "$attempt" -eq 20 ]]; then
    echo "Falha ao validar a API em http://localhost:8000/joke/."
    exit 1
  fi

  sleep 1
done

echo "Use './run.sh --reset-db' para recriar o banco e reaplicar o seed."