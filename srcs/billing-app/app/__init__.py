from flask import Flask
from .config import Config
from .db import db
from .routes import register_routes

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)

    with app.app_context():
        db.create_all()

    register_routes(app)
    return app