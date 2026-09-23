FROM debian:bookworm

RUN apt-get update -yqq && \
	apt-get install -yqq nginx openssl && \
	rm -rf /var/lib/apt/lists/*

COPY conf/nginx.base.conf /nginx.base.conf
COPY conf/nginx.bonus.conf /nginx.bonus.conf
COPY tools/setup_nginx.sh /usr/local/bin/setup_nginx.sh

RUN chmod +x /usr/local/bin/setup_nginx.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup_nginx.sh"]
