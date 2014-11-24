#!/usr/bin/perl -w

use strict;
use DBI;
use POSIX;
use File::Path qw(make_path);
use Net::SCP qw(scp);
use Net::SMTP;
#use MIME::Lite;

#create user 'bak'@'192.168.26.171' identified by 'bak';
#grant all on *.* to 'bak'@'192.168.26.171';

my %dbs_info = (
                                 'ch171_11db' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.26.171', 'port' => 3370, 'policy' => 'every day', 'ignoretab' => 'no' },
                                 'ch171_10db' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.26.171', 'port' => 3371, 'policy' => 'every day', 'ignoretab' => 'no' },
                                 'ch171_9db' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.26.171', 'port' => 3373, 'policy' => 'every day', 'ignoretab' => 'yes' },
                                 'ch171_8db' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.26.171', 'port' => 3372, 'policy' => 'every day', 'ignoretab' => 'no' },
#                                 'ar18_tst_4' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.10.18', 'port' => 3310, 'policy' => 'once a week 6' },
#                                 'ar18_prd_3' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.10.18', 'port' => 3370, 'policy' => 'every day' },
#                                 'ar18_demo_5' => { 'user' => 'bak', 'pd'  => 'bak', 'host' => '192.168.10.18', 'port' => 3350, 'policy' => 'once a month 10' },
                           );

my $basedir = "/data/mysqlbackup/";
my $filterfile = "filter.list";
my $current = strftime("%Y%m%d",localtime);
my (undef,undef,undef,$mday,undef,undef,$wday,undef,undef) = localtime(time());
my @ignore_db = qw/ information_schema performance_schema mysql dbadb /;


# send report to email
sub send_msg {
        my $ref_content = shift;
        my $mailsrv = '192.168.10.66';
        my $fromaddr = 'dbteam@mediaadx.com';
        #my $ccaddr = 'alex_kim@mediaadx.com';
        my $toaddr = 'alex_kim@mediaadx.com';

#       my $smtp = Net::SMTP->new($mailsrv,Hello=>"mediaadx.com",Debug=>1);

        my $smtp = Net::SMTP->new($mailsrv);
        die "can not connect mail server" unless $smtp;
        if(!$smtp->auth('dbteam@mediaadx.com','dbteam')){
                print "auth failed,check it again $!\n";
        }

        $smtp->mail($fromaddr);
        $smtp->to($toaddr);
        $smtp->data();
        $smtp->datasend("From:$fromaddr\n");
        $smtp->datasend("To:$toaddr\n");
        $smtp->datasend("Subject: backup report\n");
        $smtp->datasend("Content-Type: text/html\n");
        $smtp->datasend("\n");
        my $TITLE= <<'END_TAG';
        <tr>
        <td>Start time</td>
        <td>End time</td>
        <td>Elapsed(second)</td>
        <td>Instance</td>
        <td>Schema</td>
        <td>Status</td>
        </tr>
END_TAG

        $smtp->datasend('<html><body><table border="1" style="color:chartreuse" bgcolor="#000000">');
        $smtp->datasend("$TITLE\n");

        for my $i (0..$#$ref_content){
                $smtp->datasend("</tr>");
                for my $j (0..$#{$ref_content->[$i]}){
                        if($ref_content->[$i][$j] =~ m/\d{10}/){
                                $ref_content->[$i][$j] = strftime "%Y-%m-%d %H:%M:%S",localtime($ref_content->[$i][$j]);
                        }
                        $smtp->datasend("<td>$ref_content->[$i][$j]</td>");
                }
                $smtp->datasend("</tr>");
                $smtp->datasend("\n");
        }
        $smtp->datasend('</table></body></html>');
        $smtp->dataend();
        $smtp->quit();
}

sub get_dbh {
        my $ref = shift;
        return DBI->connect("dbi:mysql:dbadb:".$$ref{'host'}.":".$$ref{'port'},$$ref{'user'},$$ref{'pd'}) or die("can not connect db");
}

sub get_schemas {
        my $dbh = shift;
        my $sql = "SHOW SCHEMAS";
        my $schema_ref = $dbh->selectall_arrayref($sql);
        my @schemas;
        foreach my $i (@$schema_ref){
                push @schemas,$$i[0];
        }
        return \@schemas;
}

