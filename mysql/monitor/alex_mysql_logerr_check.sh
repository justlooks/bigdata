#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

TGT="/var/lib/mysql"
search=$(date +%y%m%d)
# 3 hours
threhold=10800

for i in `ls $TGT`;do
if [[ $i =~ ^[0-9]$ ]];then
        inst_msg=$(awk '/^'${search}'/{if($3~/[ERROR]/){bb=$2;gsub(":"," ",bb);if(systime()-mktime("20"substr($1,1,2)" "substr($1,3,2)" "substr($1,5,2)" "bb)<='${threhold}'){$1="";print $0}}}' ${TGT}/${i}/sm_${i}db.err | sed -n 'H;${g;s/\n//g;p;}')
    if [ x"${inst_msg}" == x'' ];then
                flag=${STATE_OK}
                msg=${msg}" instance $i log is fine |"
        else
                flag=${STATE_CRITICAL}
                msg=${msg}" instance $i : ${inst_msg} |"
        fi
fi
inst_msg=''
done
echo ${msg};exit ${flag}

