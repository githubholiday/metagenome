
version 1.0
import "tasks/common/report.task.wdl" as report_t
import "tasks/common/qc.task.wdl" as qc_t
import "tasks/common/struct.wdl" as structs
import "tasks/common/mergetable.task.wdl" as merge_t
import "tasks/common/get_size.task.wdl" as getsize_t
import "tasks/common/make_tag.wdl" as make_tag
import "tasks/common/mytools.wdl" as mytools
import "tasks/diamond.task.wdl" as blastp_t
import "tasks/annotation_stat.wdl" as anno_stat
import "tasks/kegg_task.wdl" as kegg_t
workflow Anno{
	input{
		File infa
		String outdir
		String number
		File count_file
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
		String upload_dir_suffix = "upload/Annotation"
		String upload_dir_KEGG = "upload/Annotation/KEGG"
		String upload_dir_PHI = "upload/Annotation/PHI"
		String upload_dir_ARDB = "upload/Annotation/ARDB"
		String upload_dir_COG = "upload/Annotation/COG"
		### 用于存放example的图片或者表格
		String upload_tools_suffix = "upload/tools" 
		### 用于存放中间过程重要文件，比如bam，bed这种，不需要交付给客户的
		String key_process_dir_suffix = "key_process/Annotation"
	   String key_process_dir_fa = "key_process/Annotation/Split_fa"
	   String key_process_dir_KEGG = "key_process/Annotation/KEGG"
	   String key_process_dir_COG = "key_process/Annotation/COG"
	   String key_process_dir_PHI = "key_process/Annotation/PHI"
	   String key_process_dir_ARDB = "key_process/Annotation/ARDB"
		String qc_dir_suffix = "qc/Annotation"
	}

	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["COG"]

	String logfile = logdir + "/Module.run.log.sql"

	call anno_stat.SplitFaTask  as split_fa   { 
		input:
			infa = infa,
			number = number,
			prefix = "split",
			PERL = config.software["PERL"],
			script = config.software["script"],
			outdir = outdir+"/Split_fa",
			
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "Split_Fa",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
		}

	scatter (i in range(length(split_fa.out_fa))){
		### 根据实际情况，添加task name
		### 请注意 step1_name_的最后一个下划线，作为连字符
		String scatter_name = "kegg_anno" + split_fa.out_fa[i]
		call blastp_t.BlastpTask  as kegg_blastp   { 
			input:
				pepfa = split_fa.out_fa[i],
				metDB = config.database["KEGG"],
				outfile = outdir+"/KEGG/Split_Result/KEGG.blast."+[i]+".txt",
				outdir = outdir+"/KEGG/Split_Result",
				diamond = config.software["DIAMOND"],
				MakeFinishTag = config.software["MakeFinishTag"],
				READLOG = config.software["READLOG"],

				finish_tag = all_finish_tag ,
				step_name = "KEGG_diamond_blastp_"+[i],
				logfile = logfile,

				mount = mount,
				cpu = config.environment["cpu"],
				docker = config.environment["docker"],
				sge_queue = config.environment["sge_queue"],
				memory = config.environment["memory"],
				machine = config.environment["machine"],
		}
		call kegg_t.KEGG_KOBas  as kegg_kobas   { 
			input:
				anno_file = kegg_blastp.anno_file,
				outfile = outdir+"/KEGG/Split_Result/KEGG.kobas."+[i]+".txt",
				outdir = outdir+"/KEGG/Split_Result",
				PYTHON3 = config.software["PYTHON3"],
				script =  config.software["script"],
				kobas_py = config.software["kobas_py"],
				kobas_db = config.database["kobas_db"],
				kobas_env = config.parameter["kobas_env"],


				MakeFinishTag = config.software["MakeFinishTag"],
				READLOG = config.software["READLOG"],

				finish_tag = all_finish_tag ,
				step_name = "KEGG_KOBAS+"+[i],
				logfile = logfile,

				mount = mount,
				cpu = config.environment["cpu"],
				docker = config.environment["docker"],
				sge_queue = config.environment["sge_queue"],
				memory = config.environment["memory"],
				machine = config.environment["machine"],
		}
	}
    call kegg_t.StatTask as kegg_stat   {
		input:
		    anno_file = kegg_kobas.kobas_out,
			count_file = count_file,
			kegg_count_out = outdir+"/KEGG/kegg.count.txt",
			outdir = outdir+"/KEGG/",
			pathway_out = outdir+"/KEGG/kegg.pathway.xls",
			kegg_out = outdir+"/KEGG/kegg.xls",
			outfile = outdir+"/KEGG/allsample_kegg_count.xls",
			PYTHON3 = config.software["PYTHON3"],
			script =  config.parameter["script"] , 
			CSVTK = config.parameter["CSVTK"],

			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "KEGG_Format_Stat",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],

	}
	call blastp_t.BlastpTask  as cog_blastp   { 
		input:
			pepfa = infa,
			metDB = config.database["COG"],
			outfile = outdir+"/COG/COG.blast.txt",
			outdir = outdir+"/COG/",
			diamond = config.software["DIAMOND"],
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "COG_Diamond_Blastp",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
	}
	call anno_stat.COGStatTask  as cog_stat   { 
		input:
			anno_file = cog_blastp.anno_file,
			count_file = count_file,
			cog_anno = config.database["COG_ANNO"],
			col = 1,
			cog_count_out = outdir+"/COG/COG.count.xls",
			cog_count_anno_out = outdir+"/COG/COG.count.anno.xls",
			PYTHON3 = config.software["PYTHON3"],
			CSVTK = config.parameter["CSVTK"],
			script =  config.parameter["script"],
		   
			outdir = outdir+"/COG/",
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "COG_Stat",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
	}

	call blastp_t.BlastpTask  as ardb_blastp   { 
		input:
			pepfa = infa,
			metDB = config.database["ARDB"],
			outfile = outdir+"/ARDB/ARDB.blast.txt",
			outdir = outdir+"/ARDB/",
			diamond = config.software["DIAMOND"],
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "ARDB_Diamond_Blastp",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
	}
	call anno_stat.ARDBStatTask  as ardb_stat   { 
		input:
			anno_file = ardb_blastp.anno_file,
			count_file = count_file,
			col = 1,
			ardb_db = config.database["ARDB_Relation"],
			ardb_count_out = outdir+"/ARDB/ARDB.count.xls",
			ardb_count_anno_out = outdir+"/ARDB/ARDB.count.anno.xls",
			outdir = outdir+"/ARDB/",
			PYTHON3 = config.software["PYTHON3"],
			script =  config.parameter["script"],
		   
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "ARDB_Stat",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
	}
	
	call blastp_t.BlastpTask  as phi_blastp   { 
		input:
			pepfa = infa,
			metDB = config.database["PHI"],
			outfile = outdir+"/PHI/PHI.blast.txt",
			outdir = outdir+"/PHI/",
			diamond = config.software["DIAMOND"],
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "PHI_Diamond_Blastp",
			logfile = logfile,

			mount = mount,
			cpu = config.environment["cpu"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			memory = config.environment["memory"],
			machine = config.environment["machine"],
	}
	call anno_stat.PHIStatTask  as phi_stat   { 
		input:
			anno_file = phi_blastp.anno_file,
			count_file = count_file,
			col = 1,
			PYTHON3 = config.software["PYTHON3"],
			script =  config.software["script"],
			PERL = config.parameter["PERL"],
			phi_count_anno_out =outdir+"/PHI/PHI.count.anno.xls", 
			outdir = outdir+"/PHI/",
		   
			MakeFinishTag = config.software["MakeFinishTag"],
			READLOG = config.software["READLOG"],

			finish_tag = all_finish_tag ,
			step_name = "ARDB_Stat",
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
	Array[Array[String]] upload_f = [ [cog_blastp.anno_file], [cog_stat.cog_count],[cog_stat.cog_out], [kegg_stat.kegg_pathway_out],[kegg_stat.kegg_ID_out],[kegg_stat.anno_count],kegg_kobas.kobas_out,[phi_stat.phi_out],[ardb_stat.ardb_out],[ardb_stat.ardb_count_file],split_fa.out_fa,kegg_blastp.anno_file]
	## 注意倒数第二个是tools，存放examples
	## 注意最后一个是 中间文件目录 
	Array[String] upload_p =[upload_dir_COG,upload_dir_COG,key_process_dir_COG,upload_dir_KEGG,upload_dir_KEGG,upload_dir_KEGG,upload_dir_KEGG,upload_dir_PHI,upload_dir_PHI,upload_dir_ARDB,upload_dir_ARDB, key_process_dir_fa,key_process_dir_KEGG ]

	
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



	}
	### 请如实填写，category(output, input)和required 必须要写清楚
	parameter_meta{
		infa:{
			description: "输入的蛋白fa文件", 
			required: "true" , 
			category:"input",
			type:"",
			optional:"",
			default:"" ,
			suffix:"fa"
		}
		count_file:{
			description: "输入的所有样本的基因表达count文件，第一行为样本，第一列为基因名", 
			required: "true" , 
			category:"input",
			type:"",
			optional:"",
			default:"" ,
			suffix:"txt"
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
			description: "可选参数,默认upload/COG",
			required: "false",  
			category:"input"
		}
		upload_tools_suffix:{
			description: "可选参数,存放示例文件,默认upload/tools",
			required: "false",  
			category:"input"
		}
		key_process_dir_suffix: {
			description: "可选参数，存放中间文件,key_process/COG",
			required: "false",  
			category:"input"
		}
		qc_dir_suffix:{
			description: "可选参数,默认qc/COG",
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
		author:""
		name:""
		version:"v1.0.1"
		mail:"@genome.cn"
		description:""
		software:"s1,s2,s3,s4,s5"
	}
}
