#!/usr/bin/env perl
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use File::Basename;
my ($config,$indir,$outdir,$flag_sub,$flag_main,$flag,%main,%sub,$undo,$number,$mainmenu,$submenu,
    @serials,$micmode,$keep,$md5,$list,@samples);
my $usage=<<USAGE;
    -c  config file;
    -i  indir;
    -m  micmode file used to generate html;
    -n  sample number;
    -o  outdir;
    -d  upload dir in outdir;use to check md5;
optional parameters:
    -u  output list of part undo;default value is unprocessed_list.log,in pwd dir;
    -k  keep mainmenu; formate"项目信息\tNA\nNA实验流程\n";
    -n  sample number;default value is 1;
    -d  upload dir in outdir; use to check md5; default value is "upload"; you need to set as your report dir.
    -l  sample list,first Column is sample name, then what ever.（=^_^=）with sample list,you don't have to set -n.
USAGE
GetOptions(
    "c=s"=>\$config,
    "m=s"=>\$micmode,
    "u=s"=>\$undo,
    "n=i"=>\$number,
    "k=s"=>\$keep,
    "i=s"=>\$indir,
    "o=s"=>\$outdir,
    "d=s"=>\$md5,
    "l=s"=>\$list,
);
$undo ||= "unprocessed_list.log";
$md5 ||="upload";
die "$usage" unless ($config and $indir and $outdir and $micmode);
$keep ||= "$Bin/keep.list";
&read_keep_list();
@serials=(1,1,1);
`mkdir -p $outdir`;
print STDOUT "强烈推荐删除上次的拷贝记录后再次操作，以免出现文件反复拷贝的问题\n";
if ($list) {
    open LIST,"$list" or die"not found the sample list\n";
    while(<LIST>){
        chomp;
        my @l = split;
        push @samples,$l[0];
    }
    close LIST;
    die "the number in sample list is not the same with -n\n" if ($number and $number != @samples);
    $number = @samples;
}
$number ||= 1;
open IN,"$config" or die;
open OUT,">$undo" or die;
$/= "[M]";       #### 每次读取一个主分析；
<IN>;
while(<IN>){
    chomp;
    my @l = split (/\[S\]/,$_); ######### 每次读取一个子分析；
    $mainmenu = shift @l;
    $mainmenu =~ /=(.*?)\t(\d+)/;
    $mainmenu = $1;
    $flag = $2;
    unless ($flag){
        print OUT "一级Menu内容:$mainmenu 不在此次分析中\n";
        next;
    } ;
    $flag_main = 0;
#    $flag_sub = 1;
#    print STDERR "OK#################\n";
    foreach my $k (@l){
        $serials[1]=1;
        &done_sub ($k);
        if ($flag_sub){
            $flag_main = 1;
        }
    }
    if ($flag_main){
        $serials[0]++;
        $main{$mainmenu}=1;
    }
}
close IN;
close OUT;
$/= "\n";
open IN,"$micmode" or die;
open OUT,">$outdir/metagenome.template" or die;
my $tmp;
$flag = 0;
while(<IN>){
    if ($flag == 0 and $_ !~ /^\s*MainMenu/){
        $tmp .= $_;
        next;
    }
    elsif (/^\s*MainMenu:( *)(.*+)/){
        my $title = $2;
        $title =~ s/\s|\t|\n//g;
        print OUT "$tmp";
        $tmp = "";
        if (exists $main{$title}){
            $tmp .= $_;
            $flag = 1;
        }
        else{
            $flag = -1;
        }
    }
    elsif (/^\s*SubMenu:( *)(.*+)/){
        my $title = $2;
        $title =~ s/\s|\t|\n//g;
        print OUT "$tmp";
        $tmp = "";
        if (exists $sub{$title}){
            $tmp .= $_;
            $flag = 1;
        }
        else{
            $flag = -1;
        }
    }
    elsif ($flag == 1 and ($_ !~/^\s*MainMenu|^\s*SubMenu/)){
        $tmp .= $_;
    }
    elsif ( $flag == -1 and ($_ !~/^\s*MainMenu|^\s*SubMenu/)){
        next;
    }
    else{
            die;
    }
}
close IN;
print OUT "$tmp";
#foreach my $k (keys %sub){
#    print OUT "$k\n";
#}
close OUT;
#`cd $outdir && find ./$md5 -type f -exec md5sum {} \\; >$outdir/md5.txt`;
#print STDOUT "done md5sum,exit $?\n";



