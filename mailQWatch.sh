#!/bin/bash
# Script Name: mailQWatch
# Author: Matt McKinnon
# Date: 7th June 2016
# Description:
#   This script will email a report mailq on postfix is high.

QUEUELIMIT=75
SUBJECT="Mail Queue on $HOST is currently $QUEUECOUNT"
MAILTO="support@comprofix.com"

HOST=$(/bin/hostname)
POSTQUEUE=$(which postqueue)
QUEUELENGTH=$($POSTQUEUE -p | tail -n1 | awk '{print $5}')
QUEUECOUNT=$(echo $QUEUELENGTH | grep "[0-9]")

if [ "$QUEUECOUNT" == "" ]; then
  exit;
elif [ "$QUEUECOUNT" -gt "$QUEUELIMIT" ]; then
  $POSTQUEUE -p | /bin/mail -s "$SUBJECT" "$MAILTO"
fi
