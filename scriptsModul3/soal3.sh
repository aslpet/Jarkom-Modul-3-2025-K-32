#Di Minastir
apt update -y
apt install -y bind9

nano /etc/bind/named.conf.options
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

/usr/sbin/named -u bind
netstat -tuln | grep :53    # harus ada listener UDP/TCP port 53

#Di clients/Gilgalad, Amandil, dll
# Set variabel proxy di sesi saat ini
nano /etc/resolv.conf
nameserver 192.227.5.2     # IP Minastir

verification:
in Gilgalad:
dig google.com

it should be:
;; SERVER: 192.227.5.2#53(192.227.5.2)
;; ANSWER SECTION:
google.com. 30 IN A 142.250.64.78