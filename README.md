# Laporan Resmi Praktikum Modul 3 Jarkom

|No|Nama anggota|NRP|
|---|---|---|
|1. | Tasya Aulia Darmawan | 5027241009|
|2. | Ahmad Rafi F D | 5027241068|

## Soal 1
Semua node non-router harus dikonfigurasi dengan IP static dan gateway ke Durin, serta Durin dikonfigurasi sebagai router NAT agar semua node dapat mengakses Internet/Valinor (192.168.122.1).

---
### 1. Konfigurasi Router Utama: Durin (Router/Gateway)
```
# Interface ke Internet (NAT)
auto eth0
iface eth0 inet dhcp

# Subnet 1 – Laravel Workers (Manusia)
auto eth1
iface eth1 inet static
    address 192.227.1.1
    netmask 255.255.255.0

# Subnet 2 – Clients Manusia
auto eth2
iface eth2 inet static
    address 192.227.2.1
    netmask 255.255.255.0

# Subnet 3 – DNS & DHCP
auto eth3
iface eth3 inet static
    address 192.227.3.1
    netmask 255.255.255.0

# Subnet 4 – Database & Proxy
auto eth4
iface eth4 inet static
    address 192.227.4.1
    netmask 255.255.255.0

# Subnet 5 – PHP Workers (Peri)
auto eth5
iface eth5 inet static
    address 192.227.5.1
    netmask 255.255.255.0

# NAT agar jaringan internal (192.227.0.0/16) bisa akses Internet
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.227.0.0/16
```
Di CLI:
```
nano /root/.bashrc
```
Isi dengan:
```
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
apt update -y
apt install -y iptables iptables-persistent

echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
### 2. Konfigurasi Node Non-Router (Clients & Servers)
```
auto eth0
iface eth0 inet static
    address 192.227.1-5.[nodes]
    netmask 255.255.255.0
    gateway 192.227.1-5.1

| Subnet                          | Node        | IP           | Gateway     |
| ------------------------------- | ----------- | ------------ | ----------- |
| **192.227.1.0/24 (Durin eth1)** | Elendil     | 192.227.1.2  | 192.227.1.1 |
|                                 | Isildur     | 192.227.1.3  | 192.227.1.1 |
|                                 | Anarion     | 192.227.1.4  | 192.227.1.1 |
|                                 | Miriel      | 192.227.1.5  | 192.227.1.1 |
|                                 | Amandil     | 192.227.1.6  | 192.227.1.1 |
|                                 | Elros       | 192.227.1.7  | 192.227.1.1 |
| **192.227.2.0/24 (Durin eth2)** | Gilgalad    | 192.227.2.2  | 192.227.2.1 |
|                                 | Celebrimbor | 192.227.2.3  | 192.227.2.1 |
|                                 | Pharazon    | 192.227.2.4  | 192.227.2.1 |
|                                 | Galadriel   | 192.227.2.5  | 192.227.2.1 |
|                                 | Celeborn    | 192.227.2.6  | 192.227.2.1 |
|                                 | Oropher     | 192.227.2.7  | 192.227.2.1 |
| **192.227.3.0/24 (Durin eth3)** | Khamul      | 192.227.3.95 | 192.227.3.1 |
|                                 | Erendis     | 192.227.3.2  | 192.227.3.1 |
|                                 | Amdir       | 192.227.3.3  | 192.227.3.1 |
| **192.227.4.0/24 (Durin eth4)** | Aldarion    | 192.227.4.2  | 192.227.4.1 |
|                                 | Palantir    | 192.227.4.3  | 192.227.4.1 |
|                                 | Narvi       | 192.227.4.4  | 192.227.4.1 |
| **192.227.5.0/24 (Durin eth5)** | Minastir    | 192.227.5.2  | 192.227.5.1 |
```
3. Di setiap client/nonrouter node:
```
nano /root/.bashrc
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
## Soal 2
Raja Pelaut Aldarion menetapkan pembagian tanah secara dinamis untuk Client Manusia dan Peri, sementara Khamul diberikan tanah tetap (fixed address), dengan Durin bertindak sebagai penyampai dekrit (DHCP Relay) ke semua wilayah.

---
### 1. Konfigurasi Server DHCP: Aldarion
```
apt update -y
apt install -y isc-dhcp-server
```
Lalu,
```
nano /etc/default/isc-dhcp-server
```
```
INTERFACESv4="eth0"
```
Konfigurasi rentang IP dinamis untuk setiap subnet (Subnet 1: Manusia, Subnet 2: Peri) dan penetapan IP tetap untuk Khamul.
```
nano /etc/dhcp/dhcpd.conf
```
```
# -----------------------------------------
# DHCP Configuration - Aldarion (DHCP Server)
# -----------------------------------------

ddns-update-style none;
authoritative;
log-facility local7;

default-lease-time 600;
max-lease-time 7200;

# ========================
#  SUBNET 1 - MANUSIA
# ========================
subnet 192.227.1.0 netmask 255.255.255.0 {
    range 192.227.1.6 192.227.1.34;
    range 192.227.1.68 192.227.1.94;
    option routers 192.227.1.1;
    option broadcast-address 192.227.1.255;
    option domain-name-servers 192.227.3.2, 192.227.3.3, 192.168.122.1;
}

# ========================
#  SUBNET 2 - PERI
# ========================
subnet 192.227.2.0 netmask 255.255.255.0 {
    range 192.227.2.35 192.227.2.67;
    range 192.227.2.96 192.227.2.121;
    option routers 192.227.2.1;
    option broadcast-address 192.227.2.255;
    option domain-name-servers 192.227.3.2, 192.227.3.3, 192.168.122.1;
}

# ========================
#  SUBNET 3 - KURCACI
# ========================
subnet 192.227.3.0 netmask 255.255.255.0 {
    option routers 192.227.3.1;
    option broadcast-address 192.227.3.255;
}

# ========================
#  SUBNET 4 - DATABASE
# ========================
subnet 192.227.4.0 netmask 255.255.255.0 {
    option routers 192.227.4.1;
    option broadcast-address 192.227.4.255;
}

# ========================
#  SUBNET 5 - PROXY
# ========================
subnet 192.227.5.0 netmask 255.255.255.0 {
    option routers 192.227.5.1;
    option broadcast-address 192.227.5.255;
}

# ========================
#  FIXED ADDRESS - KHAMUL
# ========================
host Khamul {
    hardware ethernet 02:42:d6:54:3a:00;
    fixed-address 192.227.3.95;
}
```
Restart
```
service isc-dhcp-server restart
```
### 2. Konfigurasi Penghubung/Relay: Durin
```
apt update -y
apt install -y isc-dhcp-relay
```
```
nano /etc/default/isc-dhcp-relay
```
```
SERVERS="192.227.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""
```
Restart
```
service isc-dhcp-relay restart
```
### 3. Konfigurasi Client Dinamis
di Gilgalad, Amandil, and Khamul:
```
apt update --allow-releaseinfo-change -y
apt install -y isc-dhcp-client
```
```
nano /etc/network/interfaces
```
change from static to dhcp:
```
auto eth0
iface eth0 inet dhcp
```
Restart
```
service networking restart
dhclient -v eth0
```
![Assets/modul3.png](assets/no2.1.png)

