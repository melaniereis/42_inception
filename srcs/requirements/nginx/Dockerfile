# srcs/requirements/nginx/Dockerfile
FROM alpine:3.21

# Install NGINX and OpenSSL for SSL certificates
RUN apk add --no-cache \
	nginx \
	openssl

# Create directories for SSL certificates and nginx configuration
RUN mkdir -p /etc/nginx/ssl \
	&& mkdir -p /var/run/nginx \
	&& mkdir -p /var/www/html

# Copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown -R nginx:nginx /var/www/html \
	&& chown -R nginx:nginx /var/run/nginx

# Entrypoint to generate SSL certificate at runtime
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 443 for HTTPS
EXPOSE 443

# Start nginx via entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
