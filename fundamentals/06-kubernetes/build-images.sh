#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLUSTER_NAME="${1:-jokeapi-cluster}"

echo "==> Usando cluster kind: '$CLUSTER_NAME' (use './build-images.sh <nome>' para outro cluster)"

echo "==> Building joke-api-python:k8s..."
docker build -t joke-api-python:k8s "$SCRIPT_DIR/api"

echo "==> Building joke-job-request:k8s..."
docker build -t joke-job-request:k8s "$SCRIPT_DIR/job"

echo "==> Loading images into kind cluster '$CLUSTER_NAME'..."
kind load docker-image joke-api-python:k8s --name "$CLUSTER_NAME"
kind load docker-image joke-job-request:k8s --name "$CLUSTER_NAME"

echo "==> Imagens disponiveis no cluster:"
docker exec "${CLUSTER_NAME}-worker" crictl images 2>/dev/null | grep -E "joke|IMAGE" || true

echo "==> Pronto. Use 'kubectl rollout restart deployment -n jokeapi' para recarregar os pods se o cluster ja estiver rodando."
