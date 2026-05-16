FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=MA/ST=Tetouan/L=Tetouan/O=42/OU=Student/CN=ajelloul.42.fr" \
    && chmod 600 /etc/nginx/ssl/nginx.key \
    && chmod 644 /etc/nginx/ssl/nginx.crt

COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf

WORKDIR /etc/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
