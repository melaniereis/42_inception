FROM debian:bullseye

# Install MariaDB and dependencies
RUN apt-get update && apt-get install -y \
	mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /run/mysqld /var/log/mysql /var/lib/mysql && \
	chown -R mysql:mysql /run/mysqld /var/log/mysql /var/lib/mysql && \
	chmod 750 /var/lib/mysql

# Copy custom MariaDB config
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy startup script
COPY tools/mariadb-start.sh /usr/local/bin/mariadb-start.sh
RUN chmod +x /usr/local/bin/mariadb-start.sh

EXPOSE 3306

CMD ["/usr/local/bin/mariadb-start.sh"]
