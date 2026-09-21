#!/bin/bash
set -e

until mysqladmin ping -h"${DB_HOST}" --skip-ssl --silent; do
    echo "Waiting MariaDB..."
    sleep 2
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
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

    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    chown -R www-data:www-data /var/www/html
else
    echo "WordPress already initialized, starting normally..."
fi

exec php-fpm -F