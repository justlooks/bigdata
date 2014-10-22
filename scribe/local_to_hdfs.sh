#!/bin/bash

echo `date` >> mylog

SRCDIR="/data/6/scribe/cookieshow_trace"
DSTDIR="/user/hive/warehouse/cookieshow.db/trace"
DUMP="/data/6/scribe/dump/cookieshow_trace"

TODAY=$(date +%Y-%m-%d)
#TODAY="test"

if hadoop fs -ls ${DSTDIR}/${TODAY} > /dev/null 2>&1;then
:
else
hadoop fs -mkdir ${DSTDIR}/${TODAY}
fi

if [ ! -e ${DUMP}/${TODAY} ];then
mkdir ${DUMP}/${TODAY}
fi


for i in ${SRCDIR}/${TODAY}/*;do
echo lsof $i
if ! /usr/sbin/lsof $i > /dev/null;then
echo i need handle $i
        if hadoop fs -put $i ${DSTDIR}/${TODAY} > /dev/null 2>&1;then
        echo hdfs upload success
        \rm $i
        else
        sleep 1
                if hadoop fs -put $i ${DSTDIR}/${TODAY} > /dev/null 2>&1;then
                echo hdfs upload success 2
                \rm $i
                else
                mv $i ${DUMP}/${TODAY}
                logger "[SCRIBE ERROR]: file $i upload to hdfs failed the file now in ${DUMP}/{TODAY}"
                fi
        fi
fi
done
