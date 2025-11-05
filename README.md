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
dig Palantir.k32.com @192.227.3.2  # Uji Master
dig Palantir.k32.com @192.227.3.3  # Uji Slave

ping 192.227.3.2 -c 3 
ping 192.227.3.3 -c 3
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

```
```

```
## Soal 6


---
### 1. 
## Soal 7


---
### 1. 
## Soal 8


---
### 1. 
## Soal 9


---
### 1. 
## Soal 10


---
### 1. 
## Soal 11


---
### 1. 
## Soal 12


---
### 1. 
## Soal 13


---
### 1. 
## Soal 14


---
### 1. 
## Soal 15


---
### 1. 
## Soal 16


---
### 1. 
## Soal 17


---
### 1. 
## Soal 18


---
### 1. 
## Soal 19


---
### 1. 
## Soal 20


---
### 1. 
