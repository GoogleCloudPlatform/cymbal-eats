FROM python:3.9-slim
RUN pip install Flask gunicorn
WORKDIR /app
COPY . .
CMD exec gunicorn --bind 0.0.0.0:8080 --workers 1 --threads 8 app:app