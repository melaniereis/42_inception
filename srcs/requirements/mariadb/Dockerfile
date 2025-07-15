# Based on the official MariaDB Docker image
FROM debian:bullseye

# Install required packages
RUN apt-get update && \
	apt-get install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

# Copy the initialization scripts into the container
COPY ./initdb.d/ /docker-entrypoint-initdb.d/

# Expose the default MariaDB port
EXPOSE 3306

# Set the volume for persistent data storage
VOLUME ["/var/lib/mysql"]

# Start MariaDB
CMD ["mysqld"]
