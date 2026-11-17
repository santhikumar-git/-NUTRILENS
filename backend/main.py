
from flask import Flask, jsonify, send_file
from pathlib import Path

app = Flask(__name__)

FRONTEND = Path(__file__).resolve().parent.parent / "frontend"

@app.route("/")
def home():
    return send_file(FRONTEND / "index.html")

@app.route("/api/health")
def health():
    return jsonify({
        "app": "NUTRILENS",
        "status": "healthy",
        "version": "1.0.0"
    })

if __name__ == "__main__":
    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False
    )


