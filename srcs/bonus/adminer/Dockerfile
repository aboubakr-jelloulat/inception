FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
        php \
        php-mysqli \
        wget \
    &&  apt-get clean && rm -rf /var/lib/apt/lists/* 


WORKDIR /var/www/html
 

RUN wget --no-check-certificate https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

EXPOSE 8888

# Use PHP built-in server — no Nginx/Apache needed, no extra packages
CMD ["php", "-S", "0.0.0.0:8888", "-t", "/var/www/html"]
