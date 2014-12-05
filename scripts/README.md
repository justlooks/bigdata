脚本说明
=================================================
1.用于提取模板文件数据生成hive DDL，并同时生成建分区语句 依赖于xlrd包 ，hive.xls是该文件的数据源
create_hive_table.py

2.用于upload scribe产生的本地文件到hdfs  
local_to_hdfs.sh

3.用于监控hive jdbc错误，在一定时间段外的错误信息将被忽略(该脚本依赖于do.exp)  
check_hive_err.sh

4.用于自动ssh提交命令在远程机器执行(依赖于安装expect)    
do.exp

5.用于监控zookeeper状态脚本(TODO)  
check_zookeeper.py

6.用于监控HDFS DN 的磁盘使用情况，以及日志目录的大小情况  
check_hadoop_volume.pl
