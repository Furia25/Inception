FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/portainer \
    && curl -L https://github.com/portainer/portainer/releases/download/2.45.1/portainer-2.45.1-linux-amd64.tar.gz \
    -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /tmp \
    && mv /tmp/portainer/portainer /opt/portainer/portainer \
    && mv /tmp/portainer/public /opt/portainer/public \
    && rm -rf /tmp/portainer*

WORKDIR /opt/portainer

EXPOSE 8000

CMD ["./portainer", "--bind", ":8000", "--tunnel-port", "8001", "--admin-password-file", "/run/secrets/portainer_password"]