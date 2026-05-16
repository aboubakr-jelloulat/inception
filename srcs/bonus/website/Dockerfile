FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/static

COPY portfolio/ .

EXPOSE 8081

CMD ["python3", "-m", "http.server", "8081", "--bind", "0.0.0.0"]


