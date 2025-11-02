#Simulate load balancing with Apache Benchmark (ab)
#Di Gilgalad
apt update
apt install -y apache2-utils

#opsi1: simple ab test without auth header
#Encode dengan
echo -n "noldor:silvan" | base64
ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/

#opsi2: ab test with dynamic auth header
ab -n 100 -c 10 -H "Authorization: Basic $(echo -n 'noldor:silvan' | base64)" http://pharazon.k32.com/

#Di Pharazon
if hasn't got upstream_addr column, do this:
nano /etc/nginx/nginx.conf
confirm:
http {
    log_format combined '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        '$upstream_addr';

    access_log /var/log/nginx/pharazon-access.log combined;

    # ... konfigurasi lain ...
}

nginx -t
service nginx restart

now do ab test again from gilgalad;
ab -n 100 -c 10 -H "Authorization: Basic $(echo -n 'noldor:silvan' | base64)" http://pharazon.k32.com/

in pharazon, check the access log:
tail -f /var/log/nginx/pharazon-access.log
it should show upstream_addr column in access log, like this:
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.5:8004
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.6:8005
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.7:8006

#Simulate nginx down in one of the worker node, e.g. Galadriel

#Di Galadriel
service nginx stop
service nginx status

#Di Gilgalad
ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/

#cara cek error (yg ke galadriel)
cat /var/log/nginx/error.log | grep "192.227.2.5:8004"

it should show something like this:
connect() failed (111: Connection refused) while connecting to upstream,
client: 192.227.2.35, server: pharazon.k32.com,
request: "GET / HTTP/1.0", upstream: "http://192.227.2.5:8004/",
host: "pharazon.k32.com"