![Assets/modul3.png](assets/no2.2.png)

Untuk verification:
in clients nodes/Gilgalad and Amandil/ and fixed ip node Khamul:
```
ip a | grep inet
cat /var/lib/dhcp/dhclient.leases
```
Di Aldarion (router/server):
```
tail -f /var/log/syslog | grep DHCPACK
```
should be:  DHCPACK on 192.227.x.x to 02:00:00:00:xx:xx via eth0
## Soal 3
Minastir didirikan untuk mengontrol arus informasi, berfungsi sebagai DNS Forwarder yang mengatur agar semua node (kecuali Durin) wajib melewati Minastir untuk mendapatkan resolusi nama sebelum mengirim pesan ke dunia luar (Valinor/Internet).

---
### 1. Konfigurasi Menara Pengawas: Minastir
```
apt update -y
apt install -y bind9
```
```
nano /etc/bind/named.conf.options
```
Isi dengan:
```
options {
    directory "/var/cache/bind";

    // Forward semua query DNS ke resolver upstream
    forwarders {
        192.168.122.1;    // bisa juga 8.8.8.8 bila ingin ke DNS publik
    };

    allow-query { any; };   // izinkan semua klien
    recursion yes;          // aktifkan recursive resolving
    dnssec-validation no;   // nonaktifkan validasi DNSSEC
    listen-on { any; };     // dengarkan di semua interface
};
```
Jalankan:
```
/usr/sbin/named -u bind
netstat -tuln | grep :53    # harus ada listener UDP/TCP port 53
```
Di clients/Gilgalad, Amandil, Elendil, Isildur, dll. (Semua node non-Durin):
```
nano /etc/resolv.conf
nameserver 192.227.5.2     # IP Minastir
```
Untuk verification:
Di Gilgalad:
```
dig google.com
```
Output yang diharapkan:
;; SERVER: 192.227.5.2#53(192.227.5.2)
;; ANSWER SECTION:
google.com. 30 IN A 142.250.64.78

![Assets/modul3.png](assets/no3.1.png)

![Assets/modul3.png](assets/no3.2.png)

## Soal 4
Ratu Erendis menetapkan <k32.com> sebagai nama domain resmi Arda, menunjuk dirinya (Erendis/ns1) dan Amdir (Amdir/ns2) sebagai penjaga peta (DNS Master-Slave). Amdir harus selalu menyalin peta dari Erendis, dan semua lokasi penting didaftarkan ke dalam peta.

---
### 1. Konfigurasi DNS Master: Di Erendis (ns1.k32.com)
```
apt update -y
apt install -y bind9
```
```
nano /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    # Dengarkan hanya IPv4 Erendis
    listen-on { 192.227.3.2; };
    listen-on-v6 { none; };

    allow-query { any; };
    recursion yes;
    dnssec-validation auto;
    auth-nxdomain no;
};
```
```
nano /etc/bind/named.conf.local
zone "k32.com" {
    type master;
    file "/etc/bind/db.k32.com";
    allow-transfer { 192.227.3.3; };   # Amdir (slave)
    notify yes;
};
```
Buat file record zone
```
nano /etc/bind/db.k32.com
$TTL 604800
@   IN  SOA ns1.k32.com. root.k32.com. (
        2025103001 ; Serial
        600        ; Refresh
        80         ; Retry
        2419200    ; Expire
        600 )      ; Negative Cache TTL

; Name Servers
@   IN  NS  ns1.k32.com.
@   IN  NS  ns2.k32.com.

; Address Records
ns1         IN  A 192.227.3.2    ; Erendis (master)
ns2         IN  A 192.227.3.3    ; Amdir (slave)

; Lokasi Penting
Palantir    IN  A  192.227.4.3
Elros       IN  A  192.227.1.7
Pharazon    IN  A  192.227.2.4
Elendil     IN  A  192.227.1.2
Isildur     IN  A  192.227.1.3
Anarion     IN  A  192.227.1.4
Galadriel   IN  A  192.227.2.5
Celeborn    IN  A  192.227.2.6
Oropher     IN  A  192.227.2.7
```
Setelah itu, restart
```
named-checkconf
named-checkzone k32.com /etc/bind/db.k32.com
/usr/sbin/named -u bind
rndc reload
```
### 2. Konfigurasi DNS Slave: Amdir (ns2.k32.com)
```
apt update -y
apt install -y bind9
```
a) Konfigurasi Global
```
nano /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };
    listen-on { 192.227.3.3; };
    listen-on-v6 { none; };
    allow-query { any; };
    recursion yes;
    dnssec-validation auto;
    auth-nxdomain no;
};
```
b) Konfigurasi zone (slave)
```
nano /etc/bind/named.conf.local
zone "k32.com" {
    type slave;
    file "/var/cache/bind/db.k32.com";
    masters { 192.227.3.2; };   # IP Erendis (master)
};
```
Restart
```
named-checkconf
/usr/sbin/named -u bind
rndc reload
service bind9 restart 
```
Kalau tidak bisa --> pkill named ; /usr/sbin/named -u bind -c /etc/bind/named.conf --> check: ps aux | grep named
Untuk Verifikasi:
Di gilgalad:
```
dig Palantir.k32.com @192.227.3.2  # Uji Master
dig Palantir.k32.com @192.227.3.3  # Uji Slave

ping 192.227.3.2 -c 3 
ping 192.227.3.3 -c 3
```
![Assets/modul3.png](assets/no4.1.png)

