#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


cobar_inst=(cobar_a cobar_b cobar_c)
msg=
for i in ${cobar_inst[@]};do
num=$(pgrep -u ${i} java)
if ps -ef | grep ${num} | grep -v grep | grep CobarStartup > /dev/null 2>&1;then
msg=${msg}" ${i} instance alived"
flag=1
else
msg=" ${i} dead"
echo ${msg}
exit ${STATE_CRITICAL}
fi
done

if [ ${flag} -eq 1 ];then
echo ${msg}
exit ${STATE_OK}
fi
