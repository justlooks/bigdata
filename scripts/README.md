脚本说明
=================================================
1.用于提取模板文件数据生成hive DDL，并同时生成建分区语句 依赖于xlrd包 ，hive.xls是该文件的数据源
create_hive_table.py

2.用于upload scribe产生的本地文件到hdfs  
local_to_hdfs.sh
