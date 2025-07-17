#!/bin/sh
# srcs/requirements/nginx/tools/entrypoint.sh

# Generate self-signed SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=PT/ST=Porto/L=Porto/O=42Porto/OU=inception/CN=${DOMAIN_NAME}"

# Set proper permissions for SSL certs
chmod 644 /etc/nginx/ssl/inception.crt
chmod 600 /etc/nginx/ssl/inception.key

# Start nginx
exec nginx -g "daemon off;"
