#!/bin/sh
set -e

# Paths to secrets
ROOT_PW_FILE="/run/secrets/db_root_password"
USER_PW_FILE="/run/secrets/db_password"

# Environment variables with defaults
DB_NAME="${MYSQL_DATABASE:-wordpress}"
DB_USER="${MYSQL_USER:-wp_user}"

# Ensure data directory is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] Initializing database directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql
fi

echo "[MariaDB] Launching server in background..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
MARIADB_PID=$!

# Wait for MariaDB to be ready
for i in $(seq 1 30); do
	if mysqladmin ping --silent; then
		break
	fi
	sleep 1
	if [ "$i" -eq 30 ]; then
		echo "[MariaDB] Startup failed."
		exit 1
	fi
done

echo "[MariaDB] Setting up initial users and database..."
mysql -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat $ROOT_PW_FILE)';
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$(cat $USER_PW_FILE)';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL

echo "[MariaDB] Shutting down background server..."
mysqladmin shutdown -uroot -p"$(cat $ROOT_PW_FILE)" || true
wait "$MARIADB_PID" || true

echo "[MariaDB] Ready. Starting in foreground."
exec mysqld --user=mysql --datadir=/var/lib/mysql
