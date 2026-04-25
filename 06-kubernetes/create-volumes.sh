#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTDIR="$SCRIPT_DIR/hostdir/postgresql"

echo "Criando diretório de volume para o PersistentVolume do PostgreSQL..."
mkdir -p "$HOSTDIR"
echo "Diretório criado: $HOSTDIR"
