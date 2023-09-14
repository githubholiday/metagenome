BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/
script_dir=$(BIN)/script

ifdef config
	include $(config)
else
	include $(BIN)/config/config.txt
endif

HELP:
	@echo Description: 此脚本对宏基因组组装的fa进行合并和去冗余
	@echo Version:v1.0.0
	@echo Author:chengfangtu
	@echo -e "\n MMSEQ2:对预测后的基因进行去冗余"
	@echo -e "make -f makefile config= dna_fa= gene_min_len= sample= outdir= MMSEQ2"
	@echo -e "\t[参数说明]" :
	@echo -e "\t\t config : [必选/输入]配置文件，默认为bin/config/config.txt"
	@echo -e "\t\t dna_fa : [必选/输入]预测的基因fa文件,使用*通配符，是所有样本的fa文件路径,如果不能通配,使用英文逗号分割"
	@echo -e "\t\t out_prefix : [必选/输出]输出文件前缀,会输出_rep_seq.fasta,cluster.tsv"
	@echo -e "\t\t mmseq2_para : [可选/输入]软件参数"

outdir=$(dir $(abspath $(firstword $(out_fa))))
mmseq2_para=--min-seq-id 0.5 -c 0.8 --cov-mode 1 --threads 4
MMSEQ2:
	echo "############### MMSEQ2 start at `date` ###############"
	mkdir -p $(outdir)
	cat $(dna_fa) > $(outdir)/all.nucleotide.tmp.fa
	$(MMSEQ2) easy-cluster $(outdir)/all.nucleotide.tmp.fa $(out_prefix)/ $(outdir)/tmp $(mmseq2_para)
	echo "############### MMSEQ2 end at `date` ###############"