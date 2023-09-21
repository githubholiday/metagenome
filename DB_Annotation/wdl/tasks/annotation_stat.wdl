version 1.0
## 建议末尾加个Task，建议用蛇形命名法；
## 建议命名为功能_软件名_Task 来命名

task COGStatTask{
	input{
		File anno_file  ## 输入文件
		File count_file
		File cog_anno
		String col
		String cog_count_out
		String cog_count_anno_out
		String PYTHON3
		String CSVTK
		String script
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String outdir  ## 输出目录
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
			make -f ~{script}/makefile anno_file=~{anno_file} count_file=~{count_file} outdir=~{outdir} col=~{col} cog_anno=~{cog_anno} cog_count_out=~{cog_count_out} cog_count_anno_out=~{cog_count_anno_out} PYTHON3=~{PYTHON3} CSVTK=~{CSVTK} COG_Stat
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
		File cog_out = "~{cog_count_anno_out}" 
		File cog_count = "~{cog_count_out}" 
	}
} 


task PHIStatTask{
	input{
		File anno_file  ## 输入文件
		File count_file
		String col
		String PYTHON3
		String PERL
		String script
		String phi_count_anno_out
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String outdir  ## 输出目录
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
			make -f ~{script}/makefile anno_file=~{anno_file} count_file=~{count_file} outdir=~{outdir} col=~{col} phi_count_anno_out=~{phi_count_anno_out} PYTHON3=~{PYTHON3} PHI_Stat
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
		File phi_out = "~{phi_count_anno_out}" 
	}
} 

task ARDBStatTask{
	input{
		File anno_file  ## 输入文件
		File count_file
		String col
		String ardb_db
		String PYTHON3
		String script
		String ardb_count_out
		String ardb_count_anno_out
		String CSVTK
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String outdir  ## 输出目录
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
			make -f ~{script}/makefile anno_file=~{anno_file} count_file=~{count_file} ardb_db=~{ardb_db} outdir=~{outdir} col=~{col} ardb_count_out=~{ardb_count_out} ardb_count_anno_out=~{ardb_count_anno_out}  PYTHON3=~{PYTHON3} CSVTK=~{CSVTK} ARDB_Stat
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
		File ardb_out = "~{ardb_count_anno_out}" 
		File ardb_count_file = "~{ardb_count_out}"
	}
}




task SplitFaTask{
	input{
		File infa  ## 输入文件
		String number
		String prefix
		String PERL
		String script
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String outdir  ## 输出目录
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
			make -f ~{script}/makefile infa=~{infa} number=~{number} outdir=~{outdir} prefix=~{prefix} PERL=~{PERL} split_fa
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
		Array[File] out_fa = glob("~{outdir}/~{prefix}*" )
	}
}
