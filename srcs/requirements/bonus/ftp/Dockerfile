FROM debian:bookworm

RUN apt-get update -yqq && \
    apt-get install -yqq vsftpd tini && \
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/sbin/nologin" >> /etc/shells

COPY ./tools/setup_ftp.sh /usr/local/bin/setup_ftp.sh
COPY ./conf/vsftpd.conf /etc/vsftpd.conf

RUN mkdir -p /var/run/vsftpd/empty && \
    chmod +x /usr/local/bin/setup_ftp.sh

EXPOSE 20 21 21100-21110

ENTRYPOINT ["/usr/local/bin/setup_ftp.sh"]