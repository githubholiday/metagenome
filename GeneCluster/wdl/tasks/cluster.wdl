version 1.0
## 建议末尾加个Task，建议用蛇形命名法；
## 建议命名为功能_软件名_Task 来命名
task GeneClusterTask{
	input{
		Array[File] infa  ## 输入文件
        String outdir
        String prefix
        String MMSEQ2
        String mmseq2_para="--min-seq-id 0.5 -c 0.8 --cov-mode 0 --threads 4"
        String script
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
            make -f ~{script}/geneCluter.mk dna_fa=~{infa} outdir=~{outdir} prefix=~{outdir}/~{prefix} MMSEQ2=~{MMSEQ2} mmseq2_para=~{mmseq2_para} MMSEQ2
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
		File out_fa = "~{outdir}/~{prefix}_rep_seq.fasta" 
	}
} 