![Assets/modul3.png](assets/no4.2.png)

## Soal 5
Untuk memudahkan navigasi, alias www.k32.com dibuat. Reverse PTR dikonfigurasi agar lokasi Erendis dan Amdir dapat dilacak dari IP mereka, dan Erendis menambahkan Pesan Rahasia (TXT record) tentang "Cincin Sauron" dan "Aliansi Terakhir" yang harus disalin oleh Amdir.

---
### 1. Konfigurasi DNS Master: Di Erendis
```
nano /etc/bind/db.k32.com
```
```
add this record:
; Alias (CNAME)
www     IN  CNAME   k32.com.

; Reverse PTR Records
; Untuk Erendis dan Amdir, kita buat zone terbalik di bawah ini
; (akan ditambahkan di file berbeda di langkah selanjutnya)

; TXT Records (Pesan Rahasia)
Elros       IN  TXT   "Cincin Sauron"
Pharazon    IN  TXT   "Aliansi Terakhir"

and change the serial number:
        2025103002 ; Serial
```
```
nano /etc/bind/db.192.227
```
```
$TTL 604800
@   IN  SOA ns1.k32.com. root.k32.com. (
        2025103001 ; Serial
        600         ; Refresh
        80          ; Retry
        2419200     ; Expire
        600 )       ; Negative Cache TTL

; Name Servers
@       IN  NS  ns1.k32.com.
@       IN  NS  ns2.k32.com.

; PTR Records (Reverse Mapping)
2.3.227.192.in-addr.arpa.   IN  PTR ns1.k32.com.   ; Erendis
3.3.227.192.in-addr.arpa.   IN  PTR ns2.k32.com.   ; Amdir
# 2       IN  PTR ns1.k32.com.   ; Erendis (192.227.3.2)
# 3       IN  PTR ns2.k32.com.   ; Amdir (192.227.3.3)
```
```
nano /etc/bind/named.conf.local
```
```
add this zone at the end:
zone "3.227.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.227";
    allow-transfer { 192.227.3.3; };
};
```
Check:
```
named-checkconf
named-checkzone k32.com /etc/bind/db.k32.com
named-checkzone 3.227.192.in-addr.arpa /etc/bind/db.192.227
pkill named
/usr/sbin/named -u bind -c /etc/bind/named.conf
```
Di Amdir:
```
nano /etc/bind/named.conf.local
```
add this zone at the end:
```
zone "3.227.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.227";
    masters { 192.227.3.2; };
};
```
```
pkill named
/usr/sbin/named -u bind -c /etc/bind/named.conf
```
Untuk verifikasi:
Di gilgalad:
``` dig www.k32.com @192.227.3.2 ```
it should be: ``` www.k32.com. 604800 IN CNAME k32.com.```
![Assets/modul3.png](assets/no5.1.png)
```
dig Elros.k32.com TXT @192.227.3.2
dig Pharazon.k32.com TXT @192.227.3.2
```
it should be: 
```
Elros.k32.com. 604800 IN TXT "Cincin Sauron"
Pharazon.k32.com. 604800 IN TXT "Aliansi Terakhir"
```
![Assets/modul3.png](assets/no5.2.png)

![Assets/modul3.png](assets/no5.3.png)
```
dig -x 192.227.3.2 @192.227.3.2
dig -x 192.227.3.3 @192.227.3.2
```
it should be: 
```
2.3.227.192.in-addr.arpa.  IN  PTR ns1.k32.com.
 3.3.227.192.in-addr.arpa.  IN  PTR ns2.k32.com.
```
![Assets/modul3.png](assets/no5.4.png)
## Soal 6
Aldarion memperbarui lease time DHCP untuk semua klien dinamis, menetapkan batas maksimal peminjaman satu jam (3600 detik), dan memberikan durasi spesifik: 30 menit (1800 detik) untuk Manusia dan 10 menit (600 detik) untuk Peri.

