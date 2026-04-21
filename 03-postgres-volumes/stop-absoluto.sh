#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose-postgres-volume-absoluto.yaml"
VOLUME_DIR="./psql_db"

echo "Parando stack do volume absoluto..."
docker compose -f "$COMPOSE_FILE" down

if [[ -d "$VOLUME_DIR" ]]; then
  rm -rf "$VOLUME_DIR"
  echo "Volume removido: $VOLUME_DIR"
else
  echo "Volume já não existia: $VOLUME_DIR"
fi
