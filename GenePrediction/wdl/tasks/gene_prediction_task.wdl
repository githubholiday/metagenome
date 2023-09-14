version 1.0
## 建议末尾加个Task，建议用蛇形命名法；
## 建议命名为功能_软件名_Task 来命名
task GenePredictionTask{
	input{
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String step_name 
		String mod
		String user
		String MGM
		String logfile
        String outdir
        String sample
		File assemble_fa
		String script
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
			make -f ~{script}/genePrediction.mk user=~{user} MGM=~{MGM} pro_fa=~{outdir}/~{sample}/~{sample}.pro.fa dna_fa=~{outdir}/~{sample}/~{sample}.dna.fa out_gff=~{outdir}/~{sample}/~{sample}.gff assemble_fa=~{assemble_fa} mod=~{mod} GenePrediction
			~{MakeFinishTag} ~{logfile} ~{step_name}
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
		File dna_fa_out = "~{outdir}/~{sample}/~{sample}.dna.fa"
		File pro_fa_out = "~{outdir}/~{sample}/~{sample}.pro.fa"
		File gff = "~{outdir}/~{sample}/~{sample}.gff"
	}
} 

task GeneFilterTask{
	input{
		String SEQKIT
		String PYTHON3
		String script
		String sample
		String outdir
		File dna_fa
		Int gene_min_len
		String MakeFinishTag
		String READLOG
		String finish_tag = "UNFINISH"  ## 必须有这个tag
		String logfile
		String step_name 
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
			make -f ~{script}/genePrediction.mk dna_fa=~{dna_fa} gene_min_len=~{gene_min_len} sample=~{sample} outdir=~{outdir} GeneFilter
			make -f ~{script}/genePrediction.mk dna_fa=~{outdir}/~{sample}.nucleotide.filter.fa pro_fa=~{outdir}/~{sample}.pro.filter.fa Cds2aa
			~{MakeFinishTag} ~{logfile} ~{step_name}
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
		File stat = "~{outdir}/~{sample}.orf_stat.xls"
		File outfa = "~{outdir}/~{sample}.nucleotide.filter.fa"
		File outfa_pro = "~{outdir}/~{sample}.pro.filter.fa"
	}
} 

