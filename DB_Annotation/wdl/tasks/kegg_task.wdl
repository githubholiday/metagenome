version 1.0
## 建议末尾加个Task，建议用蛇形命名法；
## 建议命名为功能_软件名_Task 来命名

task KEGG_KOBas{
	input{
		File anno_file  ## 输入文件
		String outfile
		String outdir
		String script
		String PYTHON3
		String kobas_py
		String kobas_db
		String kobas_env
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String logfile
		String mount
		Int cpu
		String docker
		String sge_queue
		String memory  		### unit is GB , 例如"2 GB"
		String machine 
	}
	command <<<
		set -euo pipefail ### 调试的时候可以加上-x 
		job_state=$(~{READLOG} ~{finish_tag} ~{logfile} ~{step_name} | cut -f2)
		if [ "$job_state" != "FINISH" ];then
			echo "###### task1 starts at $(date)"
			## command starts at here , 首先清理目录
			[ -d ~{outdir} ] && rm -rf ~{outdir}/* || mkdir -p ~{outdir} && echo directory ~{outdir} is ok
			make -f ~{script}/makefile infile=~{anno_file} outfile=~{outfile} PYTHON3=~{PYTHON3} annotate_py=~{kobas_py} kobas_home=~{kobas_db} blast_home=~{kobas_env} KOBAS_Anno
			~{MakeFinishTag} ~{logfile} ~{step_name}
			## 对于 多个*xls，想一起打包出来,建议用tar.gz，生成报告程序会自动解压
			cd ~{outdir} && tar -czf xls.tar.gz *xls && cd - 
			echo "###### task1 ends at $(date)"
		fi
	>>>
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		sge_queue:sge_queue
		cluster: machine
	}
	output{
		## 由于output是保留字，因此输出名不能output
		File kobas_out = "~{outfile} " 
	}
} 

task StatTask{
	input{
		Array[File] anno_file  ## 输入文件
		File count_file
		String kegg_count_out
		String outdir
		String pathway_out
		String kegg_out
		String outfile
		String script
		String PYTHON3
		String CSVTK
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String logfile

		String mount
		Int cpu
		String docker
		String sge_queue
		String memory  		### unit is GB , 例如"2 GB"
		String machine 
	}
	command <<<
		set -euo pipefail ### 调试的时候可以加上-x 
		job_state=$(~{READLOG} ~{finish_tag} ~{logfile} ~{step_name} | cut -f2)
		if [ "$job_state" != "FINISH" ];then
			echo "###### task1 starts at $(date)"
			## command starts at here , 首先清理目录
			[ -d ~{outdir} ] && rm -rf ~{outdir}/* || mkdir -p ~{outdir} && echo directory ~{outdir} is ok
			make -f ~{script}/makefile anno_file='~{sep=" " anno_file}' pathway_out=~{pathway_out} kegg_out=~{kegg_out} PYTHON3=~{PYTHON3} CSVTK=~{CSVTK} count_file=~{count_file} kegg_count_out=~{kegg_count_out} outfile=~{outfile} script=~{script} KEGG_Format
			~{MakeFinishTag} ~{logfile} ~{step_name}
			## 对于 多个*xls，想一起打包出来,建议用tar.gz，生成报告程序会自动解压
			cd ~{outdir} && tar -czf xls.tar.gz *xls && cd - 
			echo "###### task1 ends at $(date)"
		fi
	>>>
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		sge_queue:sge_queue
		cluster: machine
	}
	output{
		## 由于output是保留字，因此输出名不能output
		File kegg_pathway_out = "~{pathway_out}" 
		File kegg_ID_out = "~{kegg_out}"
		File anno_count = "~{outfile}"
	}
}

