# for journalnode zkfc  and historyserver memory
export HADOOP_HEAPSIZE=2000
# for NN and DN
export HADOOP_DATANODE_OPTS="-Xmx4096m -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$HADOOP_LOG_DIR/gc-$(hostname)-datanode.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=15M"
# about control 40T data with 1G RAM (20G enough for small cluster)
export HADOOP_NAMENODE_OPTS="-Xmx20480m -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$HADOOP_LOG_DIR/gc-namenode-$(hostname).log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=3 -XX:GCLogFileSize=150M"
