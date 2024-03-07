#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Term::ANSIColor;
use FindBin qw($Bin);
use File::Basename;
sub usage{
	print color "green";
	print <<USAGE;
Usage:
	perl $0 -t template.txt -o outdir -rc report_conf -remove "your exclude items,seperated by ';'"
	perl $0 -t SingleCell.tmplate.txt -o ***/ -rc my_report.conf -remove "Function-GO;SNP;"
Description:
	This script is used to generate the config file needed in building a Web-style Report.
	Before running me, a template file & a report-config is required, see an example at:
	***/***/***/***
*****
Author:
	JieYang <jieyang\@annoroad.com>
Attention: 
If you have more than one Excluded Items, it is required to join them by ';';
USAGE
	print color "reset";
}
#######################################################################################
my (%subs_item,%exclude_items);
#my($help,$template,$output,$report_name,$sample_num,$exclude,%exclude_items);
my ($help,$template,$outdir,$report_conf,$exclude);
GetOptions(
	"help"=>\$help,
	"t=s"=>\$template,
	"o=s"=>\$outdir,
	"rc=s"=>\$report_conf,
	"remove:s"=>\$exclude,
);
#if(defined $help || !defined $output || !defined $template || !defined $report_name ||!defined $sample_num || !defined $exclude){
if(defined $help || !defined $outdir || !defined $template || !defined $report_conf){
	&usage();
	exit 0;
}
#my $All_items="Project_Info;Filter;Alignment;Expression:rpkm,DE;Function:GO,KEGG;Variant:AS,Novel_gene,SNP;Reference;F&Q";
########################################################################################
&PRE_PARA($report_conf,\%subs_item);
if($exclude){
	&ITEM($exclude,\%exclude_items);
}
&MAIN_body($template,$outdir,\%exclude_items);
#`perl /annoroad/data1/bioinfo/PMO/huangjl/autoReport/20150408/autoReport.pl $outdir/config $outdir/`; #generate the Web-style Report;
#`perl /annoroad/data1/bioinfo/PMO/huangjl/autoReport/20150410/autoReport.pl $outdir/config $outdir/`;
#`perl /annoroad/data1/bioinfo/PMO/huangjl/autoReport/20150420/autoReport.pl $outdir/config $outdir/`;
#`perl /annoroad/data1/bioinfo/PMO/yangjie/flow_Dev/Web-report/20150619/autoReport.pl $outdir/config $outdir/`;
#`perl /annoroad/data1/bioinfo/PMO/yangjie/flow_Dev/Web-report/20150410/autoReport.pl $outdir/config $outdir/`;
#`perl /annoroad/data1/bioinfo/PMO/yangjie/flow_Dev/Web-report/20151207/autoReport.pl $outdir/config $outdir/`; #based on 20150619; fix the pdf table
`perl $Bin/bin/autoReport.pl $outdir/config $outdir/`;  #based on 20151207; add KEGGMap links;
#`/annoroad/share/software/install/p7zip_9.20.1/7za a -t7z $outdir/Report.7z $outdir/*.html $outdir/html $outdir/upload $outdir/*.pdf`;
sub ITEM{
	my ($rm_item,$ref_rm)=@_;
	my @field = split /;/,$rm_item;
	foreach my$f(@field){
		${$ref_rm}{$f}=1;
	}
}
sub PRE_PARA{
	my ($rep_con,$ref_subs)=@_;
	open RC,"<$rep_con" or die "$!";
	while(<RC>){
		chomp;
		if(/^#/){
			next;
		}
		my @field=split /:/,$_;
		if(exists ${$ref_subs}{$field[0]}){
			print "Error!Repicate Items are not allowed";
			exit 0;
		}
		${$ref_subs}{$field[0]}=$field[1];
	}
	close RC;
}

sub SUBS_PARA{
	my ($line,$ref_subsbin)=@_;
	foreach my$k(keys %{$ref_subsbin}){
		my $value=${$ref_subsbin}{$k};
		$line=~s/\$\($k\)/$value/g;
	}
	return $line;
}

sub MAIN_body{
	my ($file,$out,$ref_item)=@_;
	open IN,"<$file" or die "$file:$!";
	open OUT,">$out/config" or die "$out:$!";
	$/="#####";<IN>;$/="\n";
	while(<IN>){
		chomp(my $chunk=$_);
		if(!exists ${$ref_item}{$chunk}){
			while(<IN>){
				chomp;
				s/\s+$//;
				my $line_val=&SUBS_PARA($_,\%subs_item);
				if($line_val=~/^Title:(.+)/){
					my $font_title=&FONT($1);
					print OUT "Title:<<$font_title>>;\n\n\n";
				}elsif($line_val=~/^MainMenu:(.+)/){
					my $tmp_menu=&FONT($1);
					if($tmp_menu=~/结果目录/){
						print OUT "MainMenu:<<$tmp_menu>><<1>>;\n";
					}else{
						print OUT "MainMenu:<<$tmp_menu>><<>>;\n";
					}
				}elsif($line_val=~/^([a-zA-Z]+Menu):(.+)/){
					my $tmp_menu=&FONT($2);
					print OUT "$1:<<$tmp_menu>>;\n";
				}elsif($line_val=~/^P:#(\d*),(\d*);#(.+)/){
					my $tmp=$3;
					my $font_tmp=&FONT($tmp);
					print OUT "P==>\n$font_tmp\n<==P<<$1>><<$2>>;\n";
				}elsif($line_val=~/^PRE/){
					s/;$//;
					my @fonts=split /,/,(split /:/,$_)[1];
					my ($font_size,$font_height,$tab_num);
					if(!$fonts[0]){
						$font_size=14;
					}else{
						$font_size=$fonts[0];
					}
					if(!$fonts[1]){
						$font_height=24;
					}else{
						$font_height=$fonts[1];
					}
					if(!$fonts[2]){
						$tab_num=8;
					}else{
						$tab_num=$fonts[2];
					}
					$/="PRE\n";
					chomp(my $pre=<IN>);
					my $pre_infm=&PRE($pre,$font_size,$font_height,$tab_num);
					print OUT $pre_infm;
					$/="\n";
				}elsif($line_val=~/(^Image:.+)/){
					my $image_infm=&IMAGE($1);
					print OUT $image_infm;
				}elsif($line_val=~/(^Table:.+)/){
					my $table_infm=&TABLE($1);
					print OUT $table_infm;
				}elsif($line_val=~/(^Excel:.+)/){
					my $excel_infm=&EXCELS($1);
					print OUT $excel_infm;
				}elsif($line_val=~/^KEGG:(.+)/){
					my $keggmap_infm=&KeggMap($1);
					print OUT $keggmap_infm;
				}elsif($line_val=~/^ShowDir:(.+)/){
					print OUT "ShowDir:<<$1/>><<./result>>;\n"
				}elsif($line_val=~/^EmptyLine:(\d+)/){
					print OUT "EmptyLine:<<$1>>;\n";
				}elsif($line_val=~/^First2Menu:(\d+)/){
					print OUT "First2Menu:<<$1>>;\n";
				}elsif($line_val=~/#####/){
					my $len=length($_)+1;
					seek IN,-$len,1;
					$/="#####";
					<IN>;
					$/="\n";
					last;
				}
			}
		}else{
			$/="#####";
			<IN>;
			$/="\n";
		}
	}
}
sub TABLE{
my $table_info=$_[0];
my $table_result="SimpleTable==>\n";
my ($nrow,$ncol);
$table_info=~s/;//;
$table_info=~s/\s+$//;
my @field = split /,/,(split /:/,$table_info)[1];
if(($field[1]=~/\D+/ && $field[1] !~ /^#/) || ($field[2]=~/\D+/ && $field[2] !~ /^#/)){ #row/col number will refuse a not-number value;
	print "Error!The row_number or col_number can not be string;\n";
}
if(!$field[1] || $field[1]==0){ #the default of row number is 10000;
	$nrow=10000;
}elsif($field[1]=~/\d+/){
	$nrow=$field[1];
}
if(!$field[2] || $field[2]==0){ # the default of col number is 10000;
	$ncol=10000;
}elsif($field[2]=~/\d+/){
	$ncol=$field[2];
}
my @sample_batchs=glob($field[0]);
die "$field[0]:No such file!\n" unless @sample_batchs;
my $sample_file=$sample_batchs[0];
open T_F,"<$sample_file" or die "$sample_file:$!";
my $row_tag=0;
while(<T_F>){
	chomp;
	if(/^$/ || /^\s+$/){
		next;
	}
	if($ncol==10000){
		my @fields =split /\t/,$_;
		if($row_tag==0){
			foreach my $f(@fields){
				my $tmp=&Fir_BigA($f);
				$f=&FONT($tmp);
			}
		}else{
			if($fields[0]=~/start|end|position|pattern|\bid\b|geneID|_id\b/i){
				foreach my $f(@fields){
					my $tmp=&Fir_BigA($f);
					$f=&FONT($tmp);
				}
			}else{
				my $n=0;
				foreach my$f(@fields){
					if($n==0){
						my $tmp=&Fir_BigA($f);
						$f=&FONT($tmp);
					}else{
						$f=~s/^\s//g;
						$f=~s/\s+$//g;
						my $tmp=&DIGIT($f);
						$tmp=&Fir_BigA($tmp);
						$f=&FONT($tmp);
					}
					$n++;
				}
			}
		}
		my $font_cont=join("\t",@fields);
		$table_result.="$font_cont\n";
	}else{
		my @field_tf=split /\t/,$_;
		for(my$i=$#field_tf;$i>=$ncol;$i--){
			pop @field_tf;
		}
		if($row_tag==0){
			foreach my $f(@field_tf){
				my $tmp=&Fir_BigA($f);
				$f=&FONT($tmp);
			}
		}else{
			if($field_tf[0]=~/start|end|position|pattern|\bid\b|geneID|_id\b/i){
				foreach my $f(@field_tf){
					my $tmp=&Fir_BigA($f);
					$f=&FONT($tmp);
				}
			}else{
				my $n=0;
				foreach my$f(@field_tf){
					if($n==0){
						my $tmp=&Fir_BigA($f);
						$f=&FONT($tmp)
					}else{
						$f=~s/\s$//g;
						$f=~s/^\s//g;
						my $tmp=&DIGIT($f);
						$tmp=&Fir_BigA($tmp);
						$f=&FONT($tmp);
					}
					$n++;
				}
			}
		}
		my $font_temp=join("\t",@field_tf);
		$table_result.="$font_temp\n";
	}
	$row_tag ++;
	if($row_tag==$nrow){
		last;
	}
}
close T_F;
my $font_title=&FONT($field[-1]);
if($field[$#field-1]==1){
	$table_result.="<==SimpleTable:<<>><<$font_title>><<$field[3]>><<$field[4]>>;\n";
}else{
	$table_result.="<==SimpleTable:<<$font_title>><<>><<$field[3]>><<$field[4]>>;\n";
}
return $table_result;  #return the SimpleTable info;
}

sub EXCELS{
my$excel_info=$_[0];
my $excel_result="MoreExcels==>\n";
$excel_info=~s/\s+$//g;
$excel_info=~s/;//g;
my @ex_field=split /,/,(split /:/,$excel_info)[1];
my $note=pop@ex_field;
my $font_note=&FONT($note);
my $line_height=pop@ex_field;
my $font_size=pop@ex_field;
if(!$line_height){
	$line_height=20;
}
if(!$font_size){
	$font_size=14;
}
my $pre_excel_info=join(",",@ex_field);
my $fin_excel_info=&PRE_EXCELS($pre_excel_info);
my @field = split /,/,$fin_excel_info;
foreach my$f(@field){
	$excel_result.="$f\n";
}
$excel_result.="<==MoreExcels:<<$font_note>><<$font_size>><<$line_height>>;\n";
return $excel_result;
}

sub PRE{
my ($pre_info,$size,$height,$pre_tab_num)=@_;
my $space_pre=&ADD_SPACE($pre_tab_num); ###
my $pre_result="PRE==>\n$space_pre"; ###
$pre_info=~s/\n/\n$space_pre/g;
my $font_pre_info=&FONT($pre_info);
$pre_result.=$font_pre_info."\n<==PRE<<$size>><<$height>>;\n";
$pre_result.="PDFPRE==>\nEmptyLine:<<2>>;\n";
$font_pre_info=~s/$space_pre/\t\t/g;
$pre_result.="\t\t".$font_pre_info."\n<==PDFPRE<<$size>><<$height>>;\n";
return $pre_result;
}
sub ADD_SPACE{
	my $num=$_[0];
	my $space="";
	for(my $n=1;$n<=$num;$n++){
		$space.=" ";
	}
	return $space;
}
sub IMAGE{
my $image_info=$_[0]; #Example of image_info: IMAGE:upload/image1.png,up/image2.png,1,Raw Data*Clean Data;
my $image_result="";
$image_info=~s/\s+$//g;
$image_info=~s/;//;
my $pre_image_info=(split /:/,$image_info)[1];
my $fin_image_info=&PRE_IMAGE($pre_image_info);
my @field = split /,/,$fin_image_info; #$field[-1]:the title of pictures,when multiple pictures,join their names by "*";the one but the last one of @field:0/1,0---put the title upright your figure,1---put the title downright your figure;the others are the paths of images;
if(!$field[$#field-2]){
	$field[$#field-2]=400;
}elsif($field[$#field-2]=~/all/){
	$field[$#field-2]="";
}
my $image_title=&FONT($field[-1]);
if($#field-3>=2){ #MultiImages
		$image_result.="MoreImages==>\n";
		for(my$i=0;$i<=$#field-3;$i++){
			my $image_name=basename$field[$i];
			$image_name=~s/\.png//;
			$image_result.="<<$field[$i]>><<$image_name>>\n";
		}
		if($field[$#field-1]==0){
			$image_result.="<==MoreImages<<$image_title>><<>>;\n";
		}else{
			$image_result.="<==MoreImages<<>><<$image_title>>;\n";
		}
}else{
		if($#field-3==1){
			$image_result.="DoubleImageIn1:<<$field[0]>><<$field[1]>>";
		}elsif($#field-3==0){
			$image_result.="SingleImage:<<$field[0]>>";
		}
		if($field[$#field-1]==0){
			$image_result.="<<$image_title>><<>><<$field[$#field-2]>>;\n";
		}else{
			$image_result.="<<>><<$image_title>><<$field[$#field-2]>>;\n";
		}
	}
}

sub PRE_IMAGE{
	my$pre_image=$_[0]; #used to solve the problem of upload/*/*.png; a vague matching
	my $pre_image_result="";
	my @image_names;
	my @image_paths;
	my @field=split /,/,$pre_image;
	for(my$i=0;$i<=$#field-3;$i++){
		my $path=$field[$i];
		my @path_field=glob($path);
		push @image_paths,@path_field;
	}
	if($#image_paths<=11){
		$pre_image_result=join(",",@image_paths);
	}else{
		my @tmp_image_paths;
		for (my$i=0;$i<=11;$i++){
			push @tmp_image_paths,$image_paths[$i];
		}
		$pre_image_result=join(",",@tmp_image_paths);
	}
	$pre_image_result.=",$field[$#field-2],$field[$#field-1],$field[-1]";
	return $pre_image_result;
}

