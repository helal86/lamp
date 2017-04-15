#!/bin/bash

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123
SITE=name

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update
apt-get -y upgrade

echo -e "\n--- Install base packages ---\n"
apt-get -y install curl build-essential python-software-properties git unzip htop
echo "done"


echo -e "\n--- Configuring IP address ---\n"
IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
        sed -i "s/^${IPADDR}.*//" /etc/hosts
        echo ${IPADDR} ubuntu.localhost >> /etc/hosts  

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update
echo "done"

# MySQL setup for development purposes ONLY
echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server php5-mysql
echo "done"

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" 
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
echo "done"

echo -e "\n--- Install Apache ---\n"
apt-get -y install apache2
echo "done"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php5 libapache2-mod-php5 php5-curl php5-gd php5-mysql memcached php5-memcached php5-mcrypt 

cd /etc/php5/cli/conf.d
ln -s ../../mods-available/mcrypt.ini 20-mcrypt.ini
php5enmod mcrypt 

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite 

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Setting document root to public directory ---\n"
mkdir /var/www/$SITE
mkdir /var/www/$SITE/public_html
mkdir /var/www/$SITE/backups
mkdir /var/www/$SITE/logs

cd /var/www/
mv html/ html_old/
ln -s /var/www/$SITE/public_html/ html
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
#sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
#sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- adding vhost files and enabling sites ---\n"
# /etc/apache2/sites-available/
#a2ensite $SITE

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php 
mv composer.phar /usr/local/bin/composer

echo -e "\n--- Installing javascript components ---\n"
npm install -g gulp bower

echo "all done :)"
exit




