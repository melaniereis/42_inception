FROM debian:bullseye

RUN apt-get update && apt-get install -y php7.4-fpm php7.4-mysql curl mariadb-client sudo && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/wordpress-setup.sh /usr/local/bin/wordpress-setup.sh
RUN chmod +x /usr/local/bin/wordpress-setup.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-setup.sh"]
