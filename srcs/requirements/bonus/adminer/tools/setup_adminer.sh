#!/bin/bash
set -e

cd /var/www/html

chown -R www-data:www-data /var/www/html

exec php-fpm -F