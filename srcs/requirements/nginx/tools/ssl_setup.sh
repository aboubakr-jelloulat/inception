#!/bin/bash
set -e

# Generate SSL certificates
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=MA/ST=Tetouan/L=Tetouan/O=42/OU=Student/CN=ajelloul.42.fr"


# sudo cp /etc/nginx/ssl/nginx.crt /usr/local/share/ca-certificates/lbob.crt
# sudo update-ca-certificates

# Start nginx in foreground
exec nginx -g 'daemon off;'