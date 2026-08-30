import os
import pandas as pd
import streamlit as st
from time import sleep
from datetime import datetime, timedelta

from plotly import express as px
from cassandra.cluster import Cluster

cluster = Cluster(
    contact_points=[ os.getenv("SCYLLA_IP") ],
    port=9042,
)

session = cluster.connect()

def get_data(
    datetime: datetime
) -> pd.DataFrame:
    datetime = datetime.strftime("%Y-%m-%d %H:%M:%S")
    query = f"select * from eventdb.events where timestamp >= '{datetime}' allow filtering;"

    df = pd.DataFrame(list(session.execute(query)))
    return df

def count_quantity_events(df: pd.DataFrame):
    return df[["action", "id"]].groupby("action").count()
    
def last_login_at(df: pd.DataFrame):
    return df["event_date"].max()

def current_online_players(df: pd.DataFrame):
    login_success_df = df[df["parent_id"].isin(df.loc[df["action"] == "login success", "parent_id"])]
    current_online_players = login_success_df[["parent_id", "action"]].groupby("parent_id").count().query("action == 1").index
    current_online_players_df = login_success_df[login_success_df["parent_id"].isin(current_online_players)].reset_index(drop=True)

    current_online_players_df["playing_time"] = (datetime.now() - current_online_players_df["event_date"]).astype(str)
    current_online_players_df["playing_time"] = current_online_players_df["playing_time"].apply(lambda x: x.split(" ")[-1])

    current_online_players_df = current_online_players_df[["parent_id", "playing_time", "event_date"]]
    current_online_players_df.columns = ["player_id", "playing_time", "login_datetime"]

    return current_online_players_df

if __name__ == "__main__":
    st.title(":bricks: | Minecraft Logs")
    st.write("---")

    current_players_position = st.empty()
    c_quantity_events, c_last_login_at = st.columns(2)

    while True:
        df = get_data(datetime.now() - timedelta(minutes=60 * 4))

        current_players_position.write(current_online_players(df))

        c_quantity_events.write(count_quantity_events(df))
        c_last_login_at.subheader(f"Last Login At: {last_login_at(df).strftime('%H:%M:%S')} :fire:")

        sleep(5)
        st.rerun()
