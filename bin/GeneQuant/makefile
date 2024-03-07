BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
ifdef config
	include $(config)
else 
	include $(BIN)/config/config.txt
endif

HELP:
	@echo Description: 此脚本用于基因差异分析
	@echo Usage :
	@echo make -f makefile nongene= outindex= salmon_index
	@echo make -f makefile outdir= outindex= read1= read2= sample= salmon_gene
	@echo make -f makefile count= cmp= outdir= TPM= cor
	@echo
	@echo [参数说明]    :
	@echo config        : [必选]流程配置文件
	@echo nongene       : [必选]去冗余后的基因组
	@echo outindex      : [必选]输出salmon索引文件夹
	@echo read1         : [必选]去除宿主后的read1
	@echo read2         : [必选]去除宿主后的read2
	@echo count         : [必选]统计的count文件
	@echo TPM           : [必选]生成的TPM文件
	@echo outdir        : [必选]输出目录

salmon_index:
	echo salmon_index start at `date`
	${SALMON} index -t ${infa} -p 4 -i ${index_prefix}
	echo salmon_index end at `date`

salmon_gene:
	echo salmon_gene start at `date`
	[ -s ${outdir} ]||mkdir -p ${outdir}
	${SALMON} quant -i ${index_prefix} -l A -p 4 --meta -1 ${R1} -2 ${R2} -o ${outdir}
	cat ${outdir}/quant.sf|cut -f1,4 >${outdir}/${sample}.TPM.xls
	echo salmon_gene end at `date`

gene_boxplot:
	[ -s ${outdir} ]|| mkdir -p ${outdir}
	${PYTHON3} ${BIN}/script/combine_groupgene.py -i ${count} -c ${cmp} -o ${outdir}/gene_boxplot.xls
	${Rscript} ${BIN}/script/myboxplot.r ${outdir}/gene_boxplot.xls ${outdir}/gene_boxplot.pdf "Gene number in Groups" "Number of non-redundant gene"
	${CONVERT} ${outdir}/gene_boxplot.pdf ${outdir}/gene_boxplot.png
cor:
	echo cor start at `date`
	[ -s ${outdir} ]|| mkdir -p ${outdir}
	${PYTHON3} ${BIN}/script/prepare_TPM.py -i ${TPM} -o ${outdir}/TPM.all.xls
	${RSCRIPT} ${BIN}/script/correlation_V1.r ${outdir}/TPM.all.xls ${outdir}/TPM.cor.xls spearman 1000
	${RSCRIPT} ${BIN}/script/pheatmap.r ${outdir}/TPM.cor.xls ${outdir}/TPM.cor.pdf none T auto auto '' $(cmp)
	${CONVERT} ${outdir}/TPM.cor.pdf ${outdir}/TPM.cor.png
	echo cor end at `date`
