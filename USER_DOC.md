# User Documentation — Inception

This document explains, in simple terms, how to use the Inception infrastructure once it has
been built: what it provides, how to start/stop it, how to access it, and how to check that
everything is running correctly.

## 1. What this stack provides

The infrastructure serves a WordPress website over HTTPS, backed by a MariaDB database.
If the stack was started with `make MODE=bonus`, it also provides:

| Service    | What it's for                                                        |
|------------|------------------------------------------------------------------------|
| NGINX      | Single entrypoint (HTTPS, port 443) |
| WordPress  | The website and its administration panel                             |
| MariaDB    | Stores all WordPress content (posts, users, settings)                |
| Redis      | Speeds up WordPress by caching database queries (bonus)              |
| FTP        | Lets you browse/upload the WordPress files remotely (bonus)          |
| Static site| A separate showcase page on port 666, independent from WordPress (bonus) |
| Adminer    | Web interface to inspect the MariaDB database, via NGINX (bonus)     |
| Portainer  | Web interface to manage the Docker containers (bonus)                |

## 2. Starting and stopping the project

From the root of the repository:

```bash
make init-secrets       # only needed once, generates any missing secret files
make                     # mandatory stack: builds images and starts the containers
make MODE=bonus          # full stack including redis, ftp, adminer, static, portainer

make stop                # stop the running containers without removing them
make start                # start them again
make down                # stop and remove the containers (data is kept)
make clean                # down + system-wide docker cleanup (see note below)
make fclean                # clean + wipes /home/<user>/data + volume/network prune
make re                     # fclean, then rebuild and restart everything from scratch
```

⚠ **Note:** `make clean` and `make fclean` call `docker system prune` / `docker volume
prune` / `docker network prune`, which clean up unused Docker resources on the whole
machine, not only the ones belonging to this project. Avoid running them on a host that
runs other, unrelated Docker projects.

The containers are configured to restart automatically (`restart: always`) if one of them
crashes, so under normal use you shouldn't need to intervene once `make` has completed.

## 3. Accessing the website and the administration panel

- **Website:** `https://vdurand.42.fr`
- **Administration panel:** `https://vdurand.42.fr/wp-admin`

Because the certificate used by NGINX is self-signed, your browser will show a security
warning on the first visit — this is expected; proceed past it (e.g. "Advanced → Continue").

If the stack was started with the bonus services:

- **Static showcase site:** `https://vdurand.42.fr:666`
- **Adminer:** `https://vdurand.42.fr/adminer/`, log in with
  server `mariadb`, and the database credentials below.
- **Portainer:** `https://vdurand.42.fr/portainer/`.
- **FTP:** connect an FTP client to the host on port 21 (passive ports 21100-21110), using
  the FTP username/password below, to browse the WordPress files.

## 4. Locating and managing credentials

All passwords are kept out of the Git repository, as required, in `secrets/`:

- `secrets/db_password.txt` — password of the regular WordPress database user.
- `secrets/db_root_password.txt` — MariaDB root password.
- `secrets/wp_admin_password.txt` — password of the WordPress administrator account.
- `secrets/wp_user_password.txt` — password of the second (non-admin) WordPress user.
- `secrets/ftp_password.txt` — password of the FTP user (bonus).
- `secrets/portainer_password.txt` — password used to secure Portainer (bonus).

If any of these files are missing, running `make init-secrets` generates them automatically
with random values (`openssl rand -base64 24`); `make up`/`make` will refuse to start and
list what's missing otherwise.

Non-sensitive settings (domain name, database name, usernames, FTP host, etc.) live in
`srcs/.env`. If you ever need to change a password, edit the corresponding file in
`secrets/` **before** the first `make`, then restart the stack with `make re` (or
`make re MODE=bonus`) so the change is picked up by the setup scripts.

Note: per the subject's requirements, the WordPress administrator username never contains
"admin" or "administrator" in any form.

## 5. Checking that the services are running correctly

Check the state of every container:

```bash
make ps
# or directly:
docker ps
```

All containers listed should show a status of `Up`. A container repeatedly restarting
indicates a problem — check its logs with:

```bash
make logs
# or one service only:
docker logs <container_name>
```

Common quick checks:

- `https://vdurand.42.fr` loads the WordPress homepage without a connection error.
- Logging into `/wp-admin` with the WordPress admin credentials succeeds.
- (Bonus) Adminer can connect to the `mariadb` host and shows the WordPress database and
  tables.
- (Bonus) Portainer shows every expected container as running.
- (Bonus) The static site loads on port 666, independently from WordPress.

For more advanced troubleshooting and environment setup, see `DEV_DOC.md`.
