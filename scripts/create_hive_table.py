#!/usr/bin/python
# -*- coding: UTF-8 -*-

import xlrd
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

# define env info

env_info = { 'dev':'kkk', 'qa':'ppp' }

# read from xls file


create_tab = ''
tab_comment = ''
part_comment = "\n\n/*\n添加分区：\n./gen_partition.sh %s '2014-09-15' '2014-12-31' %s.sql\nhive -e 'use third_dsp; source %s.sql'\n*/"

tab_options = '''PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\\001'
LINES TERMINATED BY '\\n'
STORED AS TEXTFILE;'''

mydt = xlrd.open_workbook('./hive.xls')
for i in mydt.sheet_names():
        print "i get request from : ", i
        table = mydt.sheet_by_name(i)
        if table.nrows != 0:
                for j in range(0,table.nrows):
                        if(table.row_values(j)[0] != ''):
                                if(table.row_values(j)[0] == '*'):
                                        pass
                                else:
                                        env_suffix = env_info[table.row_values(j)[0]]
                                        print "use %s_%s" % (table.row_values(j)[1],env_suffix)
                                if(create_tab != '' and tab_comment != ''):
                                        print '\n'
                                        create_tab = create_tab[:-2] + '\n)'
                                        tab_comment = tab_comment[:-2] + ''
                                        print "%s\n */" % (tab_comment)
                                        print '\n'
                                        print "%s\n%s" % (create_tab,tab_options)
                                        print part_option
                                        create_tab = ''
                                        tab_comment = ''
                                create_tab = "CREATE EXTERNAL TABLE %s \n(\n" % (table.row_values(j)[2].lower())
                                tab_comment = tab_comment + "/*\n  字段注释: %s\n" % (table.row_values(j)[3])
                                part_option = part_comment % (table.row_values(j)[2].lower(),table.row_values(j)[2].lower(),table.row_values(j)[2].lower())
                        else:
                                create_tab = create_tab + "%s string,\n" % (table.row_values(j)[1])
                                tab_comment = tab_comment + "%s STRING COMMENT '%s',\n" % (table.row_values(j)[1],table.row_values(j)[2])
                print '\n\n'
                tab_comment = tab_comment[:-2] + ''
                print "%s\n */" % (tab_comment)
                print '\n'
                create_tab = create_tab[:-2] + '\n)'
                print "%s\n%s" % (create_tab,tab_options)
                print part_option

