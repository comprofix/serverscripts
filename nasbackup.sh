#!/bin/bash
#apps  backup  downloads  fun  games  movies  mp3s  tvshows  wow

mkdir -p /var/log/nasbackup

MAILTO=mmckinnon@comprofix.com
SMTP=mail.comprofix.com

MAILFROM="$(hostname)@$(dnsdomainname)"
BODSUBJECT="Backup Log `date +%d-%m-%Y`" 
LOGFOLDER=/var/log/nasbackup
N_DAYS=7



LOG=$LOGFOLDER/backuplog-`date +%d-%m-%Y`.log
echo "****************************************************************" > $LOG 2>&1
echo "     Start Backup `date`         " >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1

#rsync -urtlPO --delete --exclude 'kvm' /data/ /media/nas/ >> $LOG 2>&1
rsync -urtlOv --partial --delete --exclude 'kvm' /data/ /media/nas/ >> $LOG 2>&1

echo "****************************************************************" >> $LOG 2>&1
echo "     Finished Backup `date`      " >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1 

sendemail -o tls=no -f "NAS BACKUP <$MAILFROM>" -t $MAILTO -u "$BODSUBJECT" -m "$BODSUBJECT" -a $LOG -s $SMTP >> $LOG 2>&1

find $LOGFOLDER/* -mtime +$N_DAYS -exec rm {} \;

