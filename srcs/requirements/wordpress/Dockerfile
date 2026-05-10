FROM debian:bullseye

# Install required packages
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    mariadb-client \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create web directory
RUN mkdir -p /var/www/html

# Replace fragile sed with proper config file approach 
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Setup script
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh

RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
