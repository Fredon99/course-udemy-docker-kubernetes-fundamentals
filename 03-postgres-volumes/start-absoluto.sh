#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose-postgres-volume-absoluto.yaml"
VOLUME_DIR="./psql_db"

mkdir -p "$VOLUME_DIR"

echo "Subindo stack com volume absoluto (bind em $VOLUME_DIR)..."
docker compose -f "$COMPOSE_FILE" up -d --build

echo "Container em execução."
