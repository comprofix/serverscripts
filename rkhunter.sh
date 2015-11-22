#!/bin/sh
MAILTO="support@comprofix.com"
SMTP=mail.comprofix.com
THISSERVER=`hostname -f`
MAILFROM="support@comprofix.com"
(
/usr/bin/rkhunter --versioncheck --nocolors 
/usr/bin/rkhunter --update --nocolors
/usr/bin/rkhunter --cronjob --report-warnings-only --nocolors
) | /usr/bin/sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILTO>" -u "[rkhunter] Daily Log $THISSERVER" -q

