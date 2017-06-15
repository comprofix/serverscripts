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
MAILTO="support@comprofix.com"
MAILFROM="support@comprofix.com"
THISSERVER=$(hostname -f)
SMTP="mail.comprofix.com"

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

sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILFROM>" -u "$SUBJECT" -m "$(cat /tmp/dbbackup.msg)" -q

#Use Below to use systems postfix or local MTA
#cat /tmp/dbbackup.msg | mail -s "$SUBJECT" "$MAIL"
rm -fr /tmp/dbbackup.msg
