import random
from flask import Flask, jsonify  # type: ignore

app = Flask(__name__)

fortunes = [
    " Terraform modules are like Lego for adults.",
    " Python Lambda says hi, Aryan!",
    " Jenkins will behave today (maybe).",
    " AWS bills shrink when you IaC.",
     " Deploy early, deploy often, but always monitor logs."
]

# Optional: Food-themed fortunes
# food_fortunes = [
#     " Pizza makes every meeting better.",
#     " Jenkins pipelines are like coffee: the smoother, the better.",
#     " Chocolate solves debugging stress."
# ]

@app.route("/", methods=["GET"])
def fortune():
    """Return a random fortune as JSON with proper Unicode."""
    return jsonify({"fortune": random.choice(fortunes)})

if __name__ == "__main__":
    # Run Flask server accessible from any host on port 5000
    app.run(host="0.0.0.0", port=5000)
