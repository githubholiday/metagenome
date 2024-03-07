#! usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

my $USAGE = qq{
USAGE:
	perl $0 -i anno.xls -r string -o output\n;
};

my($annof, $remove, $outf);
GetOptions(
	'i=s' => \$annof,
	'r=s' => \$remove,
	'outf=s' => \$outf,
);
die "$USAGE" unless ($annof);

my (%annoh, %annoc);
open ANNO, "$annof" or die "$annof : $!\n";
open OUT, ">$outf" or die "$outf : $!\n";
chomp(my $head = <ANNO>);
print OUT "$head\n";
while(<ANNO>){
	chomp;
	my $count = 0;
	my @anno_col = split(/\t/, $_);
	my $gene = shift @anno_col;
	foreach my $an(@anno_col){
		$count++ if $an eq $remove;
	}
	#unshift @anno_col, $count;
	if(!exists $annoh{$gene}){
		$annoh{$gene}[0] = \@anno_col;
		$annoc{$gene} = $count;
	}
	else{
		if($count > $annoc{$gene}){
			$annoc{$gene} = $count;
		}
		push $annoh{$gene}, \@anno_col;
	}
}
#print Dumper(\%annoh);
#print Dumper(\%annoc);
foreach my $key (sort {$annoc{$a} <=> $annoc{$b}} keys %annoc){
	foreach my $anno_gene(@{$annoh{$key}}){
		print OUT $key,"\t",join("\t",@{$anno_gene}),"\n";
	}
}
close OUT;
close ANNO;
