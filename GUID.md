# Inception Project Guide

## Table of Contents

- [Project Setup](#project-setup)
- [MariaDB](#mariadb)
- [Nginx](#nginx)
- [Redis](#redis)
- [FTP](#ftp)
- [Docker Restart Policies](#docker-restart-policies)

---

## Project Setup

### Configure Local Domains

Edit `/etc/hosts` and add the following lines:

```
127.0.0.1 yourlogin.42.fr
127.0.0.1 ajelloul.42.fr
```

Websites use human-readable domain names while computers use IP addresses. Using a domain like `https://yourlogin.42.fr` matches how real sites are addressed, and Nginx uses these names for TLS and routing.

### Create the Project Structure

```bash
mkdir -p inception/srcs/requirements/{mariadb,nginx,wordpress}
mkdir -p inception/secrets

mkdir -p inception/srcs/requirements/mariadb/{conf,tools}
mkdir -p inception/srcs/requirements/nginx/{conf,tools}
mkdir -p inception/srcs/requirements/wordpress/{conf,tools}
```

Expected layout:

```
inception/
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/wp-setup.sh
        └── mariadb/
            ├── Dockerfile
            └── tools/db-setup.sh
```

### Create Host Data Folders

The project requires persistent volumes under your home directory. Replace `$USER` with your actual username:

```bash
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress
```

These folders store MariaDB and WordPress data so containers can be recreated without losing state.

---

## MariaDB

### Build the Image

Must be run from inside the `mariadb/` folder:

```bash
cd ~/Desktop/inception/srcs/requirements/mariadb
docker build -t mariadb-local .
```

### Run the Container

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

### Check Logs

```bash
docker logs -f mariadb-test
```

### Networking Tools (Inside Container)

To install `netstat` on a Debian-based container:

```bash
apt-get update && apt-get install -y net-tools
netstat -tlnp
```

Flag breakdown:

| Flag | Meaning |
|------|---------|
| `-t` | Show TCP ports |
| `-l` | Show only listening ports |
| `-n` | Show numerical addresses instead of resolving names |
| `-p` | Show the PID and program name owning each socket |

### Connect to MariaDB

From the host machine:

```bash
mysql -h 127.0.0.1 -P 3306 -u ajelloul -pAboubakr@1337
```

Exec into the container first, then connect:

```bash
docker exec -it mariadb-test bash

mysql -u ajelloul -p          # as your user
mysql -u root -pAboubakr@1337 # as root
```

### SQL Reference

```sql
-- Show all databases
SHOW DATABASES;

-- Select a database
USE wordpress;

-- Create a table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert rows
INSERT INTO users (name, email) VALUES ('Alice', 'alice@test.com');
INSERT INTO users (name, email) VALUES ('Bob', 'bob@test.com');

-- Query all rows
SELECT * FROM users;

-- Filter
SELECT * FROM users WHERE name = 'Alice';

-- Update
UPDATE users SET email = 'alice@new.com' WHERE name = 'Alice';
UPDATE wp_users SET user_login = 'newname' WHERE user_login = 'oldname';

-- Delete
DELETE FROM users WHERE name = 'Bob';

-- Drop table
DROP TABLE users;
```

### Admin SQL Commands

Run these as root:

```sql
SELECT USER();                        -- current user
SHOW GRANTS;                          -- current user privileges
SHOW TABLES;                          -- list all tables in active database
DESCRIBE users;                       -- show table structure
SELECT user, host FROM mysql.user;    -- list all database users
SHOW PROCESSLIST;                     -- active connections

-- Check database sizes in MB
SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024, 2) AS size_mb
FROM information_schema.tables
GROUP BY table_schema;
```

### Container Lifecycle

```bash
docker stop mariadb-test
docker start mariadb-test
docker rm mariadb-test                 # removes container, keeps volume

# Full reset (container + volume)
docker stop mariadb-test
docker rm -v mariadb-test
docker volume rm mariadb_data
```

### Rebuild from Scratch

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

# 4. Follow logs
docker logs -f mariadb-test
```

### Common Fixes

| Problem | Fix |
|---------|-----|
| `Found option without preceding group` | `50-server.cnf` must start with `[mysqld]` on line 1 |
| `Access denied for root (using password: NO)` | Add `-u root -p"${ROOT_PASS}"` to the `mysqladmin shutdown` call |
| `no such file or directory` on build | Run `docker build` from inside the `mariadb/` folder |
| Need a clean slate | Stop and remove container with `-v`, remove the volume, then rebuild |

### Configuration File (`50-server.cnf`)

```ini
[mysqld]
user = mysql
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
```

**`[mysqld]`** — Section header. Settings here apply to the MariaDB server daemon (`mysqld`).

**`user = mysql`** — Runs the server as the `mysql` Linux user, not as `root`. Never run a database server with root privileges.

**`bind-address = 0.0.0.0`** — Controls which network interfaces MariaDB listens on:

| Value | Meaning |
|-------|---------|
| `127.0.0.1` | Localhost only — other containers cannot connect |
| `0.0.0.0` | All interfaces — required for container-to-container communication |

**`port = 3306`** — The default MariaDB/MySQL port. WordPress connects to `mariadb:3306` over the Docker network.

**`datadir = /var/lib/mysql`** — Where MariaDB stores all its data. This path must be backed by a Docker volume for persistence:

```yaml
volumes:
  - mariadb_data:/var/lib/mysql
```

**Why `50-server.cnf`?** MariaDB reads config files from `/etc/mysql/mariadb.conf.d/` in numerical order. Later files override earlier ones. The `50-` prefix slots correctly into the expected order without conflicting with package-provided configs.

### Setup Script Internals

**Key files:**

| File | Purpose |
|------|---------|
| `mysqld.pid` | Process ID of the running MariaDB server |
| `mysqld.sock` | Unix socket for local connections |

**`mysqld.sock`** is a Unix socket file. Local programs communicate with MariaDB through it instead of TCP — faster for same-machine connections.

**Starting MariaDB temporarily:**

```bash
mariadbd --user=mysql &
```

The `&` is critical. Without it, the script blocks at that line indefinitely. With `&`, MariaDB runs in the background and the script continues.

**Shutting down the temporary instance:**

```bash
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
```

The temporary instance exists only for initial setup. It must be stopped before launching the final production process.

**Waiting for MariaDB to be ready:**

```bash
if mysqladmin ping --silent 2>/dev/null; then
    break
fi
```

| Part | Meaning |
|------|---------|
| `mysqladmin ping` | Asks MariaDB if it is alive |
| `--silent` | Suppresses output but keeps the exit status |
| `2>/dev/null` | Discards error messages during startup |

**Waiting for full shutdown:**

```bash
wait $pid
```

Waits until the background MariaDB process has fully exited. Without this, a race condition can occur where the second instance starts before the first has stopped.

**Why `exec`:**

```bash
exec mariadbd ...
```

Without `exec`, the process tree is `bash → mariadbd`. Bash remains PID 1. With `exec`, `mariadbd` becomes PID 1 — required in Docker. The main service must always be PID 1.

---

## Nginx

### Role in the Stack

Nginx serves three purposes in this project:

- **TLS terminator** — handles HTTPS so the backend does not have to.
- **Static file server** — serves HTML, CSS, and images directly.
- **Router** — forwards dynamic PHP requests to WordPress via FastCGI.

### Why Config Goes in `conf.d/`

```dockerfile
COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf
```

The base `/etc/nginx/nginx.conf` already exists and already includes `conf.d/*.conf`. Overwriting it directly would break the event loop, logging, MIME types, and performance settings. Using `/etc/nginx/conf.d/` is the correct, modular approach.

### FastCGI

FastCGI is a protocol between web servers and dynamic applications like PHP-FPM:

| Protocol | Behavior |
|----------|---------|
| CGI | New process created per request — inefficient |
| FastCGI | Persistent process handles requests — efficient |

Request flow:

```
Browser
  -> HTTPS ->
Nginx container
  -> FastCGI ->
WordPress / PHP-FPM container
  -> SQL ->
MariaDB container
```

### WordPress Routing (`location /`)

```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

`try_files` checks paths in order and stops at the first match:

| Step | What Nginx tries |
|------|-----------------|
| `$uri` | The exact requested file path |
| `$uri/` | The path as a directory |
| `/index.php?$args` | Fallback — the WordPress front controller |

Examples:

- `GET /logo.png` — file exists on disk, served directly.
- `GET /wp-admin/` — directory exists, directory index served.
- `GET /my-first-post` — neither file nor directory exists, falls back to `index.php`. WordPress maps the URL to the correct post from the database.

WordPress URLs are virtual. `/hello-world` is not a real file. Without `try_files`, pretty permalinks break entirely. `$args` preserves the query string when passing to `index.php`.

### PHP Location Block

```nginx
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_pass wordpress:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

**`location ~ \.php$`** — `~` enables regex. `\.php$` matches any URL ending with `.php` and excludes everything else.

**`include fastcgi_params`** — Loads standard FastCGI variables PHP needs: `REQUEST_METHOD`, `QUERY_STRING`, `CONTENT_TYPE`, `SERVER_NAME`.

**`fastcgi_pass wordpress:9000`** — Forwards the request to the `wordpress` container on port 9000 where PHP-FPM listens. Docker's internal DNS resolves the service name automatically. Nginx does not execute PHP — it only forwards.

**`fastcgi_param SCRIPT_FILENAME`** — Tells PHP-FPM which file to execute:

| Variable | Example value |
|----------|--------------|
| `$document_root` | `/var/www/html` |
| `$fastcgi_script_name` | `/index.php` |
| Combined | `/var/www/html/index.php` |

### Full Request Flow

Example: user visits `https://ajelloul.42.fr/wp-login.php`

```
1. Browser sends HTTPS request
2. Nginx receives it, matches location ~ \.php$
3. Nginx forwards to wordpress:9000 via FastCGI
4. PHP-FPM executes /var/www/html/wp-login.php
5. WordPress queries MariaDB
6. MariaDB returns user data
7. PHP generates the login page HTML
8. Nginx sends the response to the browser
```

### Test URLs

| What to test | URL |
|-------------|-----|
| Homepage | `https://ajelloul.42.fr` |
| Login page | `https://ajelloul.42.fr/wp-login.php` |
| Admin panel | `https://ajelloul.42.fr/wp-admin/` |
| Pretty permalinks | `https://ajelloul.42.fr/hello-world` |

To verify MariaDB persistence: create posts or settings in the WordPress dashboard, restart all containers, and confirm the data still exists.

---

## Redis

### How the Connection Works

The Redis connection is not made by your setup script directly. It is made by the WordPress Redis Object Cache plugin, which installs a file at `wp-content/object-cache.php`. WordPress loads this file automatically when it exists and uses it to override the default caching layer.

Your setup script does three things:

```bash
wp plugin install redis-cache --activate --allow-root
wp config set WP_REDIS_HOST redis
wp config set WP_REDIS_PORT 6379
wp config set WP_CACHE true --raw
```

This produces the following in `wp-config.php`:

```php
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_CACHE', true);
```

The actual PHP connection inside the plugin looks like:

```php
$redis = new Redis();
$redis->connect('redis', 6379);
```

The hostname `redis` resolves to the Redis container via Docker's internal DNS.

To inspect the object cache drop-in:

```bash
docker exec -it wordpress bash -c "cat wp-content/object-cache.php"
```

### Testing Redis Connectivity

```bash
# Enter the WordPress container
docker exec -it wordpress bash

# Install redis-cli temporarily
apt update && apt install redis-tools -y

# Connect to the Redis container
redis-cli -h redis
```

Inside `redis-cli`:

```
PING         # expected: PONG
KEYS *       # list all cached keys
DBSIZE       # number of keys
INFO         # server info
```

From outside the container:

```bash
docker exec -it redis redis-cli KEYS "*"
```

If the WordPress cache plugin is active, you will see keys prefixed with `wp_`.

### Flushing the Cache

If you need to clear all cached data (for example, after deleting a user):

```bash
docker exec -it redis redis-cli FLUSHALL
```

### Managing WordPress Users

Do not delete WordPress users directly from the database. Use WP-CLI:

```bash
# Delete a user and reassign their content
docker exec -it wordpress wp user delete USERNAME --reassign=1 --allow-root

# List all users
docker exec -it wordpress wp user list --allow-root
```

### Redis Commands Reference

| Command | Description |
|---------|-------------|
| `PING` | Check server connectivity |
| `DBSIZE` | Number of keys in the database |
| `KEYS *` | List all keys |
| `FLUSHALL` | Remove all keys from all databases |
| `INFO` | Display server information |

---

## FTP

### Architecture

```
Your Computer (FileZilla)
        |
        v
 Docker Host
        |
        +-- Port 21        (FTP control / login)
        |
        +-- Ports 30000-30009  (passive data transfer)
                |
                v
       FTP Container
                |
                v
       /var/www/html  <-->  Shared Docker Volume  <-->  WordPress
```

### Port Behavior

`EXPOSE` in a Dockerfile does not publish a port to your host. It only documents that the container listens on that port and signals Docker to allow other containers to reach it.

Port 21 is always open once the container starts. Ports 30000–30009 are passive ports and are only opened dynamically during actual file operations such as listing a directory, uploading, or downloading. You will not see them in `ss` or `netstat` output unless a client is actively transferring data.

### Verifying Passive Ports During Transfer

Open a monitoring session inside the FTP container:

```bash
docker exec -it ftp bash
watch "ss -tan | grep 30"
```

Then connect with FileZilla and perform an action (upload a file, list a directory). Ports in the 30000–30009 range will appear temporarily during the transfer and disappear when idle.

### FileZilla Setup on Ubuntu

```bash
sudo apt update && sudo apt install -y filezilla
filezilla --version
```

Connection settings:

| Field | Value |
|-------|-------|
| Host | `localhost` or `127.0.0.1` |
| Port | `21` |
| Protocol | FTP |
| Mode | Passive |

---

## Docker Restart Policies

| Policy | Restarts on crash | Restarts on reboot | Restarts after manual stop |
|--------|:-----------------:|:------------------:|:--------------------------:|
| `no` (default) | No | No | No |
| `always` | Yes | Yes | Yes |
| `unless-stopped` | Yes | Yes | No |
| `on-failure` | Yes (exit code != 0 only) | No | No |

**`unless-stopped`** is the standard choice for Inception. Containers recover from crashes and system reboots, but stay stopped if you explicitly stop them yourself.

#### Test : Docker daemon restart


1. Restart Docker service:
```
sudo systemctl restart docker
```
Then:
```
docker ps
```
✔ all containers with restart policy will come back automatically

**`on-failure`** can accept a retry limit:

```yaml
restart: on-failure:5
```

This retries up to 5 times before giving up.