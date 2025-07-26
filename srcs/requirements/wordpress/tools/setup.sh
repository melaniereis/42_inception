#!/bin/sh
set -e
set -x

# Ensure PHP-FPM runtime dir exists
mkdir -p /run/php

# Load DB password from Docker secret
export MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB to be available
echo "⏳ Waiting for MariaDB..."
until mysql -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
	echo "🔄 MariaDB is not ready yet..."
	sleep 2
done
echo "✅ MariaDB is ready!"

# Check if WordPress is already installed (i.e., volume is initialized)
if [ ! -f "/var/www/html/wp-config.php" ]; then
	echo "🛠️ First-time setup: initializing WordPress..."

	# Validate domain format
	if ! echo "$DOMAIN_NAME" | grep -Eq '^[a-z0-9]+\.42\.fr$'; then
		echo "❌ ERROR: DOMAIN_NAME must match 'login.42.fr'" >&2
		exit 1
	fi

	# Validate admin username
	if echo "$WP_ADMIN_USER" | grep -qi 'admin'; then
		echo "❌ ERROR: WP_ADMIN_USER cannot contain 'admin'" >&2
		exit 1
	fi

	# Generate wp-config.php
	wp config create \
		--dbname="${WORDPRESS_DB_NAME}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${MYSQL_HOST}" \
		--allow-root

	# Install WordPress core
	wp core install \
		--url="https://${DOMAIN_NAME}" \
		--title="Inception WordPress" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="$(cat /run/secrets/wp_admin_password)" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

	# Create a secondary author user
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="$(cat /run/secrets/wp_user_password)" \
		--allow-root

	# Install and activate Neve theme
	wp theme install neve --activate --allow-root

	# Install useful plugins
	wp plugin install wp-super-cache contact-form-7 --activate --allow-root

	# Site customization
	wp option update blogdescription "A simple, dockerized WordPress site with comments ✍️" --allow-root
	wp option update show_on_front 'posts' --allow-root  # Homepage shows latest posts
	wp rewrite structure '/%postname%/' --hard --allow-root

	# Enable comments site-wide
	wp option update default_comment_status open --allow-root
	wp option update comment_registration 1 --allow-root
	wp option update require_name_email 1 --allow-root
	wp option update comment_moderation 1 --allow-root

	# Create a first post with comments enabled
	POST_ID=$(wp post create \
		--post_title="Welcome to My WordPress Site" \
		--post_content="This is your first post. Comments are enabled!" \
		--post_status=publish \
		--post_author=1 \
		--porcelain \
		--allow-root)

	wp post update "$POST_ID" --comment_status=open --allow-root

	echo "✅ WordPress successfully installed and configured."
else
	echo "🔁 Existing WordPress setup detected — skipping initialization."
fi

echo "🔥 Starting PHP-FPM..."
exec php-fpm7.4 -F
