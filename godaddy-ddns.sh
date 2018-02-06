#!/bin/bash

# This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
# Special thanks to mfox for his ps script
# https://github.com/markafox/GoDaddy_Powershell_DDNS
#
# First go to GoDaddy developer site to create a developer account and get your key and secret
#
# https://developer.godaddy.com/getstarted
# Be aware that there are 2 types of key and secret - one for the test server and one for the production server
# Get a key and secret for the production server
#
#
#Create a godaddy_keys file with the lines
#
# KEY <godaddy dev API KEY>
# SECRET <godaddy dev SECRET>
#
#
#Update the first 4 variables with your information


MAILTO="support@comprofix.com"
MAILFROM="support@comprofix.com"
SMTP="mail.comprofix.com"
 
domain="comprofix.com"   # your domain
name="home"     # name of A record to update
key=$(cat godaddy_keys | grep KEY | awk '{ print $2 }') # key for godaddy developer API
secret=$(cat godaddy_keys | grep SECRET | awk '{ print $2 }')   # secret for godaddy developer API

headers="Authorization: sso-key $key:$secret"

# echo $headers

result=$(curl -s -X GET -H "$headers" "https://api.godaddy.com/v1/domains/$domain/records/A/$name")

# echo $result

dnsIp=$(echo $result | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

# DEBUG: Remove hash from below line
# echo "dnsIp:" $dnsIp

# Get public ip address there are several websites that can do this.
ret=$(curl -s GET "http://ipinfo.io/json")
currentIp=$(echo $ret | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

# DEBUG: Remove hash from below line
# echo "currentIp:" $currentIp

 if [ $dnsIp != $currentIp ];
 then
	# echo "Ips are not equal"
	request='{"data":"'$currentIp'","ttl":600}'
	# echo $request
	nresult=$(curl -i -s -X PUT \
 -H "$headers" \
 -H "Content-Type: application/json" \
 -d $request "https://api.godaddy.com/v1/domains/$domain/records/A/$name")
	# echo $nresult
    
    sendemail -o tls=no -s $SMTP -t $MAILTO -f "$name.$domain <$MAILFROM>" -u "$name.$domain IP has been updated" -m " 
    
    $name.$domain IP has been updated

    $name.$domain IP is now: $currentIp


    " -q

fi
