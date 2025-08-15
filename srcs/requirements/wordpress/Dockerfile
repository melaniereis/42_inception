FROM debian:bullseye

EXPOSE 9000

ARG PHPPATH=/etc/php/8.2/fpm
ARG PHP_VERSION_ENV=8.2

# Add Sury PHP repository and install PHP 8.2 with required extensions
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	ca-certificates wget gnupg2 lsb-release apt-transport-https && \
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
	php8.2 php8.2-fpm php8.2-mysql php8.2-curl php8.2-gd \
	php8.2-mbstring php8.2-xml php8.2-zip php8.2-cli php8.2-common php8.2-opcache && \
	rm -rf /var/lib/apt/lists/*

# Copy PHP-FPM pool config, WordPress config, and setup script
COPY conf/www.conf ${PHPPATH}/pool.d/www.conf
COPY conf/wp-config.php /tmp/wp-config.php
COPY tools/setup.sh /root/setup.sh

# Adjust PHP-FPM and pool settings for container use
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${PHPPATH}/php.ini && \
	sed -i "s|listen = /run/php/php${PHP_VERSION_ENV}-fpm.sock|listen = 9000|g" ${PHPPATH}/pool.d/www.conf && \
	sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' ${PHPPATH}/pool.d/www.conf && \
	sed -i 's/;daemonize = yes/daemonize = no/g' ${PHPPATH}/pool.d/www.conf

# Download and install WP-CLI for WordPress management
RUN wget --no-check-certificate https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Prepare runtime directories and set ownership for www-data
RUN mkdir -p /run/php/ /var/run/php/ /var/www/inception/ && \
	chown -R www-data:www-data /var/www/inception/

# Launch the setup script, which will start PHP-FPM in the foreground
CMD ["/root/setup.sh", "php-fpm8.2", "--nodaemonize"]
