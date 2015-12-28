#!/usr/bin/perl -w

# step 0 : alter table collate to 
# select concat('ALTER TABLE ',TABLE_SCHEMA,'.',TABLE_NAME,' COLLATE=utf8_general_ci;')  from tables where TABLE_COLLATION='utf8_bin' and TABLE_SCHEMA not in('mysql','information_schema','performance_schema');

# step 1 : use sql get all column name which is not default collate
# select TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME,COLUMN_TYPE from columns where CHARACTER_SET_NAME='utf8' and (column_type like '%char%' or column_type like '%text%') and table_schema not in ('information_schema','mysql','performance_schema') and COLLATION_NAME <>'utf8_general_ci'

# step 2 : use mysqldump get DDL from mysql ( do not use --skip-opt option ,it will drop auto_increment in DDL )
# mysqldump -uroot -ppass -S/data/mysql/mysql.sock --skip-triggers --no-data --no-create-db --all-databases > stable.sql


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
