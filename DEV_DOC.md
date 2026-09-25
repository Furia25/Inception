# Developer Documentation — Inception

This document describes how to set up, build, and work with the Inception infrastructure as
a developer.

## 1. Setting up the environment from scratch

### Prerequisites

- A Debian-based virtual machine with Docker Engine and the Docker Compose plugin installed.
- `make`.
- Root/sudo access, since the Makefile creates directories under `/home/vdurand/data` and
  edits `/etc/hosts` (or your local DNS) to point `vdurand.42.fr` at the VM's IP.

### Configuration files

| File / folder                | Purpose                                                          |
|-------------------------------|-------------------------------------------------------------------|
| `Makefile`                    | Entry point: creates data dirs, builds and runs docker compose   |
| `srcs/docker-compose.yml`     | Mandatory stack: nginx, wordpress, mariadb                        |
| `srcs/docker-compose-bonus.yml` | Full stack including redis, ftp, static, adminer, portainer     |
| `srcs/.env`                   | Non-sensitive configuration (domain name, DB name, usernames...) |
| `secrets/*.txt`                | Sensitive values (passwords), consumed as Docker secrets          |
| `srcs/requirements/<service>/` | One folder per service: `Dockerfile`, `conf/`, `tools/`          |

### Secrets

Before the first build, make sure every file under `secrets/` contains a value:

```
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

These are declared as `secrets:` in `docker-compose.yml` / `docker-compose-bonus.yml` and
mounted read-only inside the relevant containers at `/run/secrets/<name>`; the setup scripts
(`tools/setup_*.sh`) read them from there instead of from environment variables.

## 2. Building and launching the project

```bash
make          # default target: build + up (mandatory stack)
make bonus    # build + up using docker-compose-bonus.yml, if defined as a separate target
make down     # docker compose down
make clean    # down + remove images
make fclean   # clean + remove the named volumes (data loss)
make re       # fclean then make
```

Under the hood, the Makefile:

1. Creates `/home/vdurand/data/wordpress` and `/home/vdurand/data/mariadb` on the host (the
   mount points used by the named volumes).
2. Runs `docker compose -f srcs/docker-compose.yml up --build -d` (or the bonus compose file).

Each service's Dockerfile installs its packages, copies its `conf/` files, and runs its
`tools/setup_*.sh` script as the container's entrypoint/CMD — that script performs first-run
configuration (e.g. creating the WordPress `wp-config.php`, initializing the MariaDB users
and database, generating the NGINX TLS certificate, creating the FTP user) and then execs
into the real foreground process of the service (`php-fpm`, `mysqld`, `nginx -g "daemon
off;"`, `vsftpd`, etc.), so the container's PID 1 is always the actual daemon.

## 3. Managing containers and volumes

Useful `docker` / `docker compose` commands while developing:

```bash
docker compose -f srcs/docker-compose.yml ps            # status of each service
docker compose -f srcs/docker-compose.yml logs -f nginx # follow logs of one service
docker compose -f srcs/docker-compose.yml exec wordpress bash   # shell into a container
docker compose -f srcs/docker-compose.yml build --no-cache mariadb  # rebuild one image
docker compose -f srcs/docker-compose.yml restart wordpress     # restart one service

docker volume ls                                         # list named volumes
docker volume inspect srcs_wordpress_data                # check its host mountpoint
docker network ls                                         # list networks, incl. the project's
```

If you change a `conf/` file or a `tools/setup_*.sh` script, rebuild the affected image
(`docker compose build <service>`) and recreate its container
(`docker compose up -d --force-recreate <service>`) — configuration is applied at container
build/start time, not read live.

## 4. Where data is stored and how it persists

Two Docker **named volumes** are declared in `docker-compose.yml`, configured with the
`local` driver and a bind-type option that pins their storage location to the host:

- WordPress files → `/home/vdurand/data/wordpress`
- MariaDB data → `/home/vdurand/data/mariadb`

Because these are named volumes (not bind mounts), Docker manages their lifecycle: they
survive `make down`/`make clean`, and are only deleted by `make fclean` or an explicit
`docker volume rm`. Bonus services that need their own storage (e.g. the FTP container
serving the WordPress files) reuse the `wordpress` volume rather than duplicating data.
