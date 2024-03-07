BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
include $(config)

HELP:
	@echo Description: 此脚本用于宏基因组分箱后文件整理
	@echo Usage :
	@echo make -f makefile config= sample_list= indir=[result/PB_Binning] outdir=[Report/upload.bak/binninng] Binning_upload
	@echo 
	@echo [参数说明]    :
	@echo config        : [必选]流程配置文件
	@echo outdir        : [必选]输出目录
	@echo 

Binning_upload:
	echo PB_Binning upload start at `date`
	mkdir -p $(outdir)
	cat $(sample_list) |sed '1d'| while read sam group ; \
	do \
		if [ -f $(indir)/$$sam/Summary_Plots1.pdf ] ; \
		then \
			mkdir -p $(outdir)/$$sam/ ; \
			ln -sf $(indir)/$$sam/Summary_Plots1.pdf $(outdir)/$$sam/ ; \
			$(CONVERT) $(indir)/$$sam/Summary_Plots1.pdf $(outdir)/$$sam/Summary_Plots1.png ; \
			ln -sf $(indir)/$$sam/Summary_Plots2.pdf $(outdir)/$$sam/ ; \
			$(CONVERT) $(indir)/$$sam/Summary_Plots2.pdf $(outdir)/$$sam/Summary_Plots2.png ; \
		fi ; \
		cp $(indir)/$$sam/$$sam.bin_summary.xls  $(outdir)/$$sam/ ; \
		cp $(indir)/$$sam/$$sam.checkm_summary.xls  $(outdir)/$$sam/ ; \
		if [ `ls $(indir)/$$sam/filter_bins/*fa | wc -l | awk '{print $$1}'` -ge 1 ] ; \
		then \
			cp -rf $(indir)/$$sam/filter_bins/ $(outdir)/$$sam/ ; \
			for i in $(indir)/$$sam/*_plot/*.pdf ; \
			do \
				file=`echo $$i | sed -e "s/pdf/png/g"`; \
				$(CONVERT) $$i $$file ; \
			done ; \
			cp -rf $(indir)/$$sam/len_hist_plot/ $(outdir)/$$sam/ ; \
			cp -rf $(indir)/$$sam/marker_plot/ $(outdir)/$$sam/ ; \
			cp -rf $(indir)/$$sam/nx_plot/ $(outdir)/$$sam/ ; \
		fi \
	done
	#
	cat $(indir)/*/*.checkm_summary.xls | head -n 6 > $(outdir)/checkm_summary.web.xls
	cat $(indir)/*/*.bin_summary.xls | head -n 6 > $(outdir)/bin_summary.web.xls
	$(PYTHON3) $(BIN)/bin_samples.py -i $(indir)  -s $(sample_list)  -ob $(outdir)/bin_num_stat.xls -ot $(outdir)/taxonomy_summary.xls
	$(Rscript_kraken) $(BIN)/../Reads_Taxonomy/draw_richeness.r $(outdir)/taxonomy_summary.xls $(outdir)/taxonomy_summary.pdf T
	$(CONVERT) $(outdir)/taxonomy_summary.pdf $(outdir)/taxonomy_summary.png
	head -n5 $(outdir)/taxonomy_summary.xls > $(outdir)/taxonomy_summary.web.xls
	cp $(BIN)/readme.doc $(outdir)/
	echo PB_Binning upload start at `date`
