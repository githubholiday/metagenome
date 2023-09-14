version 1.0
task getsize{
	input{
		### unit is GB
		File infile
		String def_filesize = "1"
		String def_resource = "1,2"
		String max_resource = "2,16"
		String express = "1,y/x"
		####config
		String docker
		String mount
		String GetSize_Py
		String PYTHON3
		String sge_queue="sci.q" 
		Int cpu=1
		String memory="2 GB"
	}
	command {
		set -e
		set -o
		${PYTHON3} ${GetSize_Py} -o resource.txt -i ${infile} -dfs ${def_filesize} -dre ${def_resource} -e ${express} -max ${max_resource}
	}
	runtime{
		cpu: cpu
		memory: memory
		#docker: docker
		mounts: mount
		sge_queue:sge_queue
	}
	output{
		Map[String,String] resource = read_map("resource.txt")
	}
}
