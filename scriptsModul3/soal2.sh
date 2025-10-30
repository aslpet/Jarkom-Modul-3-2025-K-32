in Aldarion:
apt update -y
apt install -y isc-dhcp-server

nano /etc/default/isc-dhcp-server
INTERFACESv4="eth0"

nano /etc/dhcp/dhcpd.conf
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

service isc-dhcp-server restart

in Durin:
apt update -y
apt install -y isc-dhcp-relay

nano /etc/default/isc-dhcp-relay
SERVERS="192.227.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""

service isc-dhcp-relay restart

config dynamic client:
in Gilgalad and Amandil:
apt update --allow-releaseinfo-change -y
apt install -y isc-dhcp-client

nano /etc/network/interfaces
auto eth0
iface eth0 inet dhcp <-- change from static to dhcp

service networking restart <-- if cannot use, just skip this line
dhclient -v eth0

verification:
in clients/Gilgalad and Amandil nodes:
ip a | grep inet
cat /var/lib/dhcp/dhclient.leases

in Aldarion (router/server):
tail -f /var/log/syslog | grep DHCPACK
should be:  DHCPACK on 192.227.x.x to 02:00:00:00:xx:xx via eth0