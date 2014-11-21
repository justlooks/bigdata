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

elif [ "$mode" = "conn" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="get connect status |"}/(Aborted_connects|Connections|Max_used_connections|Threads_connected)[^_]/{msg=msg$1"="$2";;;0;"}END{print msg}'
        exit ${STATE_OK}
# you need check the query if Select_full_join or Select_range_check is not zero,
elif [ "$mode" = "query" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="get select status |"}/(Select_full_join|Select_full_range_join|Select_range|Select_range_check|Select_scan)[^_]/{msg=msg$1"="$2";;;0;"}END{print msg}'
        exit ${STATE_OK}
# check sort status ,if sort_merge_passes is large ,you need increase sort_buffer_size
elif [ "$mode" = "sort" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="get sort status |"}/(Sort_merge_passes|Sort_range|Sort_rows|Sort_scan)[^_]/{msg=msg$1"="$2";;;0;"}END{print msg}'
        exit ${STATE_OK}
elif [ "$mode" = "tpool" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="thread pool status |"}/(Threadpool_threads|Threadpool_idle_threads)[^_]/{msg=msg$1"="
$2";;;0;"}END{print msg}'
        exit ${STATE_OK}

elif [ "$mode" = "tmp" ];then
        mysql -h$host -P$port -u$username -p$pass -e "show global status" | awk 'BEGIN{msg="tempoary table or file |"}/(Created_tmp_disk_tables|Created_tmp_files|Created_tmp_tables)[^_]/{msg=msg$1"="$2";;;0;"}END{print msg}'
        exit ${STATE_OK}

fi
echo host $host port $port user $username  pass $pass mode $mode
