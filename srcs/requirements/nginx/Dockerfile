# 42 Inception - NGINX Dockerfile
FROM alpine:3.21

# Install NGINX and OpenSSL for SSL certificates
RUN apk add --no-cache \
	nginx \
	openssl

# Create directories for SSL certificates and nginx configuration
RUN mkdir -p /etc/nginx/ssl \
	&& mkdir -p /var/run/nginx \
	&& mkdir -p /var/www/html

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=PT/ST=Porto/L=Porto/O=42Porto/OU=meferraz/CN=meferraz.42.fr"

# Copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chmod 644 /etc/nginx/ssl/inception.crt \
	&& chmod 600 /etc/nginx/ssl/inception.key \
	&& chown -R nginx:nginx /var/www/html \
	&& chown -R nginx:nginx /var/run/nginx

# Expose port 443 for HTTPS
EXPOSE 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
