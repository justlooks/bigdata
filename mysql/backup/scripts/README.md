备份在192.168.26.171上运行
备份结果展示在192.168.26.251/dbbackup

备份脚本路径：

备份逻辑脚本       /root/scripts/mybackup.pl
备份结果上传脚本   /root/scripts/send.exp
备份启动脚本       /root/scripts/bak_and_send.sh

备份启动脚本执行结果是生成备份report文件 /tmp/result.html,并将其上传到192.168.26.251的"/var/www/html/dbbackup/today"目录下，作为当天备份结果查看

备份存放目录  /data/mysqlbackup/CH_backup/实例名/日期,目录中备份以库为单位分成多个压缩文件

关于备份结果展示的相关代码

# tree /var/www/html/dbbackup/
/var/www/html/dbbackup/
├── archive
│   ├── 20140829
│   │   └── index.html
│   ├── 20140830
│   ├── 20140831
│   ├── 20140901
│   │   ├── index.php
│   │   └── result.html
│   └── index.php
├── index.php
└── today
    └── index.php


访问地址为
http://192.168.26.251/dbbackup/


放在192.168.26.251上的脚本
移动并清理脚本  /root/scripts/mv_report.sh   (将非当天的报告移动到archive目录的对应日期目录下，用crontab 每天执行)

crontab

/root/scripts/mv_report.sh    每天凌晨5点执行
0 5 * * *      /root/scripts/mv_report.sh

/root/scripts/bak_and_send.sh  每天凌晨1点执行
0 1 * * *       /root/scripts/bak_and_send.sh  >> /tmp/mylog



前置要求
192.168.26.171 
创建mysql备份账号
#create user 'bak'@'192.168.26.171' identified by 'xxx';
#grant all on *.* to 'bak'@'192.168.26.171';

并安装expect  yum install expect

192.168.26.251 
安装httpd和php
yum install httpd php
