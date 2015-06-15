#!/bin/bash
bakdate=$(date +%Y%m%d%H%M)

DBUSER='dbbackup'
DBPASS='EWFfP3GZsqr427Yj'
BACKUPDIR='/BACKUP/db/'

rotate_backups() {
    find $BACKUPDIR -type f -mtime +7 -exec rm -frv {} \;

}

rotate_backups

databases=`mysql --user=$DBUSER --password=$DBPASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
 
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --force --opt --user=$DBUSER --password=$DBPASS --databases $db > $BACKUPDIR/$db.`date +%Y%m%d`.sql
    fi

done


