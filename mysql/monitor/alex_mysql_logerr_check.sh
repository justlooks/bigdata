#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

TGT="/var/lib/mysql"
search=$(date +%y%m%d)

for i in `ls $TGT`;do
if [[ $i =~ ^[0-9]$ ]];then
        inst_msg=$(awk '/^'${search}'/{if($3~/[ERROR]/){$1="";print $0}}' ${TGT}/${i}/sm_${i}db.err | sed -n 'H;${g;s/\n//g;p;}')
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

