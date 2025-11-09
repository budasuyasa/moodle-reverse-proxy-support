#!/bin/bash
set -e

echo "⏳ Waiting for database ${MOODLE_DATABASE_HOST}:${MOODLE_DATABASE_PORT_NUMBER}..."
until nc -z -v -w30 "$MOODLE_DATABASE_HOST" "$MOODLE_DATABASE_PORT_NUMBER"; do
  echo "   Database not ready, retrying..."
  sleep 5
done
echo "✅ Database is ready."

# --- Pastikan permission awal aman ---
chown -R www-data:www-data /var/www/html /var/www/moodledata

# --- Jalankan instalasi hanya jika belum ada config.php ---
if [ ! -f /var/www/html/config.php ]; then
  echo "🚀 Installing Moodle..."
  php admin/cli/install.php \
    --lang=${MOODLE_LANG:-en} \
    --wwwroot=${MOODLE_HOST} \
    --dataroot=/var/www/moodledata \
    --dbtype=${MOODLE_DATABASE_TYPE:-mysql} \
    --dbhost=${MOODLE_DATABASE_HOST:-moodle-db} \
    --dbname=${MOODLE_DATABASE_NAME:-moodle} \
    --dbuser=${MOODLE_DATABASE_USER:-moodle} \
    --dbpass=${MOODLE_DATABASE_PASSWORD:-moodlepass} \
    --fullname="${MOODLE_SITE_NAME:-Moodle LMS}" \
    --shortname="${MOODLE_SITE_SHORTNAME:-Moodle}" \
    --adminuser=${MOODLE_USERNAME:-admin} \
    --adminpass=${MOODLE_PASSWORD:-Admin123} \
    --adminemail=${MOODLE_EMAIL:-admin@example.com} \
    --agree-license \
    --non-interactive || true

  echo "✅ Installation complete."
fi

# --- Tambahkan setting reverse proxy dan SSL proxy jika diperlukan ---
if [ "${MOODLE_SSLPROXY}" = "true" ]; then
  echo "💡 Enabling reverse proxy SSL support..."
  grep -q "\$CFG->sslproxy" /var/www/html/config.php ||
    sed -i "/require_once(__DIR__ . '\/lib\/setup.php');/i \$CFG->sslproxy = 1;" /var/www/html/config.php
fi

if [ "${MOODLE_REVERSEPROXY}" = "true" ]; then
  grep -q "\$CFG->reverseproxy" /var/www/html/config.php ||
    sed -i "/require_once(__DIR__ . '\/lib\/setup.php');/i \$CFG->reverseproxy = true;" /var/www/html/config.php
fi

# --- Pastikan file akhirnya dimiliki www-data ---
chown -R www-data:www-data /var/www/html /var/www/moodledata

# --- Jalankan supervisord (Apache + cron) ---
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
