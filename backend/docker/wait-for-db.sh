#!/bin/sh
set -e

cd /var/www/html

read_env_value() {
  key="$1"
  value=$(sed -n "s/^${key}=//p" /var/www/html/.env | tail -n 1 | tr -d '\r')
  value=${value#\"}
  value=${value%\"}
  printf '%s' "$value"
}

if [ ! -f /var/www/html/vendor/autoload.php ]; then
  echo "Preparing Composer dependencies inside container volume..."
  mkdir -p /var/www/html/vendor
  composer install --no-interaction --prefer-dist --optimize-autoloader --no-scripts
fi

echo "Waiting for MySQL to accept connections..."

DB_HOST=$(read_env_value DB_HOST)
DB_PORT=$(read_env_value DB_PORT)
DB_DATABASE=$(read_env_value DB_DATABASE)
DB_USERNAME=$(read_env_value DB_USERNAME)
DB_PASSWORD=$(read_env_value DB_PASSWORD)

export DB_HOST DB_PORT DB_DATABASE DB_USERNAME DB_PASSWORD

until php -r '
$host = getenv("DB_HOST") ?: "mysql";
$port = (int) (getenv("DB_PORT") ?: 3306);
$database = getenv("DB_DATABASE") ?: "";
$username = getenv("DB_USERNAME") ?: "";
$password = getenv("DB_PASSWORD") ?: "";

try {
    new PDO(
        "mysql:host={$host};port={$port};dbname={$database}",
        $username,
        $password,
        [PDO::ATTR_TIMEOUT => 3]
    );
} catch (Throwable $exception) {
    fwrite(STDERR, $exception->getMessage() . PHP_EOL);
    exit(1);
}
'; do
  sleep 2
done

echo "Finishing Laravel package discovery..."
php artisan package:discover --ansi

echo "Creating storage symlink..."
php artisan storage:link --force

echo "MySQL is ready. Starting PHP-FPM..."
exec php-fpm
