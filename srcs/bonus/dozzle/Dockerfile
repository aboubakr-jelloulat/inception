FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && curl -fSL https://github.com/amir20/dozzle/releases/download/v1.20.21/dozzle_1.20.21_Linux_64-bit.tar.gz\
    | tar xz -C /usr/local/bin \
    && apt-get purge -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

ENTRYPOINT ["dozzle"]