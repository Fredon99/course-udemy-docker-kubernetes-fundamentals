import os
import threading
from uuid import uuid4
from time import sleep
from random import choice
from datetime import datetime

from cassandra.cluster import Cluster

def connect_with_retry(contact_points, port, retries=10, interval=5):
    for attempt in range(1, retries + 1):
        try:
            cluster = Cluster(contact_points=contact_points, port=port)
            session = cluster.connect()
            print(f"Connected to ScyllaDB on attempt {attempt}.")
            return session
        except Exception as e:
            print(f"Attempt {attempt}/{retries}: ScyllaDB not ready ({e}). Retrying in {interval}s...")
            sleep(interval)
    raise RuntimeError("Could not connect to ScyllaDB after multiple retries.")

session = connect_with_retry(
    contact_points=[os.getenv("SCYLLA_IP")],
    port=9042,
)

query = """
INSERT INTO eventdb.events (id, parent_id, timestamp, action, event_date)
VALUES (%s, %s, toTimestamp(now()), %s, %s)
"""

def get_action(
    event_id: str,
    next_action: str
) -> dict:
    return (
        str(uuid4()),
        event_id,
        next_action,
        datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )

def generate_event(abc):
    sleep(abc)

    event_id = str(uuid4())
    first_action = (event_id, "1", "connected", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

    print(first_action)
    session.execute(query, first_action)

    next_action = choice(["login success", "login fail", "login success", "login success", "login success"])

    if next_action == "login fail":
        sleep(3)
        next_action = get_action(event_id, next_action)
        print(next_action)
        session.execute(query, next_action)

        sleep(2)
        final_action = get_action(event_id, "disconnected")
        print(final_action)
        session.execute(query, final_action)

        return

    elif next_action == "login success":
        sleep(3)
        next_action = get_action(event_id, next_action)
        print(next_action)
        session.execute(query, next_action)

        wait_seconds = choice([20, 50, 60])
        sleep(wait_seconds)

        final_action = get_action(event_id, "disconnected")
        print(final_action)
        session.execute(query, final_action)

        return

    else:
        sleep(3)
        next_action = get_action(event_id, next_action)
        print(next_action)
        session.execute(query, next_action)

        return

def create_keyspace():
    session.execute("CREATE KEYSPACE IF NOT EXISTS eventdb WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor': 2 };")
    session.execute("CREATE TABLE IF NOT EXISTS eventdb.events(id varchar, parent_id varchar, timestamp timestamp, action varchar, event_date timestamp, PRIMARY KEY(id, parent_id, action, timestamp));")

def main():
    while True:
        generate_event(choice(range(1, 10, 2)))
        sleep(2)

if __name__ == "__main__":
    create_keyspace()

    thread1 = threading.Thread(target=main)
    thread2 = threading.Thread(target=main)
    thread3 = threading.Thread(target=main)

    thread1.start()
    thread2.start()
    thread3.start()

    while True:
        sleep(1)