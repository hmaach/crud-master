import os

class Config:
    INVENTORY_URL = os.getenv("INVENTORY_URL")
    RABBITMQ_URL = os.getenv("RABBITMQ_URL")
    QUEUE_NAME = "billing_queue"