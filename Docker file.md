FROM ubuntu:24.04

LABEL maintainer="admin@localhost"

RUN apt update && \
    apt install -y nginx wget curl zip unzip && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/web.zip https://templatemo.com/download/templatemo_604_christmas_piano && \
    unzip -q /tmp/web.zip -d /tmp/web && \
    rm -rf /var/www/html/* && \
    cp -r /tmp/web/*/* /var/www/html/ && \
    rm -rf /tmp/web /tmp/web.zip

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
