FROM debian:bookworm

RUN apt-get update -yqq && \
    apt-get install -yqq mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/setup_db.sh /usr/local/bin/setup_db.sh
RUN chmod +x setup_db.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup_db.sh"]