#!/bin/bash
# Script Name: dbbackup
# Author: Matt McKinnon
# Date: 7th June 2016
# Description:
#   This script will backup your mysql databases.
#   Send an email report of databases that have been backed up.
#   Rotate backups for 7 days
#
#   NOTE:
#   A user will need to be grated permissions on the databases
#   Login to mysql with your root user.
#
#   CREATE USER 'dbbackup'@'localhost' IDENTIFIED BY 'PASSWORD';
#   GRANT LOCK TABLES, SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'dbbackup'@'localhost';


MAIL="support@comprofix.com"
O365_SMTP=$(grep SMTP office365.conf | awk -F'=' '{print $2}')
O365_USER=$(grep USER office365.conf | awk -F'=' '{print $2}')
O365_PASS=$(grep PASS office365.conf | awk -F'=' '{print $2}')

SUBJECT="$(hostname -f) Database Backup Completed $BAKDATE"
BAKDATE=$(date +%Y%m%d)
DBUSER='dbbackup'
DBPASS='EWFfP3GZsqr427Yj'
BACKUPDIR='/BACKUP/db/'

rotate_backups() {
    find $BACKUPDIR -type f -mtime +7 -exec rm -frv {} \;

}

rotate_backups

databases=$(mysql --user=$DBUSER --password=$DBPASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db" >> /tmp/dbbackup.msg
        mysqldump --force --opt --user=$DBUSER --password=$DBPASS --databases $db > $BACKUPDIR/$db.$BAKDATE.sql
    fi

done

sendemail -o tls=auto -s "$O365_SMTP" -xu "$O365_USER" -xp "$O365_PASS" -t "$MAIL" -f "$MAIL" -u "$SUBJECT" -m "$(cat /tmp/dbbackup.msg)"

#Use Below to use systems postfix or local MTA
#cat /tmp/dbbackup.msg | mail -s "$SUBJECT" "$MAIL"
rm -fr /tmp/dbbackup.msg
