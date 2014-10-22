#!/bin/bash

# need add "nagios  ALL=NOPASSWD: /usr/local/nagios/libexec/check_hdfsupload.sh" in file /etc/sudoers
# comment Defaults    requiretty
# Defaults   !visiblepw  ->  Defaults   visiblepw 

export LANG=en_US.UTF-8

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

TGT="/var/log/messages"

format=$(date "+%b %d %H:%M" -d "1 hour ago")
keyword="SCRIBE ERROR"

res=$(awk "BEGIN{count=0}/$format/,0{if(\$0~/$keyword/){count++}}END{print count}" ${TGT})
if [ ${res} -ne 0 ];then
echo "CRITICAL - HDFS upload error ,check it!!"
exit $STATE_CRITICAL
else
echo "OK - HDFS upload work fine last hour"
exit $STATE_OK
fi
