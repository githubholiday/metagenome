#!/usr/bin/env perl
use strict;
use warnings;
use diagnostics;
use Getopt::Long;
use File::Basename;

my (%opts);
GetOptions(\%opts,"input:s","min:s","max:s","help");
my @opts=keys %opts;

sub help{
        print STDERR <<USEAGE;
        perl $0 -input <fasta.fa> -min <min_length> -max <max_length> 

        		-input		input File
        		-min 		min_length [defualt 0]
        		-max 		max_length [defualt 很大]
     
USEAGE
}

$opts{min} ||= '0';
$opts{max} ||= '9999999999';
unless($opts{input}){
        help;
        exit;
}

my $name=basename $opts{input};
my ($ok,$min,$max)=(0,0,0);
print '-------------------------------------------'."\n";
print "The following files will be processed:\n";
print "$name\n";
print "Minimum seuquence length: $opts{min} \n";
print "Maximum seuquence length: $opts{max} \n";
print "Processing $name \n";
open IN,$opts{input} or die;
print "...\r";
open OK,">Sequences_OK.fa" or die;
open MX,">Sequences_Long.fa" or die;
open MN,">Sequences_Short.fa" or die;
$/='>';
while(<IN>){
print "...\r";
	chomp;
	if($_ ne ''){
		my ($id,$seq)=(split(/\n/,$_,2))[0,1];
		$seq=~s/\s//g;
		my $length=length $seq;
		$seq =~ s/(\S{100})/$1\n/g;
		if($length < $opts{min}){
			$min++;
			print MN ">$id\n$seq\n";
		}elsif($length > $opts{max}){
			$max++;
			print MX ">$id\n$seq\n";
		}else{
			$ok++;
			print OK ">$id\n$seq\n";
		}

	}
}
close IN;
close OK;
close MN;
close MX;
print "Done. \n";
print "Sequences with proper size:	$ok\n";
print "Sequences too long:		$max\n";
print "Sequences too short:		$min\n";
print '-------------------------------------------'."\n";
