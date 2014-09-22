#!/bin/bash

basedir="/var/www/html/dbbackup/"
currdate=$(date +%Y%m%d)
if [ ! -d "${basedir}/archive/${currdate}" ];then
        mkdir ${basedir}/archive/${currdate}
        cp ${basedir}/today/index.php ${basedir}/archive/${currdate}
        mv ${basedir}/today/result.html ${basedir}/archive/${currdate}
fi


# delete report older than 1 month

rm -rf ${basedir}/archive/$(date +%Y%m%d -d '1 month ago')

