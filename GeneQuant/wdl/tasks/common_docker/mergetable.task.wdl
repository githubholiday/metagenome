version 1.0 
task merge_table{
	input{
		Array[File] inputs
		String prefix="merge"
		Boolean column
		String finish_tag = "UNFINISH"  ## 必须有这个tag

		####config
		String docker
		String mount
		Int cpu = "1"
		String memory = "1 GB"
		String machine
		String outdir
		String sge_queue
		String logfile
		String step_name 
		String MakeFinishTag
		String READLOG


		###Script
		String PYTHON3
		String Merge_Py
	}
	command<<<
		set -e
		set -o
		job_state=$(~{READLOG} ~{finish_tag} ~{logfile} ~{step_name} | cut -f2)
		if [ "$job_state" != "FINISH" ];then
			mkdir -p ~{outdir}
			~{PYTHON3} ~{Merge_Py} -f ~{sep=" " inputs} -o ~{outdir}/~{prefix}.xls  ~{true='-t' false='' column}
			~{MakeFinishTag} ~{logfile} ~{step_name}
		fi
	>>>
	runtime{
		cpu: cpu
		memory: memory
		docker: docker
		mounts: mount
		cluster: machine
		sge_queue: sge_queue
	}

	output{
		File cmbfile = "~{outdir}/~{prefix}.xls"
	}
}
