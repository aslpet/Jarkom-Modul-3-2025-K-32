in Palantir (Database server):
apt update -y
apt install -y mariadb-server
service mariadb start

mysql -u root
CREATE DATABASE laravel_db;
CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravel123';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
EXIT;

nano /etc/mysql/mariadb.conf.d/50-server.cnf
edit bind-address line:
- bind-address = 127.0.0.1
+ bind-address = 0.0.0.0

service mariadb restart

in worker laravel nodes (Elendil, Isildur, Anarion):
# Ganti nilai 'listen' dan 'server_name' sesuai tabel di bawah:
# Elendil: 8001 & elendil.k32.com
# Isildur: 8002 & isildur.k32.com
# Anarion: 8003 & anarion.k32.com

nano /etc/nginx/sites-available/laravel
server {
    listen 8001;    # 8002, 8003 untuk node lain
    server_name elendil.k32.com;   # sesuaikan

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # IZINKAN domain Elendil + Elros (reverse proxy) + IP internal (optional)
    # if ($host !~ ^(Elendil|Elros|localhost)\.k32\.com$) {
    #     return 403;
    # }
}

ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
nginx -t
service nginx restart
service php8.4-fpm restart

only in Elendil for seeding (to verify connection to database):
# 1. Edit koneksi database di .env (setelah Soal 7 selesai)
# (Gunakan kredensial yang kamu set di Palantir)
nano /var/www/laravel/.env
DB_CONNECTION=mysql
DB_HOST=192.227.4.3        # IP Palantir (Database)
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel
DB_PASSWORD=laravel123

# 2. Jalankan Migrasi dan Seeding
cd /var/www/laravel
php artisan migrate --seed

verification:
in Palantir:
mysql -u laravel -p
USE laravel_db;
SHOW TABLES;
SELECT * FROM users;
it should show users created by seeder

from other nodes (e.g., Gilgalad/Amandil):
curl -I http://elendil.k32.com:8001
it should return HTTP/1.1 200 OK
curl -I http://192.227.1.2:8001
it should return HTTP/1.1 403 Forbidden

lynx http://elendil.k32.com:8001

IF IN VERIFICATION IT SHOWS DATABASE CONNECTION ERROR/ OR IN MIGRATION IT FAILS:
cd /var/www/laravel
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
service php8.4-fpm restart
service nginx reload