#!/bin/bash
# Script Name: sentora_www-backup.sh
# Author Name: Matt McKinnon
# Date: 7th June 2016
# Description:
# This script will:
#   Backup your public_html folder under /var/sentora/hostdata/DOMAIN_NAME/public_html

BACKUPDIR='/BACKUP/www/'
BAKDATE=$(date +%Y%m%d)
HOSTDATA="/var/sentora/hostdata"
MAILTO="support@comprofix.com"
SUBJECT="$(hostname -f) sentora sites backup"

rotate_backups() {
        find $BACKUPDIR -type f -mtime +7 -exec rm -frv {} \;

    }

rotate_backups

WEBPATH=$(find $HOSTDATA/* -maxdepth 0 -type d  | awk -F/ '{print $5}')

for SITES in $WEBPATH; do
    tar -zcf $BACKUPDIR/$SITES-$BAKDATE.tar.gz -P $HOSTDATA/$SITES >> /tmp/sentora_backup.msg
    echo "$SITES-$BAKDATE.tar.gz - $SITES backup successfull" >> /tmp/sentora_backup.msg
done

cat /tmp/sentora_backup.msg | mail -r "$MAILTO" -s "$SUBJECT" "$MAILTO"
rm -fr /tmp/sentora_backup.msg

