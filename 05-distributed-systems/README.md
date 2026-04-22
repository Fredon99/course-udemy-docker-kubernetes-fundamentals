# Distributed Systems - Minecraft Event Tracking

A distributed system that simulates real-time Minecraft player session tracking. It combines a ScyllaDB cluster for high-throughput writes, a Python service that continuously generates and inserts synthetic game events, and a Streamlit dashboard for live visualization.

---

## Architecture

```
                        +---------------------------+
                        |     ScyllaDB Cluster      |
                        |                           |
                        |  scylla-node1 (seed)      |
                        |  scylla-node2 (seed)      |
                        |                           |
                        |  Network: scylla-net      |
                        |  Keyspace: eventdb        |
                        |  Table: eventdb.events    |
                        +------------^--------------+
                                     |
              +----------------------+----------------------+
              |                                             |
+-------------+-----------+               +----------------+-----------+
|   python_data_writer    |               |      streamlit_app         |
|                         |               |                            |
|  Generates synthetic    |               |  Reads events from         |
|  player session events  |               |  ScyllaDB every 5s and     |
|  (connected, login,     |               |  renders live metrics:     |
|   disconnected) and     |               |  - Online players          |
|  inserts into ScyllaDB  |               |  - Event counts            |
|  using 3 threads        |               |  - Last login time         |
+-------------------------+               +----------------------------+
```

### Data Flow

1. `python_data_writer` generates player session events at random intervals using three concurrent threads.
2. Each event is inserted into the `eventdb.events` table in the ScyllaDB cluster.
3. `streamlit_app` queries the last 4 hours of events every 5 seconds and displays live metrics on a web dashboard.

---

## Services

| Service | Description | Tech |
|---|---|---|
| scylla-node1 | Primary ScyllaDB node (seed) | ScyllaDB 5.2 |
| scylla-node2 | Secondary ScyllaDB node (seed) | ScyllaDB 5.2 |
| python_data_writer | Generates and writes synthetic game events | Python 3.10, cassandra-driver |
| streamlit_app | Live dashboard for event visualization | Python 3.10, Streamlit, Plotly |

### ScyllaDB Schema

```cql
CREATE KEYSPACE IF NOT EXISTS eventdb
  WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 2 };

CREATE TABLE IF NOT EXISTS eventdb.events (
  id         varchar,
  parent_id  varchar,
  timestamp  timestamp,
  action     varchar,
  event_date timestamp,
  PRIMARY KEY (id, parent_id, action, timestamp)
);
```

### Event Types

| Action | Meaning |
|---|---|
| connected | Player connected to the server |
| login success | Player authenticated successfully |
| login fail | Player failed authentication |
| disconnected | Player left the server |

---

## Project Structure

```
05-distributed-systems/
├── docker-compose.yaml          # App services (streamlit + data writer)
├── start.sh                     # Brings up the full environment in order
├── stop.sh                      # Tears down all services
├── python_data_writer/
│   ├── data_gen.py              # Event generator and ScyllaDB writer
│   ├── Dockerfile
│   └── requirements.txt
├── streamlit_app/
│   ├── streamlit_minecraft_logs.py
│   ├── Dockerfile
│   └── requirements.txt
└── scylla_cluster/
    ├── docker-compose.yaml      # ScyllaDB 2-node cluster
    ├── scylla_config/
    │   └── scylla.yaml
    ├── scylla-node1-data/
    └── scylla-node2-data/
```

---

## Running the Environment

### Start

```bash
chmod +x start.sh stop.sh
./start.sh [writer_replicas]
```

The optional `writer_replicas` argument sets how many `python_data_writer` containers to run in parallel. Defaults to `1` if omitted.

```bash
./start.sh    # 1 python_data_writer (default)
./start.sh 3  # 3 python_data_writers writing concurrently
```

The script:
1. Starts the ScyllaDB cluster.
2. Polls `nodetool status` until both nodes report `UN` (Up/Normal).
3. Starts `python_data_writer` and `streamlit_app`.

### Stop

```bash
./stop.sh
```

The script stops the application services first, then the ScyllaDB cluster.

### Streamlit Dashboard

After startup, access the dashboard at:

```
http://localhost:8501
```

---

## Networking

The application services connect to the ScyllaDB cluster through an external Docker network named `scylla_cluster_scylla-net`, created automatically by the `scylla_cluster` compose project. This is why the cluster must be running before the application services start.
