### 模块： mk_Network

*模块功能：Network图绘制
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage:
	 make -f mk_Network infile= outfile1= outfile2= outdir= software= Network
参数说明：
	 software: [文件|可选]  模块配置文件，和软件相关参数，默认为.//software/software.txt 
	 infile: [文件|必需]  输入文件，物种丰度文件，如merge.qiime.xls，列为样本，行为物种名称，值为丰度
	 threshold: [字符|可选]  筛选阈值，默认0.6
	 outfile1: [文件|必需]  输出文件，Network.edge.csv, 网络图的边结果
	 outfile2: [文件|必需]  输出文件，Network.pdf, 网络图
	 outdir: [路径|必需]   输出路径 

### 输入文件示例
见test/input/
.
└── merge.qiime.xls

### 运行环境及软件：
	北京238 R 4.2.3 (reshape2,igraph)

### 资源消耗及运行时长
	申请CPU：1
	申请内存：1G
	运行时长：1min

### 输出文件示例
.
├── Network.edge.csv
├── Network.pdf
└── Network.png

主要结果文件说明：
（1）Network.edge.csv
Source：物种1
Target：物种2
Weight：物种1和物种2的相关性值。计算方法为pearson，正值代表正相关，负值代表负相关。绝对值越大相关性越强。
（2）Network.pdf/png
圈的大小代表该物种在所有样本中出现的次数多少，圈越大，出现次数越多，圈越小，出现次数越小。
线条的粗细代表两个物种间的相关性大小（绝对值），相关性越大，线条越粗，相关性越小，线条越细。

### 注意事项
