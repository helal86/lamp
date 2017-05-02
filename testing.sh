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

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo "<?php

// Show all information, defaults to INFO_ALL
phpinfo();

?>" >> /var/www/html/index.php


echo "all done"
exit




