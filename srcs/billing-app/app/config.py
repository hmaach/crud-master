import os


class Config:
    DATABASE_URL = os.getenv("DATABASE_URL")
    RABBITMQ_URL = os.getenv("RABBITMQ_URL")
    QUEUE_NAME = "billing_queue"