---
### 1. Konfigurasi DHCP Server: Aldarion (Penyesuaian Lease Time)
```
nano /etc/dhcp/dhcpd.conf
```
```
# -----------------------------------------
# DHCP Configuration - Aldarion (DHCP Server)
# -----------------------------------------
ddns-update-style none;
authoritative;
log-facility local7;

#default-lease-time 600;    <-- hapus baris ini
# Batas maksimum peminjaman untuk semua keluarga (1 jam)
max-lease-time 3600;       <-- ganti dari 7200


# ========================
#  SUBNET 1 - MANUSIA
# ========================
subnet 192.227.1.0 netmask 255.255.255.0 {
    range 192.227.1.6 192.227.1.34;
    range 192.227.1.68 192.227.1.94;
    option routers 192.227.1.1;
    option broadcast-address 192.227.1.255;
    option domain-name-servers 192.227.3.2, 192.227.3.3, 192.168.122.1;

    # Manusia: 30 menit (1800 detik)
    default-lease-time 1800;    <-- tambah baris ini
}

# ========================
#  SUBNET 2 - PERI
# ========================
subnet 192.227.2.0 netmask 255.255.255.0 {
    range 192.227.2.35 192.227.2.67;
    range 192.227.2.96 192.227.2.121;
    option routers 192.227.2.1;
    option broadcast-address 192.227.2.255;
    option domain-name-servers 192.227.3.2, 192.227.3.3, 192.168.122.1;

    # Peri: 10 menit (600 detik)
    default-lease-time 600;    <-- tambah baris ini
}

# ========================
#  SUBNET 3 - KURCACI
# ========================
subnet 192.227.3.0 netmask 255.255.255.0 {
    option routers 192.227.3.1;
    option broadcast-address 192.227.3.255;
}

# ========================
#  SUBNET 4 - DATABASE
# ========================
subnet 192.227.4.0 netmask 255.255.255.0 {
    option routers 192.227.4.1;
    option broadcast-address 192.227.4.255;
}

# ========================
#  SUBNET 5 - PROXY
# ========================
subnet 192.227.5.0 netmask 255.255.255.0 {
    option routers 192.227.5.1;
    option broadcast-address 192.227.5.255;
}

# ========================
#  FIXED ADDRESS - KHAMUL
# ========================
host Khamul {
    hardware ethernet 02:42:d6:54:3a:00;
    fixed-address 192.227.3.95;
}
```
Restart
```
service isc-dhcp-server restart
```
Untuk Verifikasi:
```
tail -f /var/log/syslog | grep DHCPACK
```
It should show different lease times for Manusia and Peri clients:
```
DHCPACK on 192.227.1.20 to 02:42:xx:xx:xx:xx via eth0 (lease 1800 seconds)
DHCPACK on 192.227.2.40 to 02:42:yy:yy:yy:yy via eth0 (lease 600 seconds)
```
Verification client side:
in Manusia client (e.g., Amandil):
```
dhclient -v
cat /var/lib/dhcp/dhclient.leases | grep lease
```
it should show lease time of 1800 seconds
![Assets/modul3.png](assets/no6.1.png)
in Peri client (e.g., Gilgalad):
```
dhclient -v
cat /var/lib/dhcp/dhclient.leases | grep lease
```
it should show lease time of 600 seconds
![Assets/modul3.png](assets/no6.2.png)
## Soal 7
Ksatria Númenor (Elendil, Isildur, dan Anarion) membangun benteng digital mereka. Mereka harus menginstal semua tools yang dibutuhkan (PHP 8.4, Composer, Nginx) dan mendapatkan cetak biru benteng (Laravel) dari repository yang ditentukan, lalu memverifikasinya melalui client.

---
### Lakukan langkah-langkah ini di Elendil, Isildur, dan Anarion:
```
apt update -y
```
### 1. Install Nginx, PHP-FPM, dan tools untuk Laravel
```
apt install -y nginx php8.4 php8.4-fpm php8.4-cli php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip unzip composer git
```
![Assets/modul3.png](assets/no7.1.png)

### 2. Clone Project Laravel
```
cd /var/www
rm -rf laravel   # Hapus folder jika ada
git clone https://github.com/elshiraphine/laravel-simple-rest-api laravel
cd laravel
```
### 3. Install Dependency
Ini akan mengunduh semua library yang dibutuhkan Laravel
```
composer install
composer update
```
### 4. Setup Lingkungan
Buat file .env dari contoh dan generate encryption key
```
cp .env.example .env
php artisan key:generate
```
### 5. Atur Kepemilikan (penting agar Nginx dan PHP-FPM bisa menulis ke log/cache)
```
chown -R www-data:www-data /var/www/laravel
chmod -R 775 /var/www/laravel/storage
```
```
service php8.4-fpm restart
service nginx restart
```
Verifikasi dari node lain (Gilgalad dan Amandil):
```
apt update && apt install lynx -y
ping -c 4 elendil.k32.com
curl -I http://elendil.k32.com:8001/api/products
lynx http://elendil.k32.com:8001/api/products
```
![Assets/modul3.png](assets/no7.2.png)
## Soal 8
Palantir dikonfigurasi sebagai Database Server (MariaDB) yang dapat diakses dari luar. Semua Laravel Worker dikonfigurasi untuk terhubung ke Palantir. Nginx diatur dengan Virtual Host unik per worker (8001, 8002, 8003) dan hanya mengizinkan akses melalui Domain Nama (menolak akses via IP). Migrasi dan seeding awal dijalankan di Elendil.

### 1. Konfigurasi Database Server: Palantir
```
in Palantir (Database server 192.227.4.3):
apt update -y
apt install -y mariadb-server
service mariadb start

# Setup User dan Database
mysql -u root
CREATE DATABASE laravel_db;
CREATE USER 'laravel'@'%' IDENTIFIED BY 'laravel123';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';
FLUSH PRIVILEGES;
EXIT;

# Izinkan Akses dari Luar (Bind Address)
nano /etc/mysql/mariadb.conf.d/50-server.cnf
# Ganti:
- bind-address = 127.0.0.1
+ bind-address = 0.0.0.0

service mariadb restart
```
### 2. Konfigurasi Worker Laravel (Elendil, Isildur, Anarion)
#### Ganti nilai 'listen' dan 'server_name' sesuai tabel di bawah:
#### Elendil: 8001 & elendil.k32.com
#### Isildur: 8002 & isildur.k32.com
#### Anarion: 8003 & anarion.k32.com
```
nano /etc/nginx/sites-available/laravel
server {
    listen 8001;    # 8002, 8003 untuk node lain
    server_name elendil.k32.com;   # sesuaikan

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # IZINKAN domain Elendil + Elros (reverse proxy) + IP internal (optional)
    # if ($host !~ ^(Elendil|Elros|localhost)\.k32\.com$) {
    #     return 403;
    # }
}
```
```
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
nginx -t
service nginx restart
service php8.4-fpm restart
```
### 3. Seeding (HANYA di Elendil)
```
# 1. Edit koneksi database di .env (setelah Soal 7 selesai)
# (Gunakan kredensial yang kamu set di Palantir)
nano /var/www/laravel/.env
DB_CONNECTION=mysql
DB_HOST=192.227.4.3        # IP Palantir (Database)
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel
DB_PASSWORD=laravel123

# 2. Jalankan Migrasi dan Seeding
cd /var/www/laravel
php artisan migrate --seed
```
### 4. Verifikasi
```
in Palantir:
mysql -u laravel -p
USE laravel_db;
SHOW TABLES;
SELECT * FROM users;
it should show users created by seeder

from other nodes (e.g., Gilgalad/Amandil):
curl -I http://elendil.k32.com:8001
it should return HTTP/1.1 200 OK
curl -I http://192.227.1.2:8001
it should return HTTP/1.1 403 Forbidden

lynx http://elendil.k32.com:8001
```
![Assets/modul3.png](assets/no8.1.png)

