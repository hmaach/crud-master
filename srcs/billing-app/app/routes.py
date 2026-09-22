from flask import jsonify

from .models import Order


def register_routes(app):

    @app.route("/api/billing", methods=["GET"])
    def get_billing():

        orders = Order.query.all()

        return jsonify([
            {
                "id": order.id,
                "total_amount": order.total_amount,
            }
            for order in orders
        ])
