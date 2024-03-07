#!/usr/bin/perl

=head1 Name

  cog_parser.pl  --  extract the cog number.

=head1 Description

  This program is designed for extracting the cog number after blast, and cacualte the gene numbers in
  each COG classes.

=head1 Version

  Author: sunjuan, sunjuan@genomics.org.cn
  Author: fanwei, fanw@genomics.org.cn
  Version: 2.0,  Date: 2008-5-21

=head1 Usage
	
  perl cog_parser.pl <blast_tab>
  --verbose   output verbose information to screen  
  --help      output help information to screen  

=head1 Exmple

  perl cog_parser.pl PLASMID.fasta.ori.glimmer3.pep.blast.tab

=cut

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname); 
use Data::Dumper;

my $whog_file ="$Bin/whog";
my $fun_file = "$Bin/fun.txt"; 

my ($Verbose,$Help);
GetOptions(
        "verbose"=>\$Verbose,
        "help"=>\$Help
);
die `pod2text $0` if (@ARGV == 0 || $Help);

my $blast_tab = shift;
#my $blast_tab_base = basename($blast_tab);

my %config;


my %Gene_COG; ##store gene and cog relations
my %Class_Anno; ##store COG class and description relations
my %COG_Anno;
my %COG_Class;
my %Class_Gene; ##store the class and gene relations

##read fun.txt
open FUN,$fun_file || die "fail $fun_file";
while (<FUN>) {
	if (/\[(\w)\]\s(.+?)\n$/) {
		my ($class,$function) = ($1,$2);
		$Class_Anno{$class} = $function;
	}
}
close FUN;


##read whog
open WHOG,$whog_file || die "fail $whog_file";
$/="_______";
while (<WHOG>) {
	chomp;
	my ($class,$cog_num,$cog_anno) = ($1,$2,$3) if (/\[(\w+)\]\s+(COG\d+)\s+(.+?)\n/s);
	$COG_Anno{$cog_num} = $cog_anno;
	$COG_Class{$cog_num} = $class;
	my @lines = split /\n/;
	foreach  (@lines) {
		chomp;
		if (s/^\s+\w+:\s+//) {
			while (/(\S+)/g) {
				$Gene_COG{$1} = "$cog_num";
			}
		}
	}
}
$/="\n";
close WHOG;



##read the tab file and create a file including cog info
open IN,$blast_tab || die "fail $blast_tab";
open OUT,">$blast_tab.anno.xls" || die "fail $blast_tab.anno";
print OUT "";
print OUT "Gene_ID\tSubject_ID\tCOG_Num\tCOG_Anno\tClass\tClass_Anno\n";
while (<IN>) {
	chomp;
	my ($gene_id,$cog_gene) = (split /\t/)[0,1];
	my $cog_num = $Gene_COG{$cog_gene};
	my $class = $COG_Class{$cog_num};
	my $class_anno;
	foreach  (split //,$class) {
		$class_anno .= $Class_Anno{$_}."; ";
		push @{$Class_Gene{$_}}, [$gene_id,$cog_num];
	}
	chop $class_anno;

	print OUT "$gene_id\t$cog_gene\t$cog_num\t$COG_Anno{$cog_num}\t$class\t$class_anno\n" if (exists $Gene_COG{$cog_gene}); 
}
close OUT;
close IN;


##parse the software.config file, and check the existence of each software
####################################################
sub parse_config{
    my $conifg_file = shift;
    my $config_p = shift;

    my $error_status = 0;
    open IN,$conifg_file || die "fail open: $conifg_file";
    while (<IN>) {
        next if(/#/);
        if (/(\S+)\s*=\s*(\S+)/) {
            my ($software_name,$software_address) = ($1,$2);
            $config_p->{$software_name} = $software_address;
            if (! -e $software_address){
                warn "Non-exist:  $software_name  $software_address\n"; 
                $error_status = 1;
            }
        }
    }
    close IN;
    die "\nExit due to error of software configuration\n" if($error_status);
}
