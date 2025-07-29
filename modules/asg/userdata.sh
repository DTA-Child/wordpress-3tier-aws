#!/bin/bash
set -e

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/wordpress-setup.log
}

log "Starting WordPress installation with PHP 7.4..."

# Update system
yum update -y

# Remove any existing PHP installations
yum remove -y php*

# Enable and install PHP 7.4
log "Installing PHP 7.4..."
amazon-linux-extras enable php7.4
yum clean metadata
yum install -y httpd php php-mysqlnd php-fpm php-json php-gd php-mbstring php-xml php-curl php-zip mysql awscli

# Start services
systemctl start httpd php-fpm
systemctl enable httpd php-fpm

# Verify PHP version
log "PHP version: $(php -v | head -n 1)"

# Disable Apache welcome page (CRITICAL FIX)
log "Disabling Apache welcome page..."
if [ -f /etc/httpd/conf.d/welcome.conf ]; then
    mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.disabled
fi

# Download WordPress
cd /var/www/html
log "Downloading WordPress..."
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz

# Wait for RDS database
log "Waiting for database connection..."
DB_HOST="${db_endpoint}"
DB_USER="${db_username}"
DB_PASS="${db_password}"
DB_NAME="${db_name}"

for i in {1..60}; do
    if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" &>/dev/null; then
        log "Database connection successful"
        break
    fi
    log "Waiting for database... attempt $i/60"
    sleep 10
done

# Generate WordPress salts
log "Generating WordPress salts..."
SALTS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

# Create wp-config.php
log "Creating wp-config.php..."
cat > wp-config.php << EOF
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASS');
define('DB_HOST', '$DB_HOST');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

$SALTS

\$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html
chmod 600 wp-config.php

# Configure Apache for WordPress
cat > /etc/httpd/conf.d/000-wordpress.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    DirectoryIndex index.php index.html
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/httpd/wordpress_error.log
    CustomLog /var/log/httpd/wordpress_access.log combined
</VirtualHost>
EOF

# Enable mod_rewrite
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Final restart
systemctl restart httpd

log "WordPress installation completed with PHP $(php -v | head -n 1)!"