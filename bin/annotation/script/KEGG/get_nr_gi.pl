#!/usr/bin/env perl
#Query_id	Subject_id	%identity	alignment_length	mismatches	gap_openings	q.start	q.end	s.start	s.end	e-value	bit_score
#gene_1000|GeneMark.hmm|90_aa|+|1|273	gi|189442053|gb|AAI67171.1|	50.77	65	32	0	17	81	1195	1259	1e-11	70.1	2
#gene_1002|GeneMark.hmm|567_aa|+|1|1701	gi|30583905|gb|AAP36201.1|	44.02	234	122	5	3	230	94	324	9e-47	 182	23
open IN,$ARGV[0] or die;
open OUT,">$ARGV[1]" or die;
while(<IN>){
	chomp;
	next if /Query_id/;
	my @tab=split;
	$tab[1]=~s#gi\|(\d+)\|\S+#$1#;
	print OUT "$tab[0]\t$tab[1]\n";
}
