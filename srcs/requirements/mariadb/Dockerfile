# 42 Inception - MariaDB Dockerfile
FROM alpine:3.21

# Install MariaDB and related packages
RUN apk add --no-cache \
	mariadb \
	mariadb-client \
	mariadb-server-utils \
	openrc \
	&& mkdir -p /run/mysqld \
	&& chown -R mysql:mysql /run/mysqld

# Copy MariaDB configuration
COPY conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/init-db.sh /docker-entrypoint-initdb.d/init-db.sh

# Set proper permissions
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# Create directories and set permissions
RUN mkdir -p /var/lib/mysql /run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /run/mysqld \
	&& chmod 755 /var/lib/mysql /run/mysqld

# Copy startup script
COPY tools/mariadb-start.sh /usr/local/bin/mariadb-start.sh
RUN chmod +x /usr/local/bin/mariadb-start.sh

# Expose MariaDB port
EXPOSE 3306

# Switch to mysql user
USER mysql

# Start MariaDB
CMD ["/usr/local/bin/mariadb-start.sh"]
