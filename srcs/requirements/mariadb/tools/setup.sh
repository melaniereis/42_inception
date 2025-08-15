#!/bin/bash

# Create the MariaDB socket directory if missing and set permissions
if [ ! -d /run/mysqld ]; then
	mkdir /run/mysqld
	chown mysql:mysql /run/mysqld
fi

# Read secrets from Docker secrets if available
if [ -f /run/secrets/db_root_password ]; then
	MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_user ]; then
	MYSQL_USER=$(cat /run/secrets/db_user)
fi
if [ -f /run/secrets/db_password ]; then
	MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/db_name ]; then
	MYSQL_DATABASE=$(cat /run/secrets/db_name)
fi

export MYSQL_ROOT_PASSWORD MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE

# Make sure the data directory is owned by mysql
chown -R mysql:mysql /var/lib/mysql

# Initialize the database if it hasn't been set up yet
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    mysqld --user=mysql --bootstrap <<SQL
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL
fi

# Launch MariaDB as the mysql user
exec gosu mysql "$@"
