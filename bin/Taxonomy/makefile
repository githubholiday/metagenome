BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/script
include $(config)

HELP:
	@echo Description: 此脚本用于宏基因组物种分类
	@echo Usage :
	@echo make -f makefile config= outdir= input= out_prefix= bam2fasta
	@echo make -f makefile config= sample= outdir= ccs_fa= Assemble
	@echo make -f makefile config= contig_fa= sample= outdir= Assemble_Stat
	@echo 
	@echo [参数说明] :
	@echo config : [必选]流程配置文件路径为 BIN/config/config.txt
	@echo sample : [必选]样本名称
	@echo outdir : [必选]输出目录
	@echo input  : [必选]输入文件
	@echo level  : [必选]物种分类水平，通常为genus|species
	@echo top    : [必选]物种丰度最高的几个物种，11代表前10（有表头）
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-02-11 by 'zhangyue' [yuezhang\@genome.cn];
	@echo 再一次输入用法：make -f makefile outdir= project= fqdir= number= Shell

TaxonomyPickUp:
	echo Stat all sample start at `date`
	$(PYTHON3) $(BIN)/TaxonomyPickUp.py -i $(input) -o $(output) -a $(accession2taxid) -t $(TaxInfo)
	echo Stat all sample end at `date`

Tax:
	echo Tax start at `date`
	[ -s $(outdir) ] || mkdir -p $(outdir)
	$(PYTHON3) $(BIN)/extract_single_annotation.py -i $(input) -a $(result_all) -o $(sample_result)
	$(PYTHON3) $(BIN)/StatTaxonomy.py -c $(input) -i $(sample_result) -t $(level) -o $(outdir)/$(sample).$(level).count.txt
	# head -n $(top) >top$(top)\_$(level).xls
	echo Tax end at `date`

Stat_all:
	echo Stat all sample start at `date`
	$(PYTHON3) $(BIN)/merge_all.py -i $(input) -o $(output)
	echo Stat all sample end at `date`

BarPlot:
	echo bar plot start at `date`
	$(PYTHON3) $(BIN)/get_top_data.py -i $(input) -o $(input).tmp -n $(number)
	$(RSCRIPT) $(BIN)/plot.r $(input).tmp $(prefix).pdf
	$(CONVERT) $(prefix).pdf $(prefix).png
	rm -rf $(input).tmp 
	echo bar plot end at `date`
