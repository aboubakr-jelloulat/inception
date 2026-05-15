#!/bin/bash
set -e

mkdir -p /var/run/vsftpd/empty

FTP_USER=${FTP_USER:-ftpuser}

# Read password from secret file if set, else fallback to env var
if [ -f "$FTP_PASSWORD_FILE" ]; then
    FTP_PASS=$(cat "$FTP_PASSWORD_FILE")
else
    FTP_PASS=${FTP_PASS:-ftppass}
fi

# Create user if it doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -d /var/www/html "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd

# Register user in vsftpd userlist
echo "$FTP_USER" > /etc/vsftpd.userlist

# Fix ownership so FTP user can write
chown -R "$FTP_USER:$FTP_USER" /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
