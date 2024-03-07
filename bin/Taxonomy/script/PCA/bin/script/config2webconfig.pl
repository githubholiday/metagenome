#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use List::Util qw(max min sum);
my $BEGIN_TIME=time();
my $version="1.0.0";
#######################################################################################

# ------------------------------------------------------------------
# GetOptions
# ------------------------------------------------------------------
my ($fIn,$fOut,$Report,$EmptyLine);
GetOptions(
				"help|?" =>\&USAGE,
				"o:s"=>\$fOut,
				"i:s"=>\$fIn,
				"r:s"=>\$Report,
				"e:s"=>\$EmptyLine,
				) or &USAGE;
&USAGE unless ($fIn and $fOut and $Report);
#######################################################################################
mkdir $fOut if (! -d $fOut);
$fOut=ABSOLUTE_DIR($fOut);
$EmptyLine ||="35";
#my $Project="$Bin/Project.csv";
#my $Backup="$Bin/gannt_linux.txt";
#######################################################################################
my $tempfile="$fOut/report.template";
my $conffile="$fOut/report.conf";
open (CON,">$conffile") or die $!;
print CON "PROJECT_NAME:$Report"."结题报告\n";
print CON "REPORT_DIR:$fOut\/result\n";
close CON;

open (IN,$fIn) or die $!;
open (OUT,">$tempfile") or die $!;
print OUT "#####Project_Info\n";
print OUT "Title:\$(PROJECT_NAME)\n";
print OUT "EmptyLine:$EmptyLine\n";
#print OUT "MainMenu:个性化分析结果\n";

while (<IN>) {
	chomp;
	next if (/^$/);
	my $line=$_;
	if ($line=~/^# /) {
		print OUT OneType($line)."\n";
	}elsif ($line=~/^## /) {
		print OUT OneType($line)."\n";
	}elsif ($line=~/^\! /) {
		print OUT Image($line)."\n";
	}elsif ($line=~/^\? /) {
		print OUT Table($line)."\n";
	}elsif ($line=~/^\& /) {
		print OUT Excel($line)."\n";	
	}elsif ($line=~/^\* /) {
		print OUT Note($line)."\n";	
	}else{
		print OUT Text($line)."\n";	
	}
}
print OUT "First2Menu:3\n";
close IN;
close OUT;
#######################################################################################
print STDOUT "\nDone. Total elapsed time : ",time()-$BEGIN_TIME,"s\n";
#######################################################################################

# ------------------------------------------------------------------
# sub function
# ------------------------------------------------------------------
sub OneType{	#一级标题变更,一级标题：#
	my $line=shift;
	$line=~s/^# //;
	my $content="MainMenu:$line";
	return $content;
}
# ------------------------------------------------------------------
sub TwoType{	#二级标题变更,备用,二级标题：##
	my $line=shift;
	$line=~s/^## //;
	my $content="SubMenu:$line";
	return $content;
}
# ------------------------------------------------------------------
sub Image{	#插入图片,插入图片:! []()
	my $line=shift;
	$line=~s/^\! //;
	my ($tital,$address)=split/\]\(/,$line;
	$tital=~s/^\[//;
	$address=~s/\)$//;
	my $content="Image:$address,,1,$tital;";
	return $content;
}
# ------------------------------------------------------------------
sub Excel{	#下载，下载地址：& []()
	my $line=shift;
	$line=~s/^\& //;
	my ($tital,$address)=split/\]\(/,$line;
	$tital=~s/^\[//;
	$address=~s/\)$//;
	my $content="Excel:$address,,,$tital\：;";
	return $content;
	
}
# ------------------------------------------------------------------
sub Note{	#插入表注或图注，图注或标注：* 图注
	my $line=shift;
	$line=~s/^\* //;
	my $content="PRE:,,57;\n$line\nPRE";
	return $content;	
}
# ------------------------------------------------------------------
sub Table{	#插入表格,插入表格：? []()
	my $line=shift;
	$line=~s/^\? //;
	my ($tital,$address)=split/\]\(/,$line;
	$tital=~s/^\[//;
	$address=~s/\)$//;
	my $content="Table:$address,,,$tital;";
	return $content;
}
# ------------------------------------------------------------------
sub Text{	#插入正文
	my $line=shift;
	my $content="P:#,;#$line";
	return $content;	
}
# ------------------------------------------------------------------
sub Myprint
{                #千分位标记
	$_=shift;
	$_ =reverse $_;
	$_=~s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return reverse($_);
}
# ------------------------------------------------------------------
sub DESK{
	my $desk=shift;
	if ($desk =~/K/i) {
		$desk=~s/k//ig;
		$desk*=1024;
		return $desk;
	}elsif ($desk =~/M/i) {
		$desk=~s/M//ig;
		$desk*=1024*1024;
		return $desk;
	}elsif ($desk =~/G/i) {
		$desk=~s/G//ig;
		$desk*=1024*1024*1024;
		return $desk;
	}elsif ($desk =~/T/i) {
		$desk=~s/T//ig;
		$desk*=1024*1024*1024*1024;
		return $desk;
	}else{
		return $desk;
	}
}
# ------------------------------------------------------------------
sub ABSOLUTE_DIR{ #$pavfile=&ABSOLUTE_DIR($pavfile);
	my $cur_dir=`pwd`;chomp($cur_dir);
	my ($in)=@_;
	my $return="";
	if(-f $in){
		my $dir=dirname($in);
		my $file=basename($in);
		chdir $dir;$dir=`pwd`;chomp $dir;
		$return="$dir/$file";
	}elsif(-d $in){
		chdir $in;$return=`pwd`;chomp $return;
	}else{
		warn "Warning just for file and dir\n";
		exit;
	}
	chdir $cur_dir;
	return $return;
}
# ------------------------------------------------------------------
sub GetTime {
	my ($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdst)=localtime(time());
	return sprintf("%4d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $day, $hour, $min, $sec);
}
# ------------------------------------------------------------------
sub USAGE {#
	my $usage=<<"USAGE";
Program:
Version: $version
Contact:Su Yalei <yaleisu\@annoroad.com.cn> 
Description:
Usage:
  Options:
  -i <file>   输入配置文件
  -o <dir>    输出目录
  -r <parameter>	输入报告名称    
  -e <int>		输入留白，默认35
  -h         Help

USAGE
	print $usage;
	exit;
}
