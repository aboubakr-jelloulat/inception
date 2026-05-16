#!/bin/bash
set -e

echo "Starting WordPress container..."

DB_PASS=$(cat /run/secrets/db_password)
CREDS=$(cat /run/secrets/credentials)

WP_ADMIN_PASS=$(echo "$CREDS" | sed -n '1p')
WP_USER_PASS=$(echo "$CREDS" | sed -n '2p')

cd /var/www/html

mkdir -p /run/php

echo "Waiting for MariaDB..."

until mysqladmin ping \
    -h mariadb \
    -P 3306 \
    -u"$MYSQL_USER" \
    -p"$DB_PASS" \
    --silent; do
    sleep 2
done

echo "MariaDB is ready!"

# WordPress install

if [ ! -f wp-load.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASS" \
        --dbhost=mariadb:3306 \
        --allow-root
fi


# FORCE CONFIG 

echo "Enforcing database configuration..."
wp config set DB_HOST mariadb:3306 --allow-root


if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."

    wp core install \
        --url="http://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    echo "Creating author user..."

    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASS" \
        --allow-root
fi


# Redis configuration 

echo "Configuring Redis..."

wp plugin install redis-cache --activate --allow-root || true

# Redis config 
wp config set WP_REDIS_HOST redis --allow-root || true
wp config set WP_REDIS_PORT 6379 --allow-root || true
wp config set WP_CACHE true --raw --allow-root || true

wp redis enable --allow-root || true

echo "Redis cache configured!"

exec php-fpm8.2 -F