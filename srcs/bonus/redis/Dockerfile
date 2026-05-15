FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        redis-server \
    &&  apt-get clean && rm -rf /var/lib/apt/lists/* 

# Allow connections from any container on the Docker network
# (bind to 0.0.0.0 so WordPress container can reach it)

# RUN sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf \
#  && sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf \
#  && sed -i 's/^# maxmemory-policy .*/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf


EXPOSE 6379

CMD ["redis-server", "--protected-mode", "no", "--bind", "0.0.0.0"]
