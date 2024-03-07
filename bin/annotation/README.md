### 模块： mk_annotation

*模块功能：
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

	make -f mk_annotation infile= outdir= sample= config= annotation
	infile:  [文件|必需]  
	outdir:  [路径|必需]  分析结果输出路径 
	sample:  [字符|必需]  样本名称 
	config:  [文件|可选]  配置文件，包括软件及相关参数，默认为$(mkfdir)/config/config.txt

### 输入文件示例
见test/input/
.

### 运行环境及软件：
	北京/义乌 sge/k8s
	? 镜像：conda_perl_r:v0.5
	软件：isoseq3 (3.8.1)
	软件：samtools (1.16.1)

### 资源消耗及运行时长
	输入文件reads数目：35,528,823
	annotation：
	申请CPU：4
	申请内存：3G
	实际内存：2.944GB
	运行时长：3.21 h

### 输出文件示例
.

主要结果文件说明：
*.bcstats.tsv：XXX文件
（1）BarcodeSequence: CBC序列；
（2）NumberOfReads: 该CBC检出的reads数目；

### 注意事项