![Assets/modul3.png](assets/no8.2.png)
```
IF IN VERIFICATION IT SHOWS DATABASE CONNECTION ERROR/ OR IN MIGRATION IT FAILS:
cd /var/www/laravel
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
service php8.4-fpm restart
service nginx reload
```
![Assets/modul3.png](assets/no8.4.png)
## Soal 9
Setiap Laravel Worker (Elendil, Isildur, Anarion) diuji untuk memastikan fungsi mandiri mereka: dapat menampilkan halaman utama Laravel dan berhasil terhubung serta mengambil data dari Palantir melalui endpoint API khusus.

---
### 1. Modifikasi Rute API untuk Pengujian Koneksi Database
#### Lakukan di Elendil, Isildur, dan Anarion
#### A. Tambahkan Import DB di API Routes
#### Anda harus menambahkan 'use Illuminate\Support\Facades\DB;' di routes/api.php karena di file asli tidak ada.
```
nano /var/www/laravel/routes/api.php
```
#### Tambahkan baris di bawah 'use Illuminate\Support\Facades\Route;'
Sebelum:
```
use Illuminate\Support\Facades\Route;
```
Setelah (tambahkan baris ini):
```
use Illuminate\Support\Facades\DB;  # <-- WAJIB DITAMBAHKAN!
# use App\Http\Controllers\AiringController; # Biarkan baris ini ada
```
#### B. Tambahkan Endpoint Pengujian Koneksi DB
##### Tambahkan rute pengujian di akhir file /routes/api.php, di LUAR Route::group(['prefix' => 'airing']).
##### Rute ini akan menjadi /api/testdb
```
nano /var/www/laravel/routes/api.php
```
##### Tambahkan kode ini di BARIS PALING BAWAH file api.php:
```
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
```
##### C. Hapus/Abaikan Perubahan di bootstrap/app.php
##### DIKARENAKAN struktur file Anda adalah Laravel baru, Anda TIDAK PERLU menambahkan 'api: __DIR__.'/../routes/api.php',' secara manual. Anda CUKUP MEMASTIKAN Laravel menggunakan 'web.php' dan 'api.php' di file app/Providers/RouteServiceProvider.php
##### ABAIKAN langkah edit bootstrap/app.php yang ada di catatan Anda.
#### D. Clear dan Cache Rute
```
cd /var/www/laravel
php artisan route:clear
php artisan route:cache
php artisan route:list   # (Opsional) Verifikasi rute /api/testdb sudah terdaftar

service php8.4-fpm restart
service nginx restart
```
##### Lakukan verifikasi di node client
```
apt update && apt install -y lynx curl

echo "--- Verifikasi Halaman Utama Laravel (lynx) ---"
lynx http://Elendil.k32.com:8001
lynx http://Isildur.k32.com:8002
lynx http://Anarion.k32.com:8003
```
#### Pastikan Anda melihat halaman selamat datang Laravel.
```
echo "--- Verifikasi API /api/airing yang ASLI (curl) ---"
```
#### Karena Anda tidak membuat AiringController, ini mungkin akan error 500, tapi setidaknya Nginx/PHP berjalan.
``` curl http://Elendil.k32.com:8001/api/airing ```
#### Catatan: Rute /api/airing yang asli mengarah ke AiringController, yang mungkin belum Anda buat. Ini hanya untuk memastikan rute yang ada terbaca.
``` echo "--- Verifikasi Koneksi DB ke Palantir (/api/testdb) ---" ```
#### Ini adalah pengganti rute /api/airing yang Anda buat.
```
curl http://Elendil.k32.com:8001/api/testdb
curl http://Isildur.k32.com:8002/api/testdb
curl http://Anarion.k32.com:8003/api/testdb
```
#### Output WAJIB menampilkan "status": "connected" dan daftar database Palantir.
![Assets/modul3.png](assets/no9.png)
## Soal 10
Pemimpin bijak Elros dikonfigurasi sebagai Reverse Proxy menggunakan Nginx. Ia mengarahkan semua permintaan yang masuk ke elros.<xxxx>.com ke upstream kesatria_numenor (Elendil, Isildur, dan Anarion) secara merata menggunakan algoritma Round Robin (default).

---
### 1. Di Elros
```
apt update -y
apt install -y nginx
```
```
nano /etc/nginx/sites-available/reverse-proxy
```
```
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
```
Restart
```
ln -s /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
nginx -t
service nginx restart
```
Cek di Gilgalad/Amandil:
```
dig elros.k32.com @192.227.3.2
ping elros.k32.com
```
![Assets/modul3.png](assets/no10.png)
## Soal 11
Musuh menguji pertahanan Númenor dengan benchmark (ab) ke elros.<xxxx>.com/api/airing. Tujuan langkah ini adalah memantau kondisi worker selama serangan dan menerapkan strategi pertahanan dengan menambahkan weight pada algoritma Load Balancing di Elros, lalu membandingkan hasilnya.

---
### 1. Persiapan dan Serangan Awal (Benchmarking)
Di Gilgalad/Amandil:
```
service nginx status
service php8.4-fpm status
```
#### jika belum aktif:
```
service nginx restart
service php8.4-fpm restart
```
Untuk testing:
``` curl -I http://elros.k32.com/api/airing ```
```
apt update -y
apt install -y apache2-utils
```
low load test via ab (Apache Benchmark) from each node:
```ab -n 100 -c 10 http://elros.k32.com/api/airing/ ```
![Assets/modul3.png](assets/no11.01.png)
stress test:
```ab -n 2000 -c 100 http://elros.k32.com/api/airing/ ```
![Assets/modul3.png](assets/no11.02.png)
see worker node load (Elendil, Isildur, Anarion):
```htop / top```

```tail -f /var/log/nginx/access.log```

checkm elros logs:
```
tail -f /var/log/nginx/elros-access.log
tail -f /var/log/nginx/elros-error.log
```

it should show:
```
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.2:8001"
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.3:8002"
"GET /api/airing HTTP/1.1" 200 - -> upstream: "http://192.227.1.4:8003"
```
if not, load balancing is not working properly.

