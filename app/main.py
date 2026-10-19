import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
    )


@app.get("/health")
def health():
    return jsonify(status="ok", service="flask-api"), 200


@app.get("/ready")
def ready():
    try:
        conn = get_connection()
        conn.close()
        return jsonify(status="ready", database="connected"), 200
    except Exception:
        return jsonify(status="not-ready", database="unavailable"), 503


@app.get("/users")
def users():
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT id, email FROM users ORDER BY id LIMIT 100")
            rows = [{"id": row[0], "email": row[1]} for row in cursor.fetchall()]
        conn.close()
        return jsonify(users=rows), 200
    except Exception:
        return jsonify(error="Unable to retrieve users"), 500
