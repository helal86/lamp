#!/bin/bash

echo "Site FQDN"
read FQDN

EMAIL=helal@helalkhan.co.uk

sudo add-apt-repository -y ppa:certbot/certbot

sudo apt-get update && sudo apt-get -y install python-certbot-apache

sudo certbot --apache -n -d $FQDN -d www.$FQDN -m $EMAIL --agree-tos 

sudo certbot renew --dry-run

cd /var/www/$FQDN/public_html
sudo sed -i '7iRewriteCond %{SERVER_PORT} 80\nRewriteRule ^(.*)$ https://'$SITE'/$1 [R,L]/' .htaccess

exit