#!/bin/sh
set -e

# Generate SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/inception.key \
  -out /etc/nginx/ssl/inception.crt \
  -subj "/C=US/ST=CA/L=SF/O=42School/OU=Education/CN=$DOMAIN_NAME"

# Start NGINX
exec "$@"
