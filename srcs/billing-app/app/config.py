import os


class Config:
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    RABBITMQ_URL = os.getenv("RABBITMQ_URL")
    QUEUE_NAME = "billing_queue"
