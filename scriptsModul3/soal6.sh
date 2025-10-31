in Aldarion:
nano /etc/dhcp/dhcpd.conf
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

service isc-dhcp-server restart

verification: tail -f /var/log/syslog | grep DHCPACK
it should show different lease times for Manusia and Peri clients:
DHCPACK on 192.227.1.20 to 02:42:xx:xx:xx:xx via eth0 (lease 1800 seconds)
DHCPACK on 192.227.2.40 to 02:42:yy:yy:yy:yy via eth0 (lease 600 seconds)

verification client side:
in Manusia client (e.g., Amandil):
dhclient -v
cat /var/lib/dhcp/dhclient.leases | grep lease

it should show lease time of 1800 seconds

in Peri client (e.g., Gilgalad):
dhclient -v
cat /var/lib/dhcp/dhclient.leases | grep lease

it should show lease time of 600 seconds