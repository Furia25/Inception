FROM debian:latest

RUN apt-get update -yqq && \
	apt-get install -yqq wordpress php-fpm && \
	rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup_ssl.sh /usr/local/bin/setup_ssl.sh

ENTRYPOINT ["/usr/local/bin/setup_ssl.sh"]
