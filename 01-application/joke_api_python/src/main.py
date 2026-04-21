import random
from http import HTTPStatus
from fastapi import FastAPI

app = FastAPI()

jokes = [
    "O que o pato falou para a pata? - Vem quá",
    "Você sabe qual é o rei dos queijos? - O reiqueijão"
]

@app.get("/", status_code=HTTPStatus.OK)
def read_root():
    return {"message": "Endpoint de piadas: /joke/"}

@app.get("/joke/", status_code=HTTPStatus.OK)
def read_jokes():
    return {"joke": random.choice(jokes)}