FROM debian:latest

RUN apt-get update -yqq && \
    apt-get install -yqq mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY ./content/setup.sh /
RUN chmod +x setup.sh

ENTRYPOINT ["sh", "setup.sh"]