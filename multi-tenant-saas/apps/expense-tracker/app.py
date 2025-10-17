from flask import Flask, request, jsonify
import sqlite3, os

app = Flask(__name__)
DB_PATH = os.path.join(os.getcwd(), "expense.db")

def init_db():
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS expenses (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                description TEXT NOT NULL,
                amount REAL NOT NULL
            )
        """)
        conn.commit()

@app.route("/items", methods=["GET"])
def get_items():
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.execute("SELECT * FROM expenses")
        items = [
            {"id": row[0], "description": row[1], "amount": row[2]} 
            for row in cursor.fetchall()
        ]
    return jsonify(items), 200

@app.route("/items", methods=["POST"])
def add_item():
    data = request.get_json()
    description = data.get("description")
    amount = data.get("amount")
    if not description or amount is None:
        return jsonify({"error": "description and amount are required"}), 400
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.execute(
            "INSERT INTO expenses (description, amount) VALUES (?, ?)",
            (description, amount)
        )
        conn.commit()
        expense_id = cursor.lastrowid
    return jsonify({"id": expense_id, "description": description, "amount": amount}), 201

@app.route("/items/<int:item_id>", methods=["PUT"])
def update_item(item_id):
    data = request.get_json()
    description = data.get("description")
    amount = data.get("amount")
    if not description or amount is None:
        return jsonify({"error": "description and amount are required"}), 400
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute(
            "UPDATE expenses SET description=?, amount=? WHERE id=?",
            (description, amount, item_id)
        )
        conn.commit()
    return jsonify({"id": item_id, "description": description, "amount": amount}), 200

@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("DELETE FROM expenses WHERE id=?", (item_id,))
        conn.commit()
    return "", 204

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5001)
