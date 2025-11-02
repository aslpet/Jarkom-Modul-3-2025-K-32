edit nginx config for load balancer in each load balancer node (Pharazon and elros):
in elros and pharazon:
nano /etc/nginx/sites-available/elros-lb  or nano /etc/nginx/sites-available/pharazon-lb
add at the very top, before server block:
# Zona shared memory untuk rate limiting (1MB bisa menyimpan sekitar 16.000 IP)
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
and in server block, inside location / { ... }, before proxy_pass add:
limit_req zone=one burst=20 nodelay;

example (in pharazon):
upstream Kesatria_Lorien {
    server 192.227.2.5:8004;
    server 192.227.2.6:8005;
    server 192.227.2.7:8006;
}

limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;

server {
    listen 80;
    server_name pharazon.k32.com;

    location / {
        limit_req zone=one burst=20 nodelay;

        proxy_pass http://Kesatria_Lorien;
        proxy_set_header Authorization $http_authorization;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
    }
}

nginx -t
service nginx reload

in gilgalad/Amandil/clients:
apt install -y apache2-utils

ab -n 500 -c 50 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/

in pharazon and elros:
check log in pharazon and elros:
tail -f /var/log/nginx/error.log

it should show something like this when rate limit exceeded:
2025/10/31 22:10:23 [error] 2451#2451: *142 limiting requests, excess: 10.600 by zone "one", client: 192.227.2.35, server: pharazon.k32.com, request: "GET / HTTP/1.0"

or in access.log:
2025/10/31 22:10:23 [error] 2451#2451: *142 limiting requests, excess: 10.600 by zone "one", client: 192.227.2.35, server: pharazon.k32.com, request: "GET / HTTP/1.0"