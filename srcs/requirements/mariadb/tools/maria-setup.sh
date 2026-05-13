#!/bin/bash
set -e

# Fix permissions
chown -R mysql:mysql /var/lib/mysql 2>/dev/null || true
chown -R mysql:mysql /var/run/mysqld 2>/dev/null || true

# Read secrets
export DB_PASS=$(cat /run/secrets/db_password)
export ROOT_PASS=$(cat /run/secrets/db_root_password)

# Init only first time
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    echo "Preparing SQL file..."

    # Replace variables in template
    envsubst < /tools/init.sql > /tmp/init.sql

    echo "Running bootstrap..."

    mariadbd --bootstrap < /tmp/init.sql

    echo "Initialization done."
fi

echo "Starting MariaDB..."

exec mariadbd