#!/bin/bash
# Script Name: gitlabbackup
# Author: Matt McKinnon
# Date: 04 May 2018
# Description:
#   This script will backup your gitlab configuration files.
#   Send an email report.
#   Rotate backups for 7 days
#
# Add the following lines to /etc/gitlab/gitlab.rb once added
# run gitlab-ctl reconfigure for changes to take effect
#
# gitlab_rails['backup_path'] = '<BACKUP FOLDER>'
# gitlab_rails['backup_keep_time'] = 604800 #7 days of backups to keep

MAIL="support@comprofix.com"
MAILTO="support@comprofix.com"
MAILFROM="support@comprofix.com"
THISSERVER=$(hostname -f)
SMTP="mail.comprofix.com"
SUBJECT="$(hostname -f) Gitlab Backup Completed $BAKDATE"
BAKDATE=$(date +%Y%m%d)
BACKUPDIR='/BACKUP'
VHOSTS='/var/www/vhosts/'
LOGFOLDER=/var/log/
LOGFILE=$LOGFOLDER/backuplog-`date +%d-%m-%Y.log`


rotate_backups() {
    find $BACKUPDIR -type f -mtime +7 -exec rm -frv {} \; >> $LOGFILE

}

startlogging() {
    echo $DASHES2 >> $LOGFILE
    echo "$0 started running at $(date)" >> $LOGFILE
    echo $DASHES >> $LOGFILE
}

stoplogging() {
    echo $DASHES >> $LOGFILE
    echo "$0 finished running at $(date)" >> $LOGFILE
    echo $DASHES2 >> $LOGFILE
}

DASHES="---------------------------------------------------------------------------------"
DASHES2="================================================================================="

if [ ! -d "$BACKUPDIR" ]; then
  # Control will enter here if $DIRECTORY doesn't exist.
  mkdir $BACKUPDIR
fi

startlogging

# Rotate backup files
echo "$(date) [MESSAGE] Removing old backups" >> $LOGFILE
rotate_backups

echo "$(date) [MESSAGE] Backing up gitlab for $(hostname -f)" >> $LOGFILE
gitlab-rake gitlab:backup:create >> $LOGFILE

#Backup files to offsite location

echo "$(date) [MESSAGE] Copying backup files to offsite location" >> $LOGFILE
scp -rq -P 2222 $BACKUPDIR/* moe@home.comprofix.com:/data/backup/website

echo "$(date) [MESSAGE] Sending email of backup report" >> $LOGFILE

stoplogging

#sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILFROM>" -u "$SUBJECT" -m "$(cat /tmp/dbbackup.msg)" -q

#Use below if using POSTFIX
cat $LOGFILE | mail -s "$SUBJECT" "$MAIL"

