#!/bin/bash

echo "Site FQDN"
read FQDN

echo "Site FQDN inc www"
read WWWFQDN

sudo add-apt-repository -y ppa:certbot/certbot

sudo apt-get update && sudo apt-get -y install python-certbot-apache

sudo certbot --apache -d $FQDN -d $WWWFQDN

sudo certbot renew --dry-run

exit