sub do_dump {
        my ($path,$db,$db_info,$ignore_tabs) = @_;
        my $igoption = "";
        for(my $i=0;$i<=$#$ignore_tabs;$i++){
                $igoption .= "--ignore-table=${db}.${$ignore_tabs}[$i] ";
        }
   #     my $re = `( mysqldump -h ${$db_info}{'host'} -u ${$db_info}{'user'} -P ${$db_info}{'port'} -p${$db_info}{'pd'} $db | gzip -c - > $path/${db}_${current}.sql.gz ) 2>&1`;
# take care! when you have DDL operation during mysqldump ,--single-transaction option will cause the table which DDL on lost data see http://www.percona.com/blog/2012/03/23/best-kept-mysqldump-secret/  ,you can use --lock-all-tables option to disallow DDL during mysqldump running
        my $re = `( mysqldump --single-transaction -h ${$db_info}{'host'} -u ${$db_info}{'user'} -P ${$db_info}{'port'} -p${$db_info}{'pd'} $igoption $db | gzip -c - > $path/${db}.sql.gz ) 2>&1`;
        print "mysqldump -h ${$db_info}{'host'} -u ${$db_info}{'user'} -P ${$db_info}{'port'} -p${$db_info}{'pd'} $igoption $db | gzip -c - > $path/${db}.sql.gz\n";
        if( $? == 0 ){
                print "dump ok\n";
                return "success";
        }else{
                print "dump failed\n";
                return $re;
        }
}

sub cp_report {
#parse result to file
        my $ref_content = shift;
        my $file = "/tmp/result.html";
        open(FILE,"+>",$file) || die "Can not open $file: $!";

        my $TITLE= <<'END_TAG';
        <tr>
        <td>Start time</td>
        <td>End time</td>
        <td>Elapsed(second)</td>
        <td>Instance</td>
        <td>Schema</td>
        <td>Status</td>
        </tr>
END_TAG

        print FILE '<html><body><table border="1" style="color:chartreuse" bgcolor="#000000">';
        print FILE "$TITLE\n";

        for my $i (0..$#$ref_content){
                print FILE "</tr>";
                for my $j (0..$#{$ref_content->[$i]}){
                        if($ref_content->[$i][$j] =~ m/\d{10}/){
                                $ref_content->[$i][$j] = strftime "%Y-%m-%d %H:%M:%S",localtime($ref_content->[$i][$j]);
                        }
                        print FILE "<td>$ref_content->[$i][$j]</td>";
                }
                print FILE "</tr>";
                print FILE "\n";
        }
        print FILE '</table></body></html>';

        close(FILE);

}

#cp_report();

my @result = ();

for my $name (keys %dbs_info){
        print "with policy ". $dbs_info{$name}{'policy'}."  and $wday : $mday\n";
        my $do_flag = 0;
        if( $dbs_info{$name}{'policy'} =~ m/once a week (\d+)/  ){
                $do_flag = 1 unless $1 != $wday;
        }elsif( $dbs_info{$name}{'policy'} =~ m/once a month (\d+)/ ){
                $do_flag = 1 unless $1 != $mday;
        }elsif( $dbs_info{$name}{'policy'} =~ m/every day/ ){
                $do_flag = 1;
        }else {
                $do_flag = 0;
        }
        if($do_flag == 1){
                print "$name Backup start...\n";
                my $mybasedir;
                if( $name =~ m/^ch.*/ ){
                        $mybasedir = $basedir . 'CH_backup';
                }elsif( $name =~ m/^ar.*/ ){
                        $mybasedir = $basedir . 'AR_backup';
                }
                my $path = "${mybasedir}/${name}/${current}";
                unless (-e $path) {
                        make_path($path) or die $!;
                }
        # read the ignore tables info
                my %ignoretab = ();
                if( $dbs_info{$name}{'ignoretab'} eq "yes" ){
                        print "read filter file -> ${mybasedir}/${name}/${filterfile}\n";
                        open FILE,"<","${mybasedir}/${name}/${filterfile}" or die;
                        while(<FILE>){
                                chomp;
                                my ($key,$value)=split('\.',$_);
                                push @{$ignoretab{$key}},$value;
                        }
                        close FILE;
                }
                my $dbh = get_dbh($dbs_info{$name});
                my $dbs = get_schemas($dbh);
                foreach my $db (@$dbs){
                        if( grep { $_ eq $db } @ignore_db ){
                                print "i ignore ".$db."\n";
                        }else{
                                my $start = time();
                                #my $re = do_dump($name,$db,$dbs_info{$name});
                                my $re = do_dump($path,$db,$dbs_info{$name},$ignoretab{$db});
                                my $end = time();
                                push @result,[$start,$end,$end-$start,$name,$db,$re];
                        }
                }
                $dbh->disconnect;
        }else{
                print "i skip $name\n";
        }
        print "done\n";
}

# send report mail after backup action happened
if( @result ){
#        send_msg(\@result);
                cp_report(\@result);
}

