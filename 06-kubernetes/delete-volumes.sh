#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOSTDIR="$SCRIPT_DIR/hostdir"

if [[ -d "$HOSTDIR" ]]; then
    echo "Removendo diretório de volume: $HOSTDIR"
    rm -rf "$HOSTDIR"
    echo "Diretório removido."
else
    echo "Diretório não encontrado, nada a remover: $HOSTDIR"
fi
