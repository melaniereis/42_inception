FROM debian:bullseye

RUN apt update && apt install -y nginx openssl
RUN mkdir -p /etc/nginx/ssl

# Copia o nginx.conf para o local padrão do Nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
