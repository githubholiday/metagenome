#! /usr/bin/perl -w
use strict;

sub usage {
    print STDERR <<USAGE;

Usage:  choose_blast_m8 -i <blast_list_lile> -o <file_for_chosen_blast_results> <options>

            -i  <C>: input list contain blast m8 results
            -o  <C>: output file of chosen results
            options
            -b  <B>: Y or N, choose the BestHit.       Default Y
            -d  <N>: identity threshold.               Default 0
            -m  <N>: match length threshold.           Default 0
            -e  <N>: e_value threshold.                Default 1e-5
            -h     : output this help message.
USAGE
}

use Getopt::Std;
getopts('hi:o:d:m:e:b:');
our($opt_h,$opt_i,$opt_o,$opt_d,$opt_m,$opt_e,$opt_s,$opt_b);

if($opt_h){
    &usage;
    exit;
}
unless($opt_i && $opt_o){
    &usage;
    exit;
}

open BLAST,$opt_i or die "$opt_i $!\n";
open OUT,">$opt_o" or die "$opt_o $!\n";

$opt_d = 0 unless(defined($opt_d));
$opt_e = 1e-5 unless(defined($opt_e));
$opt_m = 0 unless((defined$opt_m));
$opt_b = "Y" unless((defined$opt_b));

my @a = ();
my %check = ();
my ($filename,$score);
while(<BLAST>) {
    chomp;
    $filename = $_;
    open TEMP,$filename or die "$filename $!\n";
    while(<TEMP>) {
        chomp;
        @a = split(/\t/);
        die "Not 12 or 13 columns, please Check Your blast m8 result!\n" if(@a != 12 and @a != 13);
        if(exists $check{$a[0]} and ($opt_b eq "Y")){
            next;
        }
        if($a[2] < $opt_d || $a[10] > $opt_e || $a[3] < $opt_m){
            next;
        }
        $check{$a[0]} = 1;
        print OUT "$_\n";
    }
    close(TEMP);
}
close(BLAST);



