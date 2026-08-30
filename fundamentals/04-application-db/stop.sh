#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$ROOT_DIR"

echo "Parando containers e removendo o volume do Postgres..."
docker compose down -v --remove-orphans

echo "Removendo pasta postgres_volume/..."
rm -rf "$ROOT_DIR/postgres_volume"

echo "Ambiente parado e volume do Postgres removido."