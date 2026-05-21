import os

import pika
import json
from flask import Flask
from .config import Config
from .db import db
from .models import Order


def start_consumer():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)

    with app.app_context():
        db.create_all()

    connection = pika.BlockingConnection(pika.URLParameters(Config.RABBITMQ_URL))
    channel = connection.channel()
    channel.queue_declare(queue=Config.QUEUE_NAME, durable=True)

    def callback(ch, method, properties, body):
        with app.app_context():
            data = json.loads(body)

            order = Order(
                user_id=data["user_id"],
                number_of_items=data["number_of_items"],
                total_amount=data["total_amount"],
            )

            db.session.add(order)
            db.session.commit()

        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(queue=Config.QUEUE_NAME, on_message_callback=callback)

    print("Waiting for messages...")
    channel.start_consuming()
