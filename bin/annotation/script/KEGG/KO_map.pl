#!/user/bin/perl
use strict;
use Getopt::Long;
my ($gi,$kegg_list,$out,%gi,$ko_list,%ko);
GetOptions(
    "g=s"=>\$gi,
    "k=s"=>\$kegg_list,
    "o=s"=>\$out,
    "l=s"=>\$ko_list
);
die "perl $0 -g <gi file> -k <kegg_list> -o <outfile>\n" unless ($gi and $out);
#$kegg_list ||= "/annoroad/data1/bioinfo/PMO/Public/database/Public/KO_GO/current/kegg.list";
#$ko_list ||="/annoroad/data1/bioinfo/PMO/Public/database/Public/KO_GO/current/ko.list";
open IN,"<$gi"  or die;
while(<IN>){
    chomp;
    my @l = split;
    $gi{$l[2]}{$l[0]} = $l[0];
}
close IN;
open KO,$ko_list or die;
while(<KO>){
	chomp;
	my @ko=split(/\t/,$_);
	$ko[0]=(split(/:/,$ko[0]))[1];
	$ko{$ko[0]}=$ko[1];
}
close KO;
open IN,"<$kegg_list" or die;
open OUT,">$out" or die;
print OUT "Genmark_ID\tSpecies_ID\tGene_ID\tKO_ID\tMap_ID\tDescription\tLink\n";
while(<IN>){
    chomp;
    my @l = split;
    if (exists $gi{$l[1]}){
        foreach my $k (keys %{$gi{$l[1]}}){
            print OUT "$k\t$l[0]\t$l[1]\t$l[2]\t$l[3]\t$ko{$l[2]}\t"."http://www.genome.jp/dbget-bin/www_bget?"."$l[0]"."\n";
        }
    }
}
close IN;
close OUT;
