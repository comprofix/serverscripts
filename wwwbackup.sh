#!/bin/bash

DATE=$(date +%Y%m%d%H%M)
BACKUPDIR='/BACKUP/www'
WWW='/var/www/'

cd $WWW

for folder in `ls -d *`; do 
	tar -zcvf $BACKUPDIR/$folder-$DATE.tar.gz $folder
done

