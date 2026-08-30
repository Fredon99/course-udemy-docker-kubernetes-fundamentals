# Sistemas Distribuídos - Rastreamento de Eventos Minecraft

Sistema distribuído que simula o rastreamento em tempo real de sessões de jogadores de Minecraft. Combina um cluster ScyllaDB para escritas de alta performance, um serviço Python que gera e insere eventos sintéticos continuamente, e um dashboard Streamlit para visualização ao vivo.

---

## Arquitetura

```
                        +---------------------------+
                        |     Cluster ScyllaDB      |
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
|  Gera eventos sintéticos|               |  Lê eventos do ScyllaDB   |
|  de sessão de jogadores |               |  a cada 5s e exibe         |
|  (connected, login,     |               |  métricas ao vivo:         |
|   disconnected) e       |               |  - Jogadores online        |
|  insere no ScyllaDB     |               |  - Contagem de eventos     |
|  com 3 threads          |               |  - Último login            |
+-------------------------+               +----------------------------+
```

### Fluxo de Dados

1. `python_data_writer` gera eventos de sessão de jogadores em intervalos aleatórios usando três threads concorrentes.
2. Cada evento é inserido na tabela `eventdb.events` do cluster ScyllaDB.
3. `streamlit_app` consulta as últimas 4 horas de eventos a cada 5 segundos e exibe métricas ao vivo no dashboard.

---

## Serviços

| Serviço | Descrição | Tecnologia |
|---|---|---|
| scylla-node1 | Nó primário do ScyllaDB (seed) | ScyllaDB 5.2 |
| scylla-node2 | Nó secundário do ScyllaDB (seed) | ScyllaDB 5.2 |
| python_data_writer | Gera e grava eventos sintéticos de jogo | Python 3.10, cassandra-driver |
| streamlit_app | Dashboard ao vivo para visualização de eventos | Python 3.10, Streamlit, Plotly |

### Schema do ScyllaDB

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

### Tipos de Evento

| Ação | Significado |
|---|---|
| connected | Jogador conectou ao servidor |
| login success | Jogador autenticou com sucesso |
| login fail | Jogador falhou na autenticação |
| disconnected | Jogador saiu do servidor |

---

## Estrutura do Projeto

```
05-distributed-systems/
├── docker-compose.yaml          # Serviços da aplicação (streamlit + data writer)
├── start.sh                     # Sobe todo o ambiente na ordem correta
├── stop.sh                      # Derruba todos os serviços
├── python_data_writer/
│   ├── data_gen.py              # Gerador de eventos e escritor no ScyllaDB
│   ├── Dockerfile
│   └── requirements.txt
├── streamlit_app/
│   ├── streamlit_minecraft_logs.py
│   ├── Dockerfile
│   └── requirements.txt
└── scylla_cluster/
    ├── docker-compose.yaml      # Cluster ScyllaDB com 2 nós
    ├── scylla_config/
    │   └── scylla.yaml
    ├── scylla-node1-data/
    └── scylla-node2-data/
```

---

## Como Executar

### Subir o ambiente

```bash
chmod +x start.sh stop.sh
./start.sh [replicas_writer]
```

O argumento opcional `replicas_writer` define quantos containers `python_data_writer` rodarão em paralelo. O padrão é `1`.

```bash
./start.sh    # 1 python_data_writer (padrão)
./start.sh 3  # 3 python_data_writers gravando concorrentemente
```

O script:
1. Sobe o cluster ScyllaDB.
2. Aguarda via `nodetool status` até ambos os nós reportarem `UN` (Up/Normal).
3. Sobe o `python_data_writer` e o `streamlit_app`.

### Parar o ambiente

```bash
./stop.sh
```

O script para os serviços da aplicação primeiro e depois o cluster ScyllaDB.

### Dashboard Streamlit

Após a subida, acesse o dashboard em:

```
http://localhost:8501
```

---

## Rede

Os serviços da aplicação se conectam ao cluster ScyllaDB através de uma rede Docker externa chamada `scylla_cluster_scylla-net`, criada automaticamente pelo projeto compose do `scylla_cluster`. Por isso o cluster precisa estar em execução antes de subir os serviços da aplicação.
