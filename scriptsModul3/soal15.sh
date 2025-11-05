#Lakukan ini di node masing2 juga
nano /etc/nginx/sites-available/php-worker
#tambahkan ini, diantara include snippets dan fastcgi_pass
fastcgi_param HTTP_X_REAL_IP $remote_addr;

nginx -t
service nginx restart

nano /var/www/html/index.php
<?php 
$hostname = gethostname();
$visitor_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];

echo "Welcome to taman digital $hostname.<br>";
echo "Anda (Sang Pengunjung) datang dari alamat IP: $visitor_ip"; 
?>

#Tes lagi dari gilgalad
# Uji galadriel, celeborn, dan oropher
curl -u noldor:silvan http://galadriel.k32.com:8004
curl -u noldor:silvan http://celeborn.k32.com:8005
curl -u noldor:silvan http:/oropher.k32.com:8006

lynx http://galadriel.k32.com:8004
lynx http://celeborn.k32.com:8005
lynx http:/oropher.k32.com:8006

output:
Welcome to Taman Digital Galadriel.
Anda (Sang Pengunjung) datang dari alamat IP: 192.227.2.35