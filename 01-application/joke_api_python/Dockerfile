FROM python:3.10-slim

WORKDIR /app

COPY ./src/main.py ./main.py
COPY ./requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

CMD ["fastapi", "run", "main.py"]