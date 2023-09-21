BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/
script_dir=$(BIN)
ifdef config
	include $(config)
else
	include $(BIN)/config/config.txt
endif

HELP:
	@echo Description: 对各个样本数据进行基因表达定量
	@echo Version:v1.0.0
	@echo Author:chengfangtu
	@echo SalmonAlignment:对样本进行表达定量
	@echo "make -f makefile config= infa= R1= R2= outdir= tpm_file SalmonAlignment"
	@echo "\t[参数说明]" :
	@echo "\t\t config : [必选/输入]配置文件,默认为bin/config/config.txt"
	@echo "\t\t ref : [必选/输入]输入的Ref fa文件"
	@echo "\t\t R1  : [必选/输入]R1 fastq文件"
	@echo "\t\t R2  : [必选/输入]R2 fastq文件"
	@echo "\t\t outdir: [必选/输出]输出目录，输出目录下输出建库文件以及salmon quant结果文件,如quant.sf文件"
	@echo "\t\t tpm_file: [必选/输出]输出的TPM文件"

SalmonAlignment:
	echo salmon_gene start at `date`
	mkdir -p ${outdir}/salmon_index/
	${SALMON} index -t ${ref} -p 4 -i ${outdir}/salmon_index/
	${SALMON} quant -i ${outdir}/salmon_index/ -l A -p 3 --meta -1 ${R1} -2 ${R2} -o ${outdir}
	cat ${outdir}/quant.sf|cut -f1,4|sed "s/TPM/${sample}/g" >${tpm_file}
	cat ${outdir}/quant.sf|cut -f1,5|sed "s/NumReads/${sample}/g" >${cout_file}
	echo salmon_gene end at `date`