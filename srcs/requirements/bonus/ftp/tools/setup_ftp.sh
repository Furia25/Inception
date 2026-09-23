#!/bin/bash
set -e

file_env() {
    local var="$1"
    local file_var="${var}_FILE"
    if [ -n "${!file_var:-}" ]; then
        export "$var"="$(cat "${!file_var}")"
    fi
}

file_env FTP_PASSWORD

: "${FTP_USER:?FTP_USER is required}"
: "${FTP_PASSWORD:?FTP_PASSWORD is required}"
: "${FTP_HOST:?FTP_HOST is required}"

FTP_HOME="/home/${FTP_USER}"

sed -i "s/__FTP_HOST__/${FTP_HOST}/" /etc/vsftpd.conf

if ! id "$FTP_USER" &>/dev/null; then
    useradd -M -d "$FTP_HOME" -s /usr/sbin/nologin -G www-data "$FTP_USER"
else
    usermod -aG www-data "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

mkdir -p "$FTP_HOME"
chown root:root "$FTP_HOME"
chmod 755 "$FTP_HOME"

mkdir -p "$FTP_HOME/wordpress"
chown -R "$FTP_USER":www-data "$FTP_HOME/wordpress"
chmod -R g+w "$FTP_HOME/wordpress"

exec /usr/sbin/vsftpd /etc/vsftpd.conf