BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/
script_dir=$(BIN)/script
ifdef config
	include $(config)
else
	include $(BIN)/config/config.txt
endif

HELP:
	@echo Description: 此脚本对宏基因组组装的fa进行基因预测、过滤
	@echo Version:v1.0.0
	@echo Author:chengfangtu
	@echo GenePrediction:使用MetaGeneMark_linux_64软件对宏基因组基因进行预测
	@echo "make -f makefile config= assemble_fa= pro_fa= dna_fa= mod= user= out_gff= GenePrediction"
	@echo "\t[参数说明]" :
	@echo "\t\t config : [必选/输入]配置文件，默认为bin/config/config.txt"
	@echo "\t\t assemble_fa : [必选/输入]组装后的fasta文件"
	@echo "\t\t user        : [必选/输入]运行的用户名，需要将配置文件拷贝到账户的home目录下"
	@echo "\t\t mod         : [可选/输入]模型文件，默认为 bin/config/MetaGeneMark_v1"
	@echo "\t\t out_gff     : [必选/输出]输出gff文件"
	@echo "\t\t pro_fa   : [必选/输出]预测的蛋白序列"
	@echo "\t\t dna_fa: [必选/输出]预测的核酸序列"

	@echo "\n GeneFilter:对预测后的基因进行过滤:长度过滤"
	@echo "make -f makefile config= dna_fa= gene_min_len= sample= outdir= GeneFilter"
	@echo "\t[参数说明]" :
	@echo "\t\t config : [必选/输入]配置文件，默认为bin/config/config.txt"
	@echo "\t\t dna_fa : [必选/输入]预测的基因fa文件"
	@echo "\t\t gene_min_len : [必选/输入]基因最短长度，用于过滤，一般可以设置为200"
	@echo "\t\t sample       : [必选/输入]样本名称"
	@echo "\t\t outdir     : [必选/输出]输出目录，输出目录下输出sample.orf.stat.xls以及过滤后的基因fa文件"

	@echo "\n MMSEQ2:对预测后的基因进行去冗余"
	@echo "make -f makefile config= dna_fa= gene_min_len= sample= outdir= GeneFilter"
	@echo "\t[参数说明]" :
	@echo "\t\t config : [必选/输入]配置文件，默认为bin/config/config.txt"
	@echo "\t\t dna_fa : [必选/输入]预测的基因fa文件,使用*通配符，是所有样本的fa文件路径,如果不能通配,使用英文逗号分割"
	@echo "\t\t out_prefix : [必选/输出]输出文件前缀,会输出_rep_seq.fasta,cluster.tsv"
	@echo "\t\t mmseq2_para : [可选/输入]软件参数"

	@echo "\n Cds2aa:将基因组fa文件转化为蛋白序列"
	@echo "make -f makefile config= dna_fa= pro_fa= Cds2aa "
	@echo "\t[参数说明]" :
	@echo "\t\t config : [必选/输入]配置文件，默认为bin/config/config.txt"
	@echo "\t\t dna_fa : [必选/输入]基因组fa文件"
	@echo "\t\t pro_fa : [必选/输出]转化后的蛋白序列"

mod=$(BIN)/config/MetaGeneMark_v1.mod
outdir=$(dir $(abspath $(firstword $(out_gff))))
GenePrediction:
	echo "############### GenePrediction start at `date` ###############"
	mkdir -p $(outdir)
	cp -rf $(MGM)/gm_key_64 ~/.gm_key
	$(MGM)/gmhmmp -r -a -d -f G -m $(mod) -A $(pro_fa) -D $(dna_fa) -o $(out_gff) $(assemble_fa)
	echo "############### GenePrediction end at `date` ###############"

GeneFilter:
	echo "############### GeneFilter start at `date` ###############"
	$(SEQKIT) seq -m $(gene_min_len) -g $(dna_fa) >$(outdir)/tmp
	$(PYTHON3) $(script_dir)/change_fa_id.py -i $(outdir)/tmp -o $(outdir)/$(sample).nucleotide.filter.fa -n $(outdir)/$(sample).orf_stat.xls -s $(sample)
	rm $(outdir)/tmp
	echo "############### GeneFilter end at `date` ###############"

outdir=$(dir $(abspath $(firstword $(out_fa))))
mmseq2_para=--min-seq-id 0.5 -c 0.8 --cov-mode 1 --threads 4
MMSEQ2:
	echo "############### MMSEQ2 start at `date` ###############"
	mkdir -p $(outdir)
	cat $(dna_fa) > $(outdir)/all.nucleotide.tmp.fa
	$(MMSEQ2) easy-cluster $(outdir)/all.nucleotide.tmp.fa $(out_prefix)/ $(outdir)/tmp $(mmseq2_para)
	echo "############### MMSEQ2 end at `date` ###############"

Cds2aa :
	echo "############### Cds2aa start at `date` ###############"
	$(PERL) $(script_dir)/cds2aa.pl $(dna_fa) >$(pro_fa)
	echo "############### Cds2aa end at `date` ###############"