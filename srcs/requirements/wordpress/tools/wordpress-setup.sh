#!/bin/bash
set -euo pipefail

# WordPress setup script. Expects secrets to exist in /run/secrets.
REQUIRED_SECRETS=("/run/secrets/db_password" "/run/secrets/wp_admin_password" "/run/secrets/wp_user_password")
for s in "${REQUIRED_SECRETS[@]}"; do
  if [ ! -f "$s" ]; then
    echo "[ERROR] Missing secret: $s" >&2
    exit 1
  fi
done

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password)
WP_USER_PASS=$(cat /run/secrets/wp_user_password)

# Required env vars
: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
: "${WP_USER:?Missing WP_USER}"
: "${DOMAIN:?Missing DOMAIN}"

cd /var/www/html

# Wait for mariadb
echo "Waiting for MariaDB..."
until mysqladmin ping -hmariadb --silent; do
  sleep 1
done

# Install wp-cli if not present
if [ ! -x /usr/local/bin/wp ]; then
  curl -s -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x /tmp/wp-cli.phar
  mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

chown -R www-data:www-data /var/www/html || true

# Download WP core if absent
if [ ! -f wp-config.php ]; then
  sudo -u www-data wp core download --allow-root || true
  sudo -u www-data wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} --dbpass=${DB_PASS} --dbhost=mariadb --allow-root
fi

# Install if not installed
if ! sudo -u www-data wp core is-installed --allow-root >/dev/null 2>&1; then
  sudo -u www-data wp core install --url=${DOMAIN} --title="Inception" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASS} --admin_email=${WP_ADMIN_EMAIL} --skip-email --allow-root
fi

# Create regular user if not exists
if ! sudo -u www-data wp user get ${WP_USER} --allow-root >/dev/null 2>&1; then
  sudo -u www-data wp user create ${WP_USER} ${WP_USER_EMAIL} --role=author --user_pass=${WP_USER_PASS} --allow-root
fi

# Exec php-fpm in foreground
exec php-fpm7.4 -F
