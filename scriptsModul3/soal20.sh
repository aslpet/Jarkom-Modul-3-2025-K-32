in pharazon:
mkdir -p /var/cache/nginx/proxy_cache
chown -R www-data:www-data /var/cache/nginx/proxy_cache

nano /etc/nginx/sites-available/pharazon-lb
add caching conf before server { , after upstream XXXX {}:
# Zona cache: 100 MB size, valid 10 menit
proxy_cache_path /var/cache/nginx/proxy_cache levels=1:2 keys_zone=my_cache:100m max_size=500m inactive=10m use_temp_path=off;

and edit server block (server {...}):
server {
    listen 80;
    server_name pharazon.k32.com;

    location / {
        proxy_pass http://Kesatria_Lorien;

        # Header dan IP forwarding
        proxy_set_header Authorization $http_authorization;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;

        # -------------------
        # ENABLE CACHING HERE
        # -------------------
        proxy_cache my_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;

        # Tambahkan header agar bisa dicek via curl
        add_header X-Cache-Status $upstream_cache_status;

        # Agar POST dan auth request tidak di-cache
        proxy_cache_methods GET HEAD;
    }
}

nginx -t
service nginx reload

verification:
in Gilgalad/Amandil/Clients:
curl -I http://pharazon.k32.com/ / curl -u noldor:silvan http://pharazon.k32.com/ / curl -I -u noldor:silvan http://pharazon.k32.com/
1st output:
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 31 Oct 2025 22:45:13 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
X-Cache-Status: MISS   <-- should be MISS

again,
curl -I http://pharazon.k32.com/ / curl -u noldor:silvan http://pharazon.k32.com/ / curl -I -u noldor:silvan http://pharazon.k32.com/
2nd output should be:
HTTP/1.1 200 OK
Server: nginx
Date: Fri, 31 Oct 2025 22:45:13 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
X-Cache-Status: HIT   <-- should be HIT

in Pharazon:
ls -lh /var/cache/nginx/proxy_cache
there's should be result of the worker response (whether it's MISS:1st; HIT:2nd,est; EXPIRED:invalid; BYPASS:bypass)

in Galadriel:
tail -f /var/log/nginx/access.log
# Pada request pertama, worker akan menerima permintaan (kode 200).
# Setelah itu, tidak akan ada permintaan baru dari Pharazon selama cache masih valid (10 menit).
