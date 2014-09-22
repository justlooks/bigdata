#!/bin/bash


log="/tmp/mylog"
file="/tmp/result.html"
pss="xxx"          # change pass
remote="ip"        # change ip
remote_dir="/var/www/html/dbbackup/today"

echo begin >> ${log}
/usr/bin/perl /root/scripts/mybackup.pl
/usr/bin/expect -f /root/scripts/send.exp ${file} ${pss} ${remote} ${remote_dir}
echo end >> ${log}

