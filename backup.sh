#!/bin/sh

THESITE="example.com"
THEDB="dbname"
THEDBUSER="dbuser"
THEDBPW="adbpassword"
THEDATE=`date +%d%m%y%H%M`

#export LC_ALL="en_US.UTF-8"

mysqldump -u $THEDBUSER -p${THEDBPW} $THEDB | gzip > /var/www/$THESITE/backups/dbbackup_${THEDB}_${THEDATE}.bak.gz

tar czf /var/www/$THESITE/backups/sitebackup_${THESITE}_${THEDATE}.tar -C / var/www/$THESITE/public_html/
gzip /var/www/$THESITE/backups/sitebackup_${THESITE}_${THEDATE}.tar

find /var/www/$THESITE/backups/site* -mtime +7 -exec rm {} \;
find /var/www/$THESITE/backups/db* -mtime +7 -exec rm {} \;
find ~/grive/website_backup/site* -mtime +3 -exec rm {} \;
find ~/grive/website_backup/db* -mtime +3 -exec rm {} \;

cp /var/www/$THESITE/backups/* ~/grive/website_backup/
cd ~/grive
grive

exit