SO, the strategy:

- adding weights in reverse proxy (Elros):

in elros:
```nano /etc/nginx/sites-available/reverse-proxy```
edit upstream block:
```
upstream kesatria_numenor {
    server 192.227.1.2:8001 weight=3    ;   # Elendil — lebih kuat
    server 192.227.1.3:8002 weight=1;   # Isildur
    server 192.227.1.4:8003 weight=2;   # Anarion
}
```
```
nginx -t
service nginx reload
```
now, retest via ab in client/laravel node (Gilgalad, Amandil) :
```ab -n 2000 -c 100 http://elros.k32.com/api/airing/```
![Assets/modul3.png](assets/no11.03.png)
Bandingkan hasilnya dengan sebelum diubah:
look in elros:
```
tail -f /var/log/nginx/access.log
tail -n 20 /var/log/nginx/elros-access.log
```
- Apakah Requests per second meningkat?
- Apakah Failed requests menurun?
- Apakah beban lebih seimbang (lihat log Elros & worker)?
## Soal 12
Para Penguasa Peri (Galadriel, Celeborn, dan Oropher) membangun Web Worker PHP. Nginx diinstal dan dikonfigurasi pada setiap node untuk menyajikan halaman index.php sederhana. Akses diatur secara ketat agar hanya dapat dilakukan melalui Domain Nama mereka, menolak akses langsung menggunakan IP.

---
### Di Galadriel, Celeborn, Oropher
#### 1. Update list paket
```apt update```
#### 2. Instal Nginx dan PHP-FPM
#### Catatan: Jika instalasi php8.4-fpm gagal, coba versi yang lebih rendah yang tersedia (misal: php8.2-fpm).
```apt install -y nginx php8.4-fpm```
#### Buat file index.php
```echo '<?php echo "Welcome to Taman Digital "; echo gethostname(); ?>' > /var/www/html/index.php```
#### Berikan hak akses yang benar untuk Nginx
```chown -R www-data:www-data /var/www/html```
#### Hapus symlink default yang aktif
```rm /etc/nginx/sites-enabled/default```
#### Edit file konfigurasi baru
```nano /etc/nginx/sites-available/php-worker```
### Di Galadriel
#### Blok utama untuk melayani domain
```
server {
    listen 80;
    server_name galadriel.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}
```
![Assets/modul3.png](assets/no12.1.png)
### For Celeborn
```
server {
    listen 80;
    server_name celeborn.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}
```
![Assets/modul3.png](assets/no12.2.png)
### For Oropher
```
server {
    listen 80;
    server_name oropher.k32.com; 

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Penanganan PHP menggunakan FPM
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock; 
    }
}

# Blok 'catch-all' untuk menolak akses selain melalui domain.
# Ini penting untuk memastikan "akses web hanya bisa melalui domain nama, tidak bisa melalui ip."
server {
    listen 80 default_server;
    server_name _; # Menangkap semua permintaan yang tidak cocok dengan blok di atas
    return 444;    # Menutup koneksi tanpa mengirim respons (lebih stealthy)
}
```
```
ln -s /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/
nginx -t
service php8.4-fpm restart
service nginx restart
```
![Assets/modul3.png](assets/no12.3.png)
### Di Gilgalad
```
apt update
apt install -y lynx
```
### Uji Galadriel
```lynx http://galadriel.k32.com```
### Uji Celeborn
```lynx http://celeborn.k32.com```
### Uji Oropher
```lynx http://oropher.k32.com```

It should show "Welcome to Taman Digital <hostname>" for each respective server.

If using ip address to access any of the servers, the connection should be closed without any response.
: curl: (52) Empty reply from server
## Soal 13
Setiap Web Worker PHP (Galadriel, Celeborn, dan Oropher) dikonfigurasi untuk mendengarkan permintaan web pada port unik (8004, 8005, atau 8006) dan meneruskan permintaan file .php ke socket PHP-FPM yang sesuai.

---
### 1. Lakukan di node masing-masing
```
nano /etc/nginx/sites-available/php-worker
```
#### untuk galadriel
```
listen	8004
server_name	galadriel.k32.com
```
#### untuk celeborn
```
listen	8005
server_name	celeborn.k32.com
```
#### untuk oropher
```
listen	8006
server_name	oropher.k32.com
```
In each node (galadriel, celeborn, and oropher):
```
nginx -t
service nginx restart
service php8.4-fpm restart
```
#### Uji Galadriel
```lynx http://galadriel.k32.com:8004```
#### Uji Celeborn
```lynx http://celeborn.k32.com:8005```
#### Uji Oropher
```lynx http://oropher.k32.com:8006```
![Assets/modul3.png](assets/no13.1.png)
## Soal 14
Keamanan ditingkatkan pada setiap PHP Worker (Galadriel, Celeborn, dan Oropher) dengan menerapkan Basic HTTP Authentication Nginx. Hanya pengguna noldor dengan kata sandi silvan yang diizinkan masuk ke gerbang taman digital.

---
### 1. Again, di masing-masing node yak (galadriel, celeborn, and oropher)
```
apt update
apt install -y apache2-utils
```
#### Perintah ini membuat file baru (-c) dan menambahkan pengguna noldor. Anda akan diminta untuk memasukkan kata sandi (silvan) dua kali.
```
htpasswd -c /etc/nginx/.htpasswd noldor
nano /etc/nginx/sites-available/php-worker

#Tambahkan ini, di bawah server_name dan diatas root /var/www/html;
    auth_basic "Akses Terbatas: Gerbang Taman Peri";
    auth_basic_user_file /etc/nginx/.htpasswd;
```
#### Uji konfigurasi Nginx
```
nginx -t
service nginx restart
```
#### Coba yg tanpa credes
```
curl -I http://galadriel.k32.com:8004
curl -I http://celeborn.k32.com:8005
curl -I http:/oropher.k32.com:8006
```
![Assets/modul3.png](assets/no14.1.png)
#### Output: HTTP/1.1 401 Unauthorized
#### With credes
```
curl -u noldor:silvan http://galadriel.k32.com:8004
curl -u noldor:silvan http://celeborn.k32.com:8005
curl -u noldor:silvan http:/oropher.k32.com:8006
```
![Assets/modul3.png](assets/no14.21.png)
![Assets/modul3.png](assets/no14.22.png)
![Assets/modul3.png](assets/no14.23.png)
## Soal 15
Konfigurasi Nginx pada setiap PHP Worker dimodifikasi untuk menambahkan header X-Real-IP dan meneruskan alamat IP pengunjung ($remote_addr) ke PHP-FPM. File index.php diubah untuk menampilkan alamat IP pengunjung yang diterima tersebut.

