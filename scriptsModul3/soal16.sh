#Di Pharazon
apt update
apt install -y nginx

rm /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/pharazon-lb

# 1. DEFINE UPSTREAM (Load Balancer Group)
upstream Kesatria_Lorien {
    # Menggunakan algoritma default (Round Robin)
    server 192.227.2.5:8004;  # Galadriel
    server 192.227.2.6:8005;  # Celeborn
    server 192.227.2.7:8006;  # Oropher
}

# 2. SERVER BLOCK (Reverse Proxy)
server {
    listen 80;
    server_name pharazon.k32.com;

    location / {
        # Meneruskan permintaan ke kelompok worker
        proxy_pass http://Kesatria_Lorien;

        # --- PENTING: Meneruskan Basic Auth & IP Asli ---
        # Meneruskan header Basic Authentication (Authorization)
        proxy_set_header Authorization $http_authorization; 

        # Meneruskan IP asli klien ke worker (worker akan melihat ini)
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        # --------------------------------------------------
    }
}

# 1. Aktifkan konfigurasi baru
ln -s /etc/nginx/sites-available/pharazon-lb /etc/nginx/sites-enabled/
nginx -t
service nginx restart

#Uji dari gilgalad
curl http://pharazon.k32.com
# Output yang diharapkan: Pesan 401 Unauthorized dari Pharazon
curl -u noldor:silvan http://pharazon.k32.com