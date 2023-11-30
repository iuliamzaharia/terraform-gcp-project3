#!/bin/bash

# Disable SELinux
sudo getenforce
sudo setenforce 0

# Install Apache
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd

# Install WGET and Unzip
sudo yum install wget unzip -y

# Download and extract website template
wget https://www.free-css.com/assets/files/free-css-templates/download/page296/browny.zip
unzip browny-v1.0.zip
mv browny-v1.0/* /var/www/html/

# Install and configure MariaDB
sudo yum install mariadb mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation
mysql_secure_installation <<EOF
n
y
y
y
y
EOF

# Install PHP 7.3
sudo yum install epel-release yum-utils -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
sudo yum-config-manager --enable remi-php73
sudo yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y
sudo systemctl restart httpd

# Install WordPress
wget https://en-gb.wordpress.org/latest-en_GB.tar.gz
tar -xf latest-en_GB.tar.gz
rm -rf /var/www/html/*
mv wordpress/* /var/www/html/
chown -R apache:apache /var/www/html

# Configure wp-config.php with the database details
sed -i -e "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sed -i -e "s/username_here/wordpress-db3-user/" /var/www/html/wp-config.php
sed -i -e "s/password_here/changeme/" /var/www/html/wp-config.php