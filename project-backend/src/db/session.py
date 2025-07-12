import psycopg
import os
from typing import AsyncGenerator, Optional



async def get_db_session():
    username = os.environ.get("POSTGRES_USER")
    password = os.environ.get("POSTGRES_PASSWORD")
    host = os.environ.get("POSTGRES_HOST")
    database = os.environ.get("POSTGRES_DB")
    port = os.environ.get("POSTGRES_PORT")

    conn = None
    try:
        conn = psycopg.connect(user=username, password=password, host=host, dbname=database, port=port)
        yield conn
    except Exception as e:
        yield None
    finally:
        if conn is not None:
            conn.close()