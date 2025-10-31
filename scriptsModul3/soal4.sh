# Di Erendis
apt update -y
apt install -y bind9

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

nano /etc/bind/named.conf.local
zone "k32.com" {
    type master;
    file "/etc/bind/db.k32.com";
    allow-transfer { 192.227.3.3; };   # Amdir (slave)
    notify yes;
};

#buat file record zone
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


#after that restart
named-checkconf
named-checkzone k32.com /etc/bind/db.k32.com
/usr/sbin/named -u bind
rndc reload

#Di Amdir
apt update -y
apt install -y bind9

#konfigurasi global
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

#konfgurasi zone (slave)
nano /etc/bind/named.conf.local
zone "k32.com" {
    type slave;
    file "/var/cache/bind/db.k32.com";
    masters { 192.227.3.2; };   # IP Erendis (master)
};

named-checkconf
/usr/sbin/named -u bind
rndc reload

service bind9 restart 
#kalo gak bisa --> pkill named ; /usr/sbin/named -u bind -c /etc/bind/named.conf --> check: ps aux | grep named

#uji lookup
in gilgalad:
dig Palantir.k32.com @192.227.3.2  # Uji Master
dig Palantir.k32.com @192.227.3.3  # Uji Slave

ping 192.227.3.2 -c 3 
ping 192.227.3.3 -c 3