import pika
from .config import Config


def publish_message(message):
    connection = pika.BlockingConnection(pika.URLParameters(Config.RABBITMQ_URL))
    channel = connection.channel()
    channel.queue_declare(queue=Config.QUEUE_NAME, durable=True)
    channel.basic_publish(
        exchange="",
        routing_key=Config.QUEUE_NAME,
        body=message,
        properties=pika.BasicProperties(delivery_mode=2),
    )
    connection.close()
