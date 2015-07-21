#!/bin/bash
#
# usage : func -w waring_V -c critical_V
#
########################

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

while getopts w:c: arg;do
        case $arg in
                w) warn=$OPTARG;;
                c) critical=$OPTARG;;
        esac
done

utils=$(pt-diskstats  --devices-regex 'dm-0' --columns-regex 'busy' --iterations 2 | tail -1 | awk -F '[ \t%]' '{print $(NF-1)}')


if [ ${utils} -gt ${critical} ];then
msg="critical"
flag=${STATE_CRITICAL}
elif [[ ${utils} -gt ${warn} && ${utils} -lt ${critical} ]];then
msg="waring"
flag=${STATE_WARNING}
else
msg="normal"
flag=${STATE_OK}
fi

echo "${msg} disk utils ${utils} | utils=${utils}:${warn}:${critical}:0:0"
