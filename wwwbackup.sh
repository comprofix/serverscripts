#!/bin/bash

DATE=$(date +%Y%m%d%H%M)
BACKUPDIR='/BACKUP/www'
WWW='/var/www/'

rotate_backups() {
        find /BACKUP/www/ -type f -mtime +7 -exec rm -fr {} \;
}


    rotate_backups


cd $WWW

for folder in `ls -d *`; do 
	tar -zcvf $BACKUPDIR/$folder-$DATE.tar.gz $folder
done

