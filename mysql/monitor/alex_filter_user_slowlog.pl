#!/usr/bin/perl 
#===============================================================================
#
#         FILE: alex_filter_user_slowlog.pl
#
#        USAGE: ./alex_filter_user_slowlog.pl  
#
#  DESCRIPTION: use for filter user content from MySQL slowlog
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alex
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/22/15 07:35:28
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my @filter = qw/ panls sup /;

my $flag = 0;
my $newline = 0;
my $hold ;
my $switch;

sub usage(){
        print " Usage : func /path/to/slowlog [on|off] \n";
        print "         on  : show the filter content .\n";
        print "         off : do not show the filter content .\n";
        exit;
}
if(!defined($ARGV[1])){usage};
if($ARGV[1] eq "off"){
        $switch = 1;
}elsif($ARGV[1] eq "on"){
        $switch = 0;
}else{
        usage;
}

open(FILE,"<","$ARGV[0]") || die "can not open file: $!\n";
while(<FILE>){
        if(/^# Time:/){
                $newline = 1;
                $flag = 0;
                $hold = $_;
                next;
        }
        if($newline == 1){
                $newline = 0;
                if(/(.*)\[\1\]/){
                        if($switch == 0){
                                $flag = 1 if grep /$1/, @filter;
                        }else{
                                $flag = 1 unless  grep /$1/, @filter;
                        }
                        print $hold unless $flag == 0;
                }
        }
        print if $flag;
}

close(FILE);
