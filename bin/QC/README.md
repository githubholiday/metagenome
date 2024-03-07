### 模块： mk_QC

*模块功能：
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage:
	 make -f mk_QC infile= n= head= outfile= Pre
	 make -f mk_QC indir= qc_content= sample= outprefix= project= place= email= out_database_dir= email_txt= templete= software= QC
参数说明 Pre 准备QC用的sample文件，仅包含单列样本名：
	 infile:[文件|必需] 包含样本名称的文件
	 n:[字符|必需] sample_list文件中第几列为样本名称
	 head:[字符|可选] sample_list文件中是否有表头，有则写T，无则不填
	 outfile:[文件|必需] 输出文件：sample.list，文件所在路径没有则会创建

参数说明 QC 对结果进行质控：
	 indir: [路径|必需] 输入目录，含有需要进行质控的文件 
	 qc_content：[字符|必需] 质控内容，质控内容以逗号分隔；仅包含质控指标名称的单列文件也可以
	 sample: [文件|必需] 输入文件，仅包含样本名称的单列文件，也可以是逗号分割的样本名 
	 outprefix：[字符|必需]  质控结果输出目录+输出前缀 
	 project: [字符|必需] 项目号 ，作为数据库名称
	 place: [字符|必需] 地点bj|yw ，用于判断是用于202/203的质控，bj=202，yw=203
	 email: [字符|可选] 邮件发送，默认yes。全部：yes/no/B/C。yes:不考虑结果均发邮件；no:不考虑结果均不发邮件；B/C:判断发邮件,含有或低于此等级发邮件,如C:当结果存在C或者D时才发邮件,且标题为相应的等级——合格,让步,不合格,终止；如果结果只包含A,B则不发邮件. 
	 email_txt: [文件|可选] 邮件配置文件，设定发件人,收件人,格式和home目录下的~/.email/.email.txt一致 
	 out_database_dir: [路径|可选] 数据库db文件输出路径 ，默认为outprefix路径
	 templete: [文件|可选] 质控标准文件，含有质控的指标情况 ，默认为script/template.xls
	 software: [文件|可选]  模块配置文件，和软件相关参数，默认为.//software/software.txt

### 输入文件示例
见test/input/
.
├── sample.list       含有样本名字的文件

### 运行环境及软件：
	北京 sge/k8s
	镜像：conda_perl_r:v0.5
	python3 3.3.2
	如果需要在202运行，则选择bj，如果在203运行，则选择yw。software/software.txt是不必修改的。
	config目录下有202和203对应的job_config.ini

### 资源消耗及运行时长
	无

### 输出文件示例
.
├── Metagenome_2023_03_31_10_42_14
│   ├── email_config.ini
│   ├── Metagenome_QC_Result.zip          
│   ├── Metagenome_Result_QUALITY.xls
│   ├── Metagenome_Result_SCORE.xls
│   ├── myemail.py
│   └── send_email.py
├── Metagenome.db
├── Metagenome_Result_DIR.xls
├── Metagenome_Result_QUALITY.xls
├── Metagenome_Result_SCORE.xls
└── sample.list


### 注意事项
	
	质控标准文件：
		
	  1. 第一列为质控指标； 
	  2. 质控指标如果包含空格和'-'会被替换成'_',如果包含'%','()','>','<','='会被删除；
	  3. 质控指标名称需与文件中名称对应，包括大小写及空格，否则会出现错误提示;
	  4. 第二、三、四、五列为A,B,C,D档，分别代表合格,让步,终止,终止;
	  5. 数值中不包含百分号(%)和千分位(,);
	  6. 判断区间使用小括号，判断区间中必须包含上、下限;
	  7. 同一档中包含多个判断区间，判断区间之间使用分号分割;
	  8. 质控内容可以忽略大小写.如某一档内容为YES时,文件内为yes，认为相同;
	  9. 第六列表头必须为'Indir',该列填写质控指标对应的结果文件所在路径,程序将填写路径中的'Indir'关键字替换成-i参数中输入的路径;用于文件捕获；
	  10. 填写'Indir'那一列应注意，表头必须为'Header'如果填写路径包含样本名称目录，样本名称所在目录需用关键字'SAMPLE'代替；
	  11．最后一列为报告内文件样品放置形式，如果文件第一行为样品名则填写R，如果文件第一列为样品名则填写C;

	  email.txt文件的格式：
[DEFAULT]
Max_count = 5
Sleep_time = 60

[HEADER]
Addressor = yangzhang@genome.cn
Password = *****
Receiver = yangzhang@genome.cn;
Copy = chengfangtu@genome.cn;taoliu@genome.cn
Server = smtp.exmail.qq.com
Receive_server = pop.exmail.qq.com


