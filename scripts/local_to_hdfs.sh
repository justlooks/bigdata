#!/bin/bash

# upload script for project dsp

echo `date` >> mylog

HDFSPREFIX="/user/hive/warehouse"

CATE=(/data/5/scribe/dsp_request /data/5/scribe/dsp_response /data/5/scribe/dsp_execution /data/5/scribe/dsp_click /data/5/scribe/cookieshow_trace /data/5/scribe/adindex_ctrrecord /data/3/scribe/third_dsp_request /data/3/scribe/third_dsp_response /data/3/scribe/third_dsp_execution /data/3/scribe/third_dsp_click)


for((k=0;k<${#CATE[@]};k++));do
SRCDIR="${CATE[$k]}"
DUMPPREFIX="`dirname ${CATE[$k]}`"
CATENAME="`basename ${CATE[$k]}`"

DSTDIR="${HDFSPREFIX}/${CATENAME%_*}.db/${CATENAME##*_}"
DUMP="${DUMPPREFIX}/dump"

echo $DSTDIR

    TODAY=$(date +%Y-%m-%d)

    if hadoop fs -ls ${DSTDIR}/${TODAY} > /dev/null 2>&1;then
    :
    else
    hadoop fs -mkdir ${DSTDIR}/${TODAY}
    fi

    if [ ! -e ${DUMP}/${TODAY} ];then
    mkdir ${DUMP}/${TODAY}
    fi

    for i in ${SRCDIR}/*;do
    echo lsof $i
    if ! /usr/sbin/lsof $i > /dev/null;then
    echo i need handle $i

    filename=$(basename $i)
    DATE=$(echo $filename | sed -e 's/data-\(.*\)_[0-9]\+/\1/')
	echo "hadoop fs -put $i ${DSTDIR}/${DATE}"

            if hadoop fs -put $i ${DSTDIR}/${DATE} > /dev/null 2>&1;then
            echo hdfs upload success
            \rm $i
            else
            sleep 2
                    if hadoop fs -put $i ${DSTDIR}/${DATE} > /dev/null 2>&1;then
                    echo hdfs upload success 2
                    \rm $i
                    else
                    mv $i ${DUMP}/${DATE}
                    logger "[SCRIBE ERROR]: file $i upload to hdfs failed the fi                                                                                                 le now in ${DUMP}/${DATE}"
                    fi
            fi
    fi
    done
done

