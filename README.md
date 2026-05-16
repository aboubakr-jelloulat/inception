*This project has been created as part of the 42 curriculum by [ajelloul].*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small infrastructure of services inside a virtual machine using Docker and Docker Compose. Each service runs in its own container, built from scratch using custom Dockerfiles based on Alpine or Debian.

The infrastructure includes:

- **NGINX** — the only entry point, listens on port 443 with TLS (TLSv1.2/1.3)
- **WordPress** — runs PHP-FPM, communicates with NGINX over a Unix socket on port 9000
- **MariaDB** — the database backend for WordPress
- **Redis** — object cache for WordPress
- **FTP** — gives FTP access to the WordPress volume
- **Adminer** — a lightweight database management UI, accessible on port 8888
- **Dozzle** — a real-time container log viewer, accessible on port 9090
- **Static website** — a simple personal page served on port 8081

### Docker in this project

Docker is used to isolate each service into its own container, keeping the environment reproducible and easy to manage. Each container is built from a custom Dockerfile — no pre-built images from Docker Hub for the main services.

All containers communicate through a user-defined bridge network called `inception`. This gives them automatic DNS resolution by name (e.g., `wordpress` can reach `mariadb` just by using the name `mariadb`). The default Docker bridge network does not support this.

Persistent data (the database and WordPress files) is stored in named volumes that are bind-mounted to `/home/<user>/data/` on the host. This means data survives container restarts and rebuilds.

Sensitive credentials (database passwords, FTP password, WordPress admin credentials) are passed to containers using Docker secrets, not plain environment variables. Secrets are mounted as files inside the container under `/run/secrets/`, keeping them out of the process environment and away from `docker inspect` output.

---

### Design choices

**Virtual Machines vs Docker**

A Virtual Machine emulates a full computer. It runs its own OS kernel on top of a hypervisor (like VirtualBox or VMware), which sits either directly on the hardware (bare-metal) or on top of the host OS (hosted). Each VM is isolated at the hardware level, which makes it heavy — VMs take minutes to boot and consume a lot of memory and disk.

A container is different. It is an isolated process on the host system, using Linux kernel features like namespaces (for isolation) and cgroups (for resource limits). Containers share the host kernel — there is no second OS. This makes them lightweight and they start in seconds. The trade-off is that containers share the kernel, so the isolation is less strict than a VM.

For this project, containers make sense because each service is a single process, and the goal is reproducibility and speed, not hardware-level isolation.

**Secrets vs Environment Variables**

Environment variables are the simplest way to pass configuration into a container. They are visible via `docker inspect`, appear in the process environment, and can leak into logs or child processes. For non-sensitive values like `DOMAIN_NAME` or `MYSQL_DATABASE`, they are fine.

Docker secrets are a safer option for sensitive values. A secret is a file stored securely by Docker and mounted inside the container at `/run/secrets/<name>`. It is only accessible to the container that needs it, and it does not appear in `docker inspect` or the environment. This project uses secrets for all passwords.

**Docker Network vs Host Network**

With host networking (`--network host`), the container shares the host's network stack. It has no separate IP, no port mapping, and behaves exactly like a process running directly on the host. This is useful for performance-sensitive tools but removes isolation entirely.

With Docker's bridge networking (used here), each container gets its own IP and is isolated from the host network. A user-defined bridge like `inception` also provides internal DNS, so containers can reach each other by name. Port mapping (`-p 443:443`) is used explicitly to expose only what needs to be public.

This project uses a user-defined bridge network for all services, so they can communicate by name with proper isolation. Only NGINX, Adminer, FTP, Dozzle, and the static website expose ports to the host.

**Docker Volumes vs Bind Mounts**

A bind mount takes a specific path on the host and mounts it into the container. You decide where the data lives. Changes on either side are immediately visible on the other.

A Docker volume is managed by Docker. Docker decides where the data lives on the host (under `/var/lib/docker/volumes/`). Volumes are more portable and work better in production contexts where you do not want to depend on a specific host path.

