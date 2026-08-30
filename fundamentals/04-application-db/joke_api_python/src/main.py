import os
from http import HTTPStatus
from fastapi import FastAPI, HTTPException

from sqlalchemy import create_engine, text
from sqlalchemy.exc import ProgrammingError, SQLAlchemyError

app = FastAPI()

engine = create_engine(url=os.getenv("POSTGRES_URL"))

@app.get("/", status_code=HTTPStatus.OK)
def read_root():
    return {"message": "Endpoint de piadas: /jokes/"}

@app.get("/joke/", status_code=HTTPStatus.OK)
def read_jokes():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("select joke from jokes order by random() limit 1")).fetchone()
    except ProgrammingError as exc:
        if getattr(exc.orig, "pgcode", None) == "42P01":
            raise HTTPException(
                status_code=HTTPStatus.SERVICE_UNAVAILABLE,
                detail="A tabela 'jokes' nao existe no banco configurado."
            ) from exc
        raise HTTPException(
            status_code=HTTPStatus.INTERNAL_SERVER_ERROR,
            detail="Erro ao consultar o banco de dados."
        ) from exc
    except SQLAlchemyError as exc:
        raise HTTPException(
            status_code=HTTPStatus.SERVICE_UNAVAILABLE,
            detail="Banco de dados indisponivel ou conexao em estado invalido."
        ) from exc

    if result is None:
        raise HTTPException(
            status_code=HTTPStatus.NOT_FOUND,
            detail="Nenhuma piada foi encontrada na tabela 'jokes'."
        )

    return {"joke": result[0]}