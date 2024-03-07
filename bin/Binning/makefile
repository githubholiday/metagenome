BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
include $(config)
threads?=10
completeness?=50
contamination?=50
contigs?=300

HELP:
	@echo Description: 此脚本用于宏基因组分箱
	@echo Usage :
	@echo make -f makefile config= contigs_fa= pb_index_file= input_bam= out_bam= outdir= Alignment
	@echo 
	@echo [参数说明]    :
	@echo config        : [必选]流程配置文件
	@echo contigs_fa    : [必选]组装结果
	@echo pb_index_file : [必选] pbmmi 索引文件
	@echo input_bam     : [必选]用于组装的输入文件
	@echo out_bam       : [必选]比对输出结果文件
	@echo outdir        : [必选]输出目录
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-03-12 by 'zhangyue' [yuezhang\@genome.cn];

Binning:
	echo Binning start at `date`
	[ -s $(outdir)/$(sample) ]|| mkdir -p $(outdir)/$(sample)
	$(BAM_DEPTH) --outputDepth $(outdir)/$(sample)/$(sample).depth.txt $(outdir)/$(sample)/$(sample).sort.bam 2> $(outdir)/$(sample)/jgi_summarize_bam_contig_depths.log.txt
	$(MetaBAT2) -i $(Assemble_Fa) -a $(outdir)/$(sample)/$(sample).depth.txt -o $(outdir)/$(sample)/$(sample) -t 16 -v &> $(outdir)/$(sample)/MetaBAT2.log.txt
	echo Binning end at `date`

Binning_Evalution:
	echo Binning_Evalution start at `date`
	[ -s $(outdir)/$(sample)/scratch ]|| mkdir -p $(outdir)/$(sample)/scratch
	if [ -f $(outdir)/$(sample)/batchfile.xls ]; then\
		rm $(outdir)/$(sample)/batchfile.xls ;\
	fi
	#$(CheckM) data setRoot $(checkM_database) & > $(outdir)/$(sample)/checkm.database.log
	if [ -f $(outdir)/$(sample)/$(sample).1.fa ]; then \
		cd $(outdir)/$(sample)/ && $(CheckM) lineage_wf -x fa -t 16 --pplacer_threads 4 --tmpdir ./scratch ./ ./ ;\
		$(CheckM) qa -o 2 $(outdir)/$(sample)/lineage.ms $(outdir)/$(sample) -f $(outdir)/$(sample)/checkm_summary.xls --tab_table ;\
	else \
		echo "no binning result for $(sample)" ;\
	fi
	echo Binning_Evalution end at `date`

Binning_Filter:
	echo Binning_Filter start at `date`
	$(PYTHON3) $(BIN)/script/CheckM-to-batch-GTDB.py -i $(outdir)/$(sample)/checkm_summary.xls -c $(completeness) -m $(contamination) -g $(contigs) -p $(outdir)/$(sample) -o $(outdir)/$(SAMPLE)/batchfile.xls -l $(outdir)/$(sample)/CheckM-to-batch-GTDB.log
	export GTDBTK_DATA_PATH=$(gtdbtk_database) && $(GTDBTK) classify_wf --batchfile $(outdir)/$(sample)/batchfile.xls --out_dir $(outdir)/$(sample) -x fa --prefix $(sample) --cpus 16 --pplacer_cpus 4 --scratch_dir $(outdir)/$(sample)/scratch
	$(PYTHON3) $(BIN)/script/Metabat-Plot.py -i $(outdir)/$(sample)/checkm_summary.xls -c $(completeness) -m $(contamination) -g $(contigs) -l $(sample) -o1 $(outdir)/$(sample)/Metabat_Plot_fig1.pdf -o2 $(outdir)/$(sample)/Metabat_Plot_fig2.pdf -o3 $(outdir)/$(sample)/Metabat_Plot_fig3.pdf -o4 $(outdir)/$(sample)/Metabat_Plot_fig4.pdf -o5 $(outdir)/$(sample)/Metabat_Plot_fig5.pdf -o6 $(outdir)/$(sample)/Metabat_Plot_fig6.pdf
	cut -f 1,6,7,8,9,12 $(outdir)/$(sample)/checkm_summary.xls > $(outdir)/$(sample)/checkm_summary_simple.xls
	$(PYTHON3) $(BIN)/script/genome-binning-summarizer.py -d $(outdir)/$(sample)/$(sample).depth.txt -b $(outdir)/$(sample)/batchfile.xls -c $(outdir)/$(sample)/checkm_summary_simple.xls -g $(outdir)/$(sample)/classify -j $(gtdbtk_database) -o $(outdir)/$(sample)/genome-binning-summarizer.xls --outdir $(outdir)/$(sample)/ -l $(outdir)/$(sample)/genome-binning-summarizer.log
	echo Binning_Filter start at `date`

