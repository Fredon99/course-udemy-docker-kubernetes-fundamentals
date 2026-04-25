import os
import requests
from sqlalchemy import create_engine

engine = create_engine(os.getenv("POSTGRES_URL"))

with engine.connect() as con:
    con.exec_driver_sql("CREATE TABLE IF NOT EXISTS jokes (joke VARCHAR(255))")
    con.commit()

    r = requests.get("https://api.chucknorris.io/jokes/random")

    if r.status_code == 200:
        data = r.json()
        data = data["value"].replace("'", "")

        con.exec_driver_sql(f"INSERT INTO jokes VALUES ('{data}')")
        con.commit()

    else:
        print(r.status_code)
