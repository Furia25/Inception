FROM debian:bookworm

RUN apt-get update -yqq && \
    apt-get install -yqq php-fpm php-mysql mariadb-client curl && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/html && \
    curl -o /tmp/wordpress.tar.gz -sO https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

COPY conf/wp-config.php /tmp/wp-config.php
COPY tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf
RUN ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup_wp.sh"]