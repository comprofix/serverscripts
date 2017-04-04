#!/bin/bash
# Script Name: diskalert
# Author: Matt McKinnon
# Date: 7th June 2016
# Description:
#   This script will email when diskspace is high.

MAIL="support@comprofix.com"
O365_SMTP=$(grep SMTP office365.conf | awk -F'=' '{print $2}')
O365_USER=$(grep USER office365.conf | awk -F'=' '{print $2}')
O365_PASS=$(grep PASS office365.conf | awk -F'=' '{print $2}')

LOGFILE="/var/log/diskalert.log"
THISSERVER=$(hostname -f)


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

declare -a DEVICES
index=0

startlogging

for i in $( df -h | grep "/dev/" | grep -v tmpfs | awk '{print $1}' );
do
	DEVICES[$index]=$i
	let "index += 1"
done

for i in ${DEVICES[@]};
do
	let space=`df -Pk $i | grep -v ^File | awk '{printf ("%i", $5) }'`
	if [ $space -le 89 ]
then
	echo "$(date) [MESSAGE] Disk space usage on $i acceptable. $space% currently in use." >> $LOGFILE
fi
if [ $space -ge 90 ]
then

echo "$(date) [WARNING] $i is running out of disk space. $space% currently in use." >> $LOGFILE
echo "
Hello,

You are running out of disk space on $THISSERVER.

Your $i is currently using $space% of disk space.

See the logfile for more info: vim $LOGFILE

Regards, " >/tmp/diskalertmail.msg

sendemail -o tls=auto -s "$O365_SMTP" -xu "$O365_USER" -xp "$O365_PASS" -t "$MAIL" -f "$MAIL" -u "[$THISSERVER] is running out of disk space" -m "$(cat /tmp/diskalertmail.msg)" -q
echo "$(date) [MESSAGE] Running out of disk space email sent to $MAILTO" >> $LOGFILE

fi
done


stoplogging
