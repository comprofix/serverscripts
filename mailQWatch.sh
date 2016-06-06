#!/bin/bash
# Checks mailQ size

QUEUELIMIT=0
HOST=$(/bin/hostname)
QUEUELENGTH=$(/usr/sbin/postqueue -p | tail -n1 | awk '{print $5}')
QUEUECOUNT=$(echo $queuelength | grep "[0-9]")
SUBJECT="Mail Queue on $HOST is currently $QUEUECOUNT"
MAILTO="mmckinnon@comprofix.com"

if [ "$QUEUECOUNT" == "" ]; then
  exit;
elif [ "$QUEUECOUNT" -gt "$QUEUELIMIT" ]; then
#echo $msg | /bin/mail -s "Mail Queue Alert $queuecount ($hostname)" "helpdesk@ambient-it.com.au"
  /usr/sbin/postqueue -p | /bin/mail -s "$SUBJECT" "$MAILTO"
fi
