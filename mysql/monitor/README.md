脚本说明
=================================================
1.用于检测MySQL实例和replication是否正常,以及查询数据库Com_ops数目,检查数据库连接情况，检查select是否正确使用索引情况,检查排序操作情况，检查线程池使用情况,检查临时表或者文件创建情况(目前只有这八个功能，脚本后续开发中)  
alex_mysql_repl_check.sh

2.用于检测keepalived的vip是否切换的脚本  
alex_keepalived_check.sh

3.用于检测是否MySQL实例中昨天binary log总量超过阀值  
alex_mysql_binlogsize_check.sh

4.用于检测是否MySQL Error log中有错误信息  
alex_mysql_logerr_check.sh

5.查看MySQL进程使用虚拟内存(VSZ)以及常驻内存(RSS)大小脚本  
alex_mysql_mem_check.sh

6.用于pnp4nagios 自定义template脚本(绘图数据由脚本alex_mysql_repl_check.sh采集)  
alex_mysql_repl_check.php
