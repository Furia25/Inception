#!/bin/bash
set -e

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal > /dev/null

    mysqld_safe --datadir=/var/lib/mysql --skip-networking &
    until mysqladmin ping --silent 2>/dev/null; do sleep 1; done

    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS ${DB_NAME};
        CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql