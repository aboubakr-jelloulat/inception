FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
        vsftpd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY tools/vsftpd.conf /etc/vsftpd.conf

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 21 30000-30009

ENTRYPOINT ["/entrypoint.sh"]
