#!/usr/bin/perl -w
#
# check each datanode directory ,ensure used disk is below warning threhold,also check the hdfs log directory ,see if it large then 10G
#
#############################

use strict;

# check datanode disk volume
my $STATE_OK=0;
my $STATE_WARNING=1;
my $STATE_CRITICAL=2;
my $STATE_UNKNOWN=3;

my $warn = 80;
my $crit = 88;
my $log_threhold = 5;
my $flag = $STATE_OK;
my $msg = "";

my $cfg_file = "/etc/hadoop/conf/hdfs-site.xml";
my $datadir_option = "dfs.datanode.data.dir";
my $log_dir = "/var/log/hadoop-hdfs";


my $content = `sed -n '/'$datadir_option'/{n;s/^[ \t]\\\+//;s/<[/]\\\?value>//g;p}' $cfg_file`;


my @dirs = split(/,/,$content);

for(my $i=0;$i<=$#dirs;$i++){
        if($dirs[$i] =~ /^file:\/\/(\/[^\/]+\/[^\/]+).*$/){
                my $getstr = $1;
                $getstr =~ s#\/#\\/#g;
                my $utils = `df |awk '/$getstr/\{print \$(NF-1)\}' |grep -oP '[0-9]+'`;
                chomp($utils);
                if(($utils >= $warn) && ($utils < $crit)){
                        $flag = $STATE_WARNING if $flag < $STATE_WARNING;
                        $msg .= "dir $getstr reach waring threhold now value is $utils | ";
                }elsif( $utils >= $crit ){
                        $flag = $STATE_CRITICAL if $flag < $STATE_CRITICAL;
                        $msg .= "dir $getstr reach critical threhold now value is $utils | ";

                }else{
                        $flag = $STATE_OK if $flag < $STATE_OK;
                        $msg .= "dir $getstr $utils check pass | ";
                }
        }

}

my $log_size = `du -s $log_dir | grep -oP '[0-9.]+'`;
chomp($log_size);
my $g_logsize = $log_size/1024/1024/0124;
my $judge = `echo "$g_logsize > $log_threhold" | bc`;
if($judge == 1){
        $flag = $STATE_CRITICAL if $flag < $STATE_CRITICAL;
        $msg .= "the log dir $log_dir large than $log_threhold G";
}else{
        $flag = $STATE_OK if $flag < $STATE_OK;
        $msg .= "log dir $log_dir is $g_logsize G";
}


print $msg;
exit $flag;

