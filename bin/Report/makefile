BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))/script

ifdef pipe_config
	include $(pipe_config)
else
	include $(BIN)/../config/config.txt
endif

user=admin
template=$(BIN)/../config/metagenome.template
upload_config=$(BIN)/../config/upload.config
keep=$(BIN)/../config/keep.list

HELP:
	@echo Description: 此脚本用于宏基因组流程生成结题报告
	@echo Usage :
	@echo make -f makefile config= template= report_conf= admin= upload= indir= outdir= template_all= upload_config= keep= sample= Report
	@echo 
	@echo [参数说明]:
	@echo pipe_config  : [必选]流程配置文件
	@echo config       : [必选]项目配置文件
	@echo template     : [必选]结题报告模板
	@echo report_conf  : [必选]结题报告配置文件
	@echo admin        : [必选]用户名，admin
	@echo upload       : [必选]结题报告目录 upload 路径
	@echo indir        : [必选]输入目录，项目 Result路径
	@echo outdir       : [必选]输出目录，项目 Report路径
	@echo template_all : [必选]流程中结题报告模板，包含所有模块
	@echo upload_config: [必选]流程中结题配置文件，根据该文件将结果连接到upload，生成template
	@echo keep         : [必选]流程中结题配置文件，根据该文件生成template的公共模块
	@echo sample       : [必选]sample.list文件，获取样本数目
	@echo 
	@echo [Version]:
	@echo v1.0.0 2020-02-11 by 'zhangyue' [yuezhang\@genome.cn];
	@echo 再一次输入用法：make -f makefile config= template= report_conf= user= upload= indir= outdir= template_all= upload_config= keep= sample= Report

Get_Upload:
	echo get upload start at `date`
	mkdir -p $(outdir)/upload
	cp ${samplelist} $(outdir)/sample.list
	$(PYTHON3) $(BIN)/report_conf.py -c $(config) -o $(outdir)/report.config -u $(outdir)/upload
	$(PYTHON3) $(get_upload) -c $(upload_config) -o $(outdir) -i $(outdir)/../ -t $(template) -b $(BIN)/../ -d public -n
	echo get upload end at `date`

Report:
	echo generate report start at `date`
	cp -r $(BIN)/../config/html $(outdir)/
	echo 'cd $(outdir) && ssh 192.168.1.3 $(PYTHON3) $(report_py) -i $(outdir)/template.new -c $(outdir)/report.config -u $(user) -t cloud' >$(outdir)/report.sh
	cd $(outdir) && ssh 192.168.1.3 $(PYTHON3) $(report_py) -i $(outdir)/template.new -c $(outdir)/report.config -u $(user) -t cloud
	echo generate report end at `date`

pipeline_record:
	@echo "===================== pipeline_record  Begin at `date` ===================== "
	$(PYTHON3) $(BIN)/pipeline_stat.py -p $(project_id) -d $(analysis_dir) -c $(config)
	@echo "===================== pipeline_record  End at `date` ===================== "

example:
	echo "===================== generate example file ============="
	less $(infile) |head -2 |$(TRANSPOSE) > $(outdir)/$(outfile) 
