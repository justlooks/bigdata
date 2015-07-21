#!/usr/bin/perl 
#===============================================================================
#
#         FILE: alex_get_slow_bytime.pl
#
#        USAGE: ./alex_get_slow_bytime.pl  '2015-01-01 00:00:00' '2016-01-01 23:59:59' /path/to/slowlog
#
#  DESCRIPTION: use to get content of mysql slowlog by time
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Alex
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/21/15 07:49:35
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

my ($sy,$sm,$sd,$sh,$smin,$ssec) = $ARGV[0] =~ /(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})/;
my ($ey,$em,$ed,$eh,$emin,$esec) = $ARGV[1] =~ /(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})/;

my $starttm = timelocal($ssec,$smin,$sh,$sd,$sm-1,$sy-1900);
my $endtm = timelocal($esec,$emin,$eh,$ed,$em-1,$ey-1900);
my $flag = 0;

open(FILE,"<","$ARGV[2]") || die "can not open file: $!\n";
while(<FILE>){
        if(/SET timestamp=(\d{10})/){
                if($1 >= $starttm && $1 <= $endtm){
                        $flag = 1;
                }else{
                        $flag = 0;
                }

        }
        if($flag == 1){
                print;
        }
}

close(FILE);
