TL;DR
-----
This script will determine which operating system is running then backup the os accordingly, once complete it will securely send it to the manager.

The script is based on R65 and all backups will be sent to "/var/tmp/backups" on the manager.

Each time the backup is run it will write a system log confirming if it was successful or unsuccessful.
If successful it will include the MD5 within the log message that you can use prior to any restores.

General
-------
This script will determine which operting system is running then backup the os accordingly.
The backup files will be sent to the manager to "/var/tmp". The manager IP is changed using the $SMARTCENTIP variable.
The backup files locally will be stored in, 

	SPLAT = /opt/CPbackups/
	IPSO = /var/backup/
	SOLARIS = /var/tmp/

Note : The script will rotate the locally store scripts.
You will be able to rotate the scripts on your manager by adding the following line to the crontab,

	find /var/tmp/backups -name *backup\* -mtime +2 -exec rm {} \;

Each time the backup is run it will write a system log confirming if it was successfull or unsuccessful.
If successful it will include the MD5 within the log message.

Installation
------------
Client:
Create ssh key `ssh-keygen -t rsa` (Do not enter a passphrase and use the folder path selected as default.)

Server:
Create a new usernamed `useradd cpbackup`
Add password to user `passwd cpbackup`
Login as cpbackup
ssh to one of the firewalls as cpbackup and then dissconnect (this will create the required ssh folder for you)
Copy the rsa_id.pub file from the client to a file called authorized_keys in the folder /home/cpbackup/.ssh/ and enure the permissions are set to 600.
Create a folder `mkdir /var/tmp/backups`
Change permissions `chown root:cpbackup /var/tmp/backups`
Change permissions `chmod 720 /var/tmp/backups`
Add the user cpbackup to the line `AllowUsers` within  /etc/ssh/sshd_config.
Restart ssh `/etc/init.d/sshd restart`
Add the following line to your crontab.

How it Works
------------
SPLAT
-----
When running this script on SPLAT you will be running the `backup` command. The backup command will not backup init.d scripts. Such as static route or arp scripts. So these are backedup seperaty within  the file /opt/CPbackups/splat-backup_[hostname]_[date}.tgz.
To restore your backup use the `restore` command.

IPSO
----
When running this script on IPSO you will be running the `manual backup` command within clish.
This will backup up the whole operating system including all proxy arps and routes.
To restore you backup use the command `clish -c "set restore manual /[path]/[filename].tgz"`

Solaris
-------
when running this script on Solaris you will be backing up the main operating system files.
To restore you will need to extract the tgz within Solaris.  

Additional Notes
----------------
For both SPLAT and Solaris backs there will be a file called "/var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt"
This will contain the output of the following commands,

	*arp -an
	*netstat -nvr
	*ifconfig -a 

If you have any issues with the script you can run it in debug mode by using the command `sh -x cp_backup.sh`
If you have any issues with the file being sent using the ssh keys you can debug this by using either, 

	*`ssh -vvv user@[manager ip]` on the client or
	*`/sbin/sshd -d -p [port]` on the manager 

