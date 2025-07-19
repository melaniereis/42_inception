#!/bin/sh
set -x

# Create necessary directories
mkdir -p /run/php

# Load environment variables
export MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
    echo "MariaDB is not ready yet. Retrying..."
    sleep 2
done
echo "MariaDB is ready!"

# Validate domain format
if ! echo "$DOMAIN_NAME" | grep -Eq '^[a-z0-9]+\.42\.fr$'; then
	echo "❌ ERROR: Domain must be in format 'login.42.fr'" >&2
	exit 1
fi

# Validate admin username
if echo "$WP_ADMIN_USER" | grep -qi 'admin'; then
	echo "❌ ERROR: Admin username cannot contain 'admin'" >&2
	exit 1
fi

# Create wp-config.php if not exists
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "🔧 Creating wp-config.php..."
	wp config create \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${MYSQL_HOST}" \
		--allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
	echo "🚀 Installing WordPress..."
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="Inception WordPress" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="$(cat /run/secrets/wp_admin_password)" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--allow-root

	echo "👤 Creating additional user..."
	wp user create \
		"${WP_USER}" \
		"${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="$(cat /run/secrets/wp_user_password)" \
		--allow-root
fi

echo "✅ WordPress setup complete!"
echo "🔥 Starting PHP-FPM..."
exec php-fpm7.4 -F

