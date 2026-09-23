#!/bin/bash

file_env() {
    local var="$1"
    local file_var="${var}_FILE"
    if [ -n "${!file_var:-}" ]; then
        export "$var"="$(cat "${!file_var}")"
    fi
}

set -e

file_env FTP_USER
file_env FTP_PASSWORD

FTP_HOME="/home/${FTP_USER}"

sed -i "s/__FTP_HOST__/${FTP_HOST}/" /etc/vsftpd.conf

if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -d "$FTP_HOME" -s /usr/sbin/nologin "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

mkdir -p "$FTP_HOME"
chown "$FTP_USER":"$FTP_USER" "$FTP_HOME"

chmod 755 "$FTP_HOME"

exec /usr/sbin/vsftpd /etc/vsftpd.conf