from flask import request, jsonify
import requests
import json
from .config import Config
from .mq import publish_message


def register_routes(app):

    @app.route("/api/movies", methods=["GET", "POST", "DELETE"])
    @app.route("/api/movies/<path:path>", methods=["GET", "PUT", "DELETE"])
    def proxy_inventory(path=None):
        url = f"{Config.INVENTORY_URL}/api/movies"
        if path:
            url += f"/{path}"

        try:
            resp = requests.request(
                method=request.method,
                url=url,
                json=request.get_json(silent=True),
                params=request.args,
            )
            return (resp.content, resp.status_code, resp.headers.items())
        except requests.exceptions.ConnectionError:
            return jsonify({"message": "Inventory service unavailable"}), 503

    @app.route("/api/billing", methods=["POST"])
    def billing():
        try:
            message = json.dumps(request.json)
            publish_message(message)
            return jsonify({"message": "Message posted"})
        except Exception:
            return jsonify({"message": "Failed to queue message"}), 503
