#Lakukan ini di node masing-masing yaa
nano /etc/nginx/sites-available/php-worker
#untuk galadriel
listen	8004
server_name	galadriel.k32.com
#untuk celeborn
listen	8005
server_name	celeborn.k32.com
#untuk oropher
listen	8006
server_name	oropher.k32.com

nginx -t
service nginx restart
service php8.4-fpm restart

# Uji Galadriel
lynx http://galadriel.k32.com:8004
# Uji Celeborn
lynx http://celeborn.k32.com:8005
# Uji Oropher
lynx http://oropher.k32.com:8006