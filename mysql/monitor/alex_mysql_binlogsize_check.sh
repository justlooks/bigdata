#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

TGT="/var/lib/mysql"
date=$(date -d '1 day ago' +%Y-%m-%d)
msg=""
# if binlog great than 5 G
threhold=5

for i in `ls $TGT`;do

if [[ $i =~ ^[0-9]$ ]];then
result=$(ls --time-style=full-iso -l ${TGT}/${i}/binlog | awk '{if($6~"'${date}'"){sum+=$5;}}END{print sum/1024/1024/1024">'${threhold}'"}' | bc)
if [ ${result} -eq 0 ];then
msg=${msg}" instance $i is ok";
else
msg=${msg}" instance $i binlog great than 5G";flag=${STATE_CRITICAL}
fi
fi

done
echo ${msg};exit ${flag}

