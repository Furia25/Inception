#!/bin/bash
set -e

file_env() {
    local var="$1"
    local file_var="${var}_FILE"
    if [ -n "${!file_var:-}" ]; then
        export "$var"="$(cat "${!file_var}")"
    fi
}

file_env WP_ADMIN_PASSWORD
file_env WP_USER_PASSWORD
file_env DB_PASSWORD

# Attendre que MariaDB accepte réellement les identifiants
until mariadb -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" --skip-ssl \
        -e "SELECT 1" "${DB_NAME}" >/dev/null 2>&1; do
    echo "Waiting MariaDB..."
    sleep 2
done

cd /var/www/html

if ! wp core is-installed --allow-root 2>/dev/null; then
    rm -f wp-config.php
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --allow-root

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

if ! wp user get "${WP_USER}" --allow-root >/dev/null 2>&1; then
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
fi

chown -R www-data:www-data /var/www/html

exec php-fpm -F