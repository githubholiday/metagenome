version 1.0
import "struct.wdl" as structs
workflow oss_report{
	input{
		Array[Array[File]] upload_file
		Array[String] upload_place
		String? workid
		String? reportdir
		String? project_name="结题报告"
		String mount
		String report_json
		File config_json 
	}
	ModuleConfig m_config= read_json(config_json)
	Parameter config = m_config.module["report"]
	call wdl_report{
		input:
			upload_file = upload_file,
			upload_place = upload_place,
			workid =workid,
			reportdir = reportdir,
			project_name = project_name,
			mount = mount,
			## 报告配置文件,根据需要调整
			input_json = config.parameter["input_json"],
			template_md = config.parameter["template_md"],
			table_software = config.parameter["table_software"],
			tools_dir = config.parameter["tools_dir"],
			platform = config.parameter["platform"],
			BIN = config.software["BIN"],
			report_config = report_json,

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
		File template_md
		File input_json
		String table_software
		String tools_dir
		String? workid="12345678"
		String? reportdir
		String? project_name="结题报告"
		String report_config=""
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
		if [[ "~{reportdir}" =~ "oss://" ]];then \
			paste -d"\t" ~{write_tsv(upload_file)} ~{write_lines(upload_place)} >upload.map ;\
			~{PYTHON3} ~{BIN}/generate_md_report/file_cp.py -f upload.map ;\
			cp -rf ~{template_md} ./ ;\
			cp -rf ~{input_json} ./ ;\
			ls  *;\
			sed -i -e 's/$/  /g' template.md ;\
			~{BIN}/others/report ~{BIN}/others/ossutil in cp "-rf upload  ~{reportdir}/upload --update" ;\
			~{PYTHON3} ~{BIN}/others/get_backend.py -i ./ -c ~{report_config} -w "~{workid}" -s ~{BIN}/backend/~{platform}.sh -o ./report.sh -t "~{project_name}" -b ~{BIN};\
			sh ./report.sh ;\
		else \
			mkdir -p ~{reportdir} ;\
			paste -d"\t" ~{write_tsv(upload_file)} ~{write_lines(upload_place)} >~{reportdir}/upload.map ;\
			[ -s ~{reportdir}/upload ] && rm -rf ~{reportdir}/upload || echo "upload ok" ;\
			~{PYTHON3} ~{BIN}/generate_md_report/file_cp.py -f ~{reportdir}/upload.map  -i ~{reportdir} ;\
			cat ~{template_md} >~{reportdir}/template.raw.md ;\
			cat ~{input_json} >~{reportdir}/input.json ;\
			~{PYTHON3} ~{BIN}/others/replace_template.py -i ~{reportdir} -j  ~{reportdir}/input.json -t ~{reportdir}/template.raw.md -o ~{reportdir}/template.md; \
			[ ! -e ~{table_software} ] || (mkdir -p ~{reportdir}/upload/tools/ && cat ~{table_software} >~{reportdir}/upload/tools/table_software.xls );\
			[ ! -d ~{tools_dir} ] || (mkdir -p ~{reportdir}/upload/tools/ && cp -rf ~{tools_dir}/* ~{reportdir}/upload/tools );\
			sed -i -e 's/$/  /g' ~{reportdir}/template.md ;\
			~{PYTHON3} ~{BIN}/others/get_backend.py -i ~{reportdir} -c "~{report_config}" -w "~{workid}" -s ~{BIN}/backend/~{platform}.sh -o ~{reportdir}/report.sh -t "~{project_name}" -b ~{BIN};\
			sh ~{reportdir}/report.sh
		fi
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
		File? report_url = "report.txt"
	}
}
 

