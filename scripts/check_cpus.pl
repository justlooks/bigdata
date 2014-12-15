#!/usr/bin/perl -w


use strict;




=pod
  /proc/stat 各字段解释

以下时间都以jiffies计算 1 jiffies=0.01 second,并以开机到目前的累计值
cpu0 13229923 260 1143831 297583202 7214522 170 236582 0 0
1 在用户态执行的时间 
2 被niced的进程在用户态执行的时间
3 进程执行在内核态的时间
4 CPU除了等待IO空闲之外的空闲时间
5 CPU等待IO完成的时间
6 处理硬中断花费的时间
7 处理软中断时间
8 steal time,当需要cpu循环时，这个资源被用于其他目的,如果所有的VM的ST都很高表示需要增加CPU资源，如果个别VM的ST值很高表示该台机器over-sold,需要将VM迁移出去
Steal time is the percentage of time a virtual CPU waits for a real CPU while the hypervisor is servicing another virtual processor.
9 guest time 运行虚拟CPU循环的时间（？？）

intr 第一个是开机以来发生中断的总量，包括没有编号的中断，后面的是对应每个有编号的中断发生次数
ctxt  上下文切换总数
btime  boot time
processes  自启动以来fork进程的个数
procs_running   当前 运行态进程个数
procs_blocked   当前被阻塞进程个数
softirq 第一个是开机以来发生软中断的总量，包括没有编号的中断，后面的是对应每个有编号的中断发生次数



=cut
