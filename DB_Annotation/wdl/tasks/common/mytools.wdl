version 1.0 
task as_map{
	input{
		Array[String] list1
		Array[String] list2

        String AS_MAP


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
		~{AS_MAP}  ~{sep="," list1}  ~{sep="," list2}
	>>>
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		cluster: machine
		sge_queue: sge_queue
	}

	output{
        Map[String ,String ] out_map = read_map(stdout())
	}
}
task select_some{
	input{
		Array[String] list1
		Array[String] list2
		Array[String] list3

        String SELECT_SOME

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
		~{SELECT_SOME}  ~{sep="," list1}  ~{sep="," list2} ~{sep="," list3}
	>>> 
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		cluster: machine
		sge_queue: sge_queue
	}

	output{
        Array[String ] out_array = read_lines(stdout())
	}
}

task combine_array{
	input{
		Array[Array[String]] list1

        String COMBINE_ARRAT

		####config
		String docker
		String mount
		Int cpu = "1"
		String memory = "1 GB"
		String machine = "a"
		String sge_queue

	}
	command<<<
		set -e
		~{COMBINE_ARRAT}  ~{write_json(list1)}   
	>>> 
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		cluster: machine
		sge_queue: sge_queue
	}

	output{
        Array[String ] out_array = read_lines(stdout())
	}
}