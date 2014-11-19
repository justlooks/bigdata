#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

IO="false"
SQL="false"

while getopts H:P:M:u:p: arg;do
        case $arg in
                H) host=$OPTARG;;
                P) port=$OPTARG;;
                u) username=$OPTARG;;
                p) pass=$OPTARG;;
                M) mode=$OPTARG;;
        esac
done

# check if repl is work
if [ "$mode" = "repl" ];then
        mysql -h$host -P$port -u$username -p$pass -e 'show slave status\G' > /tmp/alex_$$
        if grep -P '(?<=Slave_IO_Running: )Yes' /tmp/alex_$$ >/dev/null;then
                IO="true"
        fi

        if grep -P '(?<=Slave_SQL_Running: )Yes' /tmp/alex_$$ > /dev/null;then
                SQL="true"
        fi

        if [ "$IO" = "true" -a $SQL = "true" ];then
                echo " replication is ok ";\rm /tmp/alex_$$;exit ${STATE_OK}
        elif [ "$IO" = "true" ];then

                echo "SQL thread is stop"
                $(grep -oP '(?<=Last_IO_Error: ).*$' /tmp/alex_$$);\rm /tmp/alex_$$;exit ${STATE_WARNING}
        elif [ "$SQL" = "true" ];then
                echo "IO thread is stop"
                $(grep -oP '(?<=Last_SQL_Error: ).*$' /tmp/alex_$$);\rm /tmp/alex_$$;exit ${STATE_WARNING}
        else
                echo both thread is broken;\rm /tmp/alex_$$;exit ${STATE_CRITICAL}
        fi
# check if instance is alive
elif [ "$mode" = "ping" ];then
        re=$(mysqladmin -h$host -P$port -u$username -p$pass ping)
        if [ "$re" = "mysqld is alive" ];then
                echo "mysql instance is alive";exit ${STATE_OK}
        else
                echo "mysql is crashed";exit ${STATE_CRITICAL}
        fi
# check Com_ops count
elif [ "$mode" = "ops" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="get op count |"}/Com_select|Com_insert|Com_update/{msg=msg$1"="$2";;;0;"}END{print msg}'
        exit ${STATE_OK}

fi
echo host $host port $port user $username  pass $pass mode $mode
