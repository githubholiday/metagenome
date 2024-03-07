#!/usr/bin/perl
my $usage = qq{
Usage:perl $0 <infile> <col> <outfile>
	infile  -- input file
	col     -- col number of class
	outfile -- result file 
};
die($usage)unless(@ARGV==3);
my $file1 = $ARGV[0];
my $num = $ARGV[1];
my $file2 = $ARGV[2];
open(IN1,$file1)||die"$file1\t$!\n";
my $head = <IN1>;
chomp $head;
my @lab;
my %line;
my $n=0;
my %hash;
while(<IN1>){
	chomp;
	my @col = split(/\t/,$_);
	$hash{$n} = $col[$num-1];
	$line{$n} = $_;
	push @lab, $col[$num-1];
	$n++;
}
close IN1;

my %hash1;
@lab = grep{++$hash1{$_}<2} @lab;
@lab = sort @lab;
my %class;
for(my $i=0;$i<=$#lab;$i++){
	$class{$lab[$i]} = chr($i+65);
}

open(OUT1,">$file2");
print OUT1"Class\t$head\n";
foreach my $key( sort {$a<=>$b} keys %hash){
    print OUT1"$class{$hash{$key}}\t$line{$key}\n";
}
close OUT1;
