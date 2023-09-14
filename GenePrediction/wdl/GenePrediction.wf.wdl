
version 1.0
import "tasks/common/report.task.wdl" as report_t
import "tasks/common/qc.task.wdl" as qc_t
import "tasks/common/struct.wdl" as structs
import "tasks/common/mergetable.task.wdl" as merge_t
import "tasks/common/get_size.task.wdl" as getsize_t
import "tasks/common/make_tag.wdl" as make_tag
import "tasks/common/mytools.wdl" as mytools
import "tasks/gene_prediction_task.wdl" as gene_prediction_t
workflow GenePrediction{
	input{
		String user
		Array[String] samples
		Array[File] assemble_fas
		Int gene_min_len = 200
		String report_json
		File config_json
		String mount
		String outdir
		String logdir = outdir + "/log"

		String? qc_dir
		String? workid
		String? reportdir = outdir + "/report"
		String? project_name


		#### 该模块是否已运行完成，如果非 FINISHI，会允许该task
		String all_finish_tag = "UNFINISH"  
		String upload_dir_suffix = "upload/GenePrediction"
		### 用于存放example的图片或者表格
		String upload_tools_suffix = "upload/tools" 
		### 用于存放中间过程重要文件，比如bam，bed这种，不需要交付给客户的
		String key_process_dir_suffix = "key_process/GenePrediction"

		String qc_dir_suffix = "qc/GenePrediction"
	}

	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["GenePrediction"]

	### 根据实际情况，添加task name
	String logfile = logdir + "/Module.run.log.sql"

	scatter (i in range(length(samples))){
		### 请注意 step1_name_的最后一个下划线，作为连字符
		String scatter_name = "gene_prediction_task" + samples[i]
		call gene_prediction_t.GenePredictionTask  as gene_prediction_task   { 
			input:
				assemble_fa = assemble_fas[i],
                sample = samples[i],
                outdir=outdir,
				user = user,
				script = config.software["script"],
				mod = config.software["mod"],
				MGM = config.software["MGM"],
				gmhmmp_parematers = config.software["gmhmmp_parematers"],

				MakeFinishTag = config.software["MakeFinishTag"],
				READLOG = config.software["READLOG"],

				finish_tag = all_finish_tag ,
				step_name = scatter_name,
				logfile = logfile,

				mount = mount,
				cpu = config.environment["cpu"],
				docker = config.environment["docker"],
				sge_queue = config.environment["sge_queue"],
				memory = config.environment["memory"],
				machine = config.environment["machine"],
		}
		call gene_prediction_t.GeneFilterTask  as gene_filter_task   { 
			input:
				sample = samples[i],
				dna_fa = gene_prediction_task.dna_fa_out,
				gene_min_len = gene_min_len,
				
				script = config.software["script"],
				SEQKIT = config.software["SEQKIT"],
				PYTHON3 = config.software["PYTHON3"],
				MakeFinishTag = config.software["MakeFinishTag"],
				READLOG = config.software["READLOG"],

				finish_tag = all_finish_tag ,
				step_name = scatter_name,
				outdir = outdir,
				logfile = logfile,

				mount = mount,
				cpu = config.environment["cpu"],
				docker = config.environment["docker"],
				sge_queue = config.environment["sge_queue"],
				memory = config.environment["memory"],
				machine = config.environment["machine"],
		}
	}
	call merge_t.merge_table as merge_table {
		input:
			inputs = gene_filter_task.stat,
			prefix = "ORF.stat",
			column=false,
			step_name = "merge_table",
			MakeFinishTag = config.software["MakeFinishTag"],
			logfile = logfile,
			outdir=outdir,
			PYTHON3=config.software["PYTHON3"],
			Merge_Py=config.software["Merge_Py"],
			mount = mount,
			machine = config.environment["machine"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			cpu = config.environment["cpu"],
			memory = config.environment["memory"]
	}


	## 最终结果目录的readme，必须要添加
	## 如果没有image_example,请对应删除； 文件名应该尽量长，避免重复；并且类型是array
	## 如果没有中间文件，请对应的删除，
	Array[Array[String]] upload_f = [gene_prediction_task.pro_fa_out ,gene_prediction_task.dna_fa_out, gene_prediction_task.gff, gene_filter_task.outfa,gene_filter_task.outfa_pro,[merge_table.cmbfile] ]
	## 注意倒数第二个是tools，存放examples
	## 注意最后一个是 中间文件目录 
	Array[String] upload_p =[key_process_dir_suffix,key_process_dir_suffix,upload_dir_suffix ,upload_dir_suffix,upload_tools_suffix,upload_tools_suffix ]

	
	if (defined(workid) && defined(reportdir)) {
		call report_t.oss_report as report{
			input:
			## 可调参数
			workid = workid,		  ## 项目编号
			reportdir = reportdir,	## 报告存放路径
			project_name = project_name,	 ## 报告名称
			report_json = report_json,
			
			## 配置参数不用调整
			upload_file = upload_f,
			upload_place = upload_p,
			config_json = config_json,
			mount = mount

		}
	}

	Array[Array[String]] qc_f = [ ]
	Array[String] qc_p =[]

	
	if (defined(workid) && defined(qc_dir)) {
		call qc_t.check as qc_check{
			input:
			## 可调参数
			qc_dir = qc_dir,	## 报告存放路径
			project_name = project_name,	 ## 报告名称
			workid = workid, 

			## 配置参数不用调整
			upload_file = qc_f,
			upload_place = qc_p,
			config_json = config_json,
			mount = mount

		}
	}


	output{
		Array[Array[String]] upload_file = upload_f
		Array[String] upload_place = upload_p
		Array[Array[String]] qc_file = qc_f
		Array[String] qc_place = qc_p
		Array[File] dna_fa = gene_filter_task.outfa
		Array[File] pro_fa = gene_filter_task.outfa_pro

	}
	### 请如实填写，category(output, input)和required 必须要写清楚
	parameter_meta{
		samples:{
			description: "样本名称，主要用于识别任务执行情况", 
			required: "true" , 
			category:"input",
			type:"Array[String]",
			optional:"",
			default:"" ,
			suffix:""
		}
		assemble_fas:{
			description: "fa文件列表", 
			required: "true" , 
			category:"input",
			type:"Array[File]",
			optional:"",
			default:"" ,
			suffix:"fa"
		}	
		user:{
			description: "用户名称",
			required: "true" ,
			category:"input",
			type:"String",
			optional:"",
			default:"" ,
			suffix:""
		}
		gene_min_len:{
			description: "基因最小长度",
			required: "true" ,
			category:"input",
			type:"Int",
			optional:"",
			default:"200" ,
			suffix:""
		}

		pro_fas:{
			description: "基因预测输出的蛋白fa文件列表", 
			required: "true" , 
			category:"output",
			type:"Array[File]",
			optional:"",
			default:"" ,
			suffix:"fa"
		}
		dna_fas:{
			description: "基因预测输出的基因的fa文件列表", 
			required: "true" , 
			category:"output",
			type:"Array[File]",
			optional:"",
			default:"" ,
			suffix:"fa"
		}
		out_gffs:{
			description: "基因预测输出的gff文件列表", 
			required: "true" , 
			category:"output",
			type:"Array[String]",
			optional:"",
			default:"" ,
			suffix:"gff"
		}


		config_json:{
			description: "默认参数，配置文件，config/config.sge.json", 
			required: "true" , 
			category:"input"
		}
		mount:{
			description: "可选参数，挂载路径，云平台用", 
			required: "true" , 
			category:"input"
		}
		logdir: {
			description: "必选参数，日志路径", 
			required: "true" , 
			category:"input"
		}
		qc_dir: {
			description: "可选参数，QC路径", 
			category:"input"
		}
		workid:{
			description: "可选参数，任务编号，若生成报告则必填", 
			category:"input"
		}
		reportdir:{
			description: "可选参数，报告路径，若生成报告则必填" , 
			category:"input"
		}
		project_name:{
			description: "可选参数，报告名称，若生成报告则必填",  
			category:"input"
		}
		all_finish_tag:{
			description: "可选参数,如果设置为FINISH,则跳过，默认不给",
			required: "false",  
			category:"input"
		}
		upload_dir_suffix:{
			description: "可选参数,默认upload/GenePrediction",
			required: "false",  
			category:"input"
		}
		upload_tools_suffix:{
			description: "可选参数,存放示例文件,默认upload/tools",
			required: "false",  
			category:"input"
		}
		key_process_dir_suffix: {
			description: "可选参数，存放中间文件,key_process/GenePrediction",
			required: "false",  
			category:"input"
		}
		qc_dir_suffix:{
			description: "可选参数,默认qc/GenePrediction",
			required: "false",  
			category:"input"
		}
		output_bams:{
			description: "输出的bam列表",
			required: "false",  
			category:"output",
			suffix:"bam",
			type:"Array[String]"
		}

	}
	meta{
		author:"HolidayT"
		name:"基因预测以及长度过滤"
		version:"v1.0.0"
		mail:"chengfang@genome.cn"
		description:""
		software:"PYTHON3,MetaGeneMark_linux_64,SEQKIT"
	}
}
