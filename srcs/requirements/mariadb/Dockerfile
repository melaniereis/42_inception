FROM debian:bullseye

# Expose the default MariaDB port
EXPOSE 3306

# Install MariaDB server and gosu for privilege dropping
RUN apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
	mariadb-server gosu && \
	rm -rf /var/lib/apt/lists/*

# Add custom MariaDB configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the database setup script and ensure it's executable
COPY tools/setup.sh /setup.sh
RUN chmod 755 /setup.sh

# Set the entrypoint to the setup script
ENTRYPOINT ["/setup.sh"]
CMD ["mysqld"]
