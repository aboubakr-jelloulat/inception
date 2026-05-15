FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-curl \
        mariadb-client \
        wget \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

    # PHP-FPM runtime directory 
RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && mkdir -p /run/php \
    && chown -R www-data:www-data /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh

RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]