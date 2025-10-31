in Elendil, Isildur, and Anarion:
apt update -y
apt install -y nginx php8.4 php8.4-fpm php8.4-cli php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip unzip composer

cd /var/www
mkdir laravel
cd laravel
echo "<?php phpinfo(); ?>" > index.php

cd / cd ~

rm /etc/nginx/sites-enabled/default

nano /etc/nginx/sites-available/laravel
server {
    listen 80;
    server_name _;

    root /var/www/laravel;
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
}

nginx -t
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/

service php8.4-fpm start
service nginx start
service php8.4-fpm restart
service nginx restart
netstat -tuln | grep :80

verification:
from other nodes:
apt update && apt install lynx -y
ping 192.227.1.2
curl -I http://192.227.1.2
dig Elendil.k32.com @192.227.3.2
lynx http://Elendil.k32.com
