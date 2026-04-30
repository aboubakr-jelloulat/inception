## The bad old days


![Diagram 2](https://m.media-amazon.com/images/I/91iSdt0DDJS._AC_SL1500_.jpg)


Applications run businesses. If applications break, businesses break. Sometimes they even go bust. These statements get truer every day.

Most applications run on servers. In the past, we could only run one application per server. The open-systems world of Windows and Linux simply didn’t have the technologies to safely and securely run multiple applications on the same machine. So every time the business needed a new application, IT would buy a new server — often without knowing the application’s performance requirements. IT made conservative guesses and bought big, fast servers with lots of resiliency. The last thing anyone wanted was an underpowered server that couldn’t execute transactions and might lose customers and revenue.

The result was large numbers of servers running at 5–10% of their capacity. A tragic waste of capital and resources.

## Hello VMware!


Then VMware gave the world a gift — the virtual machine (VM). Suddenly we could safely and securely run multiple business applications on a single server. IT no longer needed to procure a new oversized server each time the business asked for an application. More often than not, new apps could run on existing servers with spare capacity. This let organizations extract far more value from their existing assets.

## But… (and there’s always a but)

As useful as VMs are, they’re not perfect. Every VM requires its own dedicated operating system. Each OS consumes CPU, RAM, and storage that could otherwise power applications. Each OS needs patching and monitoring and, in some cases, licensing. That adds operational and capital expense.

VMs also boot slowly, and portability can be limited — migrating VM workloads between hypervisors and cloud platforms can be harder than it should be.

## Hello Containers!


![Diagram 2](https://img.freepik.com/premium-photo/freight-shipping-container-with-flag-china-crane-hook-3d-illustration_493343-54485.jpg?semt=ais_hybrid&w=740&q=80)


Web-scale players, such as Google, adopted container technologies to address VM shortcomings.

In the container model, the container is roughly analogous to the VM, but containers do not require a full-blown OS per instance. All containers on a host share the host OS. That frees up CPU, RAM, and storage, reduces licensing and OS maintenance overhead, and lowers op-ex and cap-ex.

Containers are also fast to start and highly portable. Moving container workloads from your laptop to the cloud, or between VMs and bare metal, is straightforward.


## Linux containers

Modern containers began in the Linux world and are the result of sustained work by many people and organizations over many years. Key kernel technologies notably namespaces, control groups (cgroups), and union filesystems  laid the technical foundation for containers. Major contributors, including Google, added important container-related features to the Linux kernel; without those contributions we wouldn’t have the modern container ecosystem we rely on today.

That foundation made containers possible long before Docker. However, containers remained relatively complex and out of reach for most organizations until Docker arrived and effectively democratized container usage, making them accessible to the masses.


## Containers vs VMs


Virtualization is a process lets you run virtual instances of computer systems on top of physical hardware. It enables multiple operating systems to run concurrently on the same machine.

A Virtual Machine (VM) is a software-based computer that runs inside a physical machine. It emulates a complete system, including hardware, allowing it to run its own operating system and applications independently from the host.
VM is managed by a hypervisor, which is a software layer responsible for creating and running virtual machines. There are two types of hypervisors: bare-metal hypervisor : runs directly on the physical hardware, Hosted hypervisor : runs on top of an existing operating system
Common tools include VirtualBox and VMware.

A container is an isolated (namespaces) and restricted (cgroups, capabilities, seccomp) process. Virtualize the Operating System. They share the host system’s kernel and isolate the application processes from the rest of the system. This makes them lightweight and near instant to start.

For a structured learning path on containers, see "Learning Containers From The Bottom Up": <https://iximiuz.com/en/posts/container-learning-path/>.



## "VMs Relaxed  Then Containers Threw a House Party" : The Rise of Containers

We used to live in a world where every time the business wanted a new application, we had to buy a brand-new server for it. 
Then VMware came along and enabled IT departments to drive more value out of new and existing company IT assets.
But as good as VMware and the VM model is, it’s not perfect. Following the success of VMware and hypervisors came a newer more efficient and lightweight virtualization technology called containers. But containers were initially hard to implement and were only found in the data centers of web giants that had Linux kernel engineers on staff. 
Then along came Docker Inc. and suddenly container virtualization technologies were available to the masses.
Speaking of Docker… let’s go find who, what, and why Docker is!


## Hello Docker!

![Hello Docker](https://gadelkareem.com/wp-content/uploads/2018/10/1_JAJ910fg52ODIRZjHXASBQ.png)

When somebody says “Docker” they can be referring to any of at least three things:

1. Docker, Inc. the company  
2. Docker the container runtime and orchestration technology  
3. Docker the open source project (this is now called Moby)  

Docker is an open-source platform for packaging applications into containers: isolated environments that include everything the app needs to run, including code, dependencies, and configuration. The core problem it solves is environment inconsistency. A script that works on your laptop breaks on a server because of a different Python version or a missing library. Docker greatly reduces that inconsistency


## Docker architecture

Docker uses a client-server architecture. The Docker client talks to the Docker daemon, which does the heavy lifting of building, running, and distributing your Docker containers
![Docker architecture diagram — containers, engine, and host](https://docs.docker.com/get-started/images/docker-architecture.webp)
*Docker architecture*


### The Docker client
The Docker client (docker) is the primary way that many Docker users interact with Docker. When you use commands such as docker run, the client sends these commands to dockerd.

### The Docker daemon
The Docker daemon (dockerd) listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes. A daemon can also communicate with other daemons to manage Docker services.

### Docker registries
A Docker registry stores Docker images. Docker Hub is a public registry that anyone can use, and Docker looks for images on Docker Hub by default. You can even run your own private registry.

When you use the docker pull or docker run commands, Docker pulls the required images from your configured registry. When you use the docker push command, Docker pushes your image to your configured registry.

## Docker components

Docker originally used a monolithic architecture and relied on LXC (Linux Containers) to create lightweight container environments. As it evolved, Docker adopted a more modular architecture, replacing LXC with its own solution, libcontainer, to improve flexibility and cross-platform support. Today, Docker architecture is broken into five components: dockerCLI, dockerd, containerd,containerd-shim and runc

![Diagram 1](https://i.sstatic.net/tZwUP.png)


### Docker CLI (docker)
The command-line client users run (docker run, docker build). It composes user intent into API calls and requests to the Docker daemon. The CLI is a user facing tool for building images, running containers, managing networks/volumes, and interacting with registries.

### dockerd (Docker daemon / engine)
The long‑running service that implements the Docker API. It receives requests from the CLI (or other clients), manages images, networks, volumes, and coordinates higher‑level container lifecycle actions. dockerd talks to lower‑level runtimes (via containerd), stores image layers, and enforces Docker’s policies and configurations.

### containerd
A dedicated daemon that manages container lifecycle primitives: pulling/pushing images, storing image content, creating and managing snapshots, and supervising container execution. containerd provides a stable, focused API for runtimes and higher‑level systems (like dockerd) and splits the heavy lifting out of the Docker daemon.

### containerd‑shim
A small per‑container process launched by containerd that stays running after the container process starts. The shim’s responsibilities:
- Reparents the container process so the container can run independently of containerd (so containerd can restart without killing containers).  
- Streams container stdio and exit status back to containerd.  
- Keeps a minimal state so the runtime can exit while the container continues running.  
In short: the shim isolates containerd from the container process lifecycle.

### runc
The low‑level OCI runtime that actually creates and runs the container process using kernel primitives (namespaces, cgroups, chroot/mounts). runc implements the OCI runtime spec: it takes an on‑disk bundle (rootfs + config.json) and uses Linux kernel features to start the process inside the container. containerd typically invokes runc (or another OCI runtime) to perform the final syscall‑level work.

### How they work together
1. You run a Docker CLI command.  
2. CLI calls dockerd’s API.  
3. dockerd delegates image/content and runtime tasks to containerd.  
4. containerd prepares the image and requests an OCI runtime to start the container.  
5. containerd invokes runc to create the container process.  
6. containerd spawns a containerd‑shim for that container so the container can keep running even if containerd restarts.  
7. runc uses kernel namespaces, cgroups, and mounts to instantiate the container process.


## docker request flows

![Diagram 2](https://i.sstatic.net/KanIf.jpg)

The docker request flows over until the container is created.

A user uses the docker CLI to execute a command  
docker container run -it --name <NAME> <IMAGE>:<TAG>  

The docker client then POSTs the API payload to the correct API docker deamon’s endpoint  

Docker deamon receives instructions and calls containerd to start a new container  

containerd creates an OCI bundle from the Docker image (like we did above in the section “2. runc”)  

containerd tells runc to create a container using the OCI bundle  

runc interfaces with the OS kernel to create a container  

Container process starts as a child process  

runc exits once the container starts  

shim takes over the child process and becomes it’s parent  

Container is running!  

_for more deep about docker component see : https://medium.com/@yeldos/docker-engine-architecture-under-the-hood-741512b340d5_


## Docker Image


![Diagram 2](https://i.pinimg.com/736x/df/b2/4f/dfb24f83e60e7488c8b50456ad34e4db.jpg)

A container image is an immutable (unchangeable) file that contains everything needed to run an application: code, binaries, libraries, packages and configurations. It ensures the application runs consistently across different environments.

It is built from layered file systems on top of a base image, which allows reuse and helps reduce size and improve performance.

You can think of a container image as a template (like a class or a VM template) used to create running containers.


## What is a Dockerfile?

A Dockerfile is a simple text file that contains a set of instructions used to build a Docker image. It defines everything needed to assemble the image: the base system, dependencies, application code, and runtime configuration.

a Dockerfile acts as a **blueprint** for your image. Instead of manually setting up an environment, you describe the steps once, and Docker reproduces them consistently every time.


### Basic Structure of a Dockerfile

A Dockerfile is composed of a sequence of instructions. Each instruction performs a specific action and usually creates a new layer in the image.

Common instructions include:

- `FROM` – defines the base image
- `RUN` – executes commands during the build process
- `COPY` / `ADD` – copies files into the image
- `CMD` – specifies the default command to run
- `ENTRYPOINT` – defines the main executable
- `ENV` – sets environment variables
- `WORKDIR` – sets the working directory



## What Are Docker Image Layers?


![Diagram 2](https://miro.medium.com/v2/resize:fit:4800/format:webp/1*Jl97IVi_he8VdHvX9EbWcA.png)


A Docker image is not a single monolithic file. It is built as a sequence of **layers**, each representing a set of changes applied to a filesystem. These layers are stacked on top of one another to form the final image.

A useful way to think about a layer is as a **filesystem diff**: it contains only what changed compared to the previous layer. This could include adding files, modifying existing ones, or deleting them.

Each instruction in a Dockerfile typically creates a new layer. Because layers are immutable and cached, Docker can reuse them across builds, which makes image construction efficient and fast.


### What Does a Layer Contain?

A layer does not have a fixed type of content. Instead, it can include anything that can exist in a filesystem:

- Application source code
- Compiled binaries
- Installed packages and their dependencies
- Configuration files
- System libraries
- File deletions or modifications

In other words, a layer reflects the *result* of executing a single Dockerfile instruction.

It is also important to distinguish between **filesystem layers** and **image metadata**. Some instructions (like `RUN` or `COPY`) create filesystem layers, while others (like `CMD`) define metadata that tells Docker how to run the container.

#### Filesystem Layers vs Image Metadata

When working with Docker images, it is important to understand that not every instruction in a Dockerfile produces the same kind of result. Broadly speaking, Docker image instructions fall into two categories:

- Filesystem layers
- Image metadata

They serve different purposes and are handled differently by Docker.



#### Filesystem Layers

Filesystem layers represent **actual changes to the image’s filesystem**. Each of these layers is created when an instruction modifies the contents of the image (files, directories, installed software ...).

#### What creates filesystem layers?

The following instructions typically create filesystem layers:

- `FROM`
- `RUN`
- `COPY`
- `ADD`

#### What do filesystem layers contain?

A filesystem layer is essentially a **diff** (difference) from the previous layer. It can include:

- New files (application code)
- Installed packages (Python, Node.js, golang ...)
- System libraries and binaries
- Modified files
- Deleted files

Each layer is immutable and stacked on top of the previous ones to form the final filesystem.


#### Image Metadata

Image metadata does not affect the filesystem. Instead, it defines how the image behaves when it is run as a container. Define runtime behavior Contains configuration and execution settings

#### What creates image metadata?

Common metadata instructions include:

- `CMD`
- `ENTRYPOINT`
- `ENV`
- `EXPOSE`
- `WORKDIR`
- `USER`
- `LABEL`

#### What does metadata contain?

Metadata defines:

- Default command to run (`CMD`)
- Executable entrypoint (`ENTRYPOINT`)
- Environment variables (`ENV`)
- Default working directory (`WORKDIR`)
- Exposed network ports (`EXPOSE`)
- Additional descriptive information (`LABEL`)


```dockerfile
CMD ["python3", "/app/app.py"]
```

### Breaking Down an Image Layer by Layer

Consider the following Dockerfile:

```dockerfile
FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install -y python3
COPY app.py /app/app.py
CMD ["python3", "/app/app.py"]
```


#### 1. Base Layer — `FROM ubuntu:22.04`

This instruction defines the starting point of the image. It pulls a prebuilt image based on Ubuntu 22.04.

This base layer already contains a complete minimal Linux filesystem, including:

- Core system directories (`/bin`, `/usr`, `/lib`, ...)
- Essential system libraries (such as `libc`)
- Basic command-line utilities (`bash`, `ls`, `cat`, ...)
- Package management tools (`apt`)

Everything that follows builds on top of this foundation.

---

#### 2. Update Package Index — `RUN apt-get update`

This step creates a new layer that updates the package manager’s index.

What this layer adds:

- Updated package lists stored under `/var/lib/apt/lists/`
- Metadata required for installing software

No new software is installed yet; this layer only prepares the system for installation.

---

#### 3. Install Python — `RUN apt-get install -y python3`

This layer installs Python and its dependencies.

What this layer contains:

- Python binary (typically `/usr/bin/python3`)
- Standard libraries for Python
- Shared libraries required by Python
- Additional system packages pulled as dependencies

This is usually one of the heavier layers because it introduces multiple files and dependencies.

---

#### 4. Add Application Code — `COPY app.py /app/app.py`

This instruction copies your application code into the image.

What this layer contains:

- A new directory `/app` (if it does not already exist)
- The file `app.py` placed at `/app/app.py`

This layer is typically small, but it is the one that changes most frequently during development.

---

#### 5. Runtime Metadata — `CMD ["python3", "/app/app.py"]`

This instruction does not create a filesystem layer.

Instead, it defines metadata for the image:

- The default command to run when a container starts from this image

In this case, it tells Docker to execute:

```bash
python3 /app/app.py
```


## Docker containers
![DockerContainers] (https://www.theinfostride.com/wp-content/uploads/2025/07/Containers.jpg)


A container is the runtime instance of an image. In the same way that we can start a virtual machine (VM) from a virtual machine template, we start one or more containers from a single image. 
The big difference between a VM and a container is that containers are faster and more lightweight  instead of running a full-blown
OS like a VM, containers share the OS/kernel with the host they’re running on.

## How Docker Uses the Linux Kernel for Isolation


A container is not a virtual machine. A VM emulates an entire computer, including its own kernel. A container is just a regular Linux process but one that has been tricked into thinking it's alone on the machine. That trick is pulled off by three kernel features: **Namespaces**, **cgroups**, and **OverlayFS**. Docker is just a friendly tool that orchestrates all three.



### Namespaces — the isolation trick

A namespace wraps a global kernel resource and gives a process its own private view of it. The process thinks it owns the world. Six types are used: `PID` (its own process tree), `NET` (its own network stack and ports), `MNT` (its own filesystem view), `UTS` (its own hostname), `IPC` (its own inter process communication), and `USER` (root inside the container, unprivileged on the host).

### cgroups — the resource governor

cgroups enforce hard limits on what a group of processes is allowed to consume. Docker uses them to cap CPU, memory, disk I/O, and process count  so one container can never starve the rest of the machine.

### OverlayFS — the magic filesystem

OverlayFS stacks the read-only image layers under a per-container writable layer. The container sees one unified filesystem. Reads come straight from the shared image at zero cost; writes copy only the modified file into the container's private layer. Delete a container — the image is untouched, ready for the next one.

OverlayFS works with two layers:

lowerdir (read-only) — this is the Docker image. It's immutable. Shared between every container that uses the same image. If 100 containers use the Ubuntu image, they all read from the same lowerdir on disk. Zero duplication.

upperdir (read-write) — this is the container's private "scratch space." It starts empty. When a container modifies a file, the change goes here, not into the lowerdir.

> These three primitives are the entire foundation of containers. Everything else Docker, Podman, Kubernetes is tooling built on top of the same kernel APIs.


## Storage in Docker


![Diagram 2](https://www.ajfriesen.com/content/images/size/w1200/2024/09/docker-volumes-vs-bind-mounts.png)


Containers are ephemeral, when you delete one, everything written inside it is gone. For data that needs to survive, Docker gives you two options: **Bind Mounts** and **Docker Volumes**.


### Bind Mount

A bind mount takes a directory on your host machine and mounts it directly into the container. Same files, same bytes seen from two places at once. Edit a file on your host, the container sees it instantly. The container writes a file, it appears on your host instantly.

It's the go to during development: your editor changes code on your machine, the container picks it up without a rebuild.

```bash
# Basic syntax
docker run -v /host/path:/container/path image

# Example — mount your source code into a Node container
docker run -v $(pwd)/src:/app node:20 node /app/server.js

# Read-only — container can read but not write back
docker run -v /host/config:/etc/app:ro image

```


### Docker Volumes

A Docker volume is a directory that Docker itself creates and manages. You give it a name, Docker decides where it lives on the host, under `/var/lib/docker/volumes/<name>/_data`. You never need to think about the host path.

Because Docker owns it, a volume survives container deletions, can be shared between containers, and is portable, a volume named `pgdata` means the same thing on any machine running Docker.

```bash
# Create a named volume
docker volume create mydata

# Use it when running a container
docker run -v mydata:/app/data image

# Example — Postgres database that survives container restarts
docker run -d -v pgdata:/var/lib/postgresql/data postgres:16


# List all volumes
docker volume ls

# Inspect a volume (shows the host path and connected containers)
docker volume inspect mydata

# Delete a volume
docker volume rm mydata

# Delete all unused volumes
docker volume prune
```


## Bind Mount vs Docker Volume

| | Bind Mount | Docker Volume |
|---|---|---|
| Who manages the path | You | Docker |
| Path on host | You choose | `/var/lib/docker/volumes/…` |
| Survives `docker rm` | Yes (it's your file) | Yes (Docker keeps it) |
| Portable across machines | No (path must exist) | Yes (name is the reference) |
| Best for | Local development | Production data |

