#!/bin/bash
#
# Shorewall blacklist file
# blacklist file
#
BLACKLIST="/etc/shorewall/blacklist"
CUSTOM="/etc/shorewall/custom-blacklist"

#
# get URL
# 

URL[0]="http://feeds.dshield.org/block.txt"
URL[1]="http://www.spamhaus.org/drop/drop.lasso"

#Counrtry BlockLists
COUNTRY=(cn tw tr mx il id ua za)
IPDENY="http://www.ipdeny.com/ipblocks/data/countries"

# 
# Don't Edit After this line
#

# Temporary dump staging folder
  TMP=$(mktemp -d -t tmp.XXXXXXXXXX)
  #
  # @method to delete Temporary folder
  #
  function finish {
    rm -rf "$TMP"
}
trap finish EXIT

echo "Downloading new blacklists...."

#Blank out existing blacklists
cat /dev/null > "$TMP/blacklist"
cat /dev/null > $BLACKLIST

#Add custom entries
if [[ -s $CUSTOM ]]; then
    cat $CUSTOM >> "$TMP/blacklist"
fi

## top 20 attacking class C (/24)
wget -q -O - ${URL[0]} | sed '1,/Start/d' | sed '/#/d' | awk '{print $1,$3}' | sed 's/ /\//' >> "$TMP/blacklist"

##  Spamhaus DROP List
wget -q -O - ${URL[1]} | sed '1,/Expires/d' | awk '{print $1}'  >> "$TMP/blacklist"

## Country Blocklists
for BLOCK in ${COUNTRY[*]}; do
    wget -q -O - $IPDENY/$BLOCK.zone  | awk '{print $1}' >> "$TMP/blacklist"
done

#Remove duplicate entries
sort "$TMP/blacklist" | uniq -c | awk '{print $2}' > $BLACKLIST

shorewall refresh
