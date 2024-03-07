#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
my $faminfo="$Bin/FamInfo.txt";
my $in = shift;
my $out = shift;
my $xls = shift;
my %type=(
	"PL"=>"PL:Polysaccharide Lyases",
	"GT"=>"GT:GlycosylTransferases",
	"GH"=>"GH:Glycoside Hydrolases",
	"CE"=>"CE:Carbohydrate Esterases",
	"CBM"=>"CBM:Carbohydrate-Binding Modules",
	"AA"=>"AA:Auxiliay Activities",
	"SLH"=>"SLH:Surface Layer Homology",
);
my %e;
open F,$faminfo or die;
while(<F>){
    chomp;
    my @ll = split(/\t/);
    $e{$ll[0]}=$ll[-1];
}
close F;

my %num;
my %count;
open IN,"$in" or die;
open XLS,">$xls";
print XLS "Gene_ID\tSubject_ID\tAnnotation\n";
while(<IN>){
	chomp;
	next if /Gene_ID/;
	next unless /\S+/;
	my @l = split;
	$l[0] =~ /^([A-Z]+)/;
	my $x=$1;
	$count{$l[0]}++;
	my $m=$l[0];
	$m=~s/.hmm//;
	$e{$m} = "--" unless ($e{$m});
	if($count{$l[0]}==1){
	print XLS "$l[2]\t$l[0]\t$e{$m}\n";
	$num{$x} ++;
	}
}
close IN;
open OUT ,">$out" or die;
foreach my $k (sort {$b cmp $a} keys %num){
	print OUT "$type{$k}\t$num{$k}\n" if ( exists $type{$k}); 
}
close OUT;
close XLS;
