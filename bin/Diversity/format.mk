BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
file=$(abspath $(firstword $(MAKEFILE_LIST)))

ifdef config
	include $(config)
else 
	include $(BIN)/config/config.txt
endif

type=species
Help:
	@echo Info:
	@echo -e "\t" Author: chengfangtu
	@echo -e "\t" Version: v1.0.0
	@echo -e "\t" Date: 2023-5-11
	@echo -e "Description:"
	@echo -e "\t"该脚本用于物种多样性分析前的文件处理
	@echo target:
	@echo -e "\t" merge: 将物种分类后的文件进行合并输出
	@echo Usage:
	@echo -e "\t" make -f ${file} config= infile= outdir= prefix= merge
	@echo 参数说明：
	@echo -e "\t" "config: [文件|可选]  模块配置文件，和软件相关参数，默认为$(BIN)/config/config.txt "
	@echo -e "\t" "infile: [文件|必需]  输入文件，各个样本的物种丰度文件，如Taxnomy/Sample_format/*format.xls"
	@echo -e "\t" "prefix: [字符|必需]  输出文件前缀"
	@echo -e "\t" "outdir: [目录|必需]  输出目录，输出目录下输出 prefix.xls"
	@echo target:
	@echo -e "\t" taxnomy_format: 将合并后的文件，按照指定物种等级将其输出，并标准化（z-score)
	@echo Usage:
	@echo -e "\t" make -f ${file} config= infile= outdir= prefix= type= taxnomy_format
	@echo 参数说明：
	@echo -e "\t" "config: [文件|可选]  模块配置文件，和软件相关参数，默认为$(BIN)/config/config.txt "
	@echo -e "\t" "infile: [文件|必需]  输入文件，各个样本的物种丰度文件，如Taxnomy/Sample_format/*format.xls"
	@echo -e "\t" "prefix: [字符|必需]  输出文件前缀"
	@echo -e "\t" "type: [字符|必需]  物种等级名称，默认为species(物种)"
	@echo -e "\t" "outdir: [目录|必需]  输出目录，输出目录下输出 prefix.xls"
	@echo target:
	@echo -e "\t" qiime_biom: 将文件转化为biom和qza格式
	@echo Usage:
	@echo -e "\t" make -f ${file} config= infile= outdir= prefix= qiime_biom
	@echo 参数说明：
	@echo -e "\t" "config: [文件|可选]  模块配置文件，和软件相关参数，默认为$(BIN)/config/config.txt "
	@echo -e "\t" "infile: [文件|必需]  输入文件，各个样本的物种丰度文件，如Taxnomy/Sample_format/*format.xls"
	@echo -e "\t" "prefix: [字符|必需]  输出文件前缀"
	@echo -e "\t" "outdir: [目录|必需]  输出目录，输出目录下输出 prefix.biom和prefix.qza"
	
merge:
	@echo "===================== Run merge Begin at `date` ===================== "
	mkdir -p ${outdir}
	$(CSVTK) -t join ${infile} > ${outdir}/$(prefix).xls
	@echo "===================== Run merge Begin at `date` ===================== "

taxnomy_format:
	@echo "===================== Run taxnomy_format Begin at `date` ===================== "
	mkdir -p $(outdir)
	export OPENBLAS_NUM_THREADS=2 && $(PYTHON3) $(BIN)/script/taxnomy_select.py -i ${infile} -o ${outdir}/$(prefix).xls -t $(type)
	export OPENBLAS_NUM_THREADS=2 && $(PYTHON3) $(BIN)/script/taxnomy_normalize.py -i ${outdir}/$(prefix).xls -o ${outdir}/$(prefix).normalize.xls
	@echo "===================== Run taxnomy_format Begin at `date` ===================== "

qiime_biom:
	@echo "===================== Run qiime_biom Begin at `date` ===================== "
	${QIIME2}/biom convert -i ${infile} -o ${outdir}/$(prefix).biom  --to-hdf5 --table-type="OTU table"
	${QIIME2}/qiime tools import --input-path ${outdir}/$(prefix).biom --type 'FeatureTable[Frequency]' --input-format BIOMV210Format --output-path ${outdir}/$(prefix).qza
	@echo "===================== Run qiime_biom End at `date` ===================== "