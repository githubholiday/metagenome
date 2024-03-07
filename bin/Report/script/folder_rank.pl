#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin $Script);
use File::Basename;
use Getopt::Long;
use Data::Dumper;

my $usage = << "USAGE";
    ***********************************************************************************
     Source: Annoroad
     Author: Menghao
     Date:   2017年 06月 08日 星期四 14:43:57 CST
    ***********************************************************************************

    Description: Rank

    Usage: perl $Script -i <indir>

USAGE

#GetOptions------------------------------------------------

my ( $indir, %jobs1, %jobs2 );
GetOptions(
    "i|indir=s"   => \$indir,
);
die $usage if ( !defined $indir );

#Mainroutine-----------------------------------------------

my @all_jobs = ("QC","Host","kraken2","kraken2_count","Assembly","Binning","Gene","Annotation","Diversity");

#判断文件-------------------------------------------------
#考虑到多次拷贝造成俄罗斯套娃的闹剧
#读取upload文件夹下的各个子文件夹的名称
my @jobs1 = `ls $indir`;
chomp @jobs1;
foreach my $job (@jobs1) {
	$jobs1{$job}++;
}

#判读各个子文件夹的是否存在于总的joblist中，如果不存在，判断是否已经重命名了（格式：/^[0-9]*_(\w+)$/）
foreach my $job (keys %jobs1) {
    if (grep {$job eq $_} @all_jobs) {
        next;
    }
    else {
        if ( $job =~ /^[0-9]*_(\w+)$/) {
            my $name = $1;
            #my $cmd = "mv $indir/$job $indir/$name";          #BUG：移动而非重命名
            if (-e "$indir/$name") {
                my $cmd = "rm -r $indir/$job";
                &mysystem($cmd);
            }
        }
    }
}


#重命名----------------------------------------------------

#再次读取upload文件夹下的各个子文件夹的名称
my @jobs2 = `ls $indir`;
chomp @jobs2;
foreach my $job (@jobs2) {
    $jobs2{$job}++;
}

#按照总的joblist的分析条目顺序进行排序重命名
my $n = 1;
my $num;
foreach my $all_job (@all_jobs) {
    if ( $n < 10 ) {
        ( $num = $n ) =~ s/(\d){1}/0$1/;        #N小于10，改成0N
    }
    else {
        $num = $n;
    }
	if (exists $jobs2{$all_job}) {
		my $cmd = "mv $indir/$all_job $indir/$num"."_$all_job";
		&mysystem($cmd);
		$n++;
	}
}

#Sub-------------------------------------------------------

sub mysystem {
    my $cmd=shift;
    if(system($cmd)!=0){
		print STDERR "系统调用(system)出错:$cmd\n";
		die;
    }
    else{
        print STDOUT "系统调用(system)成功:$cmd\n";
     }
}
