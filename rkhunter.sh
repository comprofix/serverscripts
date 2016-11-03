#!/bin/bash
# Script Name: rkhunter
# Author: Matt McKinnon
# Date: 7th June 2016
# Description:
#   This script will email a logwatch report
MAILTO="support@comprofix.com"
SMTP=mail.comprofix.com
THISSERVER=$(hostname -f)
MAILFROM="support@comprofix.com"
SENDEMAIL=$(which sendemail)

(
rkhunter --versioncheck --nocolors
rkhunter --update --nocolors
rkhunter --cronjob --rwo
) | $SENDEMAIL -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILTO>" -u "[rkhunter] Log $THISSERVER" -q
