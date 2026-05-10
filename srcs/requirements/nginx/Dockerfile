FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/conf.d/nginx.conf

COPY tools/ssl_setup.sh /ssl_setup.sh

RUN chmod +x /ssl_setup.sh

EXPOSE 443

CMD ["/ssl_setup.sh"]