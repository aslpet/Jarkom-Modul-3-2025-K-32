# Lakukan langkah-langkah ini di Elendil, Isildur, dan Anarion:
apt update -y
# Install Nginx, PHP-FPM, dan tools untuk Laravel
apt install -y nginx php8.4 php8.4-fpm php8.4-cli php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip unzip composer git

# 1. Clone Project Laravel
cd /var/www
rm -rf laravel   # Hapus folder jika ada
git clone https://github.com/elshiraphine/laravel-simple-rest-api laravel
cd laravel

# 2. Install Dependency
# Ini akan mengunduh semua library yang dibutuhkan Laravel
composer install
composer update

# 3. Setup Lingkungan
# Buat file .env dari contoh dan generate encryption key
cp .env.example .env
php artisan key:generate

# 4. Atur Kepemilikan (penting agar Nginx dan PHP-FPM bisa menulis ke log/cache)
chown -R www-data:www-data /var/www/laravel
chmod -R 775 /var/www/laravel/storage

service php8.4-fpm restart
service nginx restart

# Verifikasi dari node lain (Gilgalad dan Amandil):
apt update && apt install lynx -y
ping -c 4 elendil.k32.com
curl -I http://elendil.k32.com:8001/api/products
lynx http://elendil.k32.com:8001/api/products