Binning_plot:
	echo Binning_plot start at `date`
	[ -s $(outdir)/$(sample) ]|| mkdir -p $(outdir)/$(sample)
	$(Rscript) $(BIN)/script/bin_point.r $(outdir)/$(sample)/checkm_summary.xls $(outdir)/$(sample)/$(sample).allbin.pdf 1
	$(CONVERT) $(outdir)/$(sample)/$(sample).allbin.pdf $(outdir)/$(sample)/$(sample).allbin.png
	$(PYTHON3) $(BIN)/script/get_contig_summary.py -i $(outdir)/$(sample)/ -o $(outdir)/$(sample)/$(sample)-binning-contig.filter.xls
	$(Rscript) $(BIN)/script/bin_point.r $(outdir)/$(sample)/$(sample)-binning-contig.filter.xls $(outdir)/$(sample)/$(sample).filterbin.pdf 2
	$(CONVERT) $(outdir)/$(sample)/$(sample).filterbin.pdf $(outdir)/$(sample)/$(sample).filterbin.png
	echo Binning_plot end at `date`

Binning_stat:
	echo Binning_stat start at `date`
	[ -s $(outdir) ]||mkdir -p $(outdir)
	cat $(outdir)/*/*.checkm_summary.xls | head -n 6 > $(outdir)/checkm_summary.web.xls
	cat $(outdir)/*/*.bin_summary.xls | head -n 6 > $(outdir)/bin_summary.web.xls
	$(PYTHON3) $(BIN)/bin_samples.py -i $(outdir)  -s $(sample_list)  -ob $(outdir)/bin_num_stat.xls -ot $(outdir)/taxonomy_summary.xls
	$(QIIME2)/Rscript $(BIN)/../Reads_Taxonomy/draw_richeness.r $(outdir)/taxonomy_summary.xls $(outdir)/taxonomy_summary.pdf T
	$(CONVERT) $(outdir)/taxonomy_summary.pdf $(outdir)/taxonomy_summary.png
	head -n5 $(outdir)/taxonomy_summary.xls > $(outdir)/taxonomy_summary.web.xls
	for i in `ls $(outdir)/*/marker_plot/*pdf`;do \
		$(CONVERT) $$i $${i%.*}.png ;\
	done
	echo Binning_stat end at `date`

PB_Binning_plot:
	echo PB_Binning plot start at `date`
	### stat and plots
	if [ -f $(outdir)/$(sample)/checkm_summary.xls ] ; \
	then \
		awk -F"\t" '{print $$1"\t"$$2"\t"$$6"\t"$$7}' $(outdir)/$(sample)/checkm_summary.xls > $(outdir)/$(sample)/$(sample).checkm_summary.xls ; \
	fi
	if [ -f $(outdir)/$(sample)/genome-binning-summarizer.xls ] ; \
	then \
		awk -F"\t" '{print $$1"\t"$$7"\t"$$8"\t"$$9"\t"$$10"\t"$$2}' $(outdir)/$(sample)/genome-binning-summarizer.xls > $(outdir)/$(sample)/$(sample).bin_summary.xls ; \
		mkdir -p $(outdir)/$(sample)/filter_bins ; \
		grep -v "^BinName" $(outdir)/$(sample)/$(sample).bin_summary.xls | cut -f 1 | while read bin ; \
		do  \
			ln -sf $(outdir)/$(sample)/$${bin}.fa  $(outdir)/$(sample)/filter_bins ; \
		done \
	fi
	## plot
	if [ -s $(outdir)/$(sample)/filter_bins/ ] ; \
	then \
		mkdir -p $(outdir)/$(sample)/nx_plot/ ; \
		$(checkm) nx_plot --image_type pdf -x fa --font_size 15 $(outdir)/$(sample)/filter_bins/ $(outdir)/$(sample)/nx_plot/ ; \
		mkdir -p $(outdir)/$(sample)/marker_plot/ ; \
		$(checkm) marker_plot --image_type pdf -x fa --font_size 10 --width 10  --height 10 $(outdir)/$(sample)/ $(outdir)/$(sample)/filter_bins/ $(outdir)/$(sample)/marker_plot/ ; \
		mkdir -p $(outdir)/$(sample)/len_hist_plot/ ; \
		$(checkm) len_hist --image_type pdf --font_size 15 -x fa $(outdir)/$(sample)/filter_bins/  $(outdir)/$(sample)/len_hist_plot/ ; \
		rm -f $(outdir)/$(sample)/*plot/checkm.log ; \
		for i in $(outdir)/$(sample)/*plot/*.pdf ; \
		do \
			 file=`echo $$i | sed -e "s/pdf/png/g"`; \
			 echo convert $$i $$file ; \
		 done \
	fi
	echo PB_Binning plot end at `date`