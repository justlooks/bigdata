#!/usr/bin/perl -w


# step 1 : use sql get all column name which is not default collate
# select TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME,COLUMN_TYPE from columns where CHARACTER_SET_NAME='utf8' and  column_type like '%char%' and table_schema not in ('information_schema','mysql','performance_schema') and COLLATION_NAME <>'utf8_general_ci'

# step 2 : use mysqldump get DDL from mysql
# mysqldump -uroot -ppass -S/data/mysql/mysql.sock --skip-triggers --no-data --no-create-db --skip-opt --all-databases > stable.sql

# step 3 : get all schema list which need op
# for i in `cat aa`;do perl drop_collact.pl $i;done

use strict;

my $schema = shift;

my $file = '/root/stable.list';
my $ddl = '/root/stable.sql';
my $outre = qr/^$schema\s(\w+)\s(\w+)$/;

open(FILE,"<",$file) or die "can not open $file: $!";
while(<FILE>){
    chomp($_);
    if(m/^$schema\s/){
        my ($tab,$col) = $_ =~ /$outre/;
        #print "i get $tab >> $col\n";
        open(DDL,"<",$ddl) or die "can not open $file: $!";
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
		s/(?<=[^;])$/;/;
                #print;
                if(m/COLLATE/){
                    s/CHARACTER SET utf8 COLLATE utf8_bin//;
                    s/COLLATE utf8_bin//;
                }
                print "ALTER TABLE $schema.$tab MODIFY COLUMN".$_;
            }
        }
        close(DDL);
    }
}
close(FILE);