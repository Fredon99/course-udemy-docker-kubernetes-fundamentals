FROM python:3.10-slim
LABEL Gabriel Richter

COPY streamlit_minecraft_logs.py ./streamlit_minecraft_logs.py
COPY requirements.txt ./requirements.txt

RUN pip install -r requirements.txt

EXPOSE 8501

CMD streamlit run streamlit_minecraft_logs.py