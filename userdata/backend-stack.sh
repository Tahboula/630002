#!/bin/bash
sudo su
DATABASE_PASS='admin123'
yum update -y
yum install epel-release -y
yum install mariadb-server -y
yum install wget git unzip -y

#mysql_secure_installation
sed -i 's/^127.0.0.1/0.0.0.0/' /etc/my.cnf

# starting & enabling mariadb-server
systemctl start mariadb
systemctl enable mariadb

#restore the dump file for the application
cd /tmp/
wget https://raw.githubusercontent.com/devopshydclub/vprofile-repo/vp-rem/src/main/resources/db_backup.sql
mysqladmin -u root password "$DATABASE_PASS"
mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
mysql -u root -p"$DATABASE_PASS" accounts < /tmp/db_backup.sql
mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
systemctl restart mariadb
# SETUP MEMCACHED
sudo yum install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
memcached -p 11211 -U 11111 -u memcached -d
sleep 30
sudo yum install socat -y
sudo yum install wget -y
#sudo yum install rabbitmq-server -y
#sudo wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
#sudo rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
#sudo yum update -y
#sudo rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm
##
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
sudo systemctl status rabbitmq-server
sudo echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo systemctl restart rabbitmq-server

