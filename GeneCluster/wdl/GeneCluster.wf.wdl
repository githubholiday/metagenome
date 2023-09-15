
version 1.0
import "tasks/common/report.task.wdl" as report_t
import "tasks/common/qc.task.wdl" as qc_t
import "tasks/common/struct.wdl" as structs
import "tasks/common/mergetable.task.wdl" as merge_t
import "tasks/common/get_size.task.wdl" as getsize_t
import "tasks/common/make_tag.wdl" as make_tag
import "tasks/common/mytools.wdl" as mytools
import "tasks/cluster.wdl" as cluter_t
workflow GeneCluster{
	input{
		Array[File] infas
        String outdir
        String prefix
        String mmseq2_para="--min-seq-id 0.5 -c 0.8 --cov-mode 0 --threads 4"

		String report_json
		File config_json
		String mount
		String logdir = outdir + "/log"

		String? qc_dir
		String? workid
		String? reportdir = outdir + "/report"
		String? project_name


		#### 该模块是否已运行完成，如果非 FINISHI，会允许该task
		String all_finish_tag = "UNFINISH"  
		String upload_dir_suffix = "upload/GeneCluster"
		### 用于存放example的图片或者表格
		String upload_tools_suffix = "upload/tools" 
		### 用于存放中间过程重要文件，比如bam，bed这种，不需要交付给客户的
		String key_process_dir_suffix = "key_process/GeneCluster"

		String qc_dir_suffix = "qc/GeneCluster"
	}

	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["GeneCluster"]

	### 根据实际情况，添加task name
	String logfile = logdir + "/Module.run.log.sql"

	
		### 请注意 step1_name_的最后一个下划线，作为连字符
	String scatter_name = "mmseq2"
	call cluter_t.GeneClusterTask  as clutertask   { 
		input:
            infa = infas,
            prefix = prefix,
            MMSEQ2 = config.software["MMSEQ2"],
            mmseq2_para = mmseq2_para,
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

	## 最终结果目录的readme，必须要添加
	## 如果没有image_example,请对应删除； 文件名应该尽量长，避免重复；并且类型是array
	## 如果没有中间文件，请对应的删除，
	Array[Array[String]] upload_f = [ [clutertask.out_fa],  [config.parameter["readme"]]]
	## 注意倒数第二个是tools，存放examples
	## 注意最后一个是 中间文件目录 
	Array[String] upload_p =[upload_dir_suffix,upload_dir_suffix]

	
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

		Array[File] out_fa = clutertask.out_fa

	}
	### 请如实填写，category(output, input)和required 必须要写清楚
	parameter_meta{
		infas:{
			description: "所有样本的fa列表", 
			required: "true" , 
			category:"input",
			type:"Array[File]",
			optional:"",
			default:"" ,
			suffix:"fa"
		}
        prefix:{
            description: "mmseq2输出结果的前缀", 
            required: "true" , 
            category:"input",
            type:"String",
            optional:"",
            default:"" ,
            suffix:""
        }
        mmseq2_para:{
            description: "mmseq2参数", 
            required: "true" , 
            category:"input",
            type:"String",
            optional:"",
            default:"--min-seq-id 0.5 -c 0.8 --cov-mode 0 --threads 4" ,
            suffix:""
        }
        outdir:{
            description: "结果路径", 
            required: "true" , 
            category:"output",
            type:"String",
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
			description: "可选参数,默认upload/GeneCluster",
			required: "false",  
			category:"input"
		}
		upload_tools_suffix:{
			description: "可选参数,存放示例文件,默认upload/tools",
			required: "false",  
			category:"input"
		}
		key_process_dir_suffix: {
			description: "可选参数，存放中间文件,key_process/GeneCluster",
			required: "false",  
			category:"input"
		}
		qc_dir_suffix:{
			description: "可选参数,默认qc/GeneCluster",
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
		author:"Holiday T"
		name:"mmseq2聚类fasta"
		version:"v1.0.0"
		mail:"chengfang@genome.cn"
		description:"使用mmdseq2对fasta进行聚类，使用easy_cluster 功能"
		software:"MMSEQ2"
	}
}