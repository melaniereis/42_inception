#!/bin/sh
set -e

# **************************************************************************** #
#                                                                              #
#                         MARIADB STARTUP SCRIPT                              #
#                                                                              #
# **************************************************************************** #

echo "[MariaDB] 🚀 Starting MariaDB initialization..."

# Load passwords from Docker secrets
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
USER_PASSWORD=$(cat /run/secrets/db_password)

# Set default environment variables
DB_NAME="${MYSQL_DATABASE:-wordpress}"
DB_USER="${MYSQL_USER:-wp_user}"

	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql

# Inicializa e configura apenas se o banco ainda não existe
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] 🔧 Initializing empty database directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql

	# Start MariaDB em background
	mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
	MARIADB_PID=$!

	# Espera o servidor iniciar
	echo "[MariaDB] ⏳ Waiting for server to be ready..."
	for i in $(seq 1 30); do
		if mysqladmin ping --socket=/var/lib/mysql/mysql.sock --silent; then
			echo "[MariaDB] ✅ Server is ready!"
			break
		fi
		sleep 1
	done

	# Configura root e banco
	echo "[MariaDB] 🛡️ Configuring database and users..."
	mysql -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL

	echo "[MariaDB] 🛑 Shutting down temporary server..."
	mysqladmin shutdown -uroot -p"${ROOT_PASSWORD}" || true
	wait "$MARIADB_PID" 2>/dev/null || true
else
	echo "[MariaDB] Banco já inicializado, pulando configuração de root."
fi

echo "[MariaDB] 🚀 Starting MariaDB in production mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
