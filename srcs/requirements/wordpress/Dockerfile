# 42 Inception - WordPress Dockerfile
FROM alpine:3.21

# Install PHP, PHP-FPM and required extensions
RUN apk add --no-cache \
	php82 \
	php82-fpm \
	php82-mysqli \
	php82-json \
	php82-curl \
	php82-dom \
	php82-exif \
	php82-fileinfo \
	php82-mbstring \
	php82-openssl \
	php82-xml \
	php82-zip \
	php82-redis \
	php82-gd \
	php82-iconv \
	php82-pdo \
	php82-pdo_mysql \
	php82-session \
	php82-simplexml \
	php82-tokenizer \
	php82-xmlreader \
	php82-xmlwriter \
	php82-sodium \
	curl \
	wget

# Create symbolic links for PHP
RUN ln -s /usr/bin/php82 /usr/bin/php

# Download and install WordPress
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz \
	&& mv wordpress/* . \
	&& rm -rf wordpress latest.tar.gz

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Create WordPress user
RUN adduser -D -S -s /bin/sh wordpress

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/php.ini

# Copy WordPress setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Set proper permissions
RUN chown -R wordpress:wordpress /var/www/html \
	&& chmod -R 755 /var/www/html

# Create directory for PHP-FPM socket
RUN mkdir -p /run/php

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start setup script
CMD ["/usr/local/bin/setup.sh"]
