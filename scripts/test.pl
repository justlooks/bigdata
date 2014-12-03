#!/usr/bin/perl -w 

use strict;

my $curr = 1;
my $count = 2;
my $skip = 0;
my $file = "/proc/diskstats";

my @cal_data = ();

sub move_old{
	my $curr = shift;
	my $old = $curr - 1;
	$cal_data[$old] = $cal_data[$curr];

}

sub read_new{
	my $idx = shift;	
#	$cal_data[$idx]{'test'} = 'xxx';
	open(FILE,"<",$file) || die "Can not open $file: $!";
	while(<FILE>){
		chomp;
		if(m/sdf/){
			#print;
			(undef,undef,undef,$cal_data[$idx]{'rd_ios'},$cal_data[$idx]{'rd_merges'},$cal_data[$idx]{'rd_sec'},$cal_data[$idx]{'rd_ticks'},$cal_data[$idx]{'wr_ios'},$cal_data[$idx]{'wr_merges'},$cal_data[$idx]{'wr_sec'},$cal_data[$idx]{'wr_ticks'},undef,undef,undef) = split;
			print $cal_data[$idx]{'wr_sec'}; 
		}
	}
	close FILE;

}

# put data to array[1],move old data to array[0]
sub read_data{
	my $curr = shift;
	move_old($curr);
	read_new($curr);
}

sub caculate_data{
	my $curr = shift;
	my $old = $curr - 1;
	print $cal_data[$curr]{'rd_ios'};
	print $cal_data[$old]{'rd_ios'};
	print $cal_data[$curr]{'rd_ticks'};
	print $cal_data[$old]{'rd_ticks'};

	
	return ($cal_data[$curr]{'rd_ios'} - $cal_data[$old]{'rd_ios'})?($cal_data[$curr]{'rd_ticks'}-$cal_data[$curr]{'rd_ticks'})/($cal_data[$curr]{'rd_ios'} - $cal_data[$old]{'rd_ios'}):0.0;

}

#$cal_data[$curr]{'test'} = 'demo';
#read_data($curr);

do {
	read_data($curr);
	print "out round $count\n";
	if(!$skip){

		print "in round $count\n";
#		caculate_data($curr);
		if($count>0){
			$count--;
			print "inin round $count\n";
		}

	}else{
		$skip = 0;
	}


print "i get $count\n";
$count--;
} while($count>0);

