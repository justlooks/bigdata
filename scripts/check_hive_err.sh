#!/bin/bash
#
# see if hive jdbc is freezed
#
################

while getopts H: arg;do
        case $arg in
                H) host=$OPTARG;;
       esac
done


time=`expect -f alex.exp root xxxxxx $host  "fgrep 'server.TThreadPoolServer' /var/log/hive/hive-server2.log" | toc | awk -F',' '/ERROR/{print $1}'`
unixtime=`date -d "$time" +%s`
nowtime=`date +%s`
if [ `bc <<< $nowtime-$unixtime` -gt 1800 ];then
echo ok
else
echo "recently Error happened ,msg will be ignore after 30 min";exit 1
fi
exit 0

