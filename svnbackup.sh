#!/bin/bash

bakdate=$(date +%Y%m%d%H%M)

bakdest="/BACKUP/svn/"
svnrepos="/var/lib/svn"

rotate_backups() {
        find $backdest -type f -mtime +7 -exec rm -frv {} \;
}


rotate_backups


cd $svnrepos
 
if [ -d "$bakdest" ] && [ -w "$bakdest" ] ; then
  for repo in *; do
    svnadmin dump $repo > $bakdest/$repo-$bakdate.svn.dump
  done
fi
