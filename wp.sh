#!/bin/bash

# Variables

echo "Enter Current MySQL Root password"
read ROOTDBPASSWD

echo "Database name"
read DBNAME

echo "Database user"
read DBUSER

echo "Database password"
read DBPASSWD

echo "site FQDN"
read SITE

## Create Database
echo "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$ROOTDBPASSWD -e "CREATE DATABASE $DBNAME" 
mysql -uroot -p$ROOTDBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
echo "done"

echo "\n--- Setting document root to public directory ---\n"
mkdir /var/www/$SITE
mkdir /var/www/$SITE/public_html
mkdir /var/www/$SITE/backups
mkdir /var/www/$SITE/logs


echo "Installing WordPress"
cd /var/www/$SITE/public_html
wget https://en-gb.wordpress.org/wordpress-5.0.2-en_GB.zip
unzip wordpress*
mv wordpress/* .
rm -r wordpress/

cd /var/www/
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www

echo "\n--- adding vhost files and enabling sites ---\n"

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

echo "\n--- Restarting Apache ---\n"
service apache2 restart

echo "all done :)"
exit




