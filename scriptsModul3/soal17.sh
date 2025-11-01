#Di Gilgalad
apt update
apt install -y apache2-utils

#Encode dengan
echo -n "noldor:silvan" | base64

ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/

#Di Galadriel
service nginx stop
service nginx status

#Di Gilgalad
ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/

#cara cek error (yg ke galadriel)
cat /var/log/nginx/error.log | grep "192.227.2.5:8004"

log_format combined '$remote_addr - $remote_user [$time_local] '
                        '"$request" $status $body_bytes_sent '
                        '"$http_referer" "$http_user_agent" '
                        '**$upstream_addr**'; # Baris ini harus ada!
                        
    access_log /var/log/nginx/access.log combined;