#####################################    子程序     #####################################
sub done_sub {                                                     # 确定Submanual 下的文件已经完成。
    my $string = shift @_;
    my @lines = split (/\n/,$string);
    $submenu = shift @lines;
    $submenu =~ /=(.*?)\t(\d+)/;
    $submenu = $1;
    $flag = $2;
    unless ($flag){
        print OUT "二级Menu内容:$submenu 不在此次分析中\n";
        next;
    } ;
    $flag_sub = 1;
    foreach my $line (@lines) {
        my @m = split (/\t/,$line);                                 #每行的四列参数；
        $m[0] = &_replace_in($m[0]);
        $m[3] ||= 1;
        if (&_is_file($m[0],$m[3])) {
#            &_do_cmd($m[0],$m[1],$m[2]);                            # 执行拷贝工作。
#            $serials[1]++;
        }
        else{
            $flag_sub = 0;
        }      
    }
    if ($flag_sub){
        foreach my $line (@lines) {
            my @m = split (/\t/,$line);
            $m[0] = &_replace_in($m[0]);
            $m[1] = &_replace_num($m[1]);
            $serials[2]++;
            $m[1] = &_replace_out($m[1]);
#            $m[3] ||= 1;
            &_do_cmd($m[0],$m[1],$m[2]);
        }
        $serials[1]++;
        $sub{$submenu}=1;
    }
    else{
        print STDERR "$submenu没有正常完成\n";
    }
    return $flag_sub;
}


sub _is_file {
    my ($file,$num)= @_;
    if ($num =~ /^n/){
        $num =~ s/^n/$number/;
    }
    my @files = <"$file">;
    if (@files >= $num){
        foreach my $file (@files){
            unless (-f $file or -l $file){
                print STDERR "Fail to find all files:$file\t$num\n";
                return 0;
                last;
            }
        }
        return 1;
    }
    else{
        foreach my $sample (@samples){
            my @tmp = grep (/$sample/,@files);
            unless (@tmp){
                print STDERR "$sample 不在 $file中\n";
            }
            else{
                print STDERR "请检查一个样品名是否包含于另一个样品名中，可能此样品缺失了$file 文件\n";
            }
        }
        print STDERR "Fail to find all files:$file\t$num\n";
        return 0;
    }
}
sub _replace_num {
    my $file = shift @_;
	#print "$file\n";
    $file =~ s/\\d\+/$serials[0]/;
    my $tmp = $serials[0]."_".$serials[1];
    $file =~ s/\\d\+/$tmp/;
    $tmp = $serials[0]."_".$serials[1]."_".$serials[2];
    $file =~ s/\\d\+/$tmp/;
    return $file;
}
sub _replace_in {                            ##  路径替换;
    my $file = shift @_;
    $file =~ s/^INDIR/$indir/;
    return $file;
}

sub _replace_out {                           ## 路径替换;
    my $file = shift @_;
    $file =~ s/^OUTDIR/$outdir/;
    return $file;
}

sub _do_cmd {
    my ($infile,$outfile,$cmd) = @_;
    my @infiles = <"$infile">;
=cut
    if ($num){
            foreach my $sample (@samples){
                my @tmp = grep (/$sample/,@infiles);
                unless (@tmp){
                    print STDERR "$sample is missing $infile\n";
                }
            }
    }
=cut
    $infile =~ s/\*/\(\.\*\?\)/g;
    foreach my $file (@infiles){
        my $tmp_outfile = $outfile;
        my @matchs = ($file =~ /$infile/);       ## 存储全部的匹配
#        print STDOUT "$infile##############################333\n";
        my $n = 0;
        while($tmp_outfile=~/\*(\d+)/){
            $tmp_outfile=~s/\*(\d+)/$matchs[$1-1]/;
        }
        if ($cmd eq "copy"){
            my $path;
            if ($tmp_outfile=~ /\/$/){
                $path = $tmp_outfile;
            }
            else{
                $path = dirname ($tmp_outfile);
            }
            `mkdir -p $path`;
            `cp $file $tmp_outfile`;
            if ($?) {
                print STDOUT "cp $mainmenu,$submenu:$file $tmp_outfile\texit $?\n";
            }
        }
        elsif($cmd eq "link"){
            my $path;
            if ($tmp_outfile=~ /\/$/){
                $path = $tmp_outfile;
            }
            else{
                $path = dirname ($tmp_outfile);
            }
            `mkdir -p $path`;
            `ln -s $file $tmp_outfile`;
            if ($?) {
                print STDOUT "ln -s $file $tmp_outfile\texit $?\n";
            }
        }
        else{
            die "wrong command at file:$file\n";
        }
    }
}

sub read_keep_list {
    open IN,"$keep" or die "无法正常读取keep.list：$!\n";
    while(<IN>){
        chomp;
        my @l = split(/\t/,$_);
        $main{$l[0]}=1;
        $sub{$l[1]}=1;
    }
    close IN;
}
