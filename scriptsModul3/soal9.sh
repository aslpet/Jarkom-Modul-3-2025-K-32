in every laravel node (Elendil, Isildur, Anarion):
service nginx status
service php8.4-fpm status
# jika belum aktif:
service nginx restart
service php8.4-fpm restart

add a file from /var/www/laravel/routes -> api.php:
nano /var/www/laravel/routes/api.php
<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::get('/airing', function () {
    try {
        $data = DB::select('SHOW DATABASES');
        return response()->json([
            'status' => 'connected',
            'databases' => $data
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
    }
});

edit in /var/www/laravel/bootstrap/app.php:
nano /var/www/laravel/bootstrap/app.php
->withRouting(
    web: __DIR__.'/../routes/web.php',
    api: __DIR__.'/../routes/api.php',    <-- add this line
    commands: __DIR__.'/../routes/console.php',
)

cd /var/www/laravel
php artisan route:clear
php artisan route:cache
php artisan route:list
service php8.4-fpm restart
service nginx restart

verification from other nodes (clients/Gilgalad and Amandil):
nano /etc/resolv.conf
nameserver 192.227.3.2     <-- confirm this line exists, add if not
nameserver 192.227.3.3     <-- this line also exist, add if not
nameserver 192.168.122.1

lynx http://Elendil.k32.com:8001
lynx http://Isildur.k32.com:8002
lynx http://Anarion.k32.com:8003

curl http://Elendil.k32.com:8001/api/airing
curl http://Isildur.k32.com:8002/api/airing
curl http://Anarion.k32.com:8003/api/airing

verification from database node via API (Palantir):
nano /etc/resolv.conf
nameserver 192.227.3.2     <-- confirm this line exists, add if not
nameserver 192.227.3.3     <-- this line also exist, add if not
nameserver 192.168.122.1

curl http://Elendil.k32.com:8001/api/airing
curl http://Isildur.k32.com:8002/api/airing
curl http://Anarion.k32.com:8003/api/airing


all output should show:
{
  "status": "connected",
  "databases": [
    { "Database": "information_schema" },
    { "Database": "laravel_db" }
  ]
}
