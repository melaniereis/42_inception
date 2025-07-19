FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
	nginx \
	openssl && \
	rm -rf /var/lib/apt/lists/*

# Create SSL directory and PID directory
RUN mkdir -p /etc/nginx/ssl /var/run/nginx

# Create sites directories and set up symlink
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# Copy main nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy server block configuration
COPY conf/default /etc/nginx/sites-available/default

# Enable the site by creating symlink
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Copy entrypoint script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

CMD ["/entrypoint.sh"]
