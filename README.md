Scripts for different tasks
===========================

These scripts perform multiple of different tasks that help monitor the server and send emails after performing functions.
To send emails the sendEmail package is required

<pre><code>apt-get install sendemail</code></pre>

Change the following lines in scripts that send emails

MAILFROM is set to determine the server name and domain name for the server and generate and email for it to determine where the email is coming from. This can be changed to specify an email address or you can leave it to generate one.

<pre><code>
MAILTO=user@example.com
SMTP=mail.example.com
MAILFROM=$(hostaname)@$(dnsdomainname)
</code></pre>

#### 00logwatch

This script sends a report based on the log files and settings.

<b>Installation</b>
<pre><code>
apt-get install logwatch
ln -s $(pwd)/00logwatch /etc/cron.daily
</code></pre>

#### check_updates_deb_sh

This script checks for updates on your Debian based systems. If any updates are found it will download them ready for Installation and an email will be sent to an email address specified

<b>Installation</b>
<pre><code>
ln -s $(pwd)/check_updates_deb_sh /etc/cron.daily
</code></pre>

#### check_updates_rpm.sh

This is the same as above but for use on rpm based distributions (CentOS, Fedora etc)

This script has been tested and used on CentOS.

#### dbbackup.sh

This scripts backs up mysql databases and rotates the number of backups through seven days.

Specify the user and password that has access to the databases.

<pre><code>
DBUSER='dbbackup'
DBPASS='EWFfP3GZsqr427Yj'
BACKUPDIR='/BACKUP/db/'
</code></pre>

#### diskalert.sh

Sends and email when disk space reaches greater than 90%.

<b>Installation</b>
<pre><code>
ln -s ${pwd}/diskalert.sh /etc/cron.hourly
</code></pre>

#### gitlabbackup.sh

If you run your own gitlab server.

Add the following lines to /etc/gitlab/gitlab.rb once added run gitlab-ctl reconfigure for changes to take effect

<pre><code>
gitlab_rails['backup_path'] = 'BACKUP FOLDER'
gitlab_rails['backup_keep_time'] = 604800 #7 days of backups to keep
</code></pre>

Change the BACKUP FOLDER to a location where you want the backups to be saved.

<b>Installation</b>
<pre><code>
ln -s ${PWD}/gitlabbackup.sh /etc/cron.daily
</code></pre>

#### nasbackup.sh

This script does an rsync from one folder location to another

<b>Installation</b>
<pre><code>
ln -s ${PWD}/nasbackup.sh /etc/cron.daily
</code></pre>

#### rkhunter.sh

Script sends an email with the rkhunter scan and report.

<b>Installation</b>
<pre><code>
apt-get install rkhunter
ln -s ${PWD}/rkhunter.sh /etc/cron.daily
</code></pre>
