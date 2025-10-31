in erendis:
nano /etc/bind/db.k32.com

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

nano /etc/bind/db.192.227
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

nano /etc/bind/named.conf.local
add this zone at the end:
zone "3.227.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.227";
    allow-transfer { 192.227.3.3; };
};

named-checkconf
named-checkzone k32.com /etc/bind/db.k32.com
named-checkzone 3.227.192.in-addr.arpa /etc/bind/db.192.227
pkill named
/usr/sbin/named -u bind -c /etc/bind/named.conf

in amdir:
nano /etc/bind/named.conf.local
add this zone at the end:
zone "3.227.192.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.192.227";
    masters { 192.227.3.2; };
};

pkill named
/usr/sbin/named -u bind -c /etc/bind/named.conf


verification:
in gilgalad:
dig www.k32.com @192.227.3.2
it should be: www.k32.com. 604800 IN CNAME k32.com.

dig Elros.k32.com TXT @192.227.3.2
dig Pharazon.k32.com TXT @192.227.3.2
it should be: Elros.k32.com. 604800 IN TXT "Cincin Sauron"
              Pharazon.k32.com. 604800 IN TXT "Aliansi Terakhir"

dig -x 192.227.3.2 @192.227.3.2
dig -x 192.227.3.3 @192.227.3.2
it should be: 2.3.227.192.in-addr.arpa.  IN  PTR ns1.k32.com.
              3.3.227.192.in-addr.arpa.  IN  PTR ns2.k32.com.
