# Di Galadriel, Celeborn, Oropher
# 1. Update list paket dan Instal Nginx dan PHP-FPM
# Catatan: Jika instalasi php8.4-fpm gagal, coba versi yang lebih rendah yang tersedia (misal: php8.2-fpm).
apt update
apt install -y nginx php8.4-fpm

# Buat file index.php
echo '<?php echo "Welcome to Taman Digital "; echo gethostname(); ?>' > /var/www/html/index.php

# Berikan hak akses yang benar untuk Nginx
chown -R www-data:www-data /var/www/html

# Hapus symlink default yang aktif
rm /etc/nginx/sites-enabled/default

# Edit file konfigurasi baru
nano /etc/nginx/sites-available/php-worker

#For Galadriel
# Blok utama untuk melayani domain
server {
    listen 80;
    server_name galadriel.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}

#For Celeborn
server {
    listen 80;
    server_name celeborn.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}

#For Oropher
server {
    listen 80;
    server_name oropher.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}

ln -s /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/
nginx -t
service php8.4-fpm restart
service nginx restart

#Di Gilgalad
apt update
apt install -y lynx
# Uji Galadriel
lynx http://galadriel.k32.com
# Uji Celeborn
lynx http://celeborn.k32.com
# Uji Oropher
lynx http://oropher.k32.com

it should show "Welcome to Taman Digital <hostname>" for each respective server.

if using ip address to access any of the servers, the connection should be closed without any response.
: curl: (52) Empty reply from server