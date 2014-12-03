#!/bin/bash
host=192.168.26.171
user="keepalived"
pass="keepalived"
port1=3371
port2=3372
re="mysqld is alive"
mysql1=$(mysqladmin -h ${host} -u ${user} -p${pass} -P ${port1} ping)
mysql2=$(mysqladmin -h ${host} -u ${user} -p${pass} -P ${port2} ping)
if [ "${mysql1}x" != "${re}x" -o "${mysql2}x" != "${re}x" ];then
service keepalived stop
exit 1
fi
exit 0
