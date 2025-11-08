#!/bin/bash
set -e

MOODLE_CONFIG_FILE="/var/www/html/config.php"
MOODLE_CONFIG_TEMPLATE="/var/www/html/config-dist.php"

# --- If config.php doesn't exist, copy from template ---
if [ ! -f "$MOODLE_CONFIG_FILE" ]; then
  echo "No config.php found. Copying from config-dist.php..."
  cp $MOODLE_CONFIG_TEMPLATE $MOODLE_CONFIG_FILE
fi

# --- Helper to safely replace or append CFG values ---
set_cfg_value() {
  local key="$1"
  local value="$2"
  local file="$3"
  if grep -q "^\$CFG->$key" "$file"; then
    sed -i "s|^\(\$CFG->$key\s*=\s*\).*;|\1'${value}';|" "$file"
  else
    sed -i "/require_once/i \$CFG->$key = '${value}';" "$file"
  fi
}

# --- Set core Moodle configuration from ENV ---
set_cfg_value "wwwroot" "https://${MOODLE_HOST}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dataroot" "${MOODLE_DATA:-/var/www/moodledata}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dbtype" "${MOODLE_DATABASE_TYPE:-mysqli}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dbhost" "${MOODLE_DATABASE_HOST:-mariadb}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dbname" "${MOODLE_DATABASE_NAME:-moodle}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dbuser" "${MOODLE_DATABASE_USER:-moodle}" "$MOODLE_CONFIG_FILE"
set_cfg_value "dbpass" "${MOODLE_DATABASE_PASSWORD:-moodle}" "$MOODLE_CONFIG_FILE"
set_cfg_value "prefix" "mdl_" "$MOODLE_CONFIG_FILE"

# --- Proxy settings ---
if [ "${MOODLE_REVERSEPROXY}" = "true" ]; then
  set_cfg_value "reverseproxy" "true" "$MOODLE_CONFIG_FILE"
fi
if [ "${MOODLE_SSLPROXY}" = "true" ]; then
  set_cfg_value "sslproxy" "true" "$MOODLE_CONFIG_FILE"
fi

# --- SMTP settings ---
[ -n "$MOODLE_SMTP_HOST" ] && set_cfg_value "smtphosts" "$MOODLE_SMTP_HOST" "$MOODLE_CONFIG_FILE"
[ -n "$MOODLE_SMTP_USER" ] && set_cfg_value "smtpuser" "$MOODLE_SMTP_USER" "$MOODLE_CONFIG_FILE"
[ -n "$MOODLE_SMTP_PASSWORD" ] && set_cfg_value "smtppass" "$MOODLE_SMTP_PASSWORD" "$MOODLE_CONFIG_FILE"
[ -n "$MOODLE_SMTP_PROTOCOL" ] && set_cfg_value "smtpsecure" "$MOODLE_SMTP_PROTOCOL" "$MOODLE_CONFIG_FILE"
[ -n "$MOODLE_SMTP_PORT_NUMBER" ] && set_cfg_value "smtpport" "$MOODLE_SMTP_PORT_NUMBER" "$MOODLE_CONFIG_FILE"

# --- HTTPS proxy fix ---
if ! grep -q "HTTP_X_FORWARDED_PROTO" "$MOODLE_CONFIG_FILE"; then
  sed -i "1i<?php\nif (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n    \$_SERVER['HTTPS'] = 'on';\n}\n" "$MOODLE_CONFIG_FILE"
fi

chown www-data:www-data $MOODLE_CONFIG_FILE
echo "✅ Moodle config.php prepared successfully."

exec "$@"
