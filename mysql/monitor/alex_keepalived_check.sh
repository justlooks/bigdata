#!/bin/bash
#
# func -h active ip -p passtive ip  -f active ip passwd -f passtive ip passwd -v virtual ip
#
###################################

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

while getopts h:f:s:v:p: arg;do
        case $arg in
                h) aip=$OPTARG;;
                f) assap=$OPTARG;;
                s) pssap=$OPTARG;;
                v) vip=$OPTARG;;
                p) pip=$OPTARG;;
       esac
done


expect -f alex.exp root $assap $aip  "ip a show dev em1" | grep 'scope global em1' | grep -q $vip
dt_aip=$?
expect -f alex.exp root $pssap $pip  "ip a show dev em1" | grep 'scope global em1' | grep -q $vip
dt_pip=$?
#echo $dt_aip $dt_pip

if [ $dt_aip -gt $dt_pip ];then
echo "keepalived switch";exit ${STATE_CRITICAL}
fi

if [ $dt_aip -lt $dt_pip ];then
echo "nomral";exit ${STATE_OK}
fi

echo "unknow situation";exit ${STATE_UNKNOWN}

