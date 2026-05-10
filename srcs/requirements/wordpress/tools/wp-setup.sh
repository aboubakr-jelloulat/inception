#!/bin/bash
set -e

DB_PASS=$(cat /run/secrets/db_password)

cd /var/www/html

# Wait for MariaDB
until wp db check \
    --dbhost=mariadb \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$DB_PASS" \
    --allow-root 2>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Install WordPress if needed
if ! wp core is-installed --allow-root; then

    wp core download --allow-root

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASS" \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url="http://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --allow-root

    wp user create \
        "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASS" \
        --allow-root
fi

exec php-fpm7.4 -F
