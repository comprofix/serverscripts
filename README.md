Scripts for different tasks
===========================

These scripts perform multiple of different tasks that help monitor the server and send emails after performing functions.
To send emails the sendEmail package is required

<pre>
apt-get install sendemail
</pre>


Change the following lines in scripts that send emails

MAILFROM is set to determine the server name and domain name for the server and generate and email for it to determine where the email is coming from. This can be changed to specify an email address or you can leave it to generate one.

<pre>MAILTO=user@example.com
SMTP=mail.example.com
MAILFROM=$(hostaname)@$(dnsdomainname)
</pre>

#### 00logwatch

This script sends a report based on the log files and settings.

<b>Installation</b>
<pre>apt-get install logwatch
ln -s $(pwd)/00logwatch /etc/cron.daily
</pre>

#### check_updates_deb

This script checks for updates on your Debian based systems. If any updates are found it will download them ready for Installation and an email will be sent to an email address specified

<b>Installation</b>
<pre>ln -s $(pwd)/check_updates_deb /etc/cron.daily
</pre>

#### check_updates_rpm

This script checks for updates on your RPM based systems. If any updates are found it will download them ready for Installation and an email will be sent to an email address specified

<b>Installation</b>
<pre>ln -s $(pwd)/check_updates_rpm /etc/cron.daily
</pre>

#### dbbackup

This scripts backs up mysql databases and rotates the number of backups through seven days.

Specify the user and password that has access to the databases.

<pre>DBUSER='dbbackup'
DBPASS='EWFfP3GZsqr427Yj'
BACKUPDIR='/BACKUP/db/'
</pre>

<b>Installation</b>
<pre>ln -s $(pwd)/dbbackup /etc/cron.daily
</pre>

#### diskalert

Sends and email when disk space reaches greater than 90%.

<b>Installation</b>
<pre>ln -s ${pwd}/diskalert.sh /etc/cron.hourly
</pre>

#### nasbackup.sh

This script does an rsync from one folder location to another

<b>Installation</b>
<pre>
ln -s ${PWD}/nasbackup /etc/cron.daily
</pre>

#### mailQWatch

Script checks mailq size on a postfix system and sends an email when queue size is greater than threshold.

Update variables in scripts to suit your needs.

<pre>QUEUELIMIT=75
SUBJECT="Mail Queue on $HOST is currently $QUEUECOUNT"
MAILTO="user@example.com"
</pre>

<b>Installation</b>

As root, sudo will not work.

<pre>echo "*/5 * * * * ${PWD}/mailQWatch.sh" >> /etc/crontab
</pre>
