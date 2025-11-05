# Lakukan di Elendil, Isildur, dan Anarion (Pastikan Soal 7 & 8 sudah selesai)
cd /var/www/laravel
php artisan route:clear
php artisan route:cache
php artisan route:list   # (Opsional) Verifikasi rute /api/testdb sudah terdaftar

service php8.4-fpm restart
service nginx restart

# Lakukan verifikasi di node client
apt update && apt install -y lynx curl

echo "--- Verifikasi Halaman Utama Laravel (lynx) ---"
lynx http://Elendil.k32.com:8001
lynx http://Isildur.k32.com:8002
lynx http://Anarion.k32.com:8003
# Pastikan Anda melihat halaman selamat datang Laravel.

"--- Verifikasi API /api/airing yang ASLI (curl) ---"
curl http://elendil.k32.com:8001/api/airing
curl http://isildur.k32.com:8002/api/airing
curl http://anarion.k32.com:8003/api/airing