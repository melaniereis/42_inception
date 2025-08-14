FROM debian:bullseye

RUN apt update && apt install -y nginx openssl
RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/templates/default.conf.template
COPY tools/nginx-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
