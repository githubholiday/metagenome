version 1.0
import "struct.wdl" as structs
workflow check{
	input{
		Array[Array[File]] upload_file
		Array[String] upload_place
		String? workid
		String? qc_dir
		String? project_name="结题报告"
		String mount
		File config_json 
	}
	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["report"]
	call wdl_report{
		input:
			upload_file = upload_file,
			upload_place = upload_place,
			workid =workid,
			qc_dir = qc_dir,
			project_name = project_name,
			mount = mount,
			## 报告配置文件,根据需要调整
			input_json = config.parameter["input_json"],
			template_md = config.parameter["template_md"],
			table_software = config.parameter["table_software"],
			qc_config = config.parameter["qc_config"],
			platform = config.parameter["platform"],
			BIN = config.software["BIN"],
			report_config = config.parameter["report_config"],

			## 不用调整	
			PYTHON3 = config.software["PYTHON3"],
			machine = config.environment["machine"],
			docker = config.environment["docker"],
			sge_queue = config.environment["sge_queue"],
			cpu = config.environment["cpu"],
			memory = config.environment["memory"]
	}
	output{
		File? report_url = wdl_report.report_url
	}
}
task wdl_report{ 
	input{
		Array[Array[File]] upload_file
		Array[String] upload_place
		File qc_config
		File template_md
		File input_json
		String table_software
		String? workid="12345678"
		String? qc_dir
		String? project_name="结题报告"
		File report_config
		String platform 
			
		####config
		String docker
		String mount
		Int cpu = "2"
		String memory = "4 GB"
		String machine
		String sge_queue

		###Script
		String PYTHON3
		String BIN
	}
	command<<<
		set -e
		if [[ "~{qc_dir}" =~ "oss://" ]];then \
			paste -d"\t" ~{write_tsv(upload_file)} ~{write_lines(upload_place)} >upload.map ;\
			~{PYTHON3} ~{BIN}/generate_md_report/file_cp.py -f upload.map ;\
			cp -rf ~{template_md} ./ ;\
			cp -rf ~{input_json} ./ ;\
			ls  *;\
			sed -i -e 's/$/  /g' template.md ;\
			~{BIN}/others/report ~{BIN}/others/ossutil in cp "-rf upload  ~{qc_dir}/upload --update" ;\
			~{PYTHON3} ~{BIN}/others/get_backend.py -i ./ -c ~{report_config} -w "~{workid}" -s ~{BIN}/backend/~{platform}.sh -o ./report.sh -t "~{project_name}" -b ~{BIN};\
			sh ./report.sh ;\
		else \
			mkdir -p ~{qc_dir} ;\
			paste -d"\t" ~{write_tsv(upload_file)} ~{write_lines(upload_place)} >~{qc_dir}/upload.map ;\
			[ -s ~{qc_dir}/upload ] && rm -rf ~{qc_dir}/upload || echo "upload ok" ;\
			~{PYTHON3} ~{BIN}/generate_md_report/file_cp.py -f ~{qc_dir}/upload.map  -i ~{qc_dir} ;\
			cat ~{template_md} >~{qc_dir}/template.md ;\
			cat ~{input_json} >~{qc_dir}/input.json ;\
			[ ! -e ~{table_software} ] || (mkdir -p ~{qc_dir}/upload/tools/ && cat ~{table_software} >~{qc_dir}/upload/tools/table_software.xls );\
			sed -i -e 's/$/  /g' ~{qc_dir}/template.md ;\
			~{PYTHON3} ~{BIN}/others/get_backend.py -i ~{qc_dir} -c ~{report_config} -w "~{workid}" -s ~{BIN}/backend/~{platform}.sh -o ~{qc_dir}/report.sh -t "~{project_name}" -b ~{BIN};\
			sh ~{qc_dir}/report.sh
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
		File? report_url = "report.txt"
	}
}
 

