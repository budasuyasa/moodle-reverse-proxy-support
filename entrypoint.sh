#!/bin/bash
set -e

echo "🚀 Starting Moodle base container..."

# Optional: wait for DB if user provided env
if [ -n "${MOODLE_DATABASE_HOST}" ]; then
  echo "⏳ Waiting for database ${MOODLE_DATABASE_HOST}:${MOODLE_DATABASE_PORT_NUMBER:-3306}..."
  until nc -z "$MOODLE_DATABASE_HOST" "${MOODLE_DATABASE_PORT_NUMBER:-3306}"; do
    echo "   Database not ready, retrying..."
    sleep 5
  done
  echo "✅ Database reachable."
else
  echo "⚠️ No database host specified. Skipping DB wait."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html /var/www/moodledata || true
chmod -R 775 /var/www/moodledata || true

# Start Apache + cron
echo "🧭 Starting supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
