#!/bin/bash
set -e

until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    echo "En attente de MariaDB..."
    sleep 2
done

cd /var/www/html
if [ ! -f wp-config.php ]; then

    cp /tmp/wp-config.php /var/www/html/wp-config.php

    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

else
    echo "WordPress already initialized, starting normally..."
fi

exec php-fpm -F