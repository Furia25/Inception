FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/portainer/portainer/releases/download/2.45.1/portainer-2.45.1-linux-amd64.tar.gz \
    -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /tmp \
    && mv /tmp/portainer/portainer /usr/local/bin/portainer \
    && mv /tmp/portainer/public /usr/local/share/portainer-public \
    && rm -rf /tmp/portainer*

EXPOSE 9443

CMD ["portainer", "--assets", "/usr/local/share/portainer-public", "--http-listen-addr", ":9443"]