
version 1.0
import "tasks/common/report.task.wdl" as report_t
import "tasks/common/qc.task.wdl" as qc_t
import "tasks/common/struct.wdl" as structs
import "tasks/common/mergetable.task.wdl" as merge_t
import "tasks/common/get_size.task.wdl" as getsize_t
import "tasks/common/make_tag.wdl" as make_tag
import "tasks/common/mytools.wdl" as mytools
import "tasks/quant.wdl" as gene_quant_t
workflow GeneQuant{
	input{
		Array[String] R1s
        Array[String] R2s
		Array[String] samples
        File ref

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
		String upload_dir_suffix = "upload/GeneQuant"
		### 用于存放example的图片或者表格
		String upload_tools_suffix = "upload/tools" 
		### 用于存放中间过程重要文件，比如bam，bed这种，不需要交付给客户的
		String key_process_dir_suffix = "key_process/GeneQuant"

		String qc_dir_suffix = "qc/GeneQuant"
	}

	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["GeneQuant"]

	### 根据实际情况，添加task name
	String logfile = logdir + "/Module.run.log.sql"

	scatter (i in range(length(samples))){
		### 请注意 step1_name_的最后一个下划线，作为连字符
		String scatter_name = "gene_quant_" + samples[i]
		call gene_quant_t.GeneQuantTask  as gene_quant_task   { 
			input:
                sample = samples[i],
                ref = ref,
                R1 = R1s[i],
                R2 = R2s[i],
                outdir = outdir+"/"+samples[i],
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
			## 修改以下三个
			inputs = gene_quant_task.tpm_file,
			step_name = "merge_table",
			prefix = "gene_quant_task",

			finish_tag = all_finish_tag ,
			column=false,
			outdir=outdir,
			READLOG = config.software["READLOG"],
			MakeFinishTag = config.software["MakeFinishTag"],
			logfile = logfile,

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
	Array[Array[String]] upload_f = [[merge_table.cmbfile] , gene_quant_task.tpm_file]
	## 注意倒数第二个是tools，存放examples
	## 注意最后一个是 中间文件目录 
	Array[String] upload_p =[upload_dir_suffix,upload_dir_suffix ]

	
	if (defined(workid) && defined(reportdir)) {
		call report_t.oss_report as report{
            input:
			## 可调参数
			workid = workid,          ## 项目编号
			reportdir = reportdir,    ## 报告存放路径
			project_name = project_name,     ## 报告名称
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
			qc_dir = qc_dir,    ## 报告存放路径
			project_name = project_name,     ## 报告名称
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

		Array[String] sample_tpm = gene_quant_task.tpm_file

	}
	### 请如实填写，category(output, input)和required 必须要写清楚
	parameter_meta{
		ref:{
			description: "基因组fa文件", 
			required: "true" , 
			category:"input",
			type:"File",
			optional:"",
			default:"" ,
			suffix:"fa"
		}
        R1s:{
            description: "输入样品R1 fastq文件列表", 
            required: "true" , 
            category:"input",
            type:"Array[String]",
            optional:"",
            default:"" ,
            suffix:"fastq.gz"
        }
        R2s:{
            description: "输入样品R2 fastq文件列表", 
            required: "true" , 
            category:"input",
            type:"Array[String]",
            optional:"",
            default:"" ,
            suffix:"fastq.gz"
        }

		samples:{
			description: "输入样品名列表", 
			required: "true" , 
			category:"input",
			type:"Array[String]",
			optional:"",
			default:"" ,
			suffix:""
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
		outdir:{
			description: "必选参数，结果路径", 
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
		report_json:{
			description: "报告参数，配置文件，传递string到report中", 
			required: "false" , 
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
			description: "可选参数,默认upload/GeneQuant",
			required: "false",  
			category:"input"
		}
		upload_tools_suffix:{
			description: "可选参数,存放示例文件,默认upload/tools",
			required: "false",  
			category:"input"
		}
		key_process_dir_suffix: {
			description: "可选参数，存放中间文件,key_process/GeneQuant",
			required: "false",  
			category:"input"
		}
		qc_dir_suffix:{
			description: "可选参数,默认qc/GeneQuant",
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
		author:"Holiday Tu"
		name:"使用salmon软件进行基因定量"
		version:"v1.0.0"
		mail:"chengfangtu@genome.cn"
		description:""
		software:"salmon"
	}
}