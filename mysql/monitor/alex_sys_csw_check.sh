#!/bin/bash
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

CSW=$(dstat -y  1 1|tail -1|awk '{print $2}')
#CPU=$(top -n 2 | awk '/mysqld/{a=$(NF-4)}END{print a}')
if [ ${CSW%.*} -lt 10000 ];then
		flag=${STATE_OK}
		msg="CPU context switch fine"
else
		flag=${STATE_CRITICAL}
		msg="CPU context switch alert ${CSW}"
fi
PERFDATA="CSW=${CSW};8000;10000;0;20000"
echo "${msg} | ${PERFDATA}";exit ${flag}
