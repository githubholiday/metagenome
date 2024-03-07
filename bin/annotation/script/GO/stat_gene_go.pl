#!/usr/bin/perl
use strict;
my $in = shift;
my %go;
open IN,"$in" or die;
<IN>;
while(<IN>){
	chomp;
	my @l = split (/\t/,$_);
	next unless ($l[5] =~ /GO/);
	my @m = split (/;/,$l[5]);
	push @{$go{$l[0]}},@m;
}
close IN;
print "Gene_ID\tAnnotation\n";
foreach my $k (keys %go){
	my $tmp = join "\t",@{$go{$k}};
	print "$k\t$tmp\n";
}
