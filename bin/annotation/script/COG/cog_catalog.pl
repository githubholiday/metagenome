#!/usr/bin/env perl
# edit by liusanyang 2015-09-06;
use strict;
use FindBin qw($Bin);

die "usage:[in cog anno file][out cog catalog][out 25 catalog]\n" if(0 == @ARGV);

open IN,"$Bin/fun.txt"or die;
my %fun = ();
my %big = ();
my $tmp = "";

while(my $line = <IN>){
	chomp $line;
	if($line =~ /^$/){
		next;
	}
	if($line =~ /^[^\[]*$/){
		$tmp = $line;
		next;
	}
	if($line =~ /\[(\S+)\]\s*(.*)/){
		$big{$1} = $tmp;
		$fun{$1} = $2;
	}
}
close IN;

my %check = ();
my %all_cog = ();
my %all_25 = ();

open IN,"$ARGV[0]"or die;
<IN>;
while(my $line = <IN>){
	chomp $line;
#	next if($line=~/^gene_id/);
	my ($sub,$cog,$class) = (split(/\t/,$line))[0,2,4];
	my @items = split(//,$class);
	if(!exists $check{"$sub,$cog"}){
		foreach my $item (@items){
			$check{"$sub,$cog"} = 1;
			$all_cog{$cog} .= "$sub;";
			$all_25{$item} .= "$sub;";
		}
	}
}
close IN;

open OUT,">$ARGV[1]"or die;
print OUT "cog class\tnumber\tgene\n";
foreach my $key (sort keys %all_cog){
	my @a = split(/;/,$all_cog{$key});
	my $con = @a;
	print OUT "$key\t$con\t$all_cog{$key}\n";
}
close OUT;

open OUT,">$ARGV[2]"or die;
print OUT "function code\tfunction\tnumber\tgene\n";
foreach my $key (sort keys %all_25){
	my @a = split(/;/,$all_25{$key});
	my $con = @a;
	print OUT "$key\t$fun{$key}\t$con\t$all_25{$key}\n";
}
close OUT;

open OUT,">$ARGV[3]"or die;
print OUT "domain\tfunction code\tfunction\tnumber\n";
foreach my $key (sort keys %all_25){
	my @a = split(/;/,$all_25{$key});
	my $con = @a;
	print OUT "$big{$key}\t$key\t$fun{$key}\t$con\n";
}
close OUT;



