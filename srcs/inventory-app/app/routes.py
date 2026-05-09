from flask import request, jsonify
from .models import Movie
from .db import db


def register_routes(app):

    @app.route("/api/movies", methods=["GET"])
    def get_movies():
        title = request.args.get("title")
        query = Movie.query

        if title:
            query = query.filter(Movie.title.contains(title))

        movies = query.all()
        return jsonify(
            [
                {"id": m.id, "title": m.title, "description": m.description}
                for m in movies
            ]
        )

    @app.route("/api/movies/<int:id>", methods=["GET"])
    def get_movie(id):
        movie = Movie.query.get_or_404(id)
        return jsonify(
            {"id": movie.id, "title": movie.title, "description": movie.description}
        )

    @app.route("/api/movies", methods=["POST"])
    def create_movie():
        data = request.json
        movie = Movie(title=data["title"], description=data.get("description"))
        db.session.add(movie)
        db.session.commit()
        return jsonify({"message": "created"}), 201

    @app.route("/api/movies/<int:id>", methods=["PUT"])
    def update_movie(id):
        movie = Movie.query.get_or_404(id)
        data = request.json
        movie.title = data.get("title", movie.title)
        movie.description = data.get("description", movie.description)
        db.session.commit()
        return jsonify({"message": "updated"})

    @app.route("/api/movies/<int:id>", methods=["DELETE"])
    def delete_movie(id):
        movie = Movie.query.get_or_404(id)
        db.session.delete(movie)
        db.session.commit()
        return jsonify({"message": "deleted"})

    @app.route("/api/movies", methods=["DELETE"])
    def delete_all():
        Movie.query.delete()
        db.session.commit()
        return jsonify({"message": "all deleted"})
