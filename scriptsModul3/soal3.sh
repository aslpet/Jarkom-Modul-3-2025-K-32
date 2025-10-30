#Di Ministir
apt update -y
apt install -y nginx 

# Hapus konfigurasi default Nginx
rm /etc/nginx/sites-enabled/default
mkdir -p /etc/nginx/conf.d
nano /etc/nginx/conf.d/proxy.conf
server {
    listen 8080;

    resolver 192.168.122.1 ipv6=off;

    location / {
        # Izinkan subnet internal
        allow 192.227.0.0/16;
        deny all;

        # Forward ke host tujuan
        proxy_pass $scheme://$http_host$request_uri;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_connect_timeout 30s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    access_log /var/log/nginx/proxy_access.log;
    error_log /var/log/nginx/proxy_error.log;
}

nginx -t
service nginx restart
netstat -tuln | grep 8080

#Di GIlgalad
# Set variabel proxy di sesi saat ini
export http_proxy="http://192.227.4.3:8080"
export https_proxy="http://192.227.4.3:8080"

# (Opsional) Tambahkan ke .bashrc agar permanen
echo 'export http_proxy="http://192.227.4.3:8080"' >> ~/.bashrc
echo 'export https_proxy="http://192.227.4.3:8080"' >> ~/.bashrc
source ~/.bashrc

verification:
in Gilgalad:
wget -O /dev/null http://google.com
wget -O /dev/null http://www.debian.org
in Minastir:
tail -f /var/log/nginx/access.log  <-- logging