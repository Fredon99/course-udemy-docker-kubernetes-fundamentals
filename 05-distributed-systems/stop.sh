#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Stopping application services (streamlit + data writer)..."
cd "$SCRIPT_DIR"
docker compose down

echo "==> Stopping ScyllaDB cluster..."
cd "$SCRIPT_DIR/scylla_cluster"
docker compose down -v

echo "==> Removing ScyllaDB data directories..."
rm -rf "$SCRIPT_DIR/scylla_cluster/scylla-node1-data"
rm -rf "$SCRIPT_DIR/scylla_cluster/scylla-node2-data"

echo "==> Environment is down."
