#!/bin/bash
set -euo pipefail

# MariaDB runtime entrypoint. It uses an SQL init file and execs mysqld in foreground.
# It requires the docker secret /run/secrets/db_password to exist.

if [ ! -f /run/secrets/db_password ]; then
  echo "[ERROR] Missing secret: /run/secrets/db_password" >&2
  echo "Create the file srcs/secrets/db_password before starting." >&2
  exit 1
fi
DB_PASS=$(cat /run/secrets/db_password)

: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE env var}"
: "${MYSQL_USER:?Missing MYSQL_USER env var}"

INIT_SQL=/etc/mysql/init.sql
cat > ${INIT_SQL} <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL

chown mysql:mysql ${INIT_SQL} || true

# Exec mysqld in foreground; it will execute --init-file on startup
exec gosu mysql mysqld --init-file=${INIT_SQL}
