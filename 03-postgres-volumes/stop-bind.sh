#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose-postgres-volume-bind.yaml"
VOLUME_DIR="./postgres_volume"

echo "Parando stack do volume bind..."
docker compose -f "$COMPOSE_FILE" down -v

if [[ -d "$VOLUME_DIR" ]]; then
  rm -rf "$VOLUME_DIR"
  echo "Diretório do bind removido: $VOLUME_DIR"
fi
