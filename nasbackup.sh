#!/bin/bash


MAILTO="support@comprofix.com"
MAILFROM="support@comprofix.com"
THISSERVER=$(hostname -f)
SMTP="mail.comprofix.com"


SUBJECT="Backup Log `date +%d-%m-%Y`"
LOGFOLDER=/var/log/nasbackup
LOGFILE=$LOGFOLDER/backuplog-`date +%d-%m-%Y.log`
THISSERVER=`hostname --fqdn`
N_DAYS=7

startlogging() {
  echo $DASHES2 >> $LOGFILE
  echo "$0 started running at $(date)" >> $LOGFILE
  echo $DASHES2 >> $LOGFILE
}

stoplogging() {
  echo "$(date) [MESSAGE] $0 finished runnning" >> $LOGFILE
  echo $DASHES >> $LOGFILE
}

DASHES="---------------------------------------------------------------------------------"
DASHES2="================================================================================="

startlogging

mkdir -p $LOGFOLDER

rsync -urtlOv --partial --delete --exclude 'kvm' /data/ /media/nas/ >> $LOGFILE

FILES=$(find $LOGFOLDER -type f -mtime +$N_DAYS -name '*.log' | wc -l)

if [ $FILES -eq 0 ];
then
  echo "$(date) [MESSAGE] No Old Log Files Found" >> $LOGFILE
else
  echo "$(date) [MESSAGE] Older than $N_DAYS days will be deleted" >> $LOGFILE
  find $LOGFOLDER/* -mtime +$N_DAYS -exec rm {} \;
fi

echo "$(date) [MESSAGE] Backup completed $LOGFILE has been emailed." >> $LOGFILE

stoplogging


sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILFROM>" -u "$SUBJECT" -a "$LOGFILE" -m "$SUBJECT"
