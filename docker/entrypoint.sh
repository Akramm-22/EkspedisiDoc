#!/bin/bash
set -e

cd /var/www/html

echo "[entrypoint] Waiting for database at ${DB_HOST:-mysql}:${DB_PORT:-3306}..."
for i in $(seq 1 60); do
    if php -r "
        \$h = getenv('DB_HOST') ?: 'mysql';
        \$p = getenv('DB_PORT') ?: 3306;
        \$c = @fsockopen(\$h, (int) \$p, \$errno, \$errstr, 2);
        if (\$c) { fclose(\$c); exit(0); }
        exit(1);
    "; then
        echo "[entrypoint] Database is reachable."
        break
    fi
    echo "[entrypoint] Database not ready yet ($i/60)..."
    sleep 2
done

if [ -z "${APP_KEY}" ]; then
    echo "[entrypoint] ERROR: APP_KEY is empty. Generate one with 'php artisan key:generate --show'"
    echo "[entrypoint]        and set it in .env.docker before starting containers."
    exit 1
fi

# storage/ is a shared volume across all 3 web replicas, so guard the
# storage:link + migrate steps with a simple file lock. Whichever
# container starts first does the setup; the other two just wait.
LOCK_FILE="/var/www/html/storage/.bootstrapped"

(
    flock -w 60 200 || { echo "[entrypoint] Could not acquire bootstrap lock, continuing anyway."; exit 0; }

    if [ ! -f "$LOCK_FILE" ]; then
        echo "[entrypoint] Running first-time bootstrap (migrations)..."
        php artisan migrate --force
        touch "$LOCK_FILE"
        echo "[entrypoint] Bootstrap complete."
    else
        echo "[entrypoint] Migrations already applied by another replica, skipping."
    fi
) 200>/var/www/html/storage/.bootstrap.lock

# public/ lives in each container's own filesystem (not the shared storage
# volume), so every replica needs its own symlink and caches, regardless of
# which container did the migration above.
if [ ! -L public/storage ]; then
    php artisan storage:link || true
fi
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

exec "$@"
