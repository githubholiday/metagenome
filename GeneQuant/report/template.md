@@@@GeneQuant
# Bam统计分析
## 背景信息
blah
## Reads比对统计结果
利用RSeQC统计bam文件中reads的比对情况，统计表如下：
![比对统计表]{{table_stat}}
（1）Total records:总信息记录Reads数
（2）QC failed:质控不通过Reads数
（3）Optical/PCR duplicate:PCR重复reads数
（4）Non primary hits：非主比对Reads数
（5）Unmapped reads: 未比对上的Reads数
（6）mapq < mapq_cut (non-unique):非唯一比对Reads数
（7）mapq >= mapq_cut (unique):唯一比对Reads数
（8）Read-1:Reads1 数量
（9）Read-2:Reads2 数量
（10）Reads map to '+': 比对到正义链的Reads数
（11）Reads map to '-':比对到反义链的Reads数
（12）Non-splice reads:非剪切Reads数量
（13）Splice reads:剪切Reads数
（14）Reads mapped in proper pairs:成对Reads数
（15）Proper-paired reads map to different chrom:比对到不同染色体的成对Reads数
## Reads质量统计结果
利用RSeQC统计bam文件中reads的质量情况，箱式统计图如下：
![质量统计图]{{image_box}}
横坐标表示Reads上碱基位置，纵坐标表示碱基质量。
热图展示如下：
![质量统计图]{{image_heat}}
横坐标表示Reads上碱基位置，纵坐标表示碱基质量，颜色越趋近于蓝色，表示低密度，趋近于红色表示高密度。

# 附录
## 软件与参数
![软件表格]{{table_software}}

## 参考文献
* [Langmead B, Salzberg SL (2012) Fast gapped-read alignment with Bowtie 2. Nature methods 9: 357–359.](http://www.nature.com/nmeth/journal/v9/n4/full/nmeth.1923.html)


