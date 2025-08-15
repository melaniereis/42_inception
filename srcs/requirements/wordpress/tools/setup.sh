#!/bin/bash

# Ensure the secrets directory exists and copy secrets there
install -d -m 755 /var/www/inception/secrets
cp /run/secrets/* /var/www/inception/secrets/
chown -R www-data:www-data /var/www/inception/secrets
chmod -R 440 /var/www/inception/secrets/*

# Load credentials from secrets
ADMIN_PASS=$(< /run/secrets/wp_admin_password)
USER_PASS=$(< /run/secrets/wp_user_password)
ADMIN_NAME=$(< /run/secrets/wp_admin)
REGULAR_USER=$(< /var/www/inception/secrets/wp_user)

export ADMIN_PASS USER_PASS ADMIN_NAME REGULAR_USER

# Move the custom wp-config.php into place if needed
[ -f /tmp/wp-config.php ] && mv /tmp/wp-config.php "$WP_PATH/"

# Download WordPress core if not already present
if [ ! -e "$WP_PATH/wp-load.php" ]; then
	wp --allow-root --path="$WP_PATH" core download
fi

# Set permissions for the web server
chown -R www-data:www-data "$WP_PATH"

# Install WordPress if not already installed
if ! wp --allow-root --path="$WP_PATH" core is-installed; then
	wp --allow-root --path="$WP_PATH" core install \
		--url="$WP_URL" \
		--title="$WP_TITLE" \
		--admin_user="$ADMIN_NAME" \
		--admin_password="$ADMIN_PASS" \
		--admin_email="$WP_ADMIN_EMAIL"
fi

# Add a regular user if missing
if ! wp --allow-root --path="$WP_PATH" user get "$REGULAR_USER" >/dev/null 2>&1; then
	wp --allow-root --path="$WP_PATH" user create \
		"$REGULAR_USER" "$WP_EMAIL" \
		--user_pass="$USER_PASS" \
		--role="$WP_ROLE"
fi

# Activate the chosen theme
wp --allow-root --path="$WP_PATH" theme install raft --activate

# Start the container's main process
exec "$@"
