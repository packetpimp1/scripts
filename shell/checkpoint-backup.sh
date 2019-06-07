#!/bin/sh


### ENVIRONMENT VARIABLES

if [ -r /var/etc/pm_profile ]
then
        . /var/etc/pm_profile
fi

. $CPDIR/tmp/.CPprofile.sh

### VARIABLES 

OS=`uname`
SMARTCENTIP=10.1.1.1
PORT=22

### MAIN SCRIPT 

if [ -z "${OS}" ]
then
        logger -t cp_backup -p daemon.err "Unable to determine OS"

elif [ "${OS}" = "Linux" ]
then
        rm -f /opt/CPbackups/splat-backup*
        rm -f /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt
        arp -an > /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt
        netstat -rvn >> /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt
        ifconfig -a >> /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt
        chkconfig --list >> /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt
        tar czf /opt/CPbackups/splat-backup_`hostname`_OS_`/bin/date +"%Y%m%d"`.tgz /etc/group /etc/sys*.conf /etc/nsswitch.conf  /etc/init.d/* /etc/ssh /var/spool/cron /var/tmp/`hostname`_runconfig_`/bin/date +"%Y%m%d"`.txt 2>/dev/null
        /bin/backup_start all splat-backup > /tmp/cp_backup.$$
        RC=$?
        mv /opt/CPbackups/splat-backup.tgz /opt/CPbackups/splat-backup_`hostname`_`/bin/date +"%Y%m%d"`.tgz
        BKUPFILE=/opt/CPbackups/splat-backup_`hostname`_`/bin/date +"%Y%m%d"`.tgz
        BKUPFILE2=/opt/CPbackups/splat-backup_`hostname`_OS_`/bin/date +"%Y%m%d"`.tgz
        find /opt/CPbackups/ -name *backup\* -mtime +2 -exec rm {} \;

elif [ "${OS}" = "IPSO" ]
then
        clish -c "set backup manual filename ipso-backup"
        clish -c "set backup manual on"
        RC=$?
        mv /var/backup/ipso-backup_`date +"%Y%m%d"`.tgz /var/backup/ipso-backup_`hostname`_`date +"%Y%m%d"`.tgz
        BKUPFILE=/var/backup/ipso-backup_`hostname`_`date +"%Y%m%d"`.tgz
        MD5=`md5 "${BKUPFILE}"`
        find /var/backup/ -name *backup\* -mtime +2 -exec rm {} \;

elif [ "${OS}" = "SunOS" ]
then
        arp -an > /var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt
        netstat -rvn >> /var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt
        ifconfig -a >> /var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt
        tar -cf - /etc/passwd /etc/system /etc/group /etc/shadow /etc/syslog.conf /etc/nsswitch.conf /etc/hosts /etc/nodename /etc/hostname.* /etc/etheraddr* /etc/inet/netmasks /etc/inet/ntp.conf /etc/init.d/*static* /etc/init.d/*route* /etc/init.d/linkspeed /etc/init.d/*arp* /etc/ssh /var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt /var/spool/cron /usr/local/bin /usr/local/log 2>/dev/null | gzip -6c > /var/tmp/solaris-backup_`hostname`_`/bin/date +"%Y%m%d"`.tgz
        RC=$?
        rm -f /var/tmp/`hostname`_runconfig_`date +"%Y%m%d"`.txt
        BKUPFILE=/var/tmp/solaris-backup_`hostname`_`date +"%Y%m%d"`.tgz
        MD5=`md5 "${BKUPFILE}"`
        find /var/tmp/ -name *backup\* -mtime +2 -exec rm {} \;
fi

if [ "${RC}" != 0 ]
then
        logger -t cp_backup -p daemon.err "Backup unsuccessful."
        exit 1

elif [ "${RC}" = 0 -a "${OS}" = Linux ]
        then
        logger -t cp_backup -p daemon.info "Backup successful. "${BKUPFILE}". MD5:`awk ' /MD5/ { print $9 } ' /tmp/cp_backup.$$ `"
        rm -f /tmp/cp_backup.$$
        exit 0

elif [ "${RC}" = 0 -a "${OS}" = IPSO -o "${RC}" = 0 -a "${OS}" = SunOS ]
        then
        logger -t cp_backup -p notice "Backup successful. "${MD5}""
        exit 0
fi

## File Transfer

scp -P "${PORT}" "${BKUPFILE}" "${SMARTCENTIP}":/var/tmp/backups > /dev/null 2>&1
if [ "${RC}" = 0 -a "${OS}" = IPSO -o "${RC}" = 0 -a "${OS}" = SunOS ]
        then
        logger -t cp_backup -p notice "Backup Transfer successful."
        exit 0
elif [ "${RC}" = 0 -a "${OS}" = Linux ]
        then
	scp -P "${PORT}" "${BKUPFILE2}" "${SMARTCENTIP}":/var/tmp/backups && logger -t cp_backup -p daemon.info "Backup Transfer successful." > /dev/null 2>&1
        exit 0
fi

