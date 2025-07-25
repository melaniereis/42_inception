#!/bin/sh
set -e

# ----------------------------------------------------------------------
# Paths to Docker secret files
ROOT_PW_FILE="/run/secrets/db_root_password"
USER_PW_FILE="/run/secrets/db_password"

# Defaultable environment variables
DB_NAME="${MYSQL_DATABASE:-wordpress}"
DB_USER="${MYSQL_USER:-wp_user}"

# ----------------------------------------------------------------------
# One-time initialisation
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[MariaDB] Initialising empty data directory …"
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql
fi

echo "[MariaDB] Launching server in bootstrap mode …"
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
MARIADB_PID=$!

# Wait for socket readiness
for i in $(seq 1 30); do
	if mysqladmin ping --socket=/var/lib/mysql/mysql.sock --silent; then break; fi
	sleep 1
done || { echo "[MariaDB] Startup timed out"; exit 1; }

# ----------------------------------------------------------------------
# Decide whether a password is required
if mysql -uroot -e 'SELECT 1;' 2>/dev/null; then
	ROOT_AUTH=''
else
	ROOT_AUTH="-p$(cat "$ROOT_PW_FILE")"
fi

echo "[MariaDB] Creating users and database …"
mysql -uroot $ROOT_AUTH <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat "$ROOT_PW_FILE")';
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$(cat "$USER_PW_FILE")';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL

echo "[MariaDB] Shutting down bootstrap server …"
mysqladmin shutdown -uroot -p"$(cat "$ROOT_PW_FILE")" || true
wait "$MARIADB_PID" 2>/dev/null || true

echo "[MariaDB] Ready. Starting in foreground."
exec mysqld --user=mysql --datadir=/var/lib/mysql
