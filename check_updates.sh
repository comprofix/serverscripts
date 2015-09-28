#!/bin/bash
# Script Name: maint.sh
# Author Name: Keith Bawden
# Date: Wed May 17 15:40:32 JST 2006
# Description: This script will:
#   Clean up the local apt repository of retrieved packages (apt-get clean)
#   Resync the package index (apt-get update)
#   If called with AUTOUPDATE set to yes then updates will be downloaded and applied with no feed back (not recommended)
#   If called without AUTOUPDATE then packages are downloaded and an email is sent informing which packages are to be updated.
#   And more ;-)
# NOTE: Perl is needed for this script to work.

#
# Make user configuration changes in this section
#

MAILTO="mmckinnon@comprofix.com"
SMTP=mail.comprofix.com
AUTOUPDATE="no"
LOGFILE="/var/log/server_maint.log"
THISSERVER=`hostname --fqdn`
MAILFROM="mmckinnon@comprofix.com"

#
# End of user configuration section
#

DASHES="---------------------------------------------------------------------------------"
DASHES2="================================================================================="


# Check if the script is being run as root exit if it is not.

if [ $(id -u) -ne 0 ] 
then 
echo "ur not root bro"
 exit 1 
fi

startlogging() {
  echo $DASHES2 >> $LOGFILE
  echo "$0 started running at `date`" >> $LOGFILE
  echo $DASHES2 >> $LOGFILE
}

stoplogging() {
  echo "`date` [MESSAGE] $0 finished runnning" >> $LOGFILE
  echo $DASHES >> $LOGFILE
}

check_return() {
  if [ "$?" -ne "0" ]
    then
      echo "`date` [ERROR]   $1 failed to run" >> $LOGFILE
      send_error_email $1
      stoplogging
      exit 1
  fi
  echo "`date` [SUCCESS] $1 ran without error" >> $LOGFILE
}

send_error_email() {
sendemail -f "$THISSERVER <$MAILTO>" -t $MAILTO -u "[$THISSERVER] There was an error whilst running $0" -s $SMTP

"Hello,

Whilst running the update script ($0) on $THISSERVER there was a problem.

[ERROR] "$1" failed to run

The server has the following network interfaces configured ${SERVERADDS[@]}.

Please log in via ssh (e.g. ssh root@${IPADDR[0]}) and check the log file:

vim $LOGFILE

Regards."
}

# IP Address stuff
declare -a IPADDR
declare -a NICINTERFACE
declare -a SERVERADDS
index=0

for i in $( ifconfig | grep 'inet addr' | awk '{print $2}'| sed 's#addr:##g' );
do
  IPADDR[$index]=$i
  let "index += 1"
done

index=0

for i in $( ifconfig | grep 'eth' | awk '{print $1}' );
do
  SERVERADDS[$index]="$i ${IPADDR[$index]}"
  let "index += 1"
done

# End IP Address stuff
 

startlogging

apt-get clean > /dev/null
check_return "apt-get clean"

apt-get update > /dev/null
check_return "apt-get update"

if [[ "$AUTOUPDATE" == "yes" ]]
then
  apt-get -yqq upgrade > /dev/null
  check_return "apt-get -yq upgrade"
else
  PACKAGES_TO_BE_UPGRADED=`apt-get -Vs upgrade | perl -ne 'print if /upgraded:/ .. /upgraded,/'`
  apt-get -yqd upgrade > /dev/null
  check_return "apt-get -yqd upgrade"
fi

if [[ -z $PACKAGES_TO_BE_UPGRADED ]]
then
  echo "`date` [MESSAGE] No packages need updating." >> $LOGFILE
else

echo "
Hello,

Packages have been downloaded onto $THISSERVER.

$PACKAGES_TO_BE_UPGRADED

The server has the following network interfaces configured ${SERVERADDS[@]}.

To update the server log in via ssh (e.g. ssh root@${IPADDR[0]}) and run the following command:

apt-get upgrade

See the logfile for more info: vim $LOGFILE

Regards. " >/tmp/servermail.msg

cat /tmp/servermail.msg | sendemail -o tls=no -s $SMTP -t $MAILTO -f "$THISSERVER <$MAILTO>" -u "[$THISSERVER] server may need some updates applied"

  echo "`date` [MESSAGE] Packages need updating email sent to $MAILTO" >> $LOGFILE
fi

stoplogging
exit 0
