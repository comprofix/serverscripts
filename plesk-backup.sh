#!/bin/bash
# Script Name:plesk-backup
# Author: Matt McKinnon
# Date: 04 May 2018
# Description:
#   This script will backup your plesk hosting files.
#   Send an email report of plesk hosting files that have been backed up.
#   Rotate backups for 7 days
#

MAIL="support@comprofix.com"
MAILTO="support@comprofix.com"
MAILFROM="support@comprofix.com"
THISSERVER=$(hostname -f)
SMTP="mail.comprofix.com"
SUBJECT="$(hostname -f) Hosting Files Backup Completed $BAKDATE"
BAKDATE=$(date +%Y%m%d)
BACKUPDIR='/BACKUP'
VHOSTS='/var/www/vhosts/'
LOGFOLDER=/var/log/
LOGFILE=$LOGFOLDER/backuplog-`date +%d-%m-%Y.log`


rotate_backups() {
    find $BACKUPDIR -type f -mtime +7 -exec rm -frv {} \;

}

startlogging() {
    echo $DASHES2 >> $LOGFILE
    echo "$0 started running at $(date)" >> $LOGFILE
    echo $DASHES >> $LOGFILE
}

stoplogging() {
    echo $DASHES >> $LOGFILE
    echo "$0 finished running at $(date)" >> $LOGFILE >> $LOGFILE
    echo $DASHES2 >> $LOGFILE
}

DASHES="---------------------------------------------------------------------------------"
DASHES2="================================================================================="

startlogging
rotate_backups


#Backup www_root website files

WWW_ROOT=$(MYSQL_PWD=$(cat /etc/psa/.psa.shadow) mysql -sN -uadmin -e 'select www_root from psa.hosting; ')

for domain in $WWW_ROOT; do
   ARCHIVE=$(echo $domain | awk -F/ '{print $6}';)
   echo "$(date) [MESSAGE] Creating archive of $domain" >> $LOGFILE
   zip -rq $BACKUPDIR/$ARCHIVE.$BAKDATE.zip $domain
done

#Backup databases

databases=$(MYSQL_PWD=$(cat /etc/psa/.psa.shadow) mysql -sN -uadmin -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

#echo $databases;


for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "apsc" ]] && [[ "$db" != "horde" ]] && [[ "$db" != phpmyadmin_* ]] && [[ "$db" != "psa" ]] && [[ "$db" != "roundcubemail" ]] ; then
        echo "$(date) [MESSAGE] Dumping $db to sql file" >> $LOGFILE
        mysqldump --force --opt --user=$DBUSER --password=$DBPASS --databases $db > $BACKUPDIR/$db.$BAKDATE.sql
    fi
done

#Backup files to offsite location

echo "$(date) [MESSAGE] Copying backup files to offsite location" >> $LOGFILE
scp -rq -P 2222 $BACKUPDIR/* moe@home.comprofix.com:/data/backup/website

echo "$(date) [MESSAGE] Sending email of backup report" >> $LOGFILE

stoplogging

#sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILFROM>" -u "$SUBJECT" -m "$(cat /tmp/dbbackup.msg)" -q

#Use below if using POSTFIX 
cat $LOGFILE | mail -s "$SUBJECT" "$MAIL"



