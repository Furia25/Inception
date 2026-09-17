FROM debian:latest

RUN apt-get update -yqq && \
	apt-get install -yqq wordpress php-fpm && \
	rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/setup_ssl.sh"]
