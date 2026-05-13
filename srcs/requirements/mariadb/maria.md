# MariaDB Docker — Practice Cheatsheet

## Project Structure

```
inception/
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    └── requirements/
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── 50-server.cnf
            └── tools/
                └── maria-setup.sh
```

---

## Build the Image

```bash
# Must be run from inside the mariadb folder
cd ~/Desktop/inception/srcs/requirements/mariadb
docker build -t mariadb-local .
```

---

## Run the Container

Run from the project root so the `secrets/` path resolves correctly:

```bash
cd ~/Desktop/inception

docker run -d \
  --name mariadb-test \
  -p 3306:3306 \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=ajelloul \
  -v $(pwd)/secrets/db_password.txt:/run/secrets/db_password \
  -v $(pwd)/secrets/db_root_password.txt:/run/secrets/db_root_password \
  -v mariadb_data:/var/lib/mysql \
  mariadb-local
```

---

## Check Logs

```bash
docker logs -f mariadb-test
```

---

## Connect to MariaDB

**From your host machine:**
```bash
mysql -h 127.0.0.1 -P 3306 -u ajelloul -pAboubakr@1337
```

**Exec into the container first:**
```bash
docker exec -it mariadb-test bash

# Then inside:
mysql -u ajelloul -p         # as your user
mysql -u root -pAboubakr@1337  # as root
```

---

## Hands-on SQL Practice

```sql
-- See all databases
SHOW DATABASES;

-- Use your database
USE wordpress;

-- Create a test table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data
INSERT INTO users (name, email) VALUES ('Alice', 'alice@test.com');
INSERT INTO users (name, email) VALUES ('Bob', 'bob@test.com');

-- Query data
SELECT * FROM users;

-- Filter
SELECT * FROM users WHERE name = 'Alice';

-- Update
UPDATE users SET email = 'alice@new.com' WHERE name = 'Alice';

-- Delete
DELETE FROM users WHERE name = 'Bob';

-- Drop table
DROP TABLE users;
```

---

## Useful Admin Commands (as root)

```sql
-- Check current user
SELECT USER();

-- Check privileges
SHOW GRANTS;

-- List all tables
SHOW TABLES;

-- Describe table structure
DESCRIBE users;

-- See all users
SELECT user, host FROM mysql.user;

-- See running processes
SHOW PROCESSLIST;

-- Check database sizes (MB)
SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024, 2) AS size_mb
FROM information_schema.tables
GROUP BY table_schema;
```

---

## Container Lifecycle

```bash
# Stop
docker stop mariadb-test

# Start again
docker start mariadb-test

# Remove container (keeps the volume)
docker rm mariadb-test

# Full clean reset (removes container + data volume)
docker stop mariadb-test
docker rm -v mariadb-test
docker volume rm mariadb_data
```

---

## Rebuild from Scratch

```bash
# 1. Clean up
docker stop mariadb-test && docker rm -v mariadb-test
docker volume rm mariadb_data

# 2. Rebuild
cd ~/Desktop/inception/srcs/requirements/mariadb
docker build -t mariadb-local .

# 3. Run
cd ~/Desktop/inception
docker run -d \
  --name mariadb-test \
  -p 3306:3306 \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=ajelloul \
  -v $(pwd)/secrets/db_password.txt:/run/secrets/db_password \
  -v $(pwd)/secrets/db_root_password.txt:/run/secrets/db_root_password \
  -v mariadb_data:/var/lib/mysql \
  mariadb-local

# 4. Watch logs
docker logs -f mariadb-test
```

---

## Common Fixes

| Problem | Fix |
|---|---|
| `Found option without preceding group` | `50-server.cnf` must start with `[mysqld]` on line 1 |
| `Access denied for root (using password: NO)` | Add `-u root -p"${ROOT_PASS}"` to the `mysqladmin shutdown` call |
| `no such file or directory` on build | Run `docker build` from inside the `mariadb/` folder |
| Want a clean slate | Stop, remove container with `-v`, remove volume, rebuild |





1. Your MariaDB Config File Explained

You have:

[mysqld]
user = mysql
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
What Is [mysqld] ?

MariaDB configuration files are divided into sections.

Example:

[mysqld]

means:

"These settings apply to the MariaDB server daemon"

(mysqld = MariaDB server process)

user = mysql
user = mysql

Means:

"Run the MariaDB server as the mysql Linux user"

Why?

Security.

You NEVER want database servers running as root.

bind-address = 0.0.0.0

Very important in Docker.

What is bind-address?

It tells MariaDB:

"Which network interfaces should I listen on?"

127.0.0.1

Would mean:

Only localhost connections allowed

Inside Docker, WordPress container could NOT connect.

0.0.0.0

Means:

Listen on ALL interfaces

Necessary for container-to-container communication.

port = 3306

Default MariaDB/MySQL port.

WordPress connects to:

mariadb:3306

through Docker network.

datadir = /var/lib/mysql

Defines where MariaDB stores:

databases
tables
indexes
logs
internal files

This should point to your Docker volume.

Example:

volumes:
  - mariadb_data:/var/lib/mysql

This gives persistence.

Why Is The File Named 50-server.cnf ?

Very important Linux convention.

MariaDB Loads Multiple Config Files

MariaDB reads configuration directories like:

/etc/mysql/
/etc/mysql/mariadb.conf.d/

and loads files in numerical order.

Example:

10-client.cnf
20-server.cnf
50-server.cnf
99-custom.cnf
Why Numbers?

Because configuration loading order matters.

Later files override earlier files.

Example:

# 20-server.cnf
port = 3306

then later:

# 99-custom.cnf
port = 3307

Final result:

port = 3307
Why 50-server.cnf Specifically?

Debian/MariaDB packages already use this naming convention.

Typical Debian structure:

50-client.cnf
50-mysql-clients.cnf
50-mysqld_safe.cnf
50-server.cnf

You are replacing/modifying the main server config.

So using:

50-server.cnf

is correct and professional.


