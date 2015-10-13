#!/bin/bash
#apps  backup  downloads  fun  games  movies  mp3s  tvshows  wow

mkdir -p /var/log/nasbackup

FROMADDRESS=support@comprofix.com
TOADDRESS=mmckinnon@comprofix.com
SMTP=mail.comprofix.com
BODSUBJECT="Backup Log `date +%d-%m-%Y`" 
LOGFOLDER=/var/log/nasbackup
N_DAYS=7



LOG=$LOGFOLDER/backuplog-`date +%d-%m-%Y`.log
echo "****************************************************************" > $LOG 2>&1
echo "*     Start Backup `date`         *" >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1

#rsync -urtlPO --delete /data/ /mnt/nas/ >> $LOG 2>&1
rsync -urtlO --delete /data/ /mnt/nas/ >> $LOG 2>&1

echo "****************************************************************" >> $LOG 2>&1
echo "*     Finished Backup `date`      *" >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1 

sendemail -o tls=no -f "NAS BACKUP <$FROMADDRESS>" -t $TOADDRESS -u "$BODSUBJECT" -m "$BODSUBJECT" -a $LOG -s $SMTP >> $LOG 2>&1

find $LOGFOLDER/* -mtime +$N_DAYS -exec rm {} \;

