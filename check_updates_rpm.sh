#!/bin/bash
# Script Name: check_updates_rpm.sh
# Author Name: Keith Bawden
# Modified by: Matthew McKinnon
# Date: Wed May 17 15:40:32 JST 2006
# Updated: Mon Nov 22, 2015
# Description: For use on rpm based distros ie CentOS, Red Hat, Fedora
# This script will:
#   Clean up the local rpm repository of retrieved packages (yum clean)
#   Resync the package index (yum makecache)
#   If called with AUTOUPDATE set to yes then SECURITY updates will be downloaded and applied. (The package yum-plugin-security is required Install using
#   yum install yum-plugin-security)
#
# Make user configuration changes in this section
#

MAILTO="matthew@ambient-it.com.au"
AUTOUPDATE="no"
LOGFILE="/var/log/server_maint.log"
THISSERVER=`hostname --fqdn`

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
echo "Hello,

Whilst running the update script ($0) on $THISSERVER there was a problem.

[ERROR] "$1" failed to run

The server has the following network interfaces configured ${SERVERADDS[@]}.

Please log in via ssh (e.g. ssh root@${IPADDR[0]}) and check the log file:

vim $LOGFILE

Regards." | /bin/mail -s "[$THISSERVER] There was an error whilst running $0" $MAILTO
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

yum clean all > /dev/null
check_return "yum clean all"

yum makecache > /dev/null
check_return "yum makecache"

if [[ "$AUTOUPDATE" == "yes" ]]
then
  yum -y update --security > /dev/null
  check_return "yum -y update --security"
else
  PACKAGES_TO_BE_UPGRADED=`yum list updates -q`
  check_return "yum list updates -q"
fi

if [[ -z $PACKAGES_TO_BE_UPGRADED ]]
then
  echo "`date` [MESSAGE] No packages need updating." >> $LOGFILE
else

echo "
Hello,

Packages requiring updates onto $THISSERVER.

$PACKAGES_TO_BE_UPGRADED

The server has the following network interfaces configured ${SERVERADDS[@]}.

To update the server log in via ssh (e.g. ssh root@${IPADDR[0]}) and run the following command:

yum upgrade

See the logfile for more info: vim $LOGFILE

Regards. " | /bin/mail -s "[$THISSERVER] server may need some updates applied" $MAILTO

  echo "`date` [MESSAGE] Packages need updating email sent to $MAILTO" >> $LOGFILE
fi

stoplogging
exit 0
