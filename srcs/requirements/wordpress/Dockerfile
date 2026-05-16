FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-redis \
        mariadb-client \
        wget \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && mkdir -p /run/php \
    && chown -R www-data:www-data /run/php

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh

RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]