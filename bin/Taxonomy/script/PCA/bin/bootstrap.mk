bindir=$(dir  $(abspath $(firstword $(MAKEFILE_LIST))))
name=$(notdir $(firstword $(MAKEFILE_LIST)))
ifeq ($(strip $(config)),)
Bconfig=$(bindir)config/config.txt
else
Bconfig=$(config)
endif
include $(Bconfig)
thread?=4
out_dir=$(abspath $(outdir))
stdout=$(log)/stdout.log
stderr=$(log)/stderr.log

IN=$(shell /bin/bash $(bindir)/../../../public_tools/xls2txt/xls2txt.sh $(outdir)/tmp $(infile))
IN1=$(shell /bin/bash $(bindir)/../../../public_tools/xls2txt/xls2txt.sh $(outdir)/tmp $(infile1))
################ targets #######################
HELP:
	@echo 程序功能
	@echo 根据提供的matrix文件及condition文件进行主成分分析
	@echo
	@echo 程序参数
	@echo infile：[必选] 表达量矩阵文件，须有表头。
	@echo infile1：[必选] 样品分组对应关系文件，第一列为样品名，第二列为分组名，须有表头。
	@echo outdir：[必选] 输出路径。
	@echo 使用方法
	@echo make -f $(name) infile= infile1= outdir=  Main
	@echo
	@echo 程序更新
	@echo 20190415：增加colfile接口
	@echo 20200320：去掉colfile，修改只能画6组shape的bug

Main: PrePare PCA

PrePare:
	[ -d $(log) ] && echo $(log) exist || mkdir -p $(log)

PCA:
	@echo `date "+%Y%m%d %H:%M:%S"` "- PATHWAY - INFO - 开始获取输入文件" 1>$(stdout) 2>$(stderr)
	cd $(out_dir) && $(Rscript) $(bindir)/script/pca.r $(IN) $(IN1) $(out_dir) 
	@echo `date "+%Y%m%d %H:%M:%S"` "- PATHWAY - INFO - PCA过程完成" 1>>$(stdout) 2>>$(stderr)
	convert $(out_dir)/result/PCA.3d.pdf $(out_dir)/result/PCA.3d.png
	convert $(out_dir)/result/PCA_individual_dim1_dim2.pdf $(out_dir)/result/PCA_individual_dim1_dim2.png
	convert $(out_dir)/result/PCA_variable_dim1-dim2.pdf $(out_dir)/result/PCA_variable_dim1-dim2.png
	rm -rf $(out_dir)/result/demo
	mkdir -p $(out_dir)/result/demo
	head -n 4 $(out_dir)/result/PCA_summary.xls > $(out_dir)/result/demo/demo.PCA_summary.xls
	head -n 4 $(out_dir)/result/Sample_coordinate.xls > $(out_dir)/result/demo/demo.Sample_coordinate.xls
	head -n 4 $(out_dir)/result/Varable_gene_contrib.xls > $(out_dir)/result/demo/demo.Varable_gene_contrib.xls
	head -n 4 $(out_dir)/result/Variable_gene_cos2.xls > $(out_dir)/result/demo/demo.Variable_gene_cos2.xls
	cp $(bindir)/config/ReadMe.doc $(out_dir)/result/ReadMe.doc
	rm -rf $(out_dir)/tmp
Report:
	@echo `date "+%Y%m%d %H:%M:%S"` "- PATHWAY - INFO - 开始创建结题报告" 1>>$(stdout) 2>>$(stderr)
	$(PERL) $(bindir)/script/config2webconfig.pl -i $(bindir)/config/report.cf -o $(out_dir) -r 主成分分析
	cd $(out_dir) && $(PERL) $(generate_WebReport) -t $(out_dir)/report.template -o $(out_dir) -rc $(out_dir)/report.conf 
	#mv $(out_dir)/pdf.pdf $(out_dir)/主成分分析结题报告.pdf
	@echo `date "+%Y%m%d %H:%M:%S"` "- PATHWAY - INFO - 结题报告创建完成" 1>>$(stdout) 2>>$(stderr)
	#清理非结果文件
	rm -rf $(outdir)/tmp $(out_dir)/config $(out_dir)/report.conf $(out_dir)/report.template