---
### 1. Lakukan ini di node masing2 juga
```nano /etc/nginx/sites-available/php-worker```
#### tambahkan ini, diantara include snippets dan fastcgi_pass
```fastcgi_param HTTP_X_REAL_IP $remote_addr;```
```
nginx -t
service nginx restart
```
```
nano /var/www/html/index.php
<?php 
$hostname = gethostname();
$visitor_ip = $_SERVER['HTTP_X_REAL_IP'] ?? $_SERVER['REMOTE_ADDR'];

echo "Welcome to taman digital $hostname.<br>";
echo "Anda (Sang Pengunjung) datang dari alamat IP: $visitor_ip"; 
?>
```
#### Tes lagi dari gilgalad
#### Uji Galadriel
```
curl -u noldor:silvan http://galadriel.k32.com:8004
curl -u noldor:silvan http://celeborn.k32.com:8005
curl -u noldor:silvan http:/oropher.k32.com:8006
```
![Assets/modul3.png](assets/no15.1.png)
![Assets/modul3.png](assets/no15.2.png)
![Assets/modul3.png](assets/no15.3.png)
Output:
```
Welcome to Taman Digital Galadriel.
Anda (Sang Pengunjung) datang dari alamat IP: 192.227.2.35
```
## Soal 16
Raja Pharazon dikonfigurasi sebagai Reverse Proxy Nginx untuk mengawasi taman Peri (Galadriel, Celeborn, Oropher). Konfigurasi harus memastikan bahwa header Basic Authentication (Authorization) dan IP Asli pengunjung diteruskan dari Pharazon ke worker di upstream Kesatria_Lorien.

---
### Di Pharazon
```
apt update
apt install -y nginx
```
```
rm /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/pharazon-lb
```
#### 1. DEFINE UPSTREAM (Load Balancer Group)
```
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

        # Meneruskan IP asli klien ke worker (worker akan melihat ini)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # --- PENTING: Meneruskan Basic Auth & IP Asli ---
        # Meneruskan header Basic Authentication (Authorization)
        # proxy_pass_header Authorization;
        proxy_set_header Authorization $http_authorization; 
        # --------------------------------------------------
    }
#
#    access_log /var/log/nginx/pharazon-access.log;
#    error_log /var/log/nginx/pharazon-error.log;
}
```
##### 1. Aktifkan konfigurasi baru
```
ln -s /etc/nginx/sites-available/pharazon-lb /etc/nginx/sites-enabled/
nginx -t
service nginx restart
```
#### Uji dari gilgalad
```curl http://pharazon.k32.com```
![Assets/modul3.png](assets/no16.1.png)

![Assets/modul3.png](assets/no16.2.png)

![Assets/modul3.png](assets/no16.3.png)
#### Output yang diharapkan: Pesan 401 Unauthorized dari Pharazon
```curl -u noldor:silvan http://pharazon.k32.com```
## Soal 17
Lakukan benchmark ke pharazon.<xxxx>.com dengan menyertakan kredensial otentikasi. Amati distribusi beban di log Pharazon. Kemudian, simulasikan kegagalan salah satu worker PHP (Galadriel) untuk menguji fitur Failover Nginx: apakah Pharazon dapat secara otomatis mengalihkan lalu lintas hanya ke worker yang tersisa?

---
### 1. Simulate load balancing with Apache Benchmark (ab)
#### Di Gilgalad
```
apt update
apt install -y apache2-utils
```
#### opsi1: simple ab test without auth header
#### Encode dengan
```
echo -n "noldor:silvan" | base64
ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/
```
#### opsi2: ab test with dynamic auth header
```ab -n 100 -c 10 -H "Authorization: Basic $(echo -n 'noldor:silvan' | base64)" http://pharazon.k32.com/```
#### Di Pharazon
if hasn't got upstream_addr column, do this:
```nano /etc/nginx/nginx.conf
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
```
now do ab test again from gilgalad;
```ab -n 100 -c 10 -H "Authorization: Basic $(echo -n 'noldor:silvan' | base64)" http://pharazon.k32.com/```
in pharazon, check the access log:
```tail -f /var/log/nginx/pharazon-access.log```
it should show upstream_addr column in access log, like this:
```
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.5:8004
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.6:8005
192.227.2.35 - - [31/Oct/2025:21:45:12 +0000] "GET / HTTP/1.0" 200 123 "-" "ApacheBench/2.3" 192.227.2.7:8006
```
#### Simulate nginx down in one of the worker node, e.g. Galadriel
#### Di Galadriel
```
service nginx stop
service nginx status
```
#### Di Gilgalad
```ab -n 100 -c 10 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/```
![Assets/modul3.png](assets/no17.1.png)

#### cara cek error (yg ke galadriel)
```cat /var/log/nginx/error.log | grep "192.227.2.5:8004"```
![Assets/modul3.png](assets/no17.2.png)

it should show something like this:
```connect() failed (111: Connection refused) while connecting to upstream,
client: 192.227.2.35, server: pharazon.k32.com,
request: "GET / HTTP/1.0", upstream: "http://192.227.2.5:8004/",
host: "pharazon.k32.com"
```
![Assets/modul3.png](assets/no17.3.png)

## Soal 18
Kekuatan Palantir dilindungi melalui replikasi Master-Slave. Palantir dikonfigurasi sebagai Master dan Narvi sebagai Slave yang secara otomatis menyalin semua data dari Master untuk database laravel_db.

