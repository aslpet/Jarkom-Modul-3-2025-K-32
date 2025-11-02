in Palantir:
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

in Narvi:
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

#Verification:
in Palantir:
mysql -u root

USE laravel_db;
CREATE TABLE elf_army (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    rank VARCHAR(30)
);

INSERT INTO elf_army (name, rank)
VALUES ('Legolas', 'Archer'),
       ('Thranduil', 'King');

in Narvi:
mysql -u root

USE laravel_db;
SHOW TABLES;
SELECT * FROM elf_army;
it should show the data inserted from Palantir.
+----+-----------+----------+
| id | name      | rank     |
+----+-----------+----------+
|  1 | Legolas   | Archer   |
|  2 | Thranduil | King     |
+----+-----------+----------+
