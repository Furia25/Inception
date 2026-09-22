#!/bin/bash

file_env() {
    local var="$1"
    local file_var="${var}_FILE"
    if [ -n "${!file_var:-}" ]; then
        export "$var"="$(cat "${!file_var}")"
    fi
}

set -e

file_env DB_ROOT_PASSWORD
file_env DB_PASSWORD

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

INIT_MARKER="/var/lib/mysql/.inception_init_done"

if [ ! -f "$INIT_MARKER" ]; then
    if [ ! -d /var/lib/mysql/mysql ]; then
        find /var/lib/mysql -mindepth 1 -delete
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    fi

    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    if ! timeout 60 sh -c 'until mysqladmin ping --silent 2>/dev/null; do sleep 1; done'; then
        echo "ERREUR: MariaDB n'a pas répondu au ping après 60s" >&2
        exit 1
    fi

    mysql -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    wait

    touch "$INIT_MARKER"
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql