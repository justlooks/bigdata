#!/bin/bash
#
# see if hive jdbc is OOM
#
################

while getopts H: arg;do
        case $arg in
                H) host=$OPTARG;;
       esac
done


time=`expect -f /usr/local/nagios/libexec/alex.exp root adexchange123dy $host  "fgrep -B1 'java.lang.OutOfMemoryError: Java heap space' /var/log/hive/hive-server2.log" | tail -1 | awk -F',' '/ERROR/{print $1}'`
unixtime=`date -d "$time" +%s`
nowtime=`date +%s`
if [ `bc <<< $nowtime-$unixtime` -gt 1800 ];then
echo ok
else
echo "Recently OOM Error happened ,msg will be ignore after 30 min";exit 1
fi
exit 0

