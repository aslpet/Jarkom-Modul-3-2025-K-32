# Lakukan di Elendil, Isildur, dan Anarion (Pastikan Soal 7 & 8 sudah selesai)

# --- A. Tambahkan Import DB di API Routes ---
# Anda harus menambahkan 'use Illuminate\Support\Facades\DB;' di routes/api.php
# karena di file asli tidak ada.

nano /var/www/laravel/routes/api.php

# Tambahkan baris di bawah 'use Illuminate\Support\Facades\Route;'

# Sebelum:
# use Illuminate\Support\Facades\Route;

# Setelah (tambahkan baris ini):
use Illuminate\Support\Facades\DB;  # <-- WAJIB DITAMBAHKAN!
# use App\Http\Controllers\AiringController; # Biarkan baris ini ada

# --- B. Tambahkan Endpoint Pengujian Koneksi DB ---
# Tambahkan rute pengujian di akhir file /routes/api.php, di LUAR Route::group(['prefix' => 'airing']).
# Rute ini akan menjadi /api/testdb

nano /var/www/laravel/routes/api.php

# Tambahkan kode ini di BARIS PALING BAWAH file api.php:
Route::get('/testdb', function () {
    try {
        // Lakukan query sederhana untuk memastikan koneksi ke Palantir sukses
        $databases = DB::select('SHOW DATABASES');

        return response()->json([
            'status' => 'connected',
            'message' => 'Koneksi ke Palantir (DB) berhasil.',
            'databases' => $databases
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'Gagal terhubung ke Palantir. Error: ' . $e->getMessage()
        ], 500);
    }
});

# --- C. Hapus/Abaikan Perubahan di bootstrap/app.php ---
# DIKARENAKAN struktur file Anda adalah Laravel baru, Anda TIDAK PERLU
# menambahkan 'api: __DIR__.'/../routes/api.php',' secara manual.
# Anda CUKUP MEMASTIKAN Laravel menggunakan 'web.php' dan 'api.php' di file app/Providers/RouteServiceProvider.php
# ABAIKAN langkah edit bootstrap/app.php yang ada di catatan Anda.

# --- D. Clear dan Cache Rute ---
cd /var/www/laravel
php artisan route:clear
php artisan route:cache
php artisan route:list   # (Opsional) Verifikasi rute /api/testdb sudah terdaftar

service php8.4-fpm restart
service nginx restart

# Lakukan verifikasi di node client
apt update && apt install -y lynx curl

echo "--- Verifikasi Halaman Utama Laravel (lynx) ---"
lynx http://Elendil.k32.com:8001
lynx http://Isildur.k32.com:8002
lynx http://Anarion.k32.com:8003
# Pastikan Anda melihat halaman selamat datang Laravel.

echo "--- Verifikasi API /api/airing yang ASLI (curl) ---"
# Karena Anda tidak membuat AiringController, ini mungkin akan error 500, tapi 
# setidaknya Nginx/PHP berjalan.
curl http://Elendil.k32.com:8001/api/airing
# Catatan: Rute /api/airing yang asli mengarah ke AiringController, yang mungkin 
# belum Anda buat. Ini hanya untuk memastikan rute yang ada terbaca.

echo "--- Verifikasi Koneksi DB ke Palantir (/api/testdb) ---"
# Ini adalah pengganti rute /api/airing yang Anda buat.
curl http://Elendil.k32.com:8001/api/testdb
curl http://Isildur.k32.com:8002/api/testdb
curl http://Anarion.k32.com:8003/api/testdb
# Output WAJIB menampilkan "status": "connected" dan daftar database Palantir.