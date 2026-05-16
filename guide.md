# Inception Project 

### STEP 1 — Configure your domain

Edit /etc/hosts and add lines for your local domains:
```
127.0.0.1 yourlogin.42.fr
127.0.0.1 ajelloul.42.fr
```

Why: websites have human-friendly names (domains) while computers use IP addresses (e.g., 142.250.201.14). Using a domain like https://yourlogin.42.fr is clearer and matches how real sites are addressed. NGINX will use the domain names for TLS and routing.

---

### STEP 2 — Create project structure

Create the top-level project folders first:
```bash
mkdir -p inception/srcs/requirements/{mariadb,nginx,wordpress}
mkdir -p inception/secrets
```

Create service subfolders for configuration and helper tools:
```bash
mkdir -p inception/srcs/requirements/mariadb/{conf,tools}
mkdir -p inception/srcs/requirements/nginx/{conf,tools}
mkdir -p inception/srcs/requirements/wordpress/{conf,tools}
```

Your project should look like this:

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

---

### STEP 3 — Create host data folders

The assignment requires persistent volumes under your home data directory. Replace $USER with your username:
```bash
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress
```
These folders store MariaDB and WordPress data so containers can be recreated without losing state.


---

## Table of Contents

- [MariaDB](#mariadb)
  - [Project Structure](#project-structure)
  - [Build the Image](#build-the-image)
  - [Run the Container](#run-the-container)
  - [Check Logs](#check-logs)
  - [Connect to MariaDB](#connect-to-mariadb)
  - [Hands-on SQL Practice](#hands-on-sql-practice)
  - [Useful Admin Commands](#useful-admin-commands)
  - [Container Lifecycle](#container-lifecycle)
  - [Rebuild from Scratch](#rebuild-from-scratch)
  - [Common Fixes](#common-fixes)
  - [Configuration File Explained](#configuration-file-explained)
  - [Setup Script Internals](#setup-script-internals)
- [Nginx](#nginx)
  - [What is Nginx?](#what-is-nginx)
  - [Why Docker Copies to `conf.d/`](#why-docker-copies-to-confd)
  - [Nginx Configuration](#nginx-configuration)
  - [Location `/` — WordPress Routing](#location----wordpress-routing)
  - [PHP Location Block](#php-location-block)
  - [Full Request Flow](#full-request-flow)
  - [How to Test](#how-to-test)

---

## MariaDB

### Project Structure

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

### Build the Image

> Must be run from inside the `mariadb/` folder.

```bash
cd ~/Desktop/inception/srcs/requirements/mariadb
docker build -t mariadb-local .
```

---

### Run the Container

> Run from the project root so the `secrets/` path resolves correctly.

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

To install netstat on a Debian-based container,  : ```apt-get update && apt-get install -y net-tools
``` 
```netstat -tlnp```
Flag Breakdown -t: Shows TCP ports.-l: Shows only listening ports (servers).-n: Shows numerical addresses and port numbers instead of resolving names.-p: Shows the PID and name of the program owning the socket.

### Check Logs

```bash
docker logs -f mariadb-test
```

---

### Connect to MariaDB

**From your host machine:**

```bash
mysql -h 127.0.0.1 -P 3306 -u ajelloul -pAboubakr@1337
```

**Exec into the container first:**

```bash
docker exec -it mariadb-test bash

# Then inside:
mysql -u ajelloul -p            # as your user
mysql -u root -pAboubakr@1337   # as root
```

---

### Hands-on SQL Practice

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

UPDATE wp_users SET user_login = 'aidnssar'  WHERE user_login = 'lbob'; 
UPDATE users SET email = 'alice@new.com' WHERE name = 'Alice';

-- Delete
DELETE FROM users WHERE name = 'Bob';

-- Drop table
DROP TABLE users;
```

### redis cash issue :

1. Flush Redis cache (quickest fix):
bashdocker exec -it redis redis-cli FLUSHALL
Then try logging in as lbob again — it should fail now.
2. Also delete the user properly from WordPress (the right way):
Don't delete directly from the DB. Use WP-CLI inside the wordpress container:
bashdocker exec -it wordpress wp user delete lbob --reassign=1 --allow-root
Replace 1 with the admin user ID to reassign their content, or use --network flag if multisite.
3. Verify the user is gone:
bashdocker exec -it wordpress wp user list --allow-root


---

### Useful Admin Commands

> Run these as root.

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

### Container Lifecycle

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

# 4. Watch logs
docker logs -f mariadb-test
```

---

### Common Fixes

| Problem | Fix |
|---|---|
| `Found option without preceding group` | `50-server.cnf` must start with `[mysqld]` on line 1 |
| `Access denied for root (using password: NO)` | Add `-u root -p"${ROOT_PASS}"` to the `mysqladmin shutdown` call |
| `no such file or directory` on build | Run `docker build` from inside the `mariadb/` folder |
| Want a clean slate | Stop, remove container with `-v`, remove volume, rebuild |

---

### Configuration File Explained

Your config file (`50-server.cnf`) contains:

```ini
[mysqld]
user = mysql
bind-address = 0.0.0.0
port = 3306
datadir = /var/lib/mysql
```

#### `[mysqld]`

MariaDB configuration files are divided into sections. `[mysqld]` means:

> "These settings apply to the MariaDB server daemon."
> (`mysqld` = the MariaDB server process)

#### `user = mysql`

Runs the MariaDB server as the `mysql` Linux user — not as `root`. This is a security best practice. You never want a database server running with root privileges.

#### `bind-address = 0.0.0.0`

Tells MariaDB which network interfaces to listen on.

| Value | Meaning |
|---|---|
| `127.0.0.1` | Localhost only — WordPress container **cannot** connect |
| `0.0.0.0` | All interfaces — **required** for container-to-container communication |

In Docker, `0.0.0.0` is necessary so other containers (like WordPress) can reach MariaDB over the internal network.

#### `port = 3306`

The default MariaDB/MySQL port. WordPress connects to `mariadb:3306` through the Docker network.

#### `datadir = /var/lib/mysql`

Defines where MariaDB stores all its data: databases, tables, indexes, logs, and internal files. This should point to your Docker volume to ensure persistence:

```yaml
volumes:
  - mariadb_data:/var/lib/mysql
```

#### Why is the file named `50-server.cnf`?

MariaDB reads configuration files from directories like `/etc/mysql/` and `/etc/mysql/mariadb.conf.d/` in **numerical order**. Later files override earlier ones.

```
10-client.cnf
20-server.cnf
50-server.cnf   ← you are here
99-custom.cnf
```

Debian/MariaDB packages already use this naming convention for their main server config. Using `50-server.cnf` is correct and professional — it slots right into the expected order without breaking anything.

---

### Setup Script Internals

#### Key Files

| File | Purpose |
|---|---|
| `mysqld.pid` | Process ID of the MariaDB server |
| `mysqld.sock` | Unix socket for local connections |

#### What is `mysqld.sock`?

A Unix socket file. Local programs communicate with MariaDB through it instead of TCP — it's faster for same-machine connections.

#### Starting MariaDB Temporarily

```bash
mariadbd --user=mysql &
```

The `&` is critical. Without it, the script halts at that line forever and no subsequent commands execute. With `&`, MariaDB runs in the background and the script continues.

#### Shutting Down the Temporary Instance

```bash
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
```

This gracefully stops the temporary MariaDB instance used only for initial setup. Once setup is complete, it must be stopped before launching the final production process.

#### Waiting for MariaDB to Be Ready

```bash
if mysqladmin ping --silent 2>/dev/null; then
    break
fi
```

| Part | Meaning |
|---|---|
| `mysqladmin ping` | Asks MariaDB: "Are you alive?" |
| `--silent` | Suppresses normal output (`mysqld is alive`) but keeps the exit status |
| `2>/dev/null` | Redirects error messages to `/dev/null` so they don't spam the terminal |

#### Waiting for Full Shutdown

```bash
wait $pid
```

Waits until the background MariaDB process has fully exited. Without this, a race condition can occur where the second MariaDB instance starts before the first one has stopped.

#### Why `exec`?

```bash
exec mariadbd ...
```

Without `exec`, the process tree is `bash → mariadbd`. Bash remains PID 1. With `exec`, `mariadbd` **becomes** PID 1 — which is required in Docker. The main service should always be PID 1.

---

## Nginx

### What is Nginx?

Nginx is a high-performance web server and reverse proxy. In the Inception project, its primary roles are:

- **TLS Terminator** — handles HTTPS encryption/decryption so the backend (WordPress) doesn't have to.
- **Static File Server** — serves HTML, CSS, and images directly and efficiently.
- **Router** — forwards dynamic requests to the correct service via the FastCGI protocol.

---

### Why Docker Copies to `conf.d/`

```dockerfile
COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf
```

The base `/etc/nginx/nginx.conf` already exists and already includes `conf.d/*.conf`. If you overwrote it directly:

```dockerfile
COPY nginx.conf /etc/nginx/nginx.conf  # ❌
```

You would replace the full Nginx system config and risk breaking the event loop, logging, MIME types, includes, and performance settings.

Using `/etc/nginx/conf.d/` is safer and standard — it allows modular configuration, supports multiple apps, and avoids touching the core Nginx setup.

---

### Nginx Configuration

FastCGI is a high-performance binary protocol that acts as an interface between web servers (like Nginx) and dynamic applications (like PHP-FPM).

| Protocol | Behavior |
|---|---|
| CGI | A new process is created for every request — inefficient |
| FastCGI | A persistent process waits for requests — efficient |

**Architecture:**

```
Browser
   ↓ HTTPS
Nginx container
   ↓ FastCGI
WordPress / PHP-FPM container
   ↓ SQL
MariaDB container
```

---

### Location `/` — WordPress Routing

```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

This is the most important WordPress routing rule.

#### `try_files` Explained

Nginx checks files **in order**. If one exists, it serves it and stops. If none exist, it falls back to the last entry.

```nginx
try_files $uri $uri/ /index.php?$args;
```

| Step | What Nginx tries |
|---|---|
| `$uri` | The exact requested file path |
| `$uri/` | The path as a directory |
| `/index.php?$args` | Fallback — the WordPress front controller |

#### Examples

**Static file** — `GET /logo.png`

Nginx finds `/var/www/html/logo.png` on disk → serves it directly. No PHP needed.

**Directory** — `GET /wp-admin/`

Nginx finds `/var/www/html/wp-admin/` → serves the directory index.

**WordPress pretty URL** — `GET /my-first-post`

Neither `/var/www/html/my-first-post` nor `/var/www/html/my-first-post/` exist → falls back to `/index.php?$args`. WordPress receives the request through `index.php` and its internal routing system maps it to the correct post.

#### Why WordPress Needs This

WordPress URLs are **virtual** — `/hello-world` is not a real file on disk. WordPress maps it from the database at runtime. Without `try_files`, pretty permalinks break entirely.

`$args` preserves the query string (`?q=nginx`, etc.) when passing to `index.php`.

---

### PHP Location Block

```nginx
location ~ \.php$ {
    include fastcgi_params;
    fastcgi_pass wordpress:9000;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

#### `location ~ \.php$`

`~` enables regex matching. `\.php$` matches any URL ending with `.php` — such as `index.php`, `wp-login.php` — and excludes everything else (CSS, images, etc.).

#### `include fastcgi_params`

Loads standard FastCGI variables that PHP needs, such as `REQUEST_METHOD`, `QUERY_STRING`, `CONTENT_TYPE`, and `SERVER_NAME`.

#### `fastcgi_pass wordpress:9000`

The most important line. Forwards the PHP request to the `wordpress` container on port `9000`, where PHP-FPM is listening. Docker's internal DNS resolves the service name `wordpress` to the correct container IP automatically.

> **Important:** Nginx does **not** execute PHP. It only forwards the request to PHP-FPM.

#### `fastcgi_param SCRIPT_FILENAME`

```nginx
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

Tells PHP-FPM exactly which file to execute.

| Variable | Example value |
|---|---|
| `$document_root` | `/var/www/html` |
| `$fastcgi_script_name` | `/index.php` |
| **Combined result** | `/var/www/html/index.php` |

---

### Full Request Flow

**Example:** user visits `https://ajelloul.42.fr/wp-login.php`

```
1. Browser sends HTTPS request
       ↓
2. Nginx receives request, matches location ~ \.php$
       ↓
3. Nginx forwards to wordpress:9000 via FastCGI
       ↓
4. PHP-FPM executes /var/www/html/wp-login.php
       ↓
5. WordPress queries MariaDB → SELECT * FROM wp_users
       ↓
6. MariaDB returns user data
       ↓
7. PHP generates HTML for the login page
       ↓
8. Nginx sends the response back to the browser
```

---

### How to Test

| What to test | URL |
|---|---|
| Homepage | `https://ajelloul.42.fr` |
| Login page | `https://ajelloul.42.fr/wp-login.php` |
| Admin panel | `https://ajelloul.42.fr/wp-admin/` |
| Pretty permalinks | `https://ajelloul.42.fr/hello-world` |

**Verify MariaDB persistence:**

Create posts, users, or settings inside the WordPress dashboard. Restart the containers. If the data still exists, the MariaDB volume is working correctly.




## redis

> how to test  redis :

```
docker exec -it wordpress bash
```

Install redis tools (temporary test)

```
apt update && apt install redis-tools -y

```

Connect to Redis container
```
redis-cli -h redis
```
Important: hostname is service name redis (Docker DNS)



test
```
ping
```

Expected:
```
PONG
```

This proves:

>containers communicate through Docker network
WordPress can reach Redis


Step : watch keys live
```
keys *
```

If WordPress cache plugin is active, you may see:

wp_...

### redis cmds 
PING: Checks server connectivity.
DBSIZE: Returns the number of keys.
FLUSHALL: Removes all keys from all databases.
KEYS * : Finds keys
INFO : Server Info



1. WordPress → Redis connection is created by PHP plugin (NOT your script)

This line is the key:

wp plugin install redis-cache --activate --allow-root

This installs and activates a WordPress plugin called Redis Object Cache.

That plugin contains the actual PHP code that connects to Redis.

🔌 So where is the real connection code?

Inside WordPress after installation:

/var/www/html/wp-content/plugins/redis-cache/

And more importantly, it uses:

wp-content/object-cache.php

That file is the bridge between WordPress and Redis.

2. The real mechanism: object-cache.php

When Redis plugin is enabled, it drops a file like:

wp-content/object-cache.php
This file is VERY important.

WordPress automatically loads it if it exists.

It overrides WordPress caching system.

⚙️ What does it do?

It replaces default WordPress caching functions:

Normally WordPress does:
Database → PHP → page generation
With Redis plugin:
WordPress cache API → object-cache.php → Redis server
🔗 3. Where does Redis connection actually happen?

Inside PHP code like:

$redis = new Redis();
$redis->connect('redis', 6379);

BUT you usually don’t see this directly because:

👉 the plugin handles it internally

🧩 4. How WordPress knows Redis exists

These lines in your script:

wp config set WP_REDIS_HOST redis
wp config set WP_REDIS_PORT 6379
wp config set WP_CACHE true --raw

This creates in wp-config.php:

define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_CACHE', true);


Key takeaway

The real connection code is inside:

wp-content/object-cache.php

and the Redis plugin:

wp-content/plugins/redis-cache/

Your bash script only:

installs plugin
sets config values
enables caching

## FTP

1. Install FileZilla on Ubuntu :
```
sudo apt update && sudo apt install -y filezilla

filezilla --version
```



What does -R mean?

Recursive.

Meaning:

apply to folder
and all files/subfolders inside

What is /var/lib/mysql?

This is the actual database storage directory.

Inside are:

tables
indexes
user accounts
WordPress data



Does EXPOSE open the port?

NO.

This is VERY important.

EXPOSE does NOT publish the port to your computer.

It only:

documents the port
tells Docker:
“this container listens on this port”



Your Computer (FileZilla)
        │
        ▼
 Docker Host
        │
        ├── Port 21
        │      FTP commands/login
        │
        └── Ports 30000-30009
               file transfer
                    │
                    ▼
           FTP Container
                    │
                    ▼
           /var/www/html
                    │
                    ▼
           Shared Docker Volume
                    │
                    ▼
          WordPress sees files instantly


You only see ports 30000–30009 when a client is actively using FTP data transfer.

Right now you see:

0.0.0.0:21 LISTEN

That is ONLY the control port.

💥 Important concept (this is the key)

FTP passive ports are:

❌ NOT permanently open
✅ opened dynamically only during file operations

📦 What you are missing

You are only doing:

container running
no FileZilla connected
no upload/download/list

So:

👉 ports 30000–30009 are NOT used yet

🔥 When DO 30000–30009 appear?

They appear ONLY when you do actions like:

1. List directory
ls
2. Upload file
put file.txt
3. Download file
get file.txt
🧪 HOW TO PROVE IT (evaluation trick)
Step 1: open monitoring

Inside FTP container:

watch ss -tulnp
Step 2: connect with FileZilla
host: localhost or 127.0.0.1
port: 21
user: ftpuser
Step 3: DO something

Example:

upload image
refresh directory
Step 4: you will see

Suddenly:

ESTAB  172.18.0.2:30001
ESTAB  172.18.0.2:30003

or LISTEN temporarily:

0.0.0.0:30000
0.0.0.0:30001
🧠 WHY YOU DON’T SEE THEM NOW

Because:

Condition	Result
FTP server started	only port 21
no client activity	no passive ports
FileZilla idle	no data channel


test : ```docker exec -it ftp bash ``` and upload a files ```watch "ss -tan | grep 30" ```





