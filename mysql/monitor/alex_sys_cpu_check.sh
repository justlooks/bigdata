#!/bin/bash
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

CPU=$(top -b -n 1 | awk '$NF ~ /mysqld$/{print $9}')
#CPU=$(top -n 2 | awk '/mysqld/{a=$(NF-4)}END{print a}')
if [ ${CPU%.*} -lt 150 ];then
flag=${STATE_OK}
msg="CPU fine"
else
flag=${STATE_CRITICAL}
msg="CPU alert ${CPU}"
fi
PERFDATA="CPU=${CPU};150;300;0;700"
echo "${msg} | ${PERFDATA}";exit ${flag}
