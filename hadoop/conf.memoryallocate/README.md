关于hbase的GC回收机制

一般使用-XX:+ UseParNewGC和-XX:+ UseConcMarkSweepGC

对于新生代
Parallel New Collector是"stop-the-world"复制收集,当运行时停止所有JAVA进程，但是由于新生代比较小(-Xmn）所以停滞的时间比较短

对于老生代
Concurrent-Mark-Sweep collector  会导致两种情况的CMS Failure
第一种是，在标记的阶段老生代已经被塞满，这时收集方法退化为单线程，那么结果导致长时间停顿
解决方法是可以提前唤醒CMS（通过设置XX：CMSInitiatingOccupancyFraction ）,注意让老生代余量大于新生代，这样即使整个新生代内容都在收集过程中搬到老生代也不会导致收集方法退化成单线程
第二种是，碎片导致的CMS失败，即使你有较大量的剩余内存，但是内存碎片不足够满足分配需要，这种情况下无法避免落回效率超低的单线程收集

HBASE应用中大部分情况是由于memstore的刷到磁盘，导致内存碎片

java.env  调整zookeeper内存
