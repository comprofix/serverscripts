#!/bin/bash

bakdate=$(date +%Y%m%d%H%M)
echo "--------------------------------"
echo "Running SVN backup $bakdate"
echo "--------------------------------\n"
 
svnrepos="/var/lib/svn"
echo "\nGoing to backup all SVN repos located at: $svnrepos \n"
 
bakdest="/BACKUP/svn/"

cd $svnrepos
 
if [ -d "$bakdest" ] && [ -w "$bakdest" ] ; then
  for repo in *; do
    echo "Taking backup/svndump for: $repo"
    echo "Executing : svnadmin dump $repo > $bakdest/$repo-$bakdate.svn.dump \n"
    svnadmin dump $repo > $bakdest/$repo-$bakdate.svn.dump
  done
else
  echo "Unable to continue SVN backup process."
  echo "$bakdest is *NOT* a directory or you do not have write permission."
fi
echo "\n\n================================="
echo " - Backup Complete, THANK YOU :-]"
