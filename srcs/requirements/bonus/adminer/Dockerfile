FROM debian:bookworm

RUN apt-get update -yqq && \
    apt-get install -yqq php-fpm php-mysqli wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php https://www.adminer.org/latest.php

WORKDIR /var/www/html

COPY tools/setup_adminer.sh /usr/local/bin/setup_adminer.sh
RUN chmod +x /usr/local/bin/setup_adminer.sh

RUN sed -i 's|^listen = .*|listen = 8080|' /etc/php/8.2/fpm/pool.d/www.conf
RUN ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/setup_wp.sh"]