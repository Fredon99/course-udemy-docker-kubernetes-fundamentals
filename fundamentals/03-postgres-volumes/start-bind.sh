#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose-postgres-volume-bind.yaml"
VOLUME_DIR="$(pwd)/postgres_volume"

mkdir -p "$VOLUME_DIR"

echo "Subindo stack com volume bind..."
docker compose -f "$COMPOSE_FILE" up -d --build

echo "Container em execução."
