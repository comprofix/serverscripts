#!/bin/bash

bakdate=$(date +%Y%m%d)

bakdest="/BACKUP/svn/"
svnrepos="/var/lib/svn"
tracrepos="/var/lib/trac"

rotate_backups() {
        find $backdest -type f -mtime +7 -exec rm -frv {} \;
}


rotate_backups


cd $svnrepos


if [ -d "$bakdest" ] && [ -w "$bakdest" ] ; then
  for repo in *; do
    mkdir /tmp/$repo
    svnadmin dump $repo > /tmp/$repo/$repo-$bakdate.svn.dump
    trac-admin $tracrepos/$repo hotcopy /tmp/$repo/$repo-trac-$bakdate
    cd /tmp/
    tar -zcf $bakdest/$repo-$bakdate.tar.gz $repo/*
    rm -fr /tmp/$repo
    cd $svnrepos
  done
fi

