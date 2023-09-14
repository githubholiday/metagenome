version 1.0 
task task_finish{
	input{
		String name
		String logfile
		String MakeFinishTag
		String? depend
		Array[String]? array_depend

		####config
		String docker
		String mount
		Int cpu = "1"
		String memory = "1 GB"
		String machine
		String sge_queue

	}
	command<<<
		set -e
		~{MakeFinishTag} ~{logfile} ~{name}
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
	}
}

task read_log{
	input{
		Array[String] all_step
		String logfile
		String finish_all 
		String READLOG
		####config
		String docker
		String mount
		Int cpu = "1"
		String memory = "1 GB"
		String machine
		String sge_queue

	}
	command<<<
		set -e
		~{READLOG} ~{finish_all} ~{logfile} ~{sep=" "  all_step }
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
		Map[String ,String ] work_process = read_map(stdout())
	}
}
