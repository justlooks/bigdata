#!/bin/bash
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

if [ "$1" = "" ];then
echo no instance port ;exit
fi


BASEDIR=/var/lib/cobar/$1/
#BASEDIR=/usr/local/nrpe/libexec/plugins/
threshold=10     # 10G

msg=$(du -sh ${BASEDIR}shard* | awk '$1~/G/{if(substr($1,1,index($1,"G")-1)>'${threshold}'){print $2":"$1}}')
if [ X"${msg}" == X"" ];then
flag=${STATE_OK}
msg="fine, each shard size is under ${threshold}G"
else
flag=${STATE_CRITICAL}
msg="alert : "${msg}
fi
echo "${msg} ";exit ${flag}
