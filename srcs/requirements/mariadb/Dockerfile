FROM alpine:3.21

# Install MariaDB and openrc
RUN apk add --no-cache \
	mariadb mariadb-client mariadb-server-utils openrc

# Create directories
RUN mkdir -p /run/mysqld /var/lib/mysql /var/log/mysql

# Set permissions
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql /var/log/mysql \
	&& chmod 777 /var/lib/mysql

# Copy configuration
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy initialization script
COPY tools/init-db.sh /docker-entrypoint-initdb.d/init-db.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# Copy startup script
COPY tools/mariadb-start.sh /usr/local/bin/mariadb-start.sh
RUN chmod +x /usr/local/bin/mariadb-start.sh

EXPOSE 3306

# Run as root to allow initialization
CMD ["/usr/local/bin/mariadb-start.sh"]
