bin=/work/share/acdgo9idhi/liutao/easy_bioinfo/wdl_related/

check:
	echo "/cromwell*" > .gitignore
	echo "/output" > ../.gitignore
	chmod +x ../../../script/common/tools/* ../../../script/*
	chmod +x -R ../../../script/
	cp $(bin)/6_some_tools/target/release/make_finish_tag ../../../script/common/tools/
	miniwdl check ../../../wdl/*wdl
	/public/software/apps/jdk-19.0.2/bin/java -XX:ParallelGCThreads=1 -Xmx5g -Xms1g -jar /work/share/acdgo9idhi/software/cromwell/womtool-85.jar validate ../../../wdl/*.wf.wdl
	#/public/software/apps/jdk-19.0.2/bin/java -XX:ParallelGCThreads=1 -Xmx5g -Xms1g -jar /work/share/acdgo9idhi/software/cromwell/womtool-85.jar inputs ../../../wdl/*.wf.wdl > ../input/input.json
	$(bin)//6_some_tools/target/release/check_path_in_json ../../../config/config.sugon.json

run:
	chmod +x -R ../../../script/
	/public/software/apps/jdk-19.0.2/bin/java -XX:ParallelGCThreads=1 -Xmx5g -Xms1g -jar /work/share/acdgo9idhi/software/cromwell/cromwell-85.jar run ../../../wdl/*.wf.wdl -i ../input/input.json

submit:
	cd ../../../wdl && zip -r tasks.zip tasks
	chmod +x -R ../../../script/
	#chmod 777 -R ../output
	oliver su --dependencies ../../../wdl/tasks.zip -g liutao -j tgs ../../../wdl/*.wf.wdl ../input/input.json
