#!/usr/bin/python

import re
import subprocess
import shlex

# read the zookeeper config file

file = "/etc/zookeeper/conf/zoo.cfg"
nodes = []
okflag = 0
msg = 'bad zk node : '
mnt_stat = {}
def zk_cmd(cmd,node):
        send_cmd = 'echo ' + cmd + ' | nc ' + node + ' 2181'
        output = subprocess.Popen(["-c", send_cmd],stdout=subprocess.PIPE,stdin=subprocess.PIPE,shell=True)
        result = output.communicate()[0]
        return result


# check zknode alive
for line in open(file):
        regex = re.compile('^server\.\d+=')
        if re.search(regex,line):
                nodes.append(re.split('[=:]',line)[1])
for node in nodes:
        if zk_cmd('ruok',node) != 'imok':
                okflag = 1
                msg += node + ' '
        else:
                print node+' is ok'
if okflag == 1:
        print msg

# check load by wchs

for node in nodes:
        output = zk_cmd('wchs',node)
        arr = re.split('[A-Za-z :\n]+',output)[0:3]

        print 'node ' + node + ' has ' + arr[0] + ' connections and watch path is ' + arr[1] + ' total watch are ' + arr[2]

# check metrics of monitor

for node in nodes:
        output = zk_cmd('mntr',node)
        for line in output.split('\n'):
                if line:
                        mnt_stat[re.split('\s+',line)[0]] = re.split('\s+',line)[1]
        pct_used_file_dep = (float(int(mnt_stat['zk_open_file_descriptor_count']))/int(mnt_stat['zk_max_file_descriptor_count']))*100
        print 'alex get '+node+' file dep pct is ' + str(pct_used_file_dep)
        print 'still ' + mnt_stat['zk_outstanding_requests'] + ' request need handle'
'''
        for (key ,value) in mnt_stat.items():
                print "key "+key+" : value "+value
'''

print zk_cmd('wchs','192.168.26.231')   # watch by summary
print zk_cmd('wchp','192.168.26.231')  # watch by path
print zk_cmd('wchc','192.168.26.231')  # watch by connect
# zk_znode_count is total num of zk datatree node

