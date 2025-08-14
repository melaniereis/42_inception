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

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] 🔧 Initializing empty database directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql
fi

# Start MariaDB in safe mode for setup
echo "[MariaDB] 🔄 Starting temporary server for configuration..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
MARIADB_PID=$!

# Wait for MariaDB to be ready
echo "[MariaDB] ⏳ Waiting for server to be ready..."
for i in $(seq 1 30); do
	if mysqladmin ping --socket=/var/lib/mysql/mysql.sock --silent; then
		echo "[MariaDB] ✅ Server is ready!"
		break
	fi
	sleep 1
done

# Check if root password is already set
if mysql -uroot -e 'SELECT 1;' 2>/dev/null; then
	ROOT_AUTH=''
	echo "[MariaDB] 🔧 Root password not set, configuring..."
else
	ROOT_AUTH="-p${ROOT_PASSWORD}"
	echo "[MariaDB] 🔓 Root password already set, using existing..."
fi

# Configure database, users, and security
echo "[MariaDB] 🛡️ Configuring database and users..."
mysql -uroot $ROOT_AUTH <<SQL
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

-- Create database
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Security: Remove anonymous users and test database
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;

-- Apply changes
FLUSH PRIVILEGES;
SQL

echo "[MariaDB] 🛑 Shutting down temporary server..."
mysqladmin shutdown -uroot -p"${ROOT_PASSWORD}" || true
wait "$MARIADB_PID" 2>/dev/null || true

echo "[MariaDB] 🚀 Starting MariaDB in production mode..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
