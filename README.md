# Moodle 5.0.1 - Reverse Proxy Ready

Custom Docker image untuk Moodle 5.0.1 (MOODLE_501_STABLE) dengan dukungan reverse proxy (traefik, nginx, caddy dan lainnya), sudah dikonfigurasi untuk production-ready deployment dengan SSL/HTTPS.

## ✨ Fitur

- **Moodle 5.0.1** (MOODLE_501_STABLE branch)
- **PHP 8.3** dengan Apache
- **MariaDB 10.11** sebagai database (optional)
- **Reverse Proxy Ready** - Full support automatic HTTPS
- **Supervisor** - Menjalankan Apache & Moodle cron secara bersamaan
- **Ghostscript** - Untuk PDF annotation support
- **Environment-based Configuration** - Mudah dikonfigurasi via `.env` file
- **Auto SSL Proxy Detection** - Mendukung X-Forwarded-Proto header
- **SMTP Configuration** - Email configuration via environment variables
- **Optimized PHP Settings** - Pre-configured untuk performa optimal

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone <repository-url>
cd moodle-reverse-proxy
```

### 2. Setup Environment Variables

```bash
cp .env.example .env
```

Edit file `.env` dan sesuaikan dengan kebutuhan Anda:

```bash
# Domain/Host Moodle Anda
MOODLE_HOST=your-domain.com

# Database credentials
MOODLE_DATABASE_PASSWORD=your_secure_password
MOODLE_DATABASE_NAME=moodle
MOODLE_DATABASE_USER=moodle

# Admin credentials (untuk instalasi pertama kali)
MOODLE_USERNAME=admin
MOODLE_PASSWORD=your_admin_password
MOODLE_EMAIL=admin@your-domain.com

# SMTP Settings (opsional)
MOODLE_SMTP_HOST=smtp.gmail.com
MOODLE_SMTP_PORT_NUMBER=587
MOODLE_SMTP_USER=your-email@gmail.com
MOODLE_SMTP_PASSWORD=your_smtp_password
```

### 3. Build & Run

```bash
# Build image (opsional, jika ingin custom build)
docker compose build

# Run services, sesuaikan docker-compose.yml jika diperlukan
docker compose up -d
```

## 🔧 Konfigurasi

### Environment Variables

Berikut adalah environment variables yang tersedia:

#### Moodle Site Configuration

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `MOODLE_VERSION` | `MOODLE_501_STABLE` | Moodle branch version, kunjungin repository Moodle untuk mendapatkan nama branch lainnya|
| `MOODLE_SITE_NAME` | `Moodle Site` | Nama site Moodle |
| `MOODLE_HOST` | `localhost` | Domain/hostname untuk Moodle |
| `MOODLE_LANG` | `id` | Default language |
| `MOODLE_REVERSEPROXY` | `true` | Enable reverse proxy mode |
| `MOODLE_SSLPROXY` | `true` | Enable SSL proxy detection |

#### Database Configuration

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `MOODLE_DATABASE_TYPE` | `mysqli` | Database type (mysqli/pgsql) |
| `MOODLE_DATABASE_HOST` | `mariadb` | Database hostname |
| `MOODLE_DATABASE_PORT_NUMBER` | `3306` | Database port |
| `MOODLE_DATABASE_NAME` | `moodle` | Database name |
| `MOODLE_DATABASE_USER` | `moodle` | Database username |
| `MOODLE_DATABASE_PASSWORD` | `moodle` | Database password |

#### SMTP Configuration

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `MOODLE_SMTP_HOST` | `smtp` | SMTP server hostname |
| `MOODLE_SMTP_PORT_NUMBER` | `587` | SMTP port |
| `MOODLE_SMTP_USER` | - | SMTP username |
| `MOODLE_SMTP_PASSWORD` | - | SMTP password |
| `MOODLE_SMTP_PROTOCOL` | `tls` | SMTP protocol (tls/ssl) |

#### PHP Runtime Configuration

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `PHP_MEMORY_LIMIT` | `512M` | PHP memory limit |
| `UPLOAD_MAX_SIZE` | `128M` | Maximum upload file size |
| `POST_MAX_SIZE` | `128M` | Maximum POST size |
| `PHP_MAX_INPUT_VARS` | `5000` | Max input variables |

### Integrasi dengan Traefik

Untuk menggunakan Traefik sebagai reverse proxy, gunakan labels yang sudah disediakan di `traefik.label.example`:

```yaml
# Tambahkan labels berikut ke service moodle di docker-compose.yml
labels:
  - traefik.enable=true
  - traefik.docker.network=coolify
  - traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https
  - traefik.http.middlewares.gzip.compress=true
  - traefik.http.routers.moodle-http.entryPoints=http
  - traefik.http.routers.moodle-http.rule=Host(`your-domain.com`)
  - traefik.http.routers.moodle-http.middlewares=redirect-to-https
  - traefik.http.routers.moodle-https.entryPoints=https
  - traefik.http.routers.moodle-https.rule=Host(`your-domain.com`)
  - traefik.http.routers.moodle-https.middlewares=gzip
  - traefik.http.routers.moodle-https.tls.certresolver=letsencrypt
  - traefik.http.services.moodle.loadbalancer.server.port=80
```

Jangan lupa sesuaikan `your-domain.com` dengan domain Anda.

## 📁 Struktur Volume

> Pastikan Anda bind volume ini setelah proses instalasi selesai apabila dibind pada host.

```
volumes:
  - moodle_data:/var/www/moodledata    # Moodle data files
  - mariadb_data:/var/lib/mysql         # Database files
```

## 🤝 Contributing

Kontribusi selalu diterima! Silakan buat issue atau pull request.

## 📄 License

Project ini menggunakan Moodle yang dilisensikan under GPL v3. Lihat [Moodle License](https://docs.moodle.org/dev/License) untuk detail lebih lanjut.

## 👥 Maintainer

Project ini dirawat oleh Buda Suyasa (<budasuyasa@hookigroup.com>)
