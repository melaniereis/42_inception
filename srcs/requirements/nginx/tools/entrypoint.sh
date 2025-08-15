#!/bin/bash
set -euo pipefail

# Generate a self-signed cert if none exists
if [ ! -f /etc/ssl/certs/nginx-selfsigned.crt ] || [ ! -f /etc/ssl/private/nginx-selfsigned.key ]; then
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt \
	-subj "/C=PT/ST=PORTO/L=PORTO/O=42PORTO/OU=Inception/CN=${DOMAIN}"
fi

exec nginx -g 'daemon off;'
