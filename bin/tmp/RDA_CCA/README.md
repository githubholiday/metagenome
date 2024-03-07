### 模块： mk_RDA_CCA

*模块功能：RDA/CCA分析
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage:
	 make -f mk_RDA_CCA infile= cmp= envir= outfile1= outfile2= outfile3= outdir= software= RDA_CCA
参数说明：
	 software: [文件|可选]  模块配置文件，和软件相关参数，默认为.//software/software.txt 
	 infile: [文件|必需]  输入文件，物种丰度文件，如merge.qiime.xls，列为样本，行为物种名称，值为丰度
	 cmp: [文件|必需]  输入文件，如cmp.list，要求只有两列，tab分隔，第一列为Sample，第二列为Group，大小写也需要符合。
	 envir: [文件|必需] 输入文件，如environment.xls , 环境因子测量结果文件，客户提供，列为样本，行为环境因子，值为测量值。环境因子包括ph,N含量,P含量等
	 outfile1: [文件|必需]  输出文件，RDA_CCA.coordinate.pdf, RDA/CCA结果图，根据DCA的结果进行选择，只出一种图，会在图里标明是RDA或者CCA
	 outfile2: [文件|必需]  输出文件，RDA_CCA.coordinate.sample.xls, RDA/CCA结果图中样本的坐标
	 outfile3: [文件|必需]  输出文件，RDA_CCA.coordinate.env.xls, RDA/CCA结果图中环境因子的坐标
	 outdir: [路径|必需]   输出路径

### 输入文件示例
见test/input/
.
├── cmp.list              分组文件
├── environment.xls       环境因子文件
└── merge.qiime.xls       物种丰度文件

### 运行环境及软件：
	北京238 R 4.2.3 (vegan,ggplot2,ggsci,ggrepel)

### 资源消耗及运行时长
	申请CPU：1
	申请内存：1G
	运行时长：5min

### 输出文件示例
.
├── RDA_CCA.coordinate.env.xls       RDA/CCA结果图中环境因子的坐标 
├── RDA_CCA.coordinate.pdf/png       RDA/CCA结果图，根据DCA的结果进行选择，只出一种图，会在图里标明是RDA或者CCA
└── RDA_CCA.coordinate.sample.xls    RDA/CCA结果图中样本的坐标

主要结果文件说明：
（1）RDA_CCA.coordinate.pdf/png
1）环境向量的长度表示样方物种的分布与该环境因子相关性的大小，长度越长，相关性越大；
2）环境向量与约束轴夹角的大小表示环境因子与约束轴相关性的大小，夹角小说明关系密切，若正交则不相关；
3）样本点与箭头距离越近，该环境因子对样本的作用越强；
4）样本位于箭头同方向，表示环境因子与样本物种群落的变化正相关，样本位于箭头的反方向，表示环境因子与样本物种群落的变化负相关。

（2）RDA_CCA.coordinate.env.xls
CCA1/RDA1: 第一轴的坐标
CCA2/RDA2: 第二轴的坐标
factor: 环境因子

（3）RDA_CCA.coordinate.sample.xls 
CCA1/RDA1: 第一轴的坐标
CCA2/RDA2: 第二轴的坐标
Sample: 样本 
Group: 分组

### 注意事项
投递的时候有问题。
