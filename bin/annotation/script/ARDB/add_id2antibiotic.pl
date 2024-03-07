#!/usr/bin/env perl
use FindBin qw($Bin);
my %hash;
my $id2antibiotic||="$Bin/id2antibiotic.xls";
open I,$id2antibiotic or die;
while(<I>){
	chomp;
	my @id=split(/\t/,$_);
	$id[2]=~s/\;$//;
	$hash{$id[0]}=$id[2];
}
close I;

open II,$ARGV[0] or die;
my $head=<II>;
chop $head;
open OU,">$ARGV[1]" or die;
print OU "$head\tAntibiotic\n";
while(<II>){
	chomp;
	my @tab=split(/\t/,$_);
	$_=~s/\.$//;
	print OU "$_\t$hash{$tab[1]}\n";
}
close II;
close OU;
