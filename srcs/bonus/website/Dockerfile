FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx &&  apt-get clean && rm -rf /var/lib/apt/lists/* 

COPY portfolio /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]