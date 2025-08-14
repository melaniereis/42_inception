#!/bin/sh
set -e

echo "🔧 Starting WordPress setup..."

# Ensure PHP-FPM runtime directory exists
mkdir -p /run/php

# Load passwords from Docker secrets
export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
export WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
export WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait for MariaDB
echo "⏳ Waiting for MariaDB..."
while ! mysql -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT 1;" >/dev/null 2>&1; do
sleep 1
done
echo "✅ MariaDB is ready!"

# Configure WordPress if not installed
if [ ! -f "/var/www/html/wp-config.php" ]; then
echo "🛠️ Configuring WordPress..."

wp config create \
	--dbname=$MYSQL_DATABASE \
	--dbuser=$MYSQL_USER \
	--dbpass=$MYSQL_PASSWORD \
	--dbhost=mariadb \
	--allow-root

wp core install \
	--url="https://$DOMAIN_NAME" \
	--title="Inception WordPress" \
	--admin_user=$WP_ADMIN_USER \
	--admin_password=$WP_ADMIN_PASSWORD \
	--admin_email=$WP_ADMIN_EMAIL \
	--skip-email \
	--allow-root

wp user create $WP_USER $WP_USER_EMAIL \
	--role=author \
	--user_pass=$WP_USER_PASSWORD \
	--allow-root

echo "✅ WordPress installed!"
else
echo "🔁 WordPress already installed"
fi

echo "🚀 Starting PHP-FPM..."
exec php-fpm7.4 -F
