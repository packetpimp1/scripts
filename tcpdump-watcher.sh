#!/bin/bash

### ENV VAR ###

export PATH=/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

### CHECK INPUT ###

if [ -z "$1" ]; then
        echo "Usage: ";
        exit
fi

### SET VAR ###

LOGFILE=$1
STRING=$2

### MAIN ###

echo "[INFO] logfile set to ${LOGFILE}"

for x in {1..10} ; do
    echo "[*] creating backup of logfile named ${LOGFILE}$x-bak"
    cp "${LOGFILE}" "${LOGFILE}"$x-bak
    
    echo "[*] clearing logfile."
    > "${LOGFILE}"
    
    echo "[*] starting tcpdump - 100Mb file with 10 file limit set.
    tcpdump -ni any port 80 -s 0 -C 100 -W 10 -w /var/tmp/capture.pcap -Z root
    
    echo "[*] checking logs for string"
    grep "${STRING}" "${LOGFILE}"

    # check if log entry is found
    if [ $? == "0" ] ; then
        echo "[*] log found containing string, tcpdump stopped ... " ; break 
    else
        echo "[*] no log entry found, tcpdump continuing ... " 
    fi
done
