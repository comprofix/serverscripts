#!/bin/bash
source /etc/profile

devnames=`df -h | grep "/dev/" | awk '{print $1}'`
for devname in $devnames
    do
        let p=`df -Pk $devname | grep -v ^File | awk '{printf ("%i", $5) }'`
        if [ $p -ge 1 ] 
        then
            df -h $devname > /dev/null
            echo "Running out of space \"$devname ($p%)\" on $(hostname) as on $(date)" 
        fi
    done

