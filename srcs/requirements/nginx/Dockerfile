FROM debian:latest

RUN apt-get update -yqq && \
	apt-get install -yqq nginx openssl && \
	rm -rf /var/lib/apt/lists/*

RUN 

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup_ssl.sh /usr/local/bin/setup_ssl.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup_ssl.sh"]
