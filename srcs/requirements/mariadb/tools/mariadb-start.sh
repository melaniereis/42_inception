#!/bin/sh

# MariaDB startup script for 42 Inception

echo "🔧 Initializing MariaDB..."

# Initialize MariaDB if data directory is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "🚀 Setting up MariaDB for the first time..."

	# Initialize the database
	mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm --skip-test-db

	# Start MariaDB temporarily to setup users and database
	mysqld_safe --datadir=/var/lib/mysql --user=mysql &
	mysql_pid=$!

	# Wait for MariaDB to start
	while ! mysqladmin ping --silent; do
		sleep 1
	done

	echo "⚙️ Configuring database and users..."

	# Setup database and users
	mysql << EOF
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
FLUSH PRIVILEGES;
EOF

	# Stop the temporary instance
	mysqladmin -u root -p"$(cat /run/secrets/db_root_password)" shutdown
	wait $mysql_pid

	echo "✅ MariaDB initialization complete!"
else
	echo "ℹ️ MariaDB already initialized"
fi

echo "🔥 Starting MariaDB..."
exec mysqld --user=mysql --console
