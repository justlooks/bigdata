整个IO层的相关代码在block目录中

目录下的make文件为整个代码结构提供了线索

obj-$(CONFIG_BLOCK) := elevator.o blk-core.o blk-tag.o blk-sysfs.o \
            blk-flush.o blk-settings.o blk-ioc.o blk-map.o \
            blk-exec.o blk-merge.o blk-softirq.o blk-timeout.o \
            blk-iopoll.o blk-lib.o blk-mq.o blk-mq-tag.o \
            blk-mq-sysfs.o blk-mq-cpu.o blk-mq-cpumap.o ioctl.o \
            genhd.o scsi_ioctl.o partition-generic.o partitions/

obj-$(CONFIG_BLK_DEV_BSG)   += bsg.o
obj-$(CONFIG_BLK_DEV_BSGLIB)    += bsg-lib.o
obj-$(CONFIG_BLK_CGROUP)    += blk-cgroup.o
obj-$(CONFIG_BLK_DEV_THROTTLING)    += blk-throttle.o
obj-$(CONFIG_IOSCHED_NOOP)  += noop-iosched.o
obj-$(CONFIG_IOSCHED_DEADLINE)  += deadline-iosched.o
obj-$(CONFIG_IOSCHED_CFQ)   += cfq-iosched.o

obj-$(CONFIG_BLOCK_COMPAT)  += compat_ioctl.o
obj-$(CONFIG_BLK_DEV_INTEGRITY) += blk-integrity.o
obj-$(CONFIG_BLK_CMDLINE_PARSER)    += cmdline-parser.o

以上编译选项在Kconfig,Kconfig.iosched文件中有详细的描述

例如deadline-iosched.c,noop-iosched.c,cfq-iosched.c相关文件是描述调度算法相关的

IO子系统的调度入口是
genhd.c:subsys_initcall(genhd_device_init);


 899 static int __init genhd_device_init(void)
 900 {
 901     int error;
 902
# 903 ,904 是低层设备驱动注册，注册后设备将在sysfs文件系统显示 (ls /sys/block/xvdb)
 903     block_class.dev_kobj = sysfs_dev_block_kobj;
 904     error = class_register(&block_class);
 905     if (unlikely(error))
 906         return error;
# 那么kobj_map_init这个调用是做什么用的(在drivers/base/map.c有定义)
 907     bdev_map = kobj_map_init(base_probe, &block_class_lock);
 908     blk_dev_init();
 909
 910     register_blkdev(BLOCK_EXT_MAJOR, "blkext");
 911
 912     /* create top-level block dir */
 913     if (!sysfs_deprecated)
 914         block_depr = kobject_create_and_add("block", NULL);
 915     return 0;
 916 }


136 struct kobj_map *kobj_map_init(kobj_probe_t *base_probe, struct mutex *lock)
137 {
# 创建kobj_map结构
138     struct kobj_map *p = kmalloc(sizeof(struct kobj_map), GFP_KERNEL);
139     struct probe *base = kzalloc(sizeof(*base), GFP_KERNEL);
140     int i;
141
142     if ((p == NULL) || (base == NULL)) {
143         kfree(p);
144         kfree(base);
145         return NULL;
146     }
147
148     base->dev = 1;
149     base->range = ~0;
150     base->get = base_probe;
151     for (i = 0; i < 255; i++)
152         p->probes[i] = base;
153     p->lock = lock;
154     return p;
155 }

