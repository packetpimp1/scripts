#!/bin/bash
#
# This script will email you,
# - Previous scan results
# - When the last AV sig update was performed.
# Remember to change the username in the variables section prior to running.
 
#binaries
ls=/bin/ls
tail=/usr/bin/tail
head=/usr/bin/head
awk=/usr/bin/awk
logger=/usr/bin/logger
grep=/bin/grep

#variables
user=admin
logdir="/home/${user}/.avg7/testresults"
log=$(ls -lhtr ${logdir}  | ${tail} -n1 | ${awk} ' { print $8 } ')
logpath="${logdir}/${log}"
main=$(tail -n+7 ${logpath})
upd=$(tail -n1 /opt/grisoft/avg7/var/update/log/avg7upd.log)

#Main

if [ ! -r ${logpath} ]; then
        echo "Error: Unable to read logfile ${logpath}" |  ${logger} -t "AVG EMAIL UPDATE" -p mail.err
        exit 1
else

        #Create the log
cat << EOF > /tmp/avgstat.txt
$main

$upd

EOF
        #Email log
        mail -s "AVG Scan Results" jabba@thehut.com < /tmp/avgstat.txt
fi

exit 0      
