in Elros:
apt update -y
apt install -y nginx

nano /etc/nginx/sites-available/reverse-proxy
# ============================
# Reverse Proxy - Elros
# ============================

upstream kesatria_numenor {
    server 192.227.1.2:8001;   # Elendil
    server 192.227.1.3:8002;   # Isildur
    server 192.227.1.4:8003;   # Anarion
}

server {
    listen 80;
    server_name elros.k32.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Opsional: untuk debugging / keamanan
    access_log /var/log/nginx/elros-access.log;
    error_log  /var/log/nginx/elros-error.log;
}

ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
nginx -t
service nginx restart

in Gilgalad/Amandil:
dig elros.k32.com @192.227.3.2
ping elros.k32.com
