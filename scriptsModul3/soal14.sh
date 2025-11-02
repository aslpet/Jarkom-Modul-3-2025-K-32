#Again, di masing-masing node yak (galadriel, celeborn, and oropher)
apt update
apt install -y apache2-utils

# Perintah ini membuat file baru (-c) dan menambahkan pengguna noldor.
# Anda akan diminta untuk memasukkan kata sandi (silvan) dua kali.
htpasswd -c /etc/nginx/.htpasswd noldor
nano /etc/nginx/sites-available/php-worker

#Tambahkan ini, di bawah server_name dan diatas root /var/www/html;
    auth_basic "Akses Terbatas: Gerbang Taman Peri";
    auth_basic_user_file /etc/nginx/.htpasswd;

# Uji konfigurasi Nginx
nginx -t
service nginx restart

#Coba yg tanpa credes
curl -I http://galadriel.k32.com:8004
curl -I http://celeborn.k32.com:8005
curl -I http:/oropher.k32.com:8006
# Output: HTTP/1.1 401 Unauthorized
#With credes
curl -u noldor:silvan http://galadriel.k32.com:8004
curl -u noldor:silvan http://celeborn.k32.com:8005
curl -u noldor:silvan http:/oropher.k32.com:8006