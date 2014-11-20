#!/bin/bash
source /etc/profile

devnames="/dev/md0 / /dev/sdc1"
for devname in $devnames
    do
        let p=`df -Pk $devname | grep -v ^File | awk '{printf ("%i", $5) }'`
        if [ $p -ge 95 ] 
        then
            df -h $devname > /dev/null
            echo "Running out of space \"$devname ($p%)\" on $(hostname) as on $(date)" 
        fi
    done

