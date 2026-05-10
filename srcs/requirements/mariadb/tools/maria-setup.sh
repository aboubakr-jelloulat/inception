#!/bin/bash
set -e

# Fix permissions on mounted volume 
chown -R mysql:mysql /var/lib/mysql || true
chown -R mysql:mysql /var/run/mysqld || true

# Read secrets
DB_PASS=$(cat /run/secrets/db_password)
ROOT_PASS=$(cat /run/secrets/db_root_password)

# Initialize MariaDB if first run
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB temporarily (no network for safety)
mysqld_safe --skip-networking &
TEMP_PID=$!

# Wait for MariaDB to be ready 
echo "Waiting for MariaDB..."
for i in {30..0}; do
    if mysqladmin ping --silent; then
        break
    fi
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "Error: MariaDB failed to start"
    exit 1
fi

# Configure database
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Gracefully shutdown temporary MariaDB
mysqladmin shutdown

# Ensure process is fully stopped
wait $TEMP_PID 2>/dev/null || true

# Start real MariaDB server
exec mysqld --user=mysql
