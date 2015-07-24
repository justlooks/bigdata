#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

#TGT=(/home/cobar_a/cobar-A /home/cobar_b/cobar-B /home/cobar_c/cobar_C)
TGT=(/home/cobar_b/cobar-B)
search=$(date +%Y-%m-%d)
# 3 hours
threhold=10800

for k in ${TGT[@]};do
for i in `ls ${k}/logs`;do
if [[ $i =~ console.log$ ]];then
        inst_msg=$(awk '/'${search}'/{if(substr($1,index($1,":")+1)~/ERROR/){bb=$3;gsub(":"," ",bb);if(systime()-mktime(substr($2,1,4)" "substr($2,6,2)" "substr($2,9,2)" "bb)<=10800){$2="";print $0}}}' ${k}/logs/${i} | sed -n 'H;${g;s/\n//g;p;}')

    if [ x"${inst_msg}" == x'' ];then
                flag=${STATE_OK}
                msg=${msg}" dir $k log is fine |"
        else
                flag=${STATE_CRITICAL}
                msg=${msg}" dir $k : ${inst_msg} |"
                echo ${msg};exit ${flag}
        fi
fi
inst_msg=''
done
done
echo ${msg};exit ${flag}