This project uses a hybrid: volumes defined in `docker-compose.yml` with `driver: local` and `driver_opts` that configure them as bind mounts under `/home/<user>/data/`. This gives named volumes (so Docker manages them) while keeping the data at a predictable host path that survives `docker compose down`.

---

## Instructions

**Requirements:** Docker, Docker Compose, `sudo` access to edit `/etc/hosts`.

Clone the repository and run:

```bash
make
```

This will:
1. Create `/home/<user>/data/mariadb` and `/home/<user>/data/wordpress` on the host
2. Add `127.0.0.1 ajelloul.42.fr` to `/etc/hosts` if not already present
3. Build and start all containers in detached mode

**Other targets:**

```bash
make down     # Stop and remove containers
make clean    # Stop containers, prune Docker system, remove data directories
make re       # clean + all
```

Before running, make sure the `secrets/` directory exists at the project root with the following files:

```
secrets/
  db_password.txt
  db_root_password.txt
  credentials.txt
  ftp_password.txt
```

And a `.env` file in `srcs/` with at minimum:

```
DOMAIN_NAME=ajelloul.42.fr
MYSQL_DATABASE=...
MYSQL_USER=...
WP_ADMIN_USER=...
WP_ADMIN_EMAIL=...
WP_USER=...
WP_USER_EMAIL=...
FTP_USER=...
USER=<your system username>
```

Once running, the services are accessible at:

| Service   | URL                          |
|-----------|------------------------------|
| WordPress | https://ajelloul.42.fr       |
| Adminer   | http://localhost:8888        |
| Dozzle    | http://localhost:9090        |
| Website   | http://localhost:8081        |
| FTP       | ftp://localhost:21           |

---

## Resources

**Docker and containers**

- [A Learning Path for Container Fundamentals](https://iximiuz.com/en/posts/container-learning-path/) — good starting point covering the full container ecosystem
- [Docker Engine Architecture Under the Hood](https://medium.com/@yeldos/docker-engine-architecture-under-the-hood-741512b340d5) — explains how the Docker daemon, containerd, and runc work together
- [Docker Deep Dive — Nigel Poulton](https://ebooks.karbust.me/Technology/Docker%20Deep%20Dive%20-%20Nigel%20Poulton.pdf) — a practical book covering core Docker concepts
- [Docker Interview Q&A](https://www.dataquest.io/blog/docker-interview-questions-and-answers/) — covers a wide range of conceptual and practical topics
- [Deep Dive into runc and OCI Specifications](https://mkdev.me/posts/the-tool-that-really-runs-your-containers-deep-dive-into-runc-and-oci-specifications) — explains what actually runs containers at the OS level
- [How Docker Actually Works — The Hard Way](https://medium.com/@furkan.turkal/how-does-docker-actually-work-the-hard-way-a-technical-deep-diving-c5b8ea2f0422) — a low-level technical breakdown of namespaces, cgroups, and the container lifecycle

**NGINX and TLS**

- [What is NGINX?](https://medium.com/@sami.alesh/what-is-nginx-7db76b2e79f8) — a clear overview of NGINX and its use cases
- [The NGINX Handbook](https://www.freecodecamp.org/news/the-nginx-handbook/) — comprehensive guide covering configuration, proxying, and TLS setup
- [What is SSL?](https://stackchief.com/blog/What%20is%20SSL%3F) — explains TLS/SSL certificates and how HTTPS works

**AI usage**

AI (Claude) was used during this project for:
- Understanding Docker internals and clarifying documentation — how things work under the hood (namespaces, cgroups, the OCI stack)
- Helping create the setup and entrypoint bash scripts, then reviewing and questioning the output before using it
- Helping write and structure this README

All AI-generated content was reviewed, tested, and understood before being used. Where something wasn't clear, it was discussed with peers or reworked until it made sense.