#!/bin/bash
# Add the following lines to /etc/gitlab/gitlab.rb once added
# run gitlab-ctl reconfigure for changes to take effect
#
# gitlab_rails['backup_path'] = '<BACKUP FOLDER>'
# gitlab_rails['backup_keep_time'] = 604800 #7 days of backups to keep

gitlab-rake gitlab:backup:create
