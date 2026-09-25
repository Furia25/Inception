*This project has been created as part of the 42 curriculum by vdurand.*

# Inception

## Description

Inception is a system administration project whose goal is to build a small, production-like
web infrastructure entirely with Docker, inside a dedicated virtual machine. Every service
runs in its own container, built from a custom Dockerfile (no pre-built images from Docker
Hub are used, Debian being the only exception).

The mandatory stack served by this repository is:

- **NGINX** — TLSv1.2/TLSv1.3 only, the single entrypoint of the infrastructure (port 443).
- **WordPress + php-fpm** — the website itself, without any embedded web server.
- **MariaDB** — the database engine backing WordPress.

Bonus services (see the Bonus section below) extend the stack with caching, file transfer,
a static showcase site, a database GUI and a container management UI.

All persistent data is stored in Docker named volumes, physically located under
`/home/<user>/data` on the host (`vdurand` by default, or whoever runs `make`).

## Instructions

```bash
git clone <this-repo>
cd inception
make init-secrets   # generates any missing secret files under secrets/
make                # builds the images and starts the mandatory stack
```

To build and start the full stack including the bonus services:

```bash
make MODE=bonus
```

`MODE=bonus` adds `srcs/docker-compose-bonus.yml` on top of the mandatory compose file (see
`DEV_DOC.md` for details). Once the containers are up, the site is reachable at
`https://vdurand.42.fr` (see `USER_DOC.md` for the full access details and `DEV_DOC.md` for
the developer-oriented setup).

## Resources

- Docker official documentation (Dockerfile reference, Compose file reference, volumes,
  networks, healthchecks, secrets).
- The "Docker tutorial" I followed to get comfortable with multi-stage builds, `ENTRYPOINT`
  vs `CMD`, and why containers should never rely on `tail -f`/`sleep infinity` patterns to
  stay alive (PID 1 behaviour).
- Official documentation for each service: NGINX, php-fpm, WordPress (WP-CLI), MariaDB,
  Redis, vsftpd, Adminer, Portainer.

**AI usage:** I used an AI assistant  mainly for two things: drafting and structuring
these three markdown documents (README, USER_DOC, DEV_DOC) from my actual project files
(Makefile, docker-compose.yml, docker-compose-bonus.yml), and as a learning aid while writing
my shell setup scripts (`setup_db.sh`, `setup_wp.sh`, `setup_nginx.sh`, `setup_ftp.sh`,
`setup_adminer.sh`) — e.g. asking it to explain specific Bash constructs, WP-CLI commands, or
vsftpd/Redis configuration options I wasn't familiar with, and to review my draft scripts. I
did not have it generate my Dockerfiles or compose files directly; I wrote the infrastructure
configuration myself and used AI as a sounding board to check my understanding before asking
peers for review.

## Project description

### Docker usage and sources

Every service under `srcs/requirements/` has its own Dockerfile, built from a Debian base
image, and its own `tools/` setup script(s) that configure the service at container startup
(creating the WordPress config, the database users, the FTP user, etc.) before handing off to
the service's real foreground process, so that PID 1 is always the actual daemon and not a
placeholder loop. `srcs/docker-compose.yml` defines the mandatory services (`nginx`,
`wordpress`, `mariadb`) on a dedicated `inception` bridge network; `srcs/docker-compose-bonus.yml`
extends it (via Compose's multi-file merge) with `redis`, `ftp`, `adminer`, `portainer` and
`static`, and adds the extra environment variables / `depends_on` entries needed
on the `wordpress` and `nginx` services. Secrets (database, WordPress, FTP and Portainer
passwords) are stored as files under `secrets/` and injected via Docker secrets rather than
environment variables.

### Design choices and comparisons

**Virtual Machines vs Docker** — A VM virtualizes an entire machine, including its own
kernel, which makes it heavier to boot and to duplicate for each service. A Docker container
shares the host kernel and only packages the application and its dependencies, so it starts
in a fraction of the time and uses far less disk/RAM. This project uses one VM as the host
system (as required), and Docker containers inside it for each service, combining the
isolation of a VM at the infrastructure boundary with the lightness of containers for each
component.

**Secrets vs Environment Variables** — Environment variables (stored in `srcs/.env`) are
convenient for non-sensitive configuration (domain name, database name, usernames) but they
are visible in `docker inspect`, in the container's process environment, and can leak into
logs. Docker secrets mount their content as files inside the container (under
`/run/secrets/`), readable only at runtime and never exposed through `docker inspect` or
image layers, which is why this project keeps every password (`db_password`,
`db_root_password`, `wp_admin_password`, `wp_user_password`, `ftp_password`,
`portainer_password`) as a secret, referenced in the containers as `*_FILE` environment
variables pointing at `/run/secrets/<name>`.

**Docker Network vs Host Network** — `network: host` makes a container share the host's
network stack directly, removing network isolation and exposing every port the container
opens. This project instead defines a custom bridge network (`inception`) in
`docker-compose.yml`, so containers can resolve each other by service name (e.g. `wordpress`
talking to `mariadb`) while staying isolated from the host and from each other except through
the ports explicitly published (443 and, with the bonus, 666 and 21/21100-21110).

**Docker Volumes vs Bind Mounts** — A bind mount points directly to a path on the host
filesystem and bypasses Docker's volume management (permissions, drivers, lifecycle). A
named volume is managed by Docker itself, can be configured to store its data at a specific
host path, and is portable across drivers. This project uses named volumes
(`wordpress-volume`, `database`, and with the bonus `static-volume`, `portainer-volume`)
configured with a `local` driver and bind-type `driver_opts` pointing at
`/home/<user>/data/...`, satisfying the subject's requirement to avoid plain bind mounts for
the WordPress and MariaDB persistent storage.

## Bonus part

- **Redis** — object cache for WordPress (`ENABLE_REDIS=true` on the `wordpress` service).
- **FTP (vsftpd)** — exposed on ports 21 and 21100-21110, reuses the `wordpress-volume` so it
  can serve the WordPress files directly.
- **Adminer** — lightweight web GUI to inspect the MariaDB database, reached through NGINX (/adminer/).
- **Static website** — a standalone showcase site served by its own NGINX container on port
  666, backed by its own `static-volume`.
- **Portainer** — container management UI, mounted read-only against the Docker socket, with
  its own `portainer-volume`; chosen as the "service of your choice" bonus, to be justified
  during the defense, reached through NGINX (/portainer/).
