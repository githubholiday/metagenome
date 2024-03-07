BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
file=$(abspath $(firstword $(MAKEFILE_LIST)))
ifdef config
	include $(config)
else 
	include $(BIN)/config/config.txt
endif
###默认参数

LDA?=2

Help:
	@echo Description:
	@echo -e "\t" 该脚本用于物种多样性分析
	@echo -e "\t" Author "\t": liaorui
	@echo target:
	@echo -e "\t" Alpha_qiime "\t": 使用qiime计算alpha多样性
	@echo -e "\t" Alpha_phyloseq "\t": 使用phyloseq计算alpha多样性
	@echo -e "\t" Alpha_vegan "\t": 使用vegan计算alpha多样性
	@echo -e "\t" Beta_qiime "\t": 使用qiime计算beta多样性
	@echo -e "\t" Diff_lefse "\t": 使用lefse进行差异分析
	@echo Usage:
	@echo -e "\t" make -f $(file) sample= outdir= Alpha_qiime
	@echo -e "\t" make -f $(file) sample=M31,M32,M33,M34,M35,M36 outdir=$(BIN)/output Alpha_qiime
	@echo -e "\t" make -f $(file) outdir= Alpha_vegan
	@echo -e "\t" make -f $(file) sample= outdir= Beta_qiime
	@echo Parameters:
	@echo -e "\t" sample "\t": 样本名称
	@echo -e "\t" outdir "\t": 输出目录路径
	@echo -e "\t" count "\t": 统计的count文件
	
qiime_format:
	[ -s $(outdir) ] || mkdir -p $(outdir)
	$(QIIME2)/biom convert -i $(outdir)/merge.qiime.xls -o $(outdir)/merge.biom  --to-hdf5 --table-type="OTU table"
	$(QIIME2)/qiime tools import --input-path $(outdir)/merge.biom --type 'FeatureTable[Frequency]' --input-format BIOMV210Format --output-path $(outdir)/all_qiime.qza

Alpha_vegan:
	echo Alpha_vegan start at `date`
	mkdir -p $(outdir)
	$(QIIME2)/Rscript $(BIN)/script/alpha_diversity.R $(merge_file) $(outdir)/alpha_vegan.tmp.xls
	sed '1cSample\tChao1\tACE\tObserved_species\tPielou\tShannon\tSimpson' $(outdir)/alpha_vegan.tmp.xls |cut -f 4 --complement > $(outdir)/alpha_vegan_out.xls
	if [ -s $(cmp2_file) ];\
	then \
		$(RSCRIPT) $(BIN)/script/boxplot.r $(outdir)/alpha_vegan_out.xls $(group_file) $(cmp2_file) $(outdir) 2 ;\
	else \
		echo ==================== file: $(cmp2_file) is empty, so will not draw this part boxplot picture =============== ;\
	fi
	if [ -s $(cmp3_file) ] ;\
	then \
		$(RSCRIPT) $(BIN)/script/boxplot.r $(outdir)/alpha_vegan_out.xls $(group_file) $(cmp3_file) $(outdir) 3 ;\
	else \
		echo ==================== file: $(cmp3_file) is empty, so will not draw this part boxplot picture =============== ;\
	fi
	if [ `ls $(outdir)/*pdf|wc -l ` -gt 1 ];then \
		cd $(outdir)/ && for i in `ls *pdf`;do $(CONVERT) $$i `basename $$i .pdf`.png;done ;\
	else \
		echo no pdf ;\
	fi
	echo Alpha_vegan end at `date`

Beta_qiime:
	echo Beta_qiime $(method) start at `date`
	[ -s $(outdir)/tmp/$(method) ] || mkdir -p $(outdir)/tmp/$(method)
	$(QIIME2)/qiime diversity beta --i-table $(qza_file) --p-metric $(method) --o-distance-matrix $(outdir)/beta_qiime_$(method).qza
	$(QIIME2)/qiime tools export --input-path $(outdir)/beta_qiime_$(method).qza --output-path $(outdir)/tmp/$(method)
	$(PYTHON3) $(BIN)/script/retain_float.py -i $(outdir)/tmp/$(method)/distance-matrix.tsv -o $(outdir)/beta_qiime_$(method).xls
	$(QIIME2)/Rscript $(BIN)/script/draw_heat.r $(outdir)/tmp/$(method)/distance-matrix.tsv $(outdir)/beta_qiime_$(method).heatmap.pdf
	$(CONVERT) $(outdir)/beta_qiime_$(method).heatmap.pdf $(outdir)/beta_qiime_$(method).heatmap.png
	echo Beta_qiime $(method) end at `date`

