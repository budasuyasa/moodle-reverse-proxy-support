# ============================================
# Custom Moodle 5.0.1 (reverse-proxy ready)
# ============================================

FROM php:8.3-apache

LABEL maintainer="hookigroup.com" \
  description="Custom Moodle 5.0.1 image (MOODLE_501_STABLE) with Traefik support, Ghostscript, Supervisor, and ENV-based config."

# --- Install dependencies ---
RUN apt-get update && apt-get install -y \
  git unzip ghostscript cron supervisor vim \
  libpng-dev libjpeg-dev libfreetype6-dev libicu-dev libxml2-dev libzip-dev libpq-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd intl xml zip mysqli opcache \
  && a2enmod rewrite headers env \
  && rm -rf /var/lib/apt/lists/*

# --- Working directory ---
WORKDIR /var/www/html

# --- Build arguments ---
ARG MOODLE_VERSION=MOODLE_501_STABLE

# --- Fetch Moodle ---
RUN git clone -b ${MOODLE_VERSION} https://github.com/moodle/moodle.git .

# --- Environment variables ---
ENV MOODLE_DATA=/var/www/moodledata \
  MOODLE_SITE_NAME="Moodle Site" \
  MOODLE_HOST="localhost" \
  MOODLE_LANG="en" \
  MOODLE_REVERSEPROXY=true \
  MOODLE_SSLPROXY=true \
  MOODLE_USERNAME=admin \
  MOODLE_PASSWORD=admin123 \
  MOODLE_EMAIL=admin@example.com \
  MOODLE_DATABASE_TYPE=mysqli \
  MOODLE_DATABASE_HOST=mariadb \
  MOODLE_DATABASE_PORT_NUMBER=3306 \
  MOODLE_DATABASE_NAME=moodle \
  MOODLE_DATABASE_USER=moodle \
  MOODLE_DATABASE_PASSWORD=moodle \
  MOODLE_SMTP_HOST=smtp \
  MOODLE_SMTP_PORT_NUMBER=587 \
  MOODLE_SMTP_USER= \
  MOODLE_SMTP_PASSWORD= \
  MOODLE_SMTP_PROTOCOL=tls \
  PHP_MEMORY_LIMIT=512M \
  UPLOAD_MAX_SIZE=128M \
  POST_MAX_SIZE=128M \
  PHP_MAX_INPUT_VARS=5000

# --- Create Moodle data dir ---
RUN mkdir -p ${MOODLE_DATA} && chown -R www-data:www-data ${MOODLE_DATA}

# --- Apache PHP configuration ---
RUN echo "upload_max_filesize=${UPLOAD_MAX_SIZE}" > /usr/local/etc/php/conf.d/uploads.ini \
  && echo "post_max_size=${POST_MAX_SIZE}" >> /usr/local/etc/php/conf.d/uploads.ini \
  && echo "memory_limit=${PHP_MEMORY_LIMIT}" >> /usr/local/etc/php/conf.d/memory.ini \
  && echo "max_input_vars=${PHP_MAX_INPUT_VARS}" >> /usr/local/etc/php/conf.d/input_vars.ini \
  && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# --- Supervisor setup ---
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# --- Entry point for dynamic config injection ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# --- Permissions ---
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

