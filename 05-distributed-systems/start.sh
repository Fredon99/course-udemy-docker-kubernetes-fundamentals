#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRITER_REPLICAS="${1:-1}"

echo "==> Cleaning up any previous ScyllaDB state..."
cd "$SCRIPT_DIR/scylla_cluster"
docker compose down -v 2>/dev/null || true
rm -rf "$SCRIPT_DIR/scylla_cluster/scylla-node1-data"
rm -rf "$SCRIPT_DIR/scylla_cluster/scylla-node2-data"

echo "==> Creating ScyllaDB data directories..."
mkdir -p "$SCRIPT_DIR/scylla_cluster/scylla-node1-data"
mkdir -p "$SCRIPT_DIR/scylla_cluster/scylla-node2-data"

echo "==> Starting ScyllaDB cluster..."
cd "$SCRIPT_DIR/scylla_cluster"
docker compose up -d

echo "==> Waiting for ScyllaDB nodes to be ready (nodetool status: UN)..."
RETRIES=40
INTERVAL=10
for i in $(seq 1 $RETRIES); do
    UN_COUNT=$(docker exec scylla-node1 nodetool status 2>/dev/null | grep -c "^UN" || true)
    if [ "$UN_COUNT" -ge 2 ]; then
        echo "    ScyllaDB cluster ready: $UN_COUNT nodes reporting UN."
        break
    fi
    echo "    Attempt $i/$RETRIES: $UN_COUNT node(s) ready. Retrying in ${INTERVAL}s..."
    sleep $INTERVAL
    if [ "$i" -eq "$RETRIES" ]; then
        echo "ERROR: ScyllaDB cluster did not become ready within $((RETRIES * INTERVAL))s. Aborting."
        exit 1
    fi
done

echo "==> Starting application services (streamlit + data writer x${WRITER_REPLICAS})..."
cd "$SCRIPT_DIR"
docker compose up -d --build --scale python_data_writer="$WRITER_REPLICAS"

echo "==> Waiting for Streamlit to be ready..."
STREAMLIT_RETRIES=20
for i in $(seq 1 $STREAMLIT_RETRIES); do
    STREAMLIT_LOG=$(docker compose logs streamlit_app 2>/dev/null)
    if echo "$STREAMLIT_LOG" | grep -q "Local URL"; then
        echo ""
        echo "$STREAMLIT_LOG" | grep -E "Local URL|Network URL|External URL"
        echo ""
        break
    fi
    sleep 2
    if [ "$i" -eq "$STREAMLIT_RETRIES" ]; then
        echo "    Streamlit did not report URLs within expected time. Check: docker compose logs streamlit_app"
    fi
done

echo "==> Environment is up."
