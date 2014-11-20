#!/bin/bash
#apps  backup  downloads  fun  games  movies  mp3s  tvshows  wow

FROMADDRESS=mmckinnon@comprofix.com
TOADDRESS=mmckinnon@comprofix.com
SMTP=mail.comprofix.com

BODSUBJECT="Backup Log `date +%d-%m-%Y`" 


LOG=/home/moe/scripts/logs/backuplog-`date +%d-%m-%Y`.log
echo "****************************************************************" > $LOG 2>&1
echo "*     Start Backup `date`         *" >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1

rsync -rltDyzPOu --progress --delete /data/ /mnt/nas/ >> $LOG 2>&1
 
echo "****************************************************************" >> $LOG 2>&1
echo "*     Finished Backup `date`      *" >> $LOG 2>&1
echo "****************************************************************" >> $LOG 2>&1 

sendemail -f "NAS BACKUP <$FROMADDRESS>" -t $TOADDRESS -u "$BODSUBJECT" -m "$BODSUBJECT" -a $LOG -s $SMTP >> $LOG 2>&1
