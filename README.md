## The bad old days

Applications run businesses. If applications break, businesses break. Sometimes they even go bust. These statements get truer every day.

Most applications run on servers. In the past, we could only run one application per server. The open-systems world of Windows and Linux simply didn’t have the technologies to safely and securely run multiple applications on the same machine. So every time the business needed a new application, IT would buy a new server — often without knowing the application’s performance requirements. IT made conservative guesses and bought big, fast servers with lots of resiliency. The last thing anyone wanted was an underpowered server that couldn’t execute transactions and might lose customers and revenue.

The result was large numbers of servers running at 5–10% of their capacity. A tragic waste of capital and resources.

## Hello VMware!

Then VMware gave the world a gift — the virtual machine (VM). Suddenly we could safely and securely run multiple business applications on a single server. IT no longer needed to procure a new oversized server each time the business asked for an application. More often than not, new apps could run on existing servers with spare capacity. This let organizations extract far more value from their existing assets.

## But… (and there’s always a but)

As useful as VMs are, they’re not perfect. Every VM requires its own dedicated operating system. Each OS consumes CPU, RAM, and storage that could otherwise power applications. Each OS needs patching and monitoring and, in some cases, licensing. That adds operational and capital expense.

VMs also boot slowly, and portability can be limited — migrating VM workloads between hypervisors and cloud platforms can be harder than it should be.

## Hello Containers!

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

When somebody says “Docker” they can be referring to any of at least three things:

1. Docker, Inc. the company  
2. Docker the container runtime and orchestration technology  
3. Docker the open source project (this is now called Moby)  

Docker is an open-source platform for packaging applications into containers: isolated environments that include everything the app needs to run, including code, dependencies, and configuration. The core problem it solves is environment inconsistency. A script that works on your laptop breaks on a server because of a different Python version or a missing library. Docker greatly reduces that inconsistency


## Docker architecture

Docker uses a client-server architecture. The Docker client talks to the Docker daemon, which does the heavy lifting of building, running, and distributing your Docker containers
![Docker architecture diagram — containers, engine, and host](https://docs.docker.com/get-started/images/docker-architecture.webp)
*Figure: Docker architecture — engine, images, containers, and host OS.*


### The Docker client
The Docker client (docker) is the primary way that many Docker users interact with Docker. When you use commands such as docker run, the client sends these commands to dockerd.

### The Docker daemon
The Docker daemon (dockerd) listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes. A daemon can also communicate with other daemons to manage Docker services.

### Docker registries
A Docker registry stores Docker images. Docker Hub is a public registry that anyone can use, and Docker looks for images on Docker Hub by default. You can even run your own private registry.

When you use the docker pull or docker run commands, Docker pulls the required images from your configured registry. When you use the docker push command, Docker pushes your image to your configured registry.