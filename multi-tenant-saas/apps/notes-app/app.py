from flask import Flask, request, jsonify
import sqlite3, os

app = Flask(__name__)
DB_PATH = os.path.join(os.getcwd(), "notes.db")

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS notes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content TEXT NOT NULL
            )
        """)
        conn.commit()

@app.route("/")
def home():
    return "This is the Notes App!"


@app.route("/items", methods=["GET"])
def get_items():
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.execute("SELECT * FROM notes")
        items = [{"id": row[0], "content": row[1]} for row in cursor.fetchall()]
    return jsonify(items), 200

@app.route("/items", methods=["POST"])
def add_item():
    data = request.get_json()
    content = data.get("content")
    if not content:
        return jsonify({"error": "content is required"}), 400
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.execute("INSERT INTO notes (content) VALUES (?)", (content,))
        conn.commit()
        note_id = cursor.lastrowid
    return jsonify({"id": note_id, "content": content}), 201

@app.route("/items/<int:item_id>", methods=["PUT"])
def update_item(item_id):
    data = request.get_json()
    content = data.get("content")
    if not content:
        return jsonify({"error": "content is required"}), 400
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("UPDATE notes SET content=? WHERE id=?", (content, item_id))
        conn.commit()
    return jsonify({"id": item_id, "content": content}), 200

@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("DELETE FROM notes WHERE id=?", (item_id,))
        conn.commit()
    return "", 204

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
