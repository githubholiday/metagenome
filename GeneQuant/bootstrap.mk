BIN=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
log = $(outdir)
bucket=oss://annoroad-cloud-product/user

#将此处改为workflow的文件名,在下面的run中会用
model_name_wdl=GeneQuant.wf.wdl

HELP:
	@echo 程序功能:
	@echo Bam统计+Report
	@echo
	@echo 程序参数 :
	@echo "jobId: [必选]任务id (参数名固定)"
	@echo "input: [必选]输入参数（不固定，根据实际情况确认）"
	@echo "outdir: [必选]输出目录 （参数名固定）"
	@echo 使用方法
	@echo make -f bootstrap.mk input= jobId=  log= outdir= Main
	@echo
	@echo  Parameters:
	@echo -e "\t" jobId:任务id
	@echo -e "\t" input:输入参数，比对后的bam文件
	@echo -e "\t" log:运行记录存放目录
	@echo 程序更新:
	@echo v1.0.0 2020-06-02 by 'xueren' [xueren\@annoroad.com];

Widdler:
	#input.json-wdl的输入json,,option_template.json-结果数拷贝json,不需要修改内容
	cp $(BIN)input/input.json $(BIN)input/$(jobId)_input.json
	#将上面json中的变量替换成传入的参数
	sed -i 's#@bam#$(bam)#g' $(BIN)input/$(jobId)_input.json
	sed -i 's#@mount#$(BIN)#g' $(BIN)input/$(jobId)_input.json
	sed -i 's#@workid#$(jobId)#g' $(BIN)input/$(jobId)_input.json
	sed -i 's#@prefix#$(prefix)#g' $(BIN)input/$(jobId)_input.json
	sed -i 's#@reportdir#$(outdir)#g' $(BIN)input/$(jobId)_input.json
	sed -i 's#@config#$(BIN)config/config.json#g' $(BIN)input/$(jobId)_input.json

	#以下是固定内容，不需要修改
	sed -i 's#/oss#oss://annoroad-cloud-product#g' $(BIN)input/$(jobId)_input.json
	#sed -i 's#/oss#oss://annoroad-cloud-product#g' $(BIN)input/$(jobId)_option.json
	more $(BIN)input/$(jobId)_input.json
	#more $(BIN)input/$(jobId)_option.json
	cd $(BIN)wdl && widdler run $(model_name_wdl) $(BIN)input/$(jobId)_input.json  -o bcs_workflow_tag:cromwell-test -d tasks.zip -S annoroad-cromwell-server -j $(jobId)
	rm -rf $(BIN)input/$(jobId)_input.json
	#rm -rf $(BIN)input/$(jobId)_option.json

Prepare:
	[ -d $(outdir) ] && echo $(outdir) exist || mkdir -p $(outdir)
	[ -d $(log) ] && echo $(log) exist || mkdir -p $(log)

Main:Prepare Widdler
