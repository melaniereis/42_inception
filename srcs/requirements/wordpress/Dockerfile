FROM debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
	php php-fpm php-mysqli php-json php-curl php-mbstring php-xml \
	php-gd curl wget mariadb-client && \
	rm -rf /var/lib/apt/lists/*

# Setup working directory
WORKDIR /var/www/html

# Download and extract WordPress
RUN wget https://wordpress.org/latest.tar.gz \
	&& tar -xzf latest.tar.gz \
	&& mv wordpress/* . \
	&& rm -rf wordpress latest.tar.gz

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

# Copy configuration files
COPY conf/php.ini /etc/php/7.4/fpm/php.ini
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Add user and group 'wordpress'
RUN addgroup --system wordpress && \
	adduser --system --ingroup wordpress --home /var/www/html wordpress

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]
