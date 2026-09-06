FROM debian:latest

RUN apt-get update -yqq && \
    apt-get install -yqq mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copie ta config personnalisée (bind sur toutes les IP, pas juste localhost)
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Script d'initialisation (création DB, user, etc.)
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]