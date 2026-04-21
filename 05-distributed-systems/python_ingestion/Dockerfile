FROM python:3.10-slim
LABEL Gabriel Richter

COPY data_gen.py ./data_gen.py
COPY requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

CMD python data_gen.py