#!/usr/bin/perl -w

# step 1 : use mysqldump dump single schema ddl
# mysqldump -uroot -ppass -h127.0.0.1 --skip-triggers --no-data --no-create-db --skip-opt single_schema > /tmp/saint.sql ( do not use skip-opt option,it will drop auto_increament in DDL )

# step 2 : get column name and column comment into /tmp/my.pl
# format as "table_name column_name 'column_comment'"
# select concat(TABLE_NAME," ",COLUMN_NAME," '",COLUMN_COMMENT,"'") from columns where TABLE_SCHEMA='saint';

use strict;

my $file = '/tmp/my.sql';
my $ddl = '/tmp/saint.sql';
open(FILE,"<",$file) or die "can not open $file: $!";
while(<FILE>){
        chomp($_);
        open(DDL,"<",$ddl) or die "can not open $file: $!";
        my ($tab,$col,$comment) = $_ =~ /(\w+)\s(\w+)\s(.*)$/;
        my $pflag = 0;
        my $re = qr/^CREATE TABLE `$tab`/;
        while(<DDL>){
                if(m/$re/){
                        $pflag = 1;
                }
                if(m/^\/\*!/){
                        $pflag = 0;
                }
                if($pflag && m/^\s+`$col` /){
                        s/,$/;/;
                        if(m/COMMENT/){
                                s/'.*'/$comment/;
                        }else{
                                s/;$/ COMMENT $comment;/;
                        }
                        print "ALTER TABLE $tab MODIFY COLUMN".$_;
                }
        }
        close(DDL);
}
close(FILE);
