#!/bin/bash

# Variables
DBHOST=localhost
#DBNAME="dbname"
#DBUSER="dbuser"
#DBPASSWD="test123"
#SITE="name"
#ROOTDBPASSWD="root"

echo "Database name"
read DBNAME
echo "Database user"
read DBUSER
echo "Database password"
read DBPASSWD
echo "site FQDN"
read SITE
echo "MySQL Root password"
read ROOTDBPASSWD

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

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
debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOTDBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOTDBPASSWD"
apt-get -y install mysql-server php-mysql
echo "done"

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" 
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
echo "done"

echo -e "\n--- Install Apache ---\n"
apt-get -y install apache2
echo "done"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php libapache2-mod-php php-curl php-gd php-mysql memcached php7.0-mcrypt
phpenmod mcrypt

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

echo -e "\n--- adding vhost files and enabling sites ---\n"

echo "<VirtualHost *:80>

        ServerAdmin info@$SITE
        ServerName      $SITE
        ServerAlias     www.$SITE

        DocumentRoot /var/www/$SITE/public_html/
        <Directory "/var/www/$SITE/public_html/">
                Options +FollowSymLinks -Indexes
                AllowOverride All
        </Directory>
        ErrorLog /var/www/$SITE/logs/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/www/$SITE/logs/access.log combined

</VirtualHost>" > /etc/apache2/sites-available/$SITE.conf


cd /etc/apache2/sites-available/
a2ensite $SITE
a2enmod ssl

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo "all done :)"
exit




