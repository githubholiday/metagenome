#!/usr/bin/env perl
if(@ARGV!=3){die "usage : $0 usage : *.pl <*.eblast> <E Limit> <result>\n";}
open IN,"$ARGV[0]";

open out,">$ARGV[2]" or die;
#print out "Query_id\tSubject_id\t\%identity\talignment_length\tmismatches\tgap_openings\tq.start\tq.end\ts.start\ts.end\te-value\tbit_score\tAnnotation\tHits_Number\n";
print out "Gene_ID\tSubject_ID\t\%identity\talignment_length\tmismatches\tgap_openings\tq.start\tq.end\ts.start\ts.end\te-value\tbit_score\tAnnotation\tHits_Number\n";
while(<IN>){
         chomp;
         if($_!~/^Query/){  
			 @temp=split;
               $temp[-1]=uc $temp[-1];
			 if($temp[10]<=$ARGV[1] ){
			 if(!exists $hash{$temp[0]." ".$temp[-1]}){
				$num{$temp[0]}++;
				$hash{$temp[0]." ".$temp[-1]}=1;	
              #  print "$temp[0]\t1\n";
			 }
			 if(!exists $hash_e{$temp[0]}){
				$hash_e{$temp[0]}=$temp[10];
				$hash_score{$temp[0]}=$temp[11];
				$best{$temp[0]}=$_;
              #  print "$temp[0]\t2\n";
					
			}else{ 
				if($temp[10]<=$hash_e{$temp[0]} && $temp[11]>$hash_score{$temp[0]}){
					$hash_e{$temp[0]}=$temp[10];
					$hash_score{$temp[0]}=$temp[11];
					$best{$temp[0]}=$_;            	
               #     print "$temp[0]\t3\n";
				}
			 }
			}
#        }else{
#			print out "$_\tHits Number\n";	

		}
}
close IN;

foreach (sort {$a cmp $b} keys %best){
	
      print out "$best{$_}\t$num{$_}\n";	
	
}
close out;
system " perl -i.bak -F'\\t'  -alne '\$F[1]=~s/\|\$//;\$F[-2]=~s/\|\$//;print \"\$F[0]\\t\$F[1]\\t\$F[-2]\"' $ARGV[2]";
