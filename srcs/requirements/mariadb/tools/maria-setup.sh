#!/bin/bash
set -e


mkdir -p /run/mysqld /var/log/mysql
chown mysql:mysql /run/mysqld /var/log/mysql

# Check if database is initialized
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "initializing database..."
    
    # Initialize database as mysql user
    mysql_install_db --user=mysql --datadir=/var/lib/mysql 2>/dev/null || echo "DB already initialized"
    
    # Start MariaDB temporarily in background
    mariadbd --user=mysql &
    pid=$!
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo "MariaDB did not start"
        exit 1
    fi
    
    echo "Creating database and user..."

    MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
    MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
    
    # Execute SQL commands
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    
    echo "Database setup complete!"
    echo "Stopping temporary MariaDB..."
    # mysqladmin shutdown 2>/dev/null
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $pid
fi

echo "Starting MariaDB..."
exec mariadbd --user=mysql