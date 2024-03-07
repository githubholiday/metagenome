### 模块： mk_CompareAnalysis

*模块功能：
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage:用于微生物的比较分析，包括anosim adonis MRPP
	 make -f mk_CompareAnalysis qiimeFile= groupFile= cmpFile= type= outdir= config= anosim adonis MRPP
参数说明：
	 config: [文件|可选]  模块配置文件，和软件相关参数，默认为.//config/config.txt 
	 qiimeFile: [文件|必需]  输入文件，物种丰度文件，例如：merge.qiime.xls、otu.xls
	 groupFile: [文件|必需]  cmp.list, 要求有两列，tab分隔，Sample和Group，大小写需要符合 
	 cmpFile: [文件|必需]  输入文件，比较组合文件，如果是两两比较，则用tab分隔两列即可；如果是三组及以上，需要给组名 tab A B C D，用空格分隔多组
	 type: [字符|必需]  与cmpFile配套使用，如果是两两比较，则给2，如果是3个及以上，则给3 
	 outdir: [路径|必需]  分析结果输出路径 
### 输入文件示例
见test/input/
├── cmp.list              Sample和Group对应关系的groupFile文件
├── cmpM.txt              多组比较的cmpFile文件
├── cmp.txt               两两比较的cmpFile文件
└── merge.qiime.xls       物种丰度文件

### 运行环境及软件：
	北京238,R(vegan/getopt/ggplot2/dplyr/ggsci)

### 资源消耗及运行时长
	CompareAnalysis：
	申请CPU：1
	申请内存：3G
	实际内存：2G
	运行时长：0.5 h

### 输出文件示例
.
├── adonis.stat.2.xls
├── adonis.stat.3.xls
├── anosim.B-M.pdf
├── anosim.DT-B.pdf
├── anosim.DT-M.pdf
├── anosim.DT-T.pdf
├── anosim.Group1.pdf
├── anosim.Group2.pdf
├── anosim.Group3.pdf
├── anosim.stat.2.xls
├── anosim.stat.3.xls
├── anosim.T-B.pdf
├── anosim.T-M.pdf
├── mrpp.stat.2.xls
└── mrpp.stat.3.xls

主要结果文件说明：
详见script/readme.doc

### 注意事项
