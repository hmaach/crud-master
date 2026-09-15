# from app.consumer import start_consumer

# if __name__ == "__main__":
#     start_consumer()

from app import create_app


app = create_app()


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=8000
    )
