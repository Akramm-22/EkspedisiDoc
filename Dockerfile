# syntax=docker/dockerfile:1

############################################
# Stage 1: Build frontend assets (Vite)
############################################
FROM node:20-alpine AS frontend

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY resources/ resources/
COPY vite.config.js tailwind.config.js postcss.config.js ./
RUN npm run build

############################################
# Stage 2: Install PHP/Composer dependencies
############################################
FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-autoloader \
    --prefer-dist \
    --ignore-platform-reqs

COPY . .
RUN composer dump-autoload --optimize --no-dev

############################################
# Stage 3: Runtime image (PHP-FPM)
############################################
FROM php:8.2-fpm-alpine AS runtime

LABEL maintainer="drgEkspedisi"

# System dependencies + PHP extensions required by Laravel/Midtrans/GD captcha/PDF
RUN apk add --no-cache \
        bash \
        curl \
        nginx \
        libpng-dev \
        libjpeg-turbo-dev \
        libzip-dev \
        freetype-dev \
        icu-dev \
        oniguruma-dev \
        libxml2-dev \
        zip \
        unzip \
        supervisor \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        zip \
        intl \
        opcache

# Recommended php.ini settings for production
RUN { \
        echo 'opcache.enable=1'; \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.max_accelerated_files=10000'; \
        echo 'opcache.validate_timestamps=0'; \
        echo 'opcache.jit=1255'; \
        echo 'opcache.jit_buffer_size=64M'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini \
    && { \
        echo 'upload_max_filesize=20M'; \
        echo 'post_max_size=20M'; \
        echo 'memory_limit=256M'; \
    } > /usr/local/etc/php/conf.d/uploads-recommended.ini

WORKDIR /var/www/html

# Application code + vendor (from build stages)
COPY --chown=www-data:www-data . .
COPY --from=vendor --chown=www-data:www-data /app/vendor ./vendor
COPY --from=frontend --chown=www-data:www-data /app/public/build ./public/build

# Nginx (serves Laravel's public/ and proxies PHP to php-fpm on 127.0.0.1:9000)
# and Supervisor (keeps nginx + php-fpm running together in one container)
COPY docker/nginx.web.conf /etc/nginx/http.d/default.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Entrypoint handles key generation, migrations, storage link, caching
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Writable directories Laravel needs at runtime
RUN mkdir -p storage/framework/{sessions,views,cache/data} storage/logs bootstrap/cache \
    && mkdir -p /run/nginx \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Basic container health check hitting Laravel's own health route
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=5 \
    CMD curl -f http://127.0.0.1/up || exit 1

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
