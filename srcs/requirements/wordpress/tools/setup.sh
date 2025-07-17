#!/bin/sh

set -x  # Enable debugging

# Wait for MariaDB to be ready
echo "⏳ Waiting for MariaDB to be ready..."
while ! mariadb -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$(cat $WORDPRESS_DB_PASSWORD_FILE)" -e "SELECT 1" >/dev/null 2>&1; do
	sleep 2
done
echo "✅ MariaDB is ready!"

# Validate domain format
if [[ ! "$DOMAIN_NAME" =~ ^[a-z0-9]+\.42\.fr$ ]]; then
	echo "❌ ERROR: Domain must be in format 'login.42.fr'" >&2
	exit 1
fi

# Validate admin username
if [[ "$WP_ADMIN_USER" =~ [Aa]dmin ]]; then
	echo "❌ ERROR: Admin username cannot contain 'admin'" >&2
	exit 1
fi

# Check if WordPress is already configured
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "🔧 Setting up WordPress configuration..."

	# Create wp-config.php using WP-CLI
	wp config create \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$(cat $WORDPRESS_DB_PASSWORD_FILE)" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--allow-root \
		--path="/var/www/html"

	# Install WordPress if not already installed
	if ! wp core is-installed --allow-root --path="/var/www/html"; then
		echo "🚀 Installing WordPress..."

		wp core install \
			--url="https://$DOMAIN_NAME" \
			--title="Inception WordPress" \
			--admin_user="$WP_ADMIN_USER" \
			--admin_password="$(cat /run/secrets/wp_admin_password)" \
			--admin_email="$WP_ADMIN_EMAIL" \
			--allow-root \
			--path="/var/www/html"

		# Create additional user
		wp user create \
			"$WP_USER" \
			"$WP_USER_EMAIL" \
			--role=author \
			--user_pass="$(cat /run/secrets/wp_user_password)" \
			--allow-root \
			--path="/var/www/html"
	fi

	echo "✅ WordPress setup complete!"
else
	echo "ℹ️ WordPress already configured"
fi

# Set proper permissions
chown -R wordpress:wordpress /var/www/html

echo "🔥 Starting PHP-FPM..."
exec php-fpm82 -F
