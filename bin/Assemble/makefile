BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/script
ifdef config
	include $(config)
else 
	include $(BIN)/../config/config.txt
endif

HELP:
	@echo Description: 此脚本用于宏基因组数据组装，包含bam2fasta, Assemble, Assemble_Stat模块
	@echo Usage :
	@echo make -f makefile config= sample= outdir= ccs_fa= Assemble
	@echo make -f makefile config= contig_fa= sample= outdir= Assemble_Stat
	@echo make -f makefile config= R1= R2= outdir= AssembleNGS
	@echo 
	@echo [参数说明] :
	@echo config     : [必选]流程配置文件路径为 BIN/config/config.txt
	@echo sample     : [必选]样本名称
	@echo outdir     : [必选]输出目录
	@echo ccs_fa     : [必选]输入文件，ccs.fa
	@echo genomeSize : [必选]预估基因组大小
	@echo R1/R2      : [必选]去除宿主后的reads1/2
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-02-11 by 'zhangyue' [yuezhang\@genome.cn];
	@echo 再一次输入用法：make -f makefile outdir= project= fqdir= number= Shell

.PONHY:Assemble
Assemble:
	echo Assemble start at `date`
	mkdir -p $(outdir)
	$(CANU) -assemble -p $(sample) -pacbio-hifi $(ccs_fa) -d $(outdir) genomeSize=$(genomeSize) $(CANU_OPT)
	echo Assemble end at `date`

Assemblehifiasm:
	echo Assemble start at `date`
	[ -d $(outdir) ] || mkdir -p $(outdir)
	$(hifiasm_meta) -t $(thread) -o $(outdir)/$(sample) $(ccs_fa) 2>$(outdir)/$(sample).log
	$(gfatools) gfa2fa $(outdir)/$(sample).p_ctg.gfa >$(outdir)/$(sample).p_ctg.fa
	echo Assemble end at `date`

AssembleNGS:
	echo AssembleNGS start at `date`
	mkdir -p $(outdir) && rm -rf $(outdir)
#	[ -d $(outdir) ] || mkdir -p $(outdir)
	$(MEGAHIT) -1 $(R1) -2 $(R2) $(megahit_para) -o $(outdir)
	echo AssembleNGS end at `date`

Assemble_Stat:
	echo Assemble_Stat start at `date`
	mkdir -p $(outdir)
	${PERL} $(BIN)/stat_N50_90.pl -i $(contig_fa) -l 0 >$(outdir)/$(sample).assembly.n50.xls
	$(PYTHON3) $(BIN)/contig_length_stat.py -i $(contig_fa) -n 500 -p $(outdir)/$(sample).contig_length_stat.pdf
	${CONVERT} $(outdir)/$(sample).contig_length_stat.pdf $(outdir)/$(sample).contig_length_stat.png
	$(PYTHON3) $(BIN)/GC_stat.py -i $(contig_fa) -o $(outdir)/$(sample).GC.xls
	$(PYTHON3) $(BIN)/FastaTools.v2.py -i $(contig_fa) -fa -stats -o $(outdir)/$(sample).stat.xls -od $(outdir)/$(sample).length.xls
	${RSCRIPT} $(BIN)/draw_plot.R $(outdir)/$(sample).length.xls $(outdir)/$(sample) Length GC%
	echo Assemble_Stat end at `date`

StatAll:
	echo all samle stat start at `date`
	$(PYTHON3) $(BIN)/stat_all.py -i $(input) -o $(output)
	echo all samle stat end at `date`
