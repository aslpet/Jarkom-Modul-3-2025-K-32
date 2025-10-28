CONFIG ALL NODES

'DURIN' as main router/gateway
edit config:
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

in CLI:
nano /root/.bashrc

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
apt update -y
apt install -y iptables iptables-persistent

echo "nameserver 192.168.122.1" > /etc/resolv.conf

'other nodes' as clients/nonrouter:
edit config:
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

in every client/nonrouter node:
in CLI:
nano /root/.bashrc
echo "nameserver 192.168.122.1" > /etc/resolv.conf