FROM debian:bookworm

RUN apt-get update -yqq && \
	apt-get install -yqq redis && \
	rm -rf /var/lib/apt/lists/*

COPY conf/redis.conf /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]