---
### 1. Konfigurasi Database Master: Palantir
```
apt update -y
apt install -y mariadb-server
service mariadb start

mysql -u root
-- database laravel_db SUDAH ADA, jadi gak usah CREATE lagi
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel'@'%';

-- buat user replikasi baru
CREATE USER 'repluser'@'192.227.4.4' IDENTIFIED BY 'replpass';
GRANT REPLICATION SLAVE ON *.* TO 'repluser'@'192.227.4.4';
FLUSH PRIVILEGES;
EXIT;

nano /etc/mysql/mariadb.conf.d/50-server.cnf
edit:
bind-address = 0.0.0.0
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = laravel_db

service mariadb restart

mysql -u root -p -e "SHOW MASTER STATUS\G"
it will show something like this:
File: mysql-bin.000001
Position: 456
```
### 2. Konfigurasi Database Slave: Narvi
```
apt update -y
apt install -y mariadb-server
service mariadb start

nano /etc/mysql/mariadb.conf.d/50-server.cnf
edit:
bind-address = 0.0.0.0
server-id = 2
relay_log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log

service mariadb restart

mysql -u root
STOP SLAVE;
RESET SLAVE ALL;

CHANGE MASTER TO
MASTER_HOST='192.227.4.3',
MASTER_USER='repluser',
MASTER_PASSWORD='replpass',
MASTER_LOG_FILE='mysql-bin.000001',
MASTER_LOG_POS=456;

START SLAVE;

SHOW SLAVE STATUS\G
it should show:
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Seconds_Behind_Master: 0
```
#### Untuk Verifikasi
in Palantir:
```mysql -u root

USE laravel_db;
CREATE TABLE elf_army (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    rank VARCHAR(30)
);

INSERT INTO elf_army (name, rank)
VALUES ('Legolas', 'Archer'),
       ('Thranduil', 'King');
```
in Narvi:
```
mysql -u root

USE laravel_db;
SHOW TABLES;
SELECT * FROM elf_army;
```
it should show the data inserted from Palantir.
+----+-----------+----------+
| id | name      | rank     |
+----+-----------+----------+
|  1 | Legolas   | Archer   |
|  2 | Thranduil | King     |
+----+-----------+----------+
![Assets/modul3.png](assets/no18.png)

## Soal 19
Untuk menahan intensitas serangan, Rate Limiting diimplementasikan pada Elros dan Pharazon. Batasnya adalah 10 permintaan per detik per alamat IP. Pengujian dilakukan dengan Apache Benchmark (ab) dengan konkurensi tinggi untuk memverifikasi permintaan yang ditolak.

---
### 1. Konfigurasi Rate Limiting di Nginx (Elros dan Pharazon)
```nano /etc/nginx/sites-available/elros-lb  or nano /etc/nginx/sites-available/pharazon-lb```
add at the very top, before server block:
##### Zona shared memory untuk rate limiting (1MB bisa menyimpan sekitar 16.000 IP)
```limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
and in server block, inside location / { ... }, before proxy_pass add:
limit_req zone=one burst=20 nodelay;
```
example (in pharazon):
```upstream Kesatria_Lorien {
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
```
```
nginx -t
service nginx reload
```
in gilgalad/Amandil/clients:
```
apt install -y apache2-utils

ab -n 500 -c 50 -H 'Authorization: Basic bm9sZG9yOnNpbHZhbg==' http://pharazon.k32.com/
```
in pharazon and elros:
check log in pharazon and elros:
```tail -f /var/log/nginx/error.log```
it should show something like this when rate limit exceeded:
```2025/10/31 22:10:23 [error] 2451#2451: *142 limiting requests, excess: 10.600 by zone "one", client: 192.227.2.35, server: pharazon.k32.com, request: "GET / HTTP/1.0"```
or in access.log:
```2025/10/31 22:10:23 [error] 2451#2451: *142 limiting requests, excess: 10.600 by zone "one", client: 192.227.2.35, server: pharazon.k32.com, request: "GET / HTTP/1.0"```
![Assets/modul3.png](assets/no19.png)

## Soal 20
Mengaktifkan Reverse Proxy Caching pada Pharazon. Cache akan menyimpan respons dari PHP Worker (Kesatria_Lorien) selama 10 menit sehingga permintaan berulang tidak membebani worker.

---
### 1. In pharazon:
```
mkdir -p /var/cache/nginx/proxy_cache
chown -R www-data:www-data /var/cache/nginx/proxy_cache
nano /etc/nginx/sites-available/pharazon-lb
```
add caching conf before server { , after upstream XXXX {}:
#### Zona cache: 100 MB size, valid 10 menit
```proxy_cache_path /var/cache/nginx/proxy_cache levels=1:2 keys_zone=my_cache:100m max_size=500m inactive=10m use_temp_path=off;```

and edit server block (server {...}):
```
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
```

Untuk verifikasi:
in Gilgalad/Amandil/Clients:
```curl -I http://pharazon.k32.com/ / curl -u noldor:silvan http://pharazon.k32.com/ / curl -I -u noldor:silvan http://pharazon.k32.com/```
1st output:
```HTTP/1.1 200 OK
Server: nginx
Date: Fri, 31 Oct 2025 22:45:13 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
X-Cache-Status: MISS   <-- should be MISS
```
again,
```curl -I http://pharazon.k32.com/ / curl -u noldor:silvan http://pharazon.k32.com/ / curl -I -u noldor:silvan http://pharazon.k32.com/```
2nd output should be:
```HTTP/1.1 200 OK
Server: nginx
Date: Fri, 31 Oct 2025 22:45:13 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
X-Cache-Status: HIT   <-- should be HIT
```
in Pharazon:
```ls -lh /var/cache/nginx/proxy_cache```
there's should be result of the worker response (whether it's MISS:1st; HIT:2nd,est; EXPIRED:invalid; BYPASS:bypass)

in Galadriel:
```tail -f /var/log/nginx/access.log```
#### Pada request pertama, worker akan menerima permintaan (kode 200). Setelah itu, tidak akan ada permintaan baru dari Pharazon selama cache masih valid (10 menit).
![Assets/modul3.png](assets/no20.png)
