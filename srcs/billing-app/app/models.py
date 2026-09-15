from .db import db


class Order(db.Model):
    #  __tablename__ = "orders"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(50))
    number_of_items = db.Column(db.Integer)
    total_amount = db.Column(db.Float)
