#!/bin/bash
mkdir -p /BACKUP/gitlab
chown -R git:git /BACKUP/gitlab
gitlab-rake gitlab:backup:create
