FROM debian:bookworm

RUN apt-get update -yqq && \
	apt-get install -yqq vsftpd && \
	rm -rf /var/lib/apt/lists/*

COPY ./tools/setup_ftp.sh /usr/local/bin/setup_ftp.sh
COPY ./conf/vsftpd.conf /etc/vsftpd.conf

RUN mkdir -p /var/run/vsftpd/empty
RUN chmod +x /usr/local/bin/setup_ftp.sh

EXPOSE 20 21

ENTRYPOINT ["/usr/local/bin/setup_ftp.sh"]
