in every client/laravel node (Elendil, Isildur, Anarion, Gilgalad, Amandil):
service nginx status
service php8.4-fpm status
# jika belum aktif:
service nginx restart
service php8.4-fpm restart

testing:
curl -I http://elros.k32.com/api/airing

Benchmarking the setup with Apache Benchmark (ab) from every client/laravel node (Elendil, Isildur, Anarion, Gilgalad, Amandil):
apt update -y
apt install -y apache2-utils

low load test via ab (Apache Benchmark) from each node:
ab -n 100 -c 10 http://elros.k32.com/api/airing/

stress test:
ab -n 2000 -c 100 http://elros.k32.com/api/airing/

see worker node load (Elendil, Isildur, Anarion):
htop / top

tail -f /var/log/nginx/access.log

checkm elros logs:
tail -f /var/log/nginx/elros-access.log
tail -f /var/log/nginx/elros-error.log

it should show:
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.2:8001"
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.3:8002"
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.4:8003"
if not, load balancing is not working properly.

SO, the strategy:
- adding weights in reverse proxy (Elros):

nano /etc/nginx/sites-available/reverse-proxy
edit upstream block:
upstream kesatria_numenor {
    server 192.227.1.2:8001 weight=2;   # Elendil — lebih kuat
    server 192.227.1.3:8002 weight=1;   # Isildur
    server 192.227.1.4:8003 weight=1;   # Anarion
}

nginx -t
service nginx reload


now, retest via ab:
ab -n 2000 -c 100 http://elros.k32.com/api/airing/

Bandingkan hasilnya dengan sebelum diubah:
- Apakah Requests per second meningkat?
- Apakah Failed requests menurun?
- Apakah beban lebih seimbang (lihat log Elros & worker)?