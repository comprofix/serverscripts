#!/bin/bash
#
# squidGuard blacklists - download & install script to
# download blacklists from Shalla Secure Services @
# http://squidguard.shalla.de/Downloads/shallalist.tar.gz
#
# created by Steve Olive - oz.ollie[at]gmail.com
# ver 0.8 20071204 15:05 GMT+10
# Creative Commons Attribution-Share Alike 3.0 License
# http://creativecommons.org/licenses/by-sa/3.0/
#
#
# _________        ____  ____________         _______ ___________________
# ______  /__________  |/ /___  ____/________ ___    |__  ____/___  ____/
# _  __  / __  ___/__    / ______ \  ___  __ \__  /| |_  /     __  __/   
# / /_/ /  _  /    _    |   ____/ /  __  /_/ /_  ___ |/ /___   _  /___   
# \__,_/   /_/     /_/|_|  /_____/   _  .___/ /_/  |_|\____/   /_____/   
#                                    /_/           drxspace@gmail.com
#

ROOTLS=/tmp
cd ${ROOTLS} || { echo "Can't find root's squidGuard directory."; exit 1; }

SQUID=$(which squid3)
SQUIDGRD=$(which squidGuard)

[[ -f ${CONFFILE:="/etc/squidguard/squidGuard.conf"} ]] || { echo "Can't find squidGuard conf file."; exit 1; }
DATADIR=$(grep ^dbhome ${CONFFILE} | cut -d' ' -f2)

# download latest file - overwrite any existing file
echo 'Downloading new blacklists...'
wget -nv 'http://www.shallalist.de/Downloads/shallalist.tar.gz' -a /var/log/blacklists.log

# extract blacklists
tar -zxf shallalist.tar.gz
echo 'New lists downloaded and decompressed.'

# remove old database folders
test -d ${DATADIR} || mkdir -p ${DATADIR}
echo 'Removing old lists...'
rm -Rf ${DATADIR}/*

# copy downloaded blacklists to db home
echo 'Copying new lists...'
cp -R ${ROOTLS}/BL/* ${DATADIR}

# create my whitelist/blacklist directories and copy files
#mkdir -p ${DATADIR}/white ${DATADIR}/black
#cp -R ${ROOTLS}/white/* ${DATADIR}/white
#cp -R ${ROOTLS}/black/* ${DATADIR}/black

echo 'Changing ownership...'
chown -R proxy:proxy ${DATADIR}/../
find ${DATADIR} -type d | xargs chmod -R 2750

# This script performs a database rebuild for any blacklists listed in the default Squidguard config file `/etc/squid/squidGuard.conf'.
#/usr/sbin/update-squidguard -c

# build domains + urls db, then change ownership to squid user
echo 'Building database. Please wait...'
su - proxy -c "$SQUIDGRD -b -C all"
echo 'Database builds complete.'

$SQUID -k reconfigure
echo 'Squid Proxy Server reconfigured'
echo 'Cleaning space...'
rm -Rf ${ROOTLS}/BL
rm -f ${ROOTLS}/shallalist.tar.gz

echo "$(date +"%c") Blacklists updated ok." >> /var/log/blacklists.log

exit 0
