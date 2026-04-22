import os
from http import HTTPStatus
from fastapi import FastAPI

from sqlalchemy import create_engine, text

app = FastAPI()

engine = create_engine(url=os.getenv("POSTGRES_URL"))
con = engine.connect()

@app.get("/", status_code=HTTPStatus.OK)
def read_root():
    return {"message": "Endpoint de piadas: /jokes/"}

@app.get("/joke/", status_code=HTTPStatus.OK)
def read_jokes():
    return {"joke": con.execute(text("select joke from jokes order by random() limit 1")).fetchone()[0]}