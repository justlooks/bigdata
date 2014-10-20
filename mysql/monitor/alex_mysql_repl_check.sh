#!/bin/bash

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
                echo " replication is ok ";\rm /tmp/alex_$$;exit 0
        elif [ "$IO" = "true" ];then

                echo "SQL thread is stop"
                $(grep -oP '(?<=Last_IO_Error: ).*$' /tmp/alex_$$);\rm /tmp/alex_$$;exit 1
        elif [ "$SQL" = "true" ];then
                echo "IO thread is stop"
                $(grep -oP '(?<=Last_SQL_Error: ).*$' /tmp/alex_$$);\rm /tmp/alex_$$;exit 1
        else
                echo both thread is broken;\rm /tmp/alex_$$;exit 3
        fi
# check if instance is alive
elif [ "$mode" = "ping" ];then
        re=$(mysqladmin -h$host -P$port -u$username -p$pass ping)
        if [ "$re" = "mysqld is alive" ];then
                echo "mysql instance is alive";exit 0
        else
                echo "mysql is crashed";exit 1
        fi
fi
echo host $host port $port user $username  pass $pass mode $mode

