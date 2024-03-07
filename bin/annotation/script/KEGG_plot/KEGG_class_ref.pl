#!/usr/bin/perl
my $usage = qq{
Usage:perl $0 <Trinotate_report_all.xls> <ko00001.keg> <output> <T>
	Trinotate_report_all.xls -- report result
	ko00001.keg 		 -- /annoroad/data1/bioinfo/PMO/jiahan/database/KEGG/ko00001.keg
	output         		 -- result file
	T			 -- T:include Human Diseases;F:exclude Human Diseases
};
use strict;
use warnings;
die($usage)unless(@ARGV==4);
my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $file3 = $ARGV[2];
my $tag = $ARGV[3];
open(IN1,$file1)||die"$file1\t$!\n";
my %ko_gene;
my $first = <IN1>;
chomp $first;
my @head = split(/\t/,$first);
#my $k = -2;
my $k=HEADER($first,'KEGG:KO');
if($k){
	while(<IN1>){
		chomp;
		my @col = split(/\t/,$_);
		if($col[$k] eq "."){
			next;
		}else{
			my @ko_anno = split(/;/,$col[$k]);
			for(my $i=0;$i<=$#ko_anno;$i++){
				push @{$ko_gene{$ko_anno[$i]}},$col[0];
			}
		}
	}
	close IN1;
	open(IN2,$file2)||die"$file2\t$!\n";
	$/="A<";<IN2>;$/="\n";
	my $first = <IN2>;
	chomp $first;
	$first =~ s/(.*)>(.*)<(.*)/$2/;
	<IN2>;
	my $second = <IN2>;
	chomp $second;
	$second =~ s/(.*)>(.*)<(.*)/$2/;
	my (@gene,%ko_class,%ko_num,@gene_all);
	while(<IN2>){
		chomp;
		my $row = $_;
		if($row =~ /^A/){
			$row =~ s/(.*)>(.*)<(.*)/$2/;
			if($tag eq "F" && $row =~ /Human/){
				last;
			}else{
				$first = $row;
			}
		}elsif($row =~ /^B/){
			$ko_class{$second} = $first;
			my %hash;
			@gene = grep{++$hash{$_}<2} @gene;
			$ko_num{$second} = $#gene+1;
			@gene_all = (@gene_all,@gene);
			@gene=();
			$second = <IN2>;
                        chomp $second;
                        $second =~ s/(.*)>(.*)<(.*)/$2/;
		}elsif($row =~ /^D/){
			$row =(split(/\s+/,$row))[1];
			if(exists $ko_gene{$row}){
				push @gene,@{$ko_gene{$row}};
			}
			
		}else{
			next;
		}
	}
	close IN2;
	$ko_class{$second} = $first;
	my %hash2;
	@gene = grep{++$hash2{$_}<2} @gene;
	$ko_num{$second} = $#gene+1;
	my %hash1;
        @gene_all = grep{++$hash1{$_}<2} @gene_all;
	my $sum_gene = $#gene_all+1;
	open(OUT1,">$file3");
	print OUT1"Classification\tGroup\tValue\tPercent\n";
	foreach my $ko(sort { $ko_class{$a} cmp $ko_class{$b} }keys %ko_class){
		my $per = sprintf "%0.2f",$ko_num{$ko}/$sum_gene*100;
		if($ko_num{$ko} != 0){
			print OUT1"$ko_class{$ko}\t$ko\t$ko_num{$ko}\t$per%\n";
		}
	}
	close OUT1;
}else{
	close IN1;
	print"$file1 is wrong!\nPless input right file!\n";
}




sub HEADER
{                #获取行号
    my @list = @_;
    my $target=$list[1];
        my @Header=split/\t/,$list[0];
        for (my $i=0;$i<@Header ;$i++) {
            if ($target eq $Header[$i]) {
                return $i;
                }
            }
    }
