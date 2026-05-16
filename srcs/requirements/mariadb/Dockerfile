FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/maria-setup.sh /usr/local/bin/maria-setup.sh

RUN chmod +x /usr/local/bin/maria-setup.sh \
    && mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql

WORKDIR /etc/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/maria-setup.sh"]
