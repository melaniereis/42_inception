<?php

// Retrieve database credentials from secret files, fallback to empty string if missing
function get_secret($name) {
	$path = "/var/www/inception/secrets/$name";
	return file_exists($path) ? trim(file_get_contents($path)) : '';
}

define('DB_NAME',     get_secret('db_name'));
define('DB_USER',     get_secret('db_user'));
define('DB_PASSWORD', get_secret('db_password'));

// Use DB_HOST from environment or default to service name and port
define('DB_HOST', getenv('DB_HOST') ?: 'mariadb:3306');

// Load WordPress core settings
require_once ABSPATH . 'wp-settings.php';
