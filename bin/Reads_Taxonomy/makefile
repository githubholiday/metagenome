BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
file=$(abspath $(firstword $(MAKEFILE_LIST)))
threads?=10
top?=10
kmer?=35

ifdef config
	include $(config)
else 
	include $(BIN)/config/config.txt
endif

ifeq ($(ref),no_host)
	R1=$(cleandir)/QC/filter/$(sample)_R1.fq.gz
	R2=$(cleandir)/QC/filter/$(sample)_R2.fq.gz
else
	R1=$(cleandir)/Host/$(sample)/$(sample)_umap_1.fq.gz
	R2=$(cleandir)/Host/$(sample)/$(sample)_umap_2.fq.gz
endif
alignment_dir=$(outdir)/assemble/$(sample)

Help:
	@echo Description:
	@echo -e "\t" 该脚本用于物种注释
	@echo -e "\t" Author "\t": liaorui
	@echo target:
	@echo -e "\t" kraken_bracken "\t": 使用braken和kraken进行注释
	@echo -e "\t" krona "\t": 使用krona绘制物种分布圈图
	@echo Usage:
	@echo -e "\t" make -f $(file) outdir= sample= cleandir= kraken_bracken
	@echo -e "\t" make -f $(file) outdir= sample= krona
	@echo Parameters:
	@echo -e "\t" outdir "\t": 输出文件夹
	@echo -e "\t" config "\t": 配置文件，可选，默认为config/config.txt
	@echo -e "\t" sample "\t": 样本名称
	@echo -e "\t" cleandir "\t": clean数据路径

kraken_bracken:
	mkdir -p $(outdir)
	echo kraken start at `date`
	$(Kraken2) --db $(kraken2_db) --paired --threads $(threads) --report $(outdir)/$(sample).kraken.report --output $(outdir)/$(sample).kraken.output $(R1) $(R2)
	$(Braken) -d $(kraken2_db) -i $(outdir)/$(sample).kraken.report -o $(outdir)/$(sample).bracken.count  -r $(kmer) -t $(threads)
	sed '1iFraction\tCount\tCount_Single_Type\tLevel\tTaxomony_ID\tTaxomony' $(outdir)/$(sample).kraken.report >$(outdir)/$(sample).kraken.report.xls
	sed '1iFraction\tCount\tCount_Single_Type\tLevel\tTaxomony_ID\tTaxomony' $(outdir)/$(sample).kraken_bracken_species.report >$(outdir)/$(sample).kraken_bracken_species.report.xls
	$(PYTHON3) $(BIN)/script/kreport2mpa.py -r $(outdir)/$(sample).kraken.report -o $(outdir)/$(sample).kraken_format.xls
	sed -i '1 i Sample\t$(sample)' $(outdir)/$(sample).kraken_format.xls
	$(PYTHON3) $(BIN)/script/stat_taxonomy_rate.py -r $(outdir)/$(sample).kraken.report -o $(outdir)/$(sample).map.stat.xls -s $(sample)
	echo kraken end at `date`

krona:
	echo krona start at `date`
	mkdir -p $(outdir)
	echo krona start at `date`
	$(PERL) $(BIN)/script/kraken2-translate.pl $(outdir)/$(sample).kraken.report > $(outdir)/$(sample).kraken2krona
	$(ktImportText) $(outdir)/$(sample).kraken2krona -o $(outdir)/$(sample).krona.html
	#$(PYTHON3) $(BIN)/script/stat_rpm.py -c $(outdir)/$(sample).bracken.count -o $(outdir)/ -s $(sample)
	echo krona end at `date`

stat:
	echo taxonomy stat start at `date`
	mkdir -p $(outdir)
	$(CSVTK) -t join  -i ${infile} -o ${outdir}/Taxonomy_stat.xls
	$(CSVTK) -t join --outer-join --na 0 -f 1 $(outdir)/*/*kraken_format.xls > $(outdir)/merge.qiime.xls
	sed -i "s#'##g" $(outdir)/merge.qiime.xls && sed -i 's/#//g' $(outdir)/merge.qiime.xls && sed -i 's#/##g' $(outdir)/merge.qiime.xls
	$(PYTHON3) $(BIN)/script/micro.split.py -i $(outdir)/merge.qiime.xls -o $(outdir)
	echo taxonomy stat end at `date`
	

Draw_rich_heat:
	echo "Draw top ${top} rich & heat start at" `date`
	mkdir -p $(outdir)
	$(PYTHON3) $(BIN)/script/get_top.py -i $(outdir)/../Kraken/*/*kraken_format.xls -o $(outdir)/Species_count.xls
	# for Sample
	for i in Phylum Class Order Family Genus Species ;\
	do \
		$(RSCRIPT) $(BIN)/script/get_top.r $(indir)/merge.qiime_$$i.xls $(outdir)/top$(top)_$${i}_Sample.xls $(top) Sample;\
		$(RSCRIPT) $(BIN)/script/draw_richness.r $(outdir)/top$(top)_$${i}_Sample.xls $(outdir)/richness_top$(top)_$${i}_Sample.pdf Sample;\
		$(RSCRIPT) $(BIN)/script/draw_heat.r $(outdir)/top$(top)_$${i}_Sample.xls $(outdir)/heatmap_top$(top)_$${i}_Sample.pdf ;\
	done
	# for Group
	for i in Phylum Class Order Family Genus Species ;\
	do \
		$(RSCRIPT) $(BIN)/script/get_top.r $(indir)/merge.qiime_$$i.xls $(outdir)/top$(top)_$${i}_Group.xls $(top) Group $(groupFile);\
		$(RSCRIPT) $(BIN)/script/draw_richness.r $(outdir)/top$(top)_$${i}_Group.xls $(outdir)/richness_top$(top)_$${i}_Group.pdf Group;\
		$(RSCRIPT) $(BIN)/script/draw_heat.r $(outdir)/top$(top)_$${i}_Group.xls $(outdir)/heatmap_top$(top)_$${i}_Group.pdf ;\
	done
	cd $(outdir)/ && for i in `ls *.pdf`;do $(CONVERT) $$i `basename $$i .pdf`.png;done
	echo "Draw top ${top} rich & heat end at" `date`