sub PRE_EXCELS{
	my $pre_excel=$_[0];
	my $pre_excel_result="";  #the $pre_excel_result may like "f1.xls,f2.xls,out*.xls";
	my @field=split /,/,$pre_excel;
	foreach my$f(@field){
		my @path_field=glob($f);
		$pre_excel_result.=join(",",@path_field);
	}
	return $pre_excel_result;
}
sub KeggMap{
	my $line = $_[0];
	my $KeggMap_result = "KEGG_MAP==>\n";
	$line =~ s/;$//;
	my @htmls = split /,/,$line;
	foreach my$h(@htmls){
		my @vals = glob($h);
		foreach my$v(@vals){
			my $name = basename $v;
			$name =~ s/\.html$//;
			$KeggMap_result .= "<<$v>><<$name.KeggMap报告>>\n";
		}
	}
	$KeggMap_result .= "<==KEGG_MAP\n";
	return $KeggMap_result;
}
sub FONT{
	my $word=$_[0];
	$word=~s/^/#/;
	$word=~s/$/#/;
	$word=~s/<\/([a-z]+)>/<\/><$1>/g;
	$word=~s/([^<])([\w\d\.\-\"\(])(\w*\<[\d\.]+|[\%\[\]\,\w\s \.\-\_\/\(\)\;\+\*\@]*)([^>])/$1<tnr>$2$3<\/tnr>$4/g;
	$word=~s/<\/></<\//g;
	$word=~s/^#//;
	$word=~s/#$//;
	if($word=~/[Ll]og\d+/){
		$word=~s/([Ll]og)(\d+)/$1<downshow>$2<\/downshow>/g;
	}
	return $word;
}

sub DIGIT{
	my $num=$_[0];
	my $result="";
	if($num=~/^(-?)(\d+)$/){
		my $head=$1;
		if(length($2) < 4){
			$result=$num;
		}else{
			my $lack_bit=3-((length$2) % 3);
			my @field=split //,$2;
			if($lack_bit!=3){
				for(my$i=1;$i<=$lack_bit;$i++){
					unshift @field,"#";
				}
			}
			$result=$head;
			$result.=join("",@field);
			$result=~s/(.{3})/$1,/g;
			$result=~s/#//g;
			$result=~s/,$//;
		}
	}elsif($num=~/^(-?)(\d+)\.(\d+)$/){
		my $head=$1;
		my $tail=$3;
		if(length$tail < 4 ){
			my$val = 4 - length$tail;
			for (my $i=1;$i<=$val;$i++){
				$num=$num."0";
				$tail=$tail."0";
			}
		}
		if($2 != 0){
			$result=substr($num,0,(length$1)+(length$2)+5);
		}elsif($2 == 0){
			if($tail=~/^(0*)(.+)$/){
				if(length$1 <= 4){
					$result="$head"."0.";
					$result.=substr($tail,0,4);
				}else{
					$result=$head;
					$result.=substr($2,0,1).".".substr($2,1,4);
					my $units=(length$1)+1;
					$result.="e-".$units;
				}
			}
		}
	}else{
		$result=$num;
	}
	return $result;
}
sub Fir_BigA{
	my $string=$_[0];
	my $result="";
	if($string =~ /^rRNA|^p$|^q$|^pval|^padj/){
		$result=$string;
	}elsif($string =~/^(\w)/){
		if($1=~/([a-z])/){
			my $sub = chr (ord($1) - 0);
			$string=~s/^(\w)/$sub/;
			$result=$string;
		}else{
			$result=$string;
		}
	}else{
		$result=$string;
	}
	return $result;
}
