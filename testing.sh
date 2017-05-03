#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123
SITE=name

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages ---\n"
apt-get -y install curl git unzip htop
echo "done"

echo -e "\n--- Install Apache ---\n"
apt-get -y install apache2
echo "done"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php5 libapache2-mod-php5 php5-curl php5-gd php5-mysql memcached php5-memcached php5-mcrypt

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo "<?php

// Show all information, defaults to INFO_ALL
phpinfo();

?>" >> /var/www/html/index.php

mv /var/www/html/index.html /var/www/html/index1.html


echo "all done"
exit




