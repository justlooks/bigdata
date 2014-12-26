#!/bin/bash
# Begin by deleting things more than 7 days old
find /root/tcpdumps/ -type f -mtime +7 -exec rm -f '{}' \;
# Bail out if the disk is more than this %full.
PCT_THRESHOLD=95
# Bail out if the disk has less than this many MB free.
MB_THRESHOLD=100
# Make sure the disk isn't getting too full.
avail=$(df -m -P /root/tcpdumps/ | awk '/^\//{print $4}');
full=$(df -m -P /root/tcpdumps/ | awk '/^\//{print $5}' | sed -e 's/%//g');
if [ "${avail}" -le "${MB_THRESHOLD}" -o "${full}" -ge "${PCT_THRESHOLD}" ]; then
   echo "Exiting, not enough free space (${full}%, ${avail}MB free)">&2
   exit 1
fi
host=$(mysql -ss -e 'SELECT p.HOST FROM information_schema.innodb_lock_waits w INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id INNER JOIN information_schema.processlist p on b.trx_mysql_thread_id = p.ID LIMIT 1')
if [ "${host}" ]; then
   echo "Host ${host} is blocking"
   port=$(echo ${host} | cut -d: -f2)
   tcpdump -i eth0 -s 65535 -x -nn -q -tttt port 3306 and port ${port} > /root/tcpdumps/`date +%s`-tcpdump &
   mysql -e 'show innodb status\Gshow full processlist' > /root/tcpdumps/`date +%s`-innodbstatus
   pid=$!
   sleep 30
   kill ${pid}